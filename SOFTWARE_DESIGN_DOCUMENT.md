# 🏗️ Software Design Document
## Professional Flutter E-Commerce Application — ShopWave
### Version 1.0 — Authored by: Tech Lead / Senior Flutter Architect

---

> **Document Purpose**: This document is the single source of truth for the entire project.
> Every architectural decision, every technology choice, every naming convention,
> every database table — all defined here. No assumption is left undocumented.
>
> **Status**: ✅ Awaiting Phase 1 Execution Approval

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack Decisions](#2-technology-stack-decisions)
3. [Architecture Decision](#3-architecture-decision)
4. [Folder Structure](#4-folder-structure)
5. [Database Design](#5-database-design)
6. [State Management Strategy](#6-state-management-strategy)
7. [API Layer Design](#7-api-layer-design)
8. [Routing Strategy](#8-routing-strategy)
9. [Theme System](#9-theme-system)
10. [Screens Inventory](#10-screens-inventory)
11. [UX and Navigation Flow](#11-ux-and-navigation-flow)
12. [Error Handling Strategy](#12-error-handling-strategy)
13. [Security Best Practices](#13-security-best-practices)
14. [Naming Conventions](#14-naming-conventions)
15. [Project Roadmap — 8 Milestones](#15-project-roadmap--8-milestones)
16. [Phase 1 — Detailed Plan](#16-phase-1--project-foundation--infrastructure)

---

## 1. Project Overview

### 1.1 Application Name
**ShopWave** — A full-featured, bilingual (AR/EN), production-ready e-commerce mobile application.

### 1.2 Business Goals

| Goal | Description |
|------|-------------|
| Complete Shopping Experience | Browse → Search → Cart → Checkout → Track |
| Bilingual | Arabic (RTL) and English (LTR) with seamless switching |
| Premium UX | Material 3, Dark/Light theme, skeleton loading, micro-animations |
| Cross-Platform | Android and iOS from a single codebase |
| Secure | JWT auth, RLS policies, input validation |
| Scalable | Clean Architecture ensures the app can grow without rewrites |

### 1.3 Key Features
- User authentication (email/password, Google OAuth)
- Product catalog with variants (size, color, etc.)
- Categories and brands with hierarchy support
- Advanced search with filters
- Favorites / Wishlist
- Shopping cart with real-time sync
- Checkout with address management
- Coupon/discount system
- Order tracking with status timeline
- Push notifications
- Product reviews and ratings
- Offline caching for browsed products

---

## 2. Technology Stack Decisions

### 2.1 Core Framework

| Technology | Decision | Reason |
|------------|---------|--------|
| Flutter (Latest Stable 3.x) | Primary framework | Cross-platform, single codebase, excellent performance |
| Dart | Language | Flutter-native, sound null safety |
| Supabase | Backend-as-a-Service | Real PostgreSQL + RLS + Auth + Storage + Realtime |
| PostgreSQL 15+ | Primary database | Relational power for e-commerce complex queries |

**Why Supabase over Firebase?**

Supabase gives us a real PostgreSQL database with full SQL power, Row Level Security (RLS),
real-time subscriptions, Edge Functions, and open-source self-hosting capability.
Firebase's Firestore is NoSQL — it makes complex e-commerce queries (filters, joins, aggregations)
unnecessarily complicated and expensive. For an e-commerce app with complex relational data,
PostgreSQL + Supabase is the professional choice.

---

### 2.2 State Management: Riverpod (Chosen over Bloc and Provider)

| Criterion | Provider | Bloc | Riverpod |
|-----------|----------|------|----------|
| Boilerplate | Medium | High | Low |
| Testability | Good | Excellent | Excellent |
| Code Generation | No | No | Yes (riverpod_generator) |
| Auto-dispose | Manual | Manual | Built-in |
| Async Support | Limited | Good | Excellent (AsyncValue) |
| Type Safety | Good | Good | Excellent |
| Learning Curve | Easy | Hard | Medium |

**Decision**: We use Riverpod 2.x with riverpod_generator and riverpod_annotation.
The code-generation approach (@riverpod) eliminates boilerplate, gives compile-time safety,
and auto-dispose providers that do not leak memory. AsyncValue handles loading/error/data states
elegantly without boilerplate switch statements.

**Why not Bloc?** Bloc adds significant boilerplate (Event, State, Bloc classes per feature).
For a project that aims for production quality, Riverpod gives 90% of Bloc's power with 40% of the code.

---

### 2.3 Architecture: Feature-First Clean Architecture

**Why Feature-First over Layer-First?**

Feature-First (our choice):
```
lib/
  features/
    auth/
      data/         <- auth data layer
      domain/       <- auth domain layer
      presentation/ <- auth UI layer
    products/
      data/
      domain/
      presentation/
```

Feature-First is superior for teams and large projects because:
- Each feature is a self-contained module — you can add/remove a feature without touching others
- Feature ownership is clear — a developer owns a feature folder entirely
- Onboarding is easier — new devs understand one feature at a time
- Scaling is natural — each feature can grow independently
- Testing is isolated — mock only what the feature needs

---

### 2.4 All Packages (with Justification)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.0.0            # Declarative routing, deep links, shell routes

  # Backend
  supabase_flutter: ^2.0.0     # Supabase SDK (auth, db, storage, realtime)
  dio: ^5.0.0                   # HTTP client for custom API calls

  # Code Generation / Serialization
  freezed_annotation: ^2.0.0   # Immutable data classes, union types
  json_annotation: ^4.0.0      # JSON serialization annotations

  # Local Storage
  hive_flutter: ^1.1.0         # Fast local NoSQL storage for caching
  shared_preferences: ^2.0.0   # Simple key-value (theme, locale, onboarding flag)

  # UI and UX
  flutter_hooks: ^0.20.0       # useState, useEffect for stateful widget simplification
  hooks_riverpod: ^2.0.0       # Hooks + Riverpod combined ConsumerWidget
  cached_network_image: ^3.0.0 # Image caching with placeholder
  shimmer: ^3.0.0              # Skeleton loading effect
  lottie: ^3.0.0               # JSON animations (empty states, success)
  flutter_svg: ^2.0.0          # SVG assets
  smooth_page_indicator: ^1.0.0
  flutter_rating_bar: ^4.0.0
  another_flushbar: ^1.0.0

  # Forms and Validation
  reactive_forms: ^17.0.0      # Reactive form validation (Angular-inspired)

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Utilities
  dartz: ^0.10.0               # Functional programming: Either<Failure, Success>
  equatable: ^2.0.0            # Value equality without boilerplate
  logger: ^2.0.0               # Structured logging
  connectivity_plus: ^6.0.0   # Network status detection
  image_picker: ^1.0.0
  url_launcher: ^6.0.0
  share_plus: ^9.0.0
  package_info_plus: ^8.0.0

dev_dependencies:
  build_runner: ^2.0.0
  freezed: ^2.0.0
  json_serializable: ^6.0.0
  riverpod_generator: ^2.0.0
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  riverpod_test: ^2.0.0
```

---

## 3. Architecture Decision

### 3.1 Clean Architecture Layers

```
+--------------------------------------------------+
|               PRESENTATION LAYER                 |
|  Screens, Widgets, ViewModels (Notifiers), State |
|  Knows: Domain layer only                        |
+--------------------------------------------------+
|                 DOMAIN LAYER                     |
|  Entities, Use Cases, Repository Interfaces      |
|  Knows: Nothing (pure Dart, zero dependencies)   |
+--------------------------------------------------+
|                  DATA LAYER                      |
|  Repository Impls, Data Sources, Models, Mappers |
|  Knows: Domain layer (implements interfaces)     |
+--------------------------------------------------+
```

### 3.2 Dependency Rule (CRITICAL)

The Dependency Rule: Source code dependencies can only point inward.
- Presentation depends on Domain
- Data depends on Domain
- Domain depends on NOTHING

This means domain entities are pure Dart classes. If Supabase changes tomorrow,
we only rewrite the Data layer. Presentation does not know Supabase exists.

### 3.3 Data Flow

```
User Action
    |
Screen (Presentation)
    |
ViewModel / Notifier (calls use case)
    |
Use Case (Domain — orchestrates business logic)
    |
Repository Interface (Domain — contract)
    |
Repository Implementation (Data — fulfills contract)
    |
Remote Data Source --> Supabase / API
    |                        |
Local Data Source  -->  Hive Cache
    |
DTO --> Entity Mapper
    |
Entity (Domain)
    |
AsyncValue<Entity> in Notifier
    |
UI rebuilds
```

---

## 4. Folder Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── supabase_config.dart
│   │   └── app_constants.dart
│   ├── di/
│   │   └── providers.dart
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── network_info.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── logging_interceptor.dart
│   │       └── retry_interceptor.dart
│   ├── storage/
│   │   ├── hive_storage.dart
│   │   └── preferences_storage.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── app_routes.dart
│   │   └── guards/
│   │       └── auth_guard.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── app_borders.dart
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_ar.arb
│   ├── extensions/
│   │   ├── context_ext.dart
│   │   ├── string_ext.dart
│   │   ├── num_ext.dart
│   │   └── datetime_ext.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── debouncer.dart
│   │   ├── logger.dart
│   │   └── price_formatter.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_loading.dart
│       ├── app_error_widget.dart
│       ├── app_empty_state.dart
│       ├── skeleton_loader.dart
│       ├── product_card.dart
│       ├── rating_bar.dart
│       ├── app_image.dart
│       ├── app_chip.dart
│       └── paginated_list.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── onboarding_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   ├── forgot_password_screen.dart
│   │       │   └── otp_screen.dart
│   │       └── widgets/
│   │           ├── auth_form_field.dart
│   │           └── social_login_button.dart
│   │
│   ├── home/
│   ├── products/
│   ├── categories/
│   ├── cart/
│   ├── checkout/
│   ├── orders/
│   ├── favorites/
│   ├── profile/
│   ├── addresses/
│   ├── notifications/
│   ├── reviews/
│   ├── coupons/
│   └── settings/
│
├── app.dart
└── main.dart
```

---

## 5. Database Design

### 5.1 Design Principles

- UUIDs as primary keys (not serial integers) for security
- RLS (Row Level Security) on all user-data tables
- Soft deletes (deleted_at TIMESTAMP) on critical tables
- Indexes on all foreign keys and frequently filtered columns
- Timestamps (created_at, updated_at) on every table
- Triggers to auto-update updated_at using a reusable function

---

### 5.2 Schema — All Tables

#### profiles (extends Supabase auth.users)
```sql
CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT,
  avatar_url    TEXT,
  phone         TEXT UNIQUE,
  date_of_birth DATE,
  gender        TEXT CHECK (gender IN ('male', 'female', 'other')),
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: Users can only read/update their own profile
```

#### categories
```sql
CREATE TABLE categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en     TEXT NOT NULL,
  name_ar     TEXT NOT NULL,
  slug        TEXT UNIQUE NOT NULL,
  image_url   TEXT,
  parent_id   UUID REFERENCES categories(id) ON DELETE SET NULL,
  sort_order  INT DEFAULT 0,
  is_active   BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_slug ON categories(slug);
-- parent_id enables infinite category nesting (Electronics > Phones > Android)
```

#### brands
```sql
CREATE TABLE brands (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  slug        TEXT UNIQUE NOT NULL,
  logo_url    TEXT,
  is_active   BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
```

#### products
```sql
CREATE TABLE products (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en          TEXT NOT NULL,
  name_ar          TEXT NOT NULL,
  description_en   TEXT,
  description_ar   TEXT,
  slug             TEXT UNIQUE NOT NULL,
  category_id      UUID REFERENCES categories(id) ON DELETE SET NULL,
  brand_id         UUID REFERENCES brands(id) ON DELETE SET NULL,
  base_price       NUMERIC(10,2) NOT NULL,
  discount_percent NUMERIC(5,2) DEFAULT 0,
  sku              TEXT UNIQUE,
  is_active        BOOLEAN DEFAULT TRUE,
  is_featured      BOOLEAN DEFAULT FALSE,
  is_new_arrival   BOOLEAN DEFAULT FALSE,
  is_on_sale       BOOLEAN DEFAULT FALSE,
  avg_rating       NUMERIC(3,2) DEFAULT 0,   -- denormalized for performance
  review_count     INT DEFAULT 0,            -- denormalized for performance
  sold_count       INT DEFAULT 0,
  deleted_at       TIMESTAMPTZ,              -- soft delete
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_products_category  ON products(category_id);
CREATE INDEX idx_products_brand     ON products(brand_id);
CREATE INDEX idx_products_featured  ON products(is_featured) WHERE is_active = TRUE;
CREATE INDEX idx_products_sale      ON products(is_on_sale)  WHERE is_active = TRUE;
CREATE INDEX idx_products_deleted   ON products(deleted_at)  WHERE deleted_at IS NULL;
-- Full-text search index
CREATE INDEX idx_products_fts ON products
  USING gin(to_tsvector('english', name_en || ' ' || COALESCE(description_en,'')));
```

#### product_images
```sql
CREATE TABLE product_images (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  alt_text    TEXT,
  sort_order  INT DEFAULT 0,
  is_primary  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_product_images_product ON product_images(product_id);
```

#### product_attributes (e.g. "Color", "Size", "Material")
```sql
CREATE TABLE product_attributes (
  id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en TEXT NOT NULL,
  name_ar TEXT NOT NULL
);
```

#### product_attribute_values (e.g. "Red", "XL", "128GB")
```sql
CREATE TABLE product_attribute_values (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attribute_id UUID NOT NULL REFERENCES product_attributes(id) ON DELETE CASCADE,
  value_en     TEXT NOT NULL,
  value_ar     TEXT NOT NULL,
  hex_color    TEXT
);
```

#### product_variants
```sql
CREATE TABLE product_variants (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id   UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  sku          TEXT UNIQUE,
  price        NUMERIC(10,2) NOT NULL,
  stock        INT NOT NULL DEFAULT 0,
  is_default   BOOLEAN DEFAULT FALSE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_variants_product ON product_variants(product_id);
```

#### variant_attribute_values (join table: which values compose a variant)
```sql
CREATE TABLE variant_attribute_values (
  variant_id  UUID REFERENCES product_variants(id) ON DELETE CASCADE,
  value_id    UUID REFERENCES product_attribute_values(id) ON DELETE CASCADE,
  PRIMARY KEY (variant_id, value_id)
  -- A variant "Red + XL" has 2 rows here
);
```

#### addresses
```sql
CREATE TABLE addresses (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  label         TEXT,
  full_name     TEXT NOT NULL,
  phone         TEXT NOT NULL,
  country       TEXT NOT NULL DEFAULT 'SA',
  city          TEXT NOT NULL,
  district      TEXT,
  street        TEXT NOT NULL,
  building      TEXT,
  postal_code   TEXT,
  is_default    BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_addresses_user ON addresses(user_id);
```

#### coupons
```sql
CREATE TABLE coupons (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code             TEXT UNIQUE NOT NULL,
  discount_type    TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value   NUMERIC(10,2) NOT NULL,
  min_order_amount NUMERIC(10,2) DEFAULT 0,
  max_uses         INT,
  used_count       INT DEFAULT 0,
  is_active        BOOLEAN DEFAULT TRUE,
  expires_at       TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);
```

#### carts (one cart per user)
```sql
CREATE TABLE carts (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### cart_items
```sql
CREATE TABLE cart_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id      UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  variant_id   UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  quantity     INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  added_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (cart_id, variant_id)
);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
```

#### orders
```sql
CREATE TABLE orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES profiles(id),
  order_number      TEXT UNIQUE NOT NULL,
  status            TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','confirmed','processing',
                                      'shipped','delivered','cancelled','refunded')),
  payment_status    TEXT NOT NULL DEFAULT 'unpaid'
                    CHECK (payment_status IN ('unpaid','paid','refunded','failed')),
  payment_method    TEXT,
  subtotal          NUMERIC(10,2) NOT NULL,
  shipping_fee      NUMERIC(10,2) NOT NULL DEFAULT 0,
  discount_amount   NUMERIC(10,2) DEFAULT 0,
  total             NUMERIC(10,2) NOT NULL,
  coupon_id         UUID REFERENCES coupons(id),
  address_snapshot  JSONB NOT NULL,  -- snapshot of address at order time (immutable)
  notes             TEXT,
  deleted_at        TIMESTAMPTZ,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_orders_user   ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_number ON orders(order_number);
```

#### order_items
```sql
CREATE TABLE order_items (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  variant_id       UUID REFERENCES product_variants(id) ON DELETE SET NULL,
  product_snapshot JSONB NOT NULL,  -- snapshot of product at purchase time (immutable)
  quantity         INT NOT NULL,
  unit_price       NUMERIC(10,2) NOT NULL,
  total_price      NUMERIC(10,2) NOT NULL
);
CREATE INDEX idx_order_items_order ON order_items(order_id);
```

#### order_status_history
```sql
CREATE TABLE order_status_history (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id   UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status     TEXT NOT NULL,
  note       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_status_history_order ON order_status_history(order_id);
```

#### favorites
```sql
CREATE TABLE favorites (
  user_id    UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, product_id)
);
CREATE INDEX idx_favorites_user ON favorites(user_id);
```

#### reviews
```sql
CREATE TABLE reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  order_id    UUID REFERENCES orders(id),
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title       TEXT,
  body        TEXT,
  is_approved BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_user    ON reviews(user_id);
```

#### review_images
```sql
CREATE TABLE review_images (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  url       TEXT NOT NULL
);
```

#### notifications
```sql
CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type       TEXT NOT NULL,
  title_en   TEXT NOT NULL,
  title_ar   TEXT NOT NULL,
  body_en    TEXT,
  body_ar    TEXT,
  data       JSONB,
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_notifications_user   ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
```

#### banners (home screen promotions)
```sql
CREATE TABLE banners (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title_en     TEXT,
  title_ar     TEXT,
  image_url    TEXT NOT NULL,
  action_type  TEXT,
  action_value TEXT,
  sort_order   INT DEFAULT 0,
  is_active    BOOLEAN DEFAULT TRUE,
  starts_at    TIMESTAMPTZ,
  ends_at      TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
```

#### app_settings
```sql
CREATE TABLE app_settings (
  key        TEXT PRIMARY KEY,
  value      JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### 5.3 Key Design Decisions Explained

| Decision | Reason |
|----------|--------|
| address_snapshot JSONB in orders | Address may change after order. We capture it at order time |
| product_snapshot JSONB in order_items | Product price/name can change. Purchase record must be immutable |
| avg_rating denormalized on products | Avoids expensive aggregate query on every product list load |
| UUIDs everywhere | Security (no enumerable IDs), works in distributed systems |
| Soft delete on products/orders | Business requires audit trail; data is never truly lost |
| parent_id on categories | Self-referential for unlimited nesting depth |
| UNIQUE (user_id, product_id) on favorites | DB-level guarantee: no duplicate favorites |
| UNIQUE (cart_id, variant_id) on cart_items | Prevent duplicate cart entries at DB level |

---

## 6. State Management Strategy

### 6.1 Provider Types We Will Use

| Provider Type | When to Use | Example |
|---------------|-------------|---------|
| @riverpod (functional) | Simple read-only or async data | getProductsProvider |
| @Riverpod class (Notifier) | Mutable state with business logic | CartNotifier |
| @Riverpod class (AsyncNotifier) | Async mutable state | AuthNotifier |
| StreamProvider | Real-time data (Supabase subscriptions) | notificationsProvider |
| FutureProvider | One-time async fetch | appSettingsProvider |
| StateProvider | Simple primitive state | selectedTabProvider |

### 6.2 AsyncValue Pattern (no more if/else)
```dart
// In widget build()
ref.watch(productsProvider).when(
  data: (products) => ProductGrid(products: products),
  loading: () => const SkeletonLoader(),
  error: (e, st) => AppErrorWidget(
    onRetry: () => ref.invalidate(productsProvider),
  ),
);
```

### 6.3 Pagination Strategy
We use cursor-based pagination with Supabase's .range():
```dart
// ProductsNotifier extends AsyncNotifier
Future<void> loadMore() async {
  final current = state.value ?? [];
  final next = await repo.getProducts(offset: current.length, limit: 20);
  state = AsyncData([...current, ...next]);
}
```

---

## 7. API Layer Design

### 7.1 Dio Configuration
```
DioClient
  ├── BaseOptions (baseUrl, timeout, headers)
  ├── AuthInterceptor     -> attaches Bearer token from Supabase session
  ├── LoggingInterceptor  -> logs requests/responses in debug mode
  └── RetryInterceptor    -> retries failed requests up to 3 times
```

### 7.2 Repository Pattern Implementation
```
Abstract Interface (Domain)      Implementation (Data)
----------------------------------------------------------
ProductRepository  ----------->  ProductRepositoryImpl
  getProducts()                    calls RemoteDataSource
  getProductById()                 or LocalDataSource (cache)
  searchProducts()                 maps DTO to Entity
```

---

## 8. Routing Strategy

### 8.1 GoRouter Structure
```dart
GoRouter(
  redirect: authGuard,           // Global redirect for unauthenticated users
  routes: [
    ShellRoute(                   // Bottom navigation shell
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', ...),
        GoRoute(path: '/categories', ...),
        GoRoute(path: '/cart', ...),
        GoRoute(path: '/favorites', ...),
        GoRoute(path: '/profile', ...),
      ],
    ),
    GoRoute(path: '/splash', ...),
    GoRoute(path: '/onboarding', ...),
    GoRoute(path: '/login', ...),
    GoRoute(path: '/product/:id', ...),
    GoRoute(path: '/checkout', ...),
    GoRoute(path: '/orders/:id', ...),
  ],
)
```

### 8.2 Route Constants (type-safe)
```dart
abstract class AppRoutes {
  static const splash        = '/splash';
  static const onboarding    = '/onboarding';
  static const login         = '/login';
  static const home          = '/home';
  static const categories    = '/categories';
  static const productDetail = '/product/:id';
  static const cart          = '/cart';
  static const favorites     = '/favorites';
  static const checkout      = '/checkout';
  static const orders        = '/orders';
  static const profile       = '/profile';
}
```

---

## 9. Theme System

### 9.1 Color Palette

| Token | Light | Dark |
|-------|-------|------|
| primary | #6C63FF (Vibrant Indigo) | #8B85FF |
| secondary | #FF6584 (Coral Pink) | #FF8FA3 |
| surface | #FFFFFF | #1A1A2E |
| background | #F5F5FA | #0F0F1A |
| error | #D32F2F | #EF5350 |
| success | #388E3C | #66BB6A |

### 9.2 Typography Scale
Font: **Outfit** from Google Fonts (premium, modern, clean).
Sizes: 10, 12, 14, 16, 18, 20, 24, 28, 32
Weights: Regular(400), Medium(500), SemiBold(600), Bold(700)

### 9.3 Spacing Tokens (4pt grid system)
```dart
abstract class AppSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}
```

---

## 10. Screens Inventory

### Tier 1: MVP (Must Have)
| # | Screen | Feature | Priority |
|---|--------|---------|---------|
| 1 | Splash | auth | P0 |
| 2 | Onboarding | auth | P0 |
| 3 | Login | auth | P0 |
| 4 | Register | auth | P0 |
| 5 | Forgot Password | auth | P0 |
| 6 | OTP Verification | auth | P0 |
| 7 | Home | home | P0 |
| 8 | Product List | products | P0 |
| 9 | Product Detail | products | P0 |
| 10 | Cart | cart | P0 |
| 11 | Checkout | checkout | P0 |
| 12 | Order Confirmed | orders | P0 |
| 13 | Orders List | orders | P0 |
| 14 | Order Detail | orders | P0 |

### Tier 2: Enhanced UX
| # | Screen | Feature |
|---|--------|---------|
| 15 | Categories | categories |
| 16 | Search and Filters | products |
| 17 | Favorites | favorites |
| 18 | Profile | profile |
| 19 | Addresses | addresses |
| 20 | Add/Edit Address | addresses |
| 21 | Notifications | notifications |

### Tier 3: Engagement
| # | Screen | Feature |
|---|--------|---------|
| 22 | Reviews List | reviews |
| 23 | Write Review | reviews |
| 24 | Offers/Sale | products |
| 25 | Brand Products | products |
| 26 | Settings | settings |
| 27 | Edit Profile | profile |

---

## 11. UX and Navigation Flow

### 11.1 First Launch Flow
```
App Launch
    |
Splash Screen (2s, logo animation)
    |
Check: hasSeenOnboarding?
    |-- No  --> Onboarding (3 slides) --> Login
    |-- Yes --> Check: isAuthenticated?
                    |-- Yes --> Home
                    |-- No  --> Login
```

### 11.2 Main Navigation (Shell Route)
```
Bottom Navigation Bar:
  Home | Categories | Cart (badge) | Favorites | Profile
```

### 11.3 Shopping Journey
```
Home --> Category / Search --> Product List
                                    |
                               Product Detail
                                 |-- Add to Cart --> Cart --> Checkout --> Order Confirmed
                                 |-- Add to Favorites
```

### 11.4 Loading Experience
1. First load: Skeleton shimmer (NOT a spinner)
2. Pagination: Shimmer at bottom of list
3. Action buttons: Loading state inside button, disabled to prevent double-tap
4. Full-page operations: Modal loading overlay

### 11.5 Error Experience

| Error Type | UI Response |
|------------|-------------|
| Network down | Snackbar + retry button |
| Server error (5xx) | Full error widget with retry |
| Not found (404) | Friendly empty state with illustration |
| Auth expired | Silent token refresh, redirect to login if fails |
| Validation error | Field-level inline error messages |
| Empty list | Lottie animation + contextual message + CTA |

---

## 12. Error Handling Strategy

### 12.1 Failure Hierarchy (Sealed Class)
```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure    extends Failure { const ServerFailure(super.message); }
class NetworkFailure   extends Failure { const NetworkFailure(super.message); }
class CacheFailure     extends Failure { const CacheFailure(super.message); }
class AuthFailure      extends Failure { const AuthFailure(super.message); }
class ValidationFailure extends Failure {
  final Map<String, String> errors;
  const ValidationFailure(super.message, this.errors);
}
class UnexpectedFailure extends Failure { const UnexpectedFailure(super.message); }
```

### 12.2 Safe API Call Wrapper
```dart
Future<Either<Failure, T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return Right(await call());
  } on AuthException {
    return const Left(AuthFailure('Session expired. Please log in again.'));
  } on PostgrestException catch (e) {
    return Left(ServerFailure(e.message));
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionError) {
      return const Left(NetworkFailure('No internet connection'));
    }
    return Left(ServerFailure(e.message ?? 'Server error'));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}
```

---

## 13. Security Best Practices

| Practice | Implementation |
|----------|---------------|
| No API keys in code | Keys in .env file, loaded via --dart-define-from-file |
| RLS on all tables | Supabase Row Level Security at DB level |
| Input sanitization | All form inputs validated before submission |
| JWT auto-refresh | Supabase SDK handles token refresh automatically |
| Secure storage | Sensitive data in flutter_secure_storage |
| HTTPS only | All API calls over TLS, enforced by Supabase |
| No PII in logs | Logger filters personal information |
| Obfuscation | flutter build --obfuscate for release builds |

---

## 14. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | snake_case | product_card.dart |
| Classes | PascalCase | class ProductCard |
| Variables | camelCase | final productList |
| Constants | camelCase in abstract class | AppColors.primary |
| Providers | camelCase + Provider suffix | productsProvider |
| Git branches | type/description | feat/auth-login |

### Conventional Commits Format
```
feat(auth): add Google OAuth login
fix(cart): prevent negative quantity
chore(deps): upgrade riverpod to 2.6.1
refactor(products): extract ProductCard widget
test(auth): add login use case unit tests
```

---

## 15. Project Roadmap — 8 Milestones

| Phase | Focus | Timeline |
|-------|-------|---------|
| Phase 1 | Foundation and Infrastructure | Week 1 |
| Phase 2 | Authentication Flow | Week 2 |
| Phase 3 | Home and Product Catalog | Week 3-4 |
| Phase 4 | Product Detail and Reviews | Week 4-5 |
| Phase 5 | Cart and Favorites | Week 5-6 |
| Phase 6 | Checkout and Orders | Week 6-7 |
| Phase 7 | Profile and Settings | Week 7-8 |
| Phase 8 | Polish, Testing, and Launch | Week 8-9 |

---

## 16. Phase 1 — Project Foundation & Infrastructure

### 16.1 Objective
Create the scaffold of the entire application. After this phase:
- The app runs on device/emulator with zero errors
- All packages are installed and configured
- Architecture skeleton (all folders) is in place
- Theme system (light/dark/Material 3) works and is switchable
- Localization (AR/EN) is set up — Arabic shows RTL layout
- GoRouter is configured with all routes (placeholder screens)
- Riverpod ProviderScope wraps the app
- Logger works (debug: verbose, release: silent)
- Supabase is initialized (not yet used for data)

### 16.2 Files to Create in Phase 1
```
pubspec.yaml                  (updated with all packages)
analysis_options.yaml         (strict linting)
.env                          (Supabase credentials — gitignored)
.gitignore                    (updated)

lib/
  main.dart
  app.dart
  core/config/app_config.dart
  core/config/supabase_config.dart
  core/config/app_constants.dart
  core/di/providers.dart
  core/error/failures.dart
  core/error/exceptions.dart
  core/router/app_router.dart
  core/router/app_routes.dart
  core/theme/app_theme.dart
  core/theme/app_colors.dart
  core/theme/app_typography.dart
  core/theme/app_spacing.dart
  core/l10n/app_en.arb
  core/l10n/app_ar.arb
  core/utils/logger.dart
  core/widgets/app_loading.dart
  core/widgets/app_error_widget.dart
  core/widgets/app_empty_state.dart
  features/auth/presentation/screens/splash_screen.dart     (placeholder)
  features/auth/presentation/screens/login_screen.dart      (placeholder)
  features/home/presentation/screens/home_screen.dart       (placeholder)
  [all other placeholder screens]
```

### 16.3 Phase 1 Checklist (Must pass before Phase 2)
- [ ] `flutter run` on Android and iOS with ZERO errors
- [ ] Switching locale to Arabic changes layout to RTL
- [ ] Switching to dark mode works and looks correct
- [ ] All named routes navigate to placeholder screens
- [ ] `flutter analyze` shows 0 warnings or errors
- [ ] `dart run build_runner build` runs without errors
- [ ] Logger prints in debug mode, silent in release mode
- [ ] `.env` file is in `.gitignore`

### 16.4 Common Mistakes in Phase 1 and How to Avoid Them

| Mistake | Correct Approach |
|---------|-----------------|
| Putting Supabase URL in code | Use --dart-define-from-file=.env |
| Using BuildContext in providers | Pass data through constructor |
| Mixing StatefulWidget with Riverpod | Use ConsumerStatefulWidget |
| Forgetting RTL support | Always test in Arabic locale |
| Giant single theme file | Split into colors, typography, spacing files |
| Not setting up linting | Add analysis_options.yaml from the start |

### 16.5 What You Will Learn in Phase 1
- How Clean Architecture is structured in a real Flutter project
- How to configure Riverpod globally with ProviderScope
- How to set up GoRouter with ShellRoute for tab navigation
- How --dart-define-from-file works for environment variables
- How to build a complete theme system with Material 3
- How to set up localization for AR and EN with RTL support
- How to use build_runner for code generation
- How to configure strict linting (analysis_options.yaml)

---

## Appendix A — Git Repository Setup

```bash
git init
echo ".env" >> .gitignore
git add .
git commit -m "chore: initial project setup"
git branch -M main
git remote add origin [your-repo-url]
git push -u origin main
```

Branch strategy:
```
main        <- production-ready, protected
develop     <- integration branch
feat/*      <- feature branches (merge into develop via PR)
fix/*       <- bug fix branches
```

---

## Appendix B — Supabase Setup Steps

1. Create project at supabase.com
2. Settings > API > copy Project URL and anon key
3. Enable Email auth in Authentication > Providers
4. Enable Google OAuth (Phase 2)
5. Run SQL schema migrations (provided per phase)
6. Set up Storage buckets: avatars, products, reviews
7. Configure RLS policies (provided per phase)

---

*Document Version: 1.0*
*Created: 2026-08-05*
*Status: Awaiting Phase 1 Execution Approval*
