import hashlib
import re
from unicodedata import normalize

_STOP_WORDS = {
    'a',
    'an',
    'and',
    'bites',
    'bowl',
    'classic',
    'dish',
    'for',
    'fresh',
    'house',
    'plate',
    'signature',
    'special',
    'style',
    'the',
    'with',
}

_CUISINE_KEYWORDS = {
    'american': ['burger', 'fries'],
    'japanese': ['sushi', 'ramen'],
    'pizza': ['pizza', 'mozzarella'],
    'healthy': ['salad', 'healthy-food'],
    'chinese': ['noodles', 'dumplings'],
    'mexican': ['tacos', 'burrito'],
    'indian': ['curry', 'biryani'],
    'french': ['french-food', 'pastry'],
    'korean': ['korean-food', 'bibimbap'],
    'italian': ['pasta', 'italian-food'],
    'cafe': ['coffee', 'pastry'],
    'desserts': ['dessert', 'cake'],
}


def _tokenize(value: str) -> list[str]:
    normalized = normalize('NFKD', value)
    ascii_text = normalized.encode('ascii', 'ignore').decode('ascii').lower()
    stripped = re.sub(r'[^a-z0-9\s-]', ' ', ascii_text)
    stripped = re.sub(r'[-_]+', ' ', stripped)
    collapsed = re.sub(r'\s+', ' ', stripped).strip()
    if not collapsed:
        return []
    return collapsed.split(' ')


def _dedupe_keep_order(tokens: list[str]) -> list[str]:
    seen: set[str] = set()
    unique: list[str] = []
    for token in tokens:
        if token and token not in seen:
            unique.append(token)
            seen.add(token)
    return unique


def _normalized_keywords(*parts: str) -> list[str]:
    all_tokens: list[str] = []
    for part in parts:
        if not part:
            continue
        all_tokens.extend(_tokenize(part))

    filtered = [token for token in all_tokens if token not in _STOP_WORDS]
    if not filtered:
        filtered = all_tokens

    keywords = _dedupe_keep_order(filtered)
    return keywords[:5] if keywords else ['food']


def _cuisine_tokens(cuisine_type: str) -> list[str]:
    normalized = ' '.join(_tokenize(cuisine_type))
    mapped = _CUISINE_KEYWORDS.get(normalized)
    if mapped:
        return mapped
    return _tokenize(cuisine_type)


def _build_loremflickr_url_from_keywords(
    width: int,
    height: int,
    keywords: list[str],
    *lock_parts: str,
) -> str:
    deduped = _dedupe_keep_order(keywords)
    keyword_path = ','.join((deduped[:4] or ['food']))
    lock = _lock_id(*lock_parts)
    return f'https://loremflickr.com/{width}/{height}/{keyword_path}?lock={lock}'


def _lock_id(*parts: str) -> int:
    payload = '|'.join(parts).encode('utf-8')
    digest = hashlib.sha1(payload).hexdigest()
    return int(digest[:8], 16) % 9000 + 1000


def build_loremflickr_url(width: int, height: int, *parts: str) -> str:
    keywords = _normalized_keywords(*parts)
    return _build_loremflickr_url_from_keywords(width, height, keywords, *parts)


def restaurant_image_url(_name: str, cuisine_type: str) -> str:
    cuisine = _cuisine_tokens(cuisine_type)
    keywords = cuisine + ['restaurant', 'food']
    return _build_loremflickr_url_from_keywords(
        800,
        600,
        keywords,
        cuisine_type,
        'restaurant-category',
    )


def menu_item_image_url(name: str, category: str, cuisine_type: str) -> str:
    item_tokens = [token for token in _tokenize(name) if token not in _STOP_WORDS]
    category_tokens = [
        token for token in _tokenize(category) if token not in _STOP_WORDS
    ]
    cuisine = _cuisine_tokens(cuisine_type)
    keywords = item_tokens[:2] + category_tokens[:1] + cuisine[:1] + ['food']
    return _build_loremflickr_url_from_keywords(
        600,
        400,
        keywords,
        name,
        category,
        cuisine_type,
    )


def is_picsum_url(url: str) -> bool:
    return 'picsum.photos' in (url or '').lower()


def is_generated_image_url(url: str) -> bool:
    normalized = (url or '').lower()
    return 'picsum.photos' in normalized or 'loremflickr.com' in normalized
