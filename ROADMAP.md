# ShopWave — Project Roadmap

## Quick Reference for All 8 Phases

---

### ✅ Phase 1: Foundation & Infrastructure (Week 1)
**Status: READY TO START**

Goal: Runnable Flutter project with complete architecture skeleton.

Deliverables:
- pubspec.yaml with all packages
- analysis_options.yaml (strict linting)
- Clean Architecture folder structure
- Core: config, di, error, router, theme, l10n, utils, widgets
- Material 3 theme (light + dark)
- Localization: Arabic (RTL) + English
- GoRouter with all routes (placeholder screens)
- Riverpod ProviderScope
- Logger setup

---

### Phase 2: Authentication (Week 2)

Goal: Full auth flow with Supabase.

Screens: Splash, Onboarding, Login, Register, Forgot Password, OTP
Features: Email/Password auth, Google OAuth, Session persistence, Auth guard

---

### Phase 3: Home & Product Catalog (Week 3-4)

Goal: Home screen and product browsing.

Screens: Home, Categories, Product List, Search
Features: Banners carousel, Categories grid, Product grid with pagination,
          Search with debounce, Filters drawer, Skeleton loading

---

### Phase 4: Product Detail & Reviews (Week 4-5)

Goal: Full product detail experience.

Screens: Product Detail, Reviews List, Write Review
Features: Image gallery, Variant selection (color/size), Reviews and ratings,
          Related products, Share product

---

### Phase 5: Cart & Favorites (Week 5-6)

Goal: Add to cart and wishlist management.

Screens: Cart, Favorites
Features: Add/remove/update cart items, Real-time cart sync,
          Favorites toggle, Cart badge counter

---

### Phase 6: Checkout & Orders (Week 6-7)

Goal: Complete purchase flow.

Screens: Checkout, Order Confirmed, Orders List, Order Detail
Features: Address selection, Coupon validation, Order placement,
          Order status timeline, Supabase Realtime for status updates

---

### Phase 7: Profile & Settings (Week 7-8)

Goal: User account management.

Screens: Profile, Edit Profile, Addresses, Add/Edit Address,
         Notifications, Settings
Features: Avatar upload, Address CRUD, Notification center,
          Theme toggle, Language toggle

---

### Phase 8: Polish, Testing & Launch (Week 8-9)

Goal: Production-ready release.

Tasks:
- Unit tests for all use cases (mocktail)
- Widget tests for critical screens
- Integration tests for auth and checkout flows
- Performance audit (Flutter DevTools)
- Image optimization
- App icon and splash screen
- Release build (obfuscation, shrinking)
- CI/CD setup (GitHub Actions)

---

## Current Status

```
Phase 1: [x] COMPLETE — Architecture, Theme, DI, Router, Error handling
Phase 2: [x] COMPLETE — Auth flow (Supabase), Notifier, all Auth screens
Phase 3: [x] COMPLETE — Home, Categories, Search, Product Detail, Favorites, Cart, Profile
Phase 4: [x] COMPLETE — Product variants, real cart state, checkout UI
Phase 5: [x] COMPLETE — Orders & Checkout (Supabase) + Hive Cart Persistence
Phase 6: [x] COMPLETE — Favorites & Reviews (Backend-Backed Sync)
Phase 7: [x] COMPLETE — Settings, Notifications, Addresses
Phase 8: [ ] Not Started  — Testing & Production release
```

---

*Update this file as phases complete.*
