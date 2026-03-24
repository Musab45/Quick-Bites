
# Design System Specification: Editorial Utility

## 1. Overview & Creative North Star

### The Creative North Star: "The Digital Maître D’"

This design system rejects the "utility-only" aesthetic of typical delivery apps. Instead, we aim for **Editorial Utility**—a fusion of high-end food magazine layouts and frictionless transactional flows.

To move beyond the "template" look, we utilize **Intentional Asymmetry** and **Tonal Depth**. By breaking the rigid 1:1 grid with overlapping elements (e.g., a food hero image breaking the container boundary) and sophisticated typography scales, we transform a simple delivery app into a curated culinary experience. The goal is to make the user feel like they are browsing a premium menu, not just a database.

---

## 2. Color Architecture

Our palette uses a Material 3-inspired logic but applies it with a "Quiet Luxury" sensibility.

### The Palette

- **Primary (The Authority):** `#004ac6` (Primary) / `#2563eb` (Primary Container). Used for critical actions and brand presence.
- **Secondary (The Zest):** `#9d4300` (Secondary) / `#fd761a` (Secondary Container). Reserved for "appetite" cues: ratings, price highlights, and "Live Order" status.
- **Neutral Surface Tiers:**
- `surface-container-lowest`: `#ffffff` (Card backgrounds)
- `surface`: `#f8f9fb` (Base canvas)
- `surface-container-low`: `#f3f4f6` (Section backgrounds)

### The "No-Line" Rule

**Explicit Instruction:** Prohibit 1px solid borders for sectioning. Boundaries must be defined solely through background color shifts. For example, a restaurant category scroll (surface-container-low) sits on the main feed (surface) without a stroke.

### Signature Textures & Glass

To provide "visual soul," use **Glassmorphism** for floating elements like the "View Cart" bar. Use `surface-container-lowest` at 80% opacity with a `24px` backdrop blur. For Hero CTAs, apply a subtle linear gradient from `primary` to `primary_container` at a 135-degree angle to add depth that flat hex codes cannot achieve.

---

## 3. Typography

We pair the geometric confidence of **Plus Jakarta Sans** (Display/Headlines) with the hyper-legibility of **Inter** (Body).

*Note: While the initial brief suggested Poppins, we have elevated the Headline font to Plus Jakarta Sans for a more modern, editorial weight.*

| Level | Token | Font | Size | Case/Tracking |

| :--- | :--- | :--- | :--- | :--- |

| **Display** | `display-md` | Plus Jakarta Sans | 2.75rem | -2% Tracking |

| **Headline** | `headline-sm` | Plus Jakarta Sans | 1.5rem | Tight (120%) |

| **Title** | `title-md` | Inter (Medium) | 1.125rem | -1% Tracking |

| **Body** | `body-md` | Inter (Regular) | 0.875rem | Normal (150%) |

| **Label** | `label-sm` | Inter (Bold) | 0.6875rem | +5% All Caps |

**The Typography Logic:** Use `display-md` for promotional headlines to create a "magazine cover" feel. `Body-md` is optimized for ingredient lists and descriptions, ensuring high readability on OLED mobile screens.

---

## 4. Elevation & Depth

In this system, depth is a result of **Tonal Layering**, not structural lines.

- **The Layering Principle:** Stack `surface-container-lowest` (#ffffff) cards on top of `surface-container-low` (#f3f4f6) backgrounds. This creates a soft, natural lift.
- **Ambient Shadows:** For floating action buttons or high-priority cards, use a shadow with a `20px` to `40px` blur at 6% opacity. The shadow color must be a tint of `on-surface` (`#191c1e`), never pure black.
- **The "Ghost Border" Fallback:** If a border is required for accessibility, use the `outline_variant` token at **15% opacity**. High-contrast borders are strictly forbidden as they clutter the editorial whitespace.

---

## 5. Components

### Buttons

- **Primary:** `primary` fill with `on-primary` text. Border radius: `8px`. Use `1.25rem` (Space 5) horizontal padding.
- **Secondary:** `surface-container-high` fill with `primary` text. No border.
- **Tertiary:** Text-only, using `primary` color and `label-md` bold styling.

### Cards (The "Menu Item")

- **Style:** `surface-container-lowest` background, `12px` radius.
- **Rule:** Forbid divider lines. Separate "Price," "Time," and "Rating" using horizontal spacing (`space-4`) or subtle `label-sm` typographic shifts.

### Category Chips

- **Style:** `20px` fully rounded. Unselected: `surface-container-high`. Selected: `primary` fill with `on-primary` text.

### Inputs

- **Style:** `surface-container-low` fill with a bottom-only "Ghost Border" that transforms into a `2px` `primary` line on focus. This maintains the clean, "paper-like" feel of the app.

### Floating Cart (Signature Component)

- **Style:** Glassmorphic container with a `16px` radius. Placed `space-4` from the bottom of the screen. This ensures the component feels like it's part of the environment, not a static footer.

---

## 6. Do’s and Don’ts

### Do

- **Use "White Space as a Tool":** Use `space-8` (2rem) between major sections to let the food photography breathe.
- **Layer Your Surfaces:** Place white cards on grey backgrounds to denote importance.
- **Asymmetric Imagery:** Allow food photography to "bleed" off the edge of the card or container occasionally to create a premium, un-boxed feel.

### Don't

- **Don't use 1px Borders:** Never use a solid line to separate two items in a list. Use vertical padding (`space-3`) instead.
- **Don't Over-Saturate:** Avoid using the `secondary` (Orange) for large backgrounds; it is a "flavor" color meant for accents and status.
- **Don't Use Default Shadows:** Never use the standard CSS `0 2px 4px rgba(0,0,0,0.5)`. It is too heavy for this sophisticated aesthetic. Use the Ambient Shadow rules in Section 4.
