# QuickBite Implementation Plan (Milestone-Based)

## Scope Decisions (Locked)
- **Repository layout:** Monorepo with `mobile/` (Flutter) and `backend/` (FastAPI)
- **Auth scope:** Include login/register UI screens in MVP
- **Menu API contract:** Use `GET /menu/{restaurantId}` as canonical endpoint

## Working Principles
- Build backend contract first, then frontend integration.
- Ship vertical slices that are testable end-to-end.
- Keep UI consistent with documented palette, spacing, and typography rules.
- Every milestone ends with explicit acceptance checks.

---

## Milestone 1 — Monorepo Bootstrap & Foundations
**Goal:** Establish a clean, runnable project skeleton for both apps.

### Tasks
- Create root structure:
  - `mobile/`
  - `backend/`
  - root docs/config: `README.md`, `.gitignore`, `.env.example`
- Initialize Flutter project under `mobile/`
- Initialize FastAPI project under `backend/`
- Add baseline dependency manifests and startup scripts
- Define environment variable strategy for local development

### Deliverables
- Both `mobile` and `backend` run independently.
- Root README explains setup at a high level.

### Acceptance Criteria
- `flutter doctor` passes on local setup
- Flutter app launches to placeholder app shell
- FastAPI server starts and serves health response

---

## Milestone 2 — Backend Domain, Auth, and API Contract
**Goal:** Provide stable, seeded API for the full app flow.

### Tasks
- Implement database/session setup (`database.py`)
- Add SQLAlchemy models:
  - `Restaurant`, `MenuItem`, `User`, `Order`, `OrderItem`
- Add Pydantic schemas for request/response validation
- Implement auth:
  - `POST /auth/register`
  - `POST /auth/login` (JWT)
- Implement resource endpoints:
  - `GET /restaurants`
  - `GET /restaurants/{id}`
  - `GET /menu/{restaurantId}`
  - `POST /orders` (auth required)
  - `GET /orders` (auth required)
  - `GET /orders/{id}` (auth required)
- Add seed script for restaurants, menu, and demo user

### Deliverables
- Full API contract with auth + seed data available locally.

### Acceptance Criteria
- All endpoints respond with valid schemas
- Protected routes reject missing/invalid JWT
- Seed script populates test dataset reliably

---

## Milestone 3 — Flutter App Shell, Theme, Routing, Core Components
**Goal:** Build reusable app foundation before feature screens.

### Tasks
- Create Flutter structure:
  - `lib/core` (constants/theme/utils)
  - `lib/data` (models/repositories/services)
  - `lib/providers`
  - `lib/features`
- Configure packages:
  - `flutter_riverpod`, `go_router`, `dio`, `isar`, `cached_network_image`, `shimmer`, `freezed`, `json_serializable`, `flutter_svg`
- Setup `go_router` routes and app-level navigation
- Setup Riverpod provider architecture and base notifiers
- Build shared components:
  - loading skeletons
  - app bars
  - card shells
  - button variants

### Deliverables
- Navigable app shell with theme and reusable UI primitives.

### Acceptance Criteria
- Route map works without crashes
- Shared components render consistently across screens
- Static mock data can be displayed through providers

---

## Milestone 4 — Browse Flow (Home, Restaurant Detail, Menu)
**Goal:** Deliver the discovery/browsing experience backed by real API.

### Tasks
- Implement Splash and Onboarding screens
- Implement Home Feed screen:
  - city selector, cart badge, search bar
  - category chips, promo banner
  - restaurant list/cards with shimmer loading
- Implement Restaurant Detail screen
- Implement Menu screen with categories and add-to-cart actions
- Wire Dio services + repositories + providers to backend endpoints

### Deliverables
- User can browse restaurants and menu items from live backend data.

### Acceptance Criteria
- Home loads live restaurants from API
- Restaurant detail and menu navigate/load correctly
- Loading/error/empty states implemented

---

## Milestone 5 — Cart, Checkout, Orders, and Tracking
**Goal:** Complete the transactional flow end-to-end.

### Tasks
- Implement Cart screen with quantity controls and totals
- Persist cart locally with Isar
- Implement Checkout screen (address, payment method, summary)
- Implement order creation against `POST /orders`
- Implement Order Confirmation screen (animation + order details)
- Implement Order Tracking screen (status stepper + placeholders)

### Deliverables
- Full order placement flow with backend persistence.

### Acceptance Criteria
- Add/remove/update cart updates totals correctly
- Checkout submits valid payload and returns order
- Tracking screen reflects backend status

---

## Milestone 6 — Auth UI and Protected Flows
**Goal:** Integrate user authentication into real app usage.

### Tasks
- Add Login and Register screens
- Store JWT securely for session usage
- Add route guards for protected routes (checkout/orders/profile)
- Handle auth errors and token expiry gracefully

### Deliverables
- Users can register/login and access protected order features.

### Acceptance Criteria
- Auth flow works from clean install
- Protected pages redirect unauthenticated users
- Orders endpoints function only with valid session

---

## Milestone 7 — Profile, History, and UX Polish
**Goal:** Make the app portfolio-ready and coherent.

### Tasks
- Implement Profile screen with user info and settings rows
- Implement order history list via `GET /orders`
- Add UI polish pass for spacing, typography, consistency
- Validate responsiveness and visual quality on multiple device sizes

### Deliverables
- Complete polished product experience aligned with spec.

### Acceptance Criteria
- Profile and history data load correctly
- UI passes consistency review against design guidelines
- No major visual regressions across key screens

---

## Milestone 8 — QA, Packaging, and Portfolio Assets
**Goal:** Final verification and showcase-ready repository.

### Tasks
- Run static analysis/linting on Flutter and backend
- Add/update tests for key providers and API routes
- Prepare README with full setup/run instructions
- Capture portfolio screenshots and 30–60s demo flow
- Verify secrets/config hygiene (`.env`, no committed secrets)

### Deliverables
- Shareable, runnable, professional portfolio project.

### Acceptance Criteria
- Fresh clone setup succeeds
- Core happy-path flow works end-to-end
- README + assets are ready for Fiverr/GitHub showcase

---

## Execution Checklist (Track Progress)
- [x] M1: Monorepo Bootstrap & Foundations
- [x] M2: Backend Domain, Auth, and API Contract
- [x] M3: Flutter App Shell, Theme, Routing, Core Components
- [x] M4: Browse Flow (Home, Restaurant Detail, Menu)
- [x] M5: Cart, Checkout, Orders, and Tracking
- [x] M6: Auth UI and Protected Flows
- [x] M7: Profile, History, and UX Polish
- [x] M8: QA, Packaging, and Portfolio Assets

## Notes
- If API shape changes during implementation, update this plan and version the contract in README.
- Keep implementation incremental: complete one milestone with acceptance checks before moving on.
