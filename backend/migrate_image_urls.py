import argparse

from database import SessionLocal, init_db
from image_urls import is_generated_image_url, menu_item_image_url, restaurant_image_url
from models import MenuItem, Restaurant


def _should_update(url: str) -> bool:
    return not (url or '').strip() or is_generated_image_url(url)


def migrate_image_urls(commit: bool) -> None:
    init_db()
    db = SessionLocal()

    restaurants_checked = 0
    restaurants_updated = 0
    menu_items_checked = 0
    menu_items_updated = 0
    preview_lines: list[str] = []

    try:
        restaurants = db.query(Restaurant).all()
        restaurant_by_id = {restaurant.id: restaurant for restaurant in restaurants}

        for restaurant in restaurants:
            restaurants_checked += 1
            if not _should_update(restaurant.image_url):
                continue

            target_url = restaurant_image_url(restaurant.name, restaurant.cuisine_type)
            if restaurant.image_url == target_url:
                continue

            preview_lines.append(
                f"Restaurant {restaurant.id} '{restaurant.name}': {restaurant.image_url} -> {target_url}"
            )
            restaurant.image_url = target_url
            restaurants_updated += 1

        menu_items = db.query(MenuItem).all()
        for item in menu_items:
            menu_items_checked += 1
            if not _should_update(item.image_url):
                continue

            cuisine_type = ''
            restaurant = restaurant_by_id.get(item.restaurant_id)
            if restaurant is not None:
                cuisine_type = restaurant.cuisine_type

            target_url = menu_item_image_url(item.name, item.category, cuisine_type)
            if item.image_url == target_url:
                continue

            preview_lines.append(
                f"MenuItem {item.id} '{item.name}': {item.image_url} -> {target_url}"
            )
            item.image_url = target_url
            menu_items_updated += 1

        if commit:
            db.commit()
            print('Migration committed successfully.')
        else:
            db.rollback()
            print('Dry-run complete. No database changes were committed.')

        print(
            f"Restaurants checked: {restaurants_checked}, updated: {restaurants_updated}"
        )
        print(
            f"Menu items checked: {menu_items_checked}, updated: {menu_items_updated}"
        )

        if preview_lines:
            print('Sample changes:')
            for line in preview_lines[:20]:
                print(f'  - {line}')
            if len(preview_lines) > 20:
                print(f"  ... and {len(preview_lines) - 20} more")
        else:
            print('No rows required image URL updates.')
    finally:
        db.close()


def _build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Migrate restaurant/menu image URLs from Picsum to keyword-based LoremFlickr URLs.'
    )
    parser.add_argument(
        '--commit',
        action='store_true',
        help='Persist changes to the database. If omitted, runs in dry-run mode.',
    )
    return parser


if __name__ == '__main__':
    args = _build_arg_parser().parse_args()
    migrate_image_urls(commit=args.commit)
