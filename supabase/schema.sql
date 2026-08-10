-- =============================================================
-- ShopWave Database Schema
-- PostgreSQL 15+ via Supabase
-- Run this in Supabase SQL Editor
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- UTILITY: auto-update updated_at on every UPDATE
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Helper macro to attach trigger to any table
-- Usage: SELECT attach_updated_at_trigger('table_name');
CREATE OR REPLACE FUNCTION attach_updated_at_trigger(tbl TEXT)
RETURNS VOID AS $$
BEGIN
  EXECUTE format(
    'CREATE TRIGGER trg_%s_updated_at
     BEFORE UPDATE ON %I
     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()',
    tbl, tbl
  );
END;
$$ LANGUAGE plpgsql;

-- ─────────────────────────────────────────────────────────────
-- TABLE: profiles
-- Extends Supabase auth.users (1:1 relationship)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id            UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT,
  avatar_url    TEXT,
  phone         TEXT        UNIQUE,
  date_of_birth DATE,
  gender        TEXT        CHECK (gender IN ('male', 'female', 'other')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

SELECT attach_updated_at_trigger('profiles');

-- Auto-create profile when user registers
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile"   ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: categories (supports nested subcategories via parent_id)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en     TEXT        NOT NULL,
  name_ar     TEXT        NOT NULL,
  slug        TEXT        UNIQUE NOT NULL,
  image_url   TEXT,
  parent_id   UUID        REFERENCES categories(id) ON DELETE SET NULL,
  sort_order  INT         NOT NULL DEFAULT 0,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_categories_parent     ON categories(parent_id);
CREATE INDEX idx_categories_slug       ON categories(slug);
CREATE INDEX idx_categories_active     ON categories(is_active) WHERE is_active = TRUE;
SELECT attach_updated_at_trigger('categories');

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categories are public" ON categories FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: brands
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS brands (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL,
  slug        TEXT        UNIQUE NOT NULL,
  logo_url    TEXT,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_brands_slug   ON brands(slug);
CREATE INDEX idx_brands_active ON brands(is_active) WHERE is_active = TRUE;
SELECT attach_updated_at_trigger('brands');

ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Brands are public" ON brands FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: products
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en          TEXT          NOT NULL,
  name_ar          TEXT          NOT NULL,
  description_en   TEXT,
  description_ar   TEXT,
  slug             TEXT          UNIQUE NOT NULL,
  category_id      UUID          REFERENCES categories(id) ON DELETE SET NULL,
  brand_id         UUID          REFERENCES brands(id) ON DELETE SET NULL,
  base_price       NUMERIC(10,2) NOT NULL CHECK (base_price >= 0),
  discount_percent NUMERIC(5,2)  NOT NULL DEFAULT 0 CHECK (discount_percent BETWEEN 0 AND 100),
  sku              TEXT          UNIQUE,
  is_active        BOOLEAN       NOT NULL DEFAULT TRUE,
  is_featured      BOOLEAN       NOT NULL DEFAULT FALSE,
  is_new_arrival   BOOLEAN       NOT NULL DEFAULT FALSE,
  is_on_sale       BOOLEAN       NOT NULL DEFAULT FALSE,
  avg_rating       NUMERIC(3,2)  NOT NULL DEFAULT 0 CHECK (avg_rating BETWEEN 0 AND 5),
  review_count     INT           NOT NULL DEFAULT 0 CHECK (review_count >= 0),
  sold_count       INT           NOT NULL DEFAULT 0 CHECK (sold_count >= 0),
  deleted_at       TIMESTAMPTZ,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  -- Computed: final price after discount
  GENERATED ALWAYS AS (
    ROUND(base_price * (1 - discount_percent / 100), 2)
  ) STORED AS final_price NUMERIC(10,2)
);

CREATE INDEX idx_products_category   ON products(category_id);
CREATE INDEX idx_products_brand      ON products(brand_id);
CREATE INDEX idx_products_slug       ON products(slug);
CREATE INDEX idx_products_featured   ON products(is_featured)   WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_products_sale       ON products(is_on_sale)    WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_products_new        ON products(is_new_arrival) WHERE is_active = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_products_not_deleted ON products(deleted_at)   WHERE deleted_at IS NULL;
CREATE INDEX idx_products_fts        ON products
  USING gin(to_tsvector('english',
    coalesce(name_en, '') || ' ' || coalesce(description_en, '')
  ));

SELECT attach_updated_at_trigger('products');

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active products are public" ON products
  FOR SELECT USING (is_active = TRUE AND deleted_at IS NULL);

-- ─────────────────────────────────────────────────────────────
-- TABLE: product_images
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_images (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url         TEXT        NOT NULL,
  alt_text    TEXT,
  sort_order  INT         NOT NULL DEFAULT 0,
  is_primary  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_product_images_product ON product_images(product_id);

ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Product images are public" ON product_images FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: product_attributes (e.g. Color, Size, Storage)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_attributes (
  id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_en TEXT NOT NULL,
  name_ar TEXT NOT NULL
);

ALTER TABLE product_attributes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Attributes are public" ON product_attributes FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: product_attribute_values (e.g. Red, XL, 128GB)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_attribute_values (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attribute_id UUID NOT NULL REFERENCES product_attributes(id) ON DELETE CASCADE,
  value_en     TEXT NOT NULL,
  value_ar     TEXT NOT NULL,
  hex_color    TEXT  -- optional: for color swatches in UI
);

CREATE INDEX idx_attr_values_attribute ON product_attribute_values(attribute_id);

ALTER TABLE product_attribute_values ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Attribute values are public" ON product_attribute_values FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: product_variants (a specific purchasable combination)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_variants (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID          NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  sku         TEXT          UNIQUE,
  price       NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  stock       INT           NOT NULL DEFAULT 0 CHECK (stock >= 0),
  is_default  BOOLEAN       NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_variants_product ON product_variants(product_id);
SELECT attach_updated_at_trigger('product_variants');

ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Variants are public" ON product_variants FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: variant_attribute_values (which values make this variant)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS variant_attribute_values (
  variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  value_id   UUID NOT NULL REFERENCES product_attribute_values(id) ON DELETE CASCADE,
  PRIMARY KEY (variant_id, value_id)
);

ALTER TABLE variant_attribute_values ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Variant attributes are public" ON variant_attribute_values FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: banners (home screen promotional banners)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS banners (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title_en     TEXT,
  title_ar     TEXT,
  image_url    TEXT        NOT NULL,
  action_type  TEXT        CHECK (action_type IN ('product', 'category', 'brand', 'url')),
  action_value TEXT,
  sort_order   INT         NOT NULL DEFAULT 0,
  is_active    BOOLEAN     NOT NULL DEFAULT TRUE,
  starts_at    TIMESTAMPTZ,
  ends_at      TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE banners ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active banners are public" ON banners
  FOR SELECT USING (
    is_active = TRUE
    AND (starts_at IS NULL OR starts_at <= NOW())
    AND (ends_at   IS NULL OR ends_at   >= NOW())
  );

-- ─────────────────────────────────────────────────────────────
-- TABLE: addresses
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS addresses (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  label       TEXT,
  full_name   TEXT        NOT NULL,
  phone       TEXT        NOT NULL,
  country     TEXT        NOT NULL DEFAULT 'SA',
  city        TEXT        NOT NULL,
  district    TEXT,
  street      TEXT        NOT NULL,
  building    TEXT,
  postal_code TEXT,
  is_default  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_addresses_user ON addresses(user_id);
SELECT attach_updated_at_trigger('addresses');

ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own addresses" ON addresses
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: coupons
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS coupons (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  code             TEXT          UNIQUE NOT NULL,
  discount_type    TEXT          NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value   NUMERIC(10,2) NOT NULL CHECK (discount_value > 0),
  min_order_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  max_uses         INT,
  used_count       INT           NOT NULL DEFAULT 0,
  is_active        BOOLEAN       NOT NULL DEFAULT TRUE,
  expires_at       TIMESTAMPTZ,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
-- Only authenticated users can validate a coupon (read active ones)
CREATE POLICY "Authenticated users can read active coupons" ON coupons
  FOR SELECT USING (auth.role() = 'authenticated' AND is_active = TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: carts (one cart per user)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS carts (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

SELECT attach_updated_at_trigger('carts');

ALTER TABLE carts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own cart" ON carts
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: cart_items
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cart_items (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id    UUID        NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  variant_id UUID        NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  quantity   INT         NOT NULL DEFAULT 1 CHECK (quantity > 0),
  added_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (cart_id, variant_id)
);

CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own cart items" ON cart_items
  USING (
    cart_id IN (SELECT id FROM carts WHERE user_id = auth.uid())
  )
  WITH CHECK (
    cart_id IN (SELECT id FROM carts WHERE user_id = auth.uid())
  );

-- ─────────────────────────────────────────────────────────────
-- TABLE: orders
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID          NOT NULL REFERENCES profiles(id),
  order_number     TEXT          UNIQUE NOT NULL,
  status           TEXT          NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending','confirmed','processing','shipped','delivered','cancelled','refunded')),
  payment_status   TEXT          NOT NULL DEFAULT 'unpaid'
                   CHECK (payment_status IN ('unpaid','paid','refunded','failed')),
  payment_method   TEXT,
  subtotal         NUMERIC(10,2) NOT NULL,
  shipping_fee     NUMERIC(10,2) NOT NULL DEFAULT 0,
  discount_amount  NUMERIC(10,2) NOT NULL DEFAULT 0,
  total            NUMERIC(10,2) NOT NULL,
  coupon_id        UUID          REFERENCES coupons(id),
  address_snapshot JSONB         NOT NULL,
  notes            TEXT,
  deleted_at       TIMESTAMPTZ,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user       ON orders(user_id);
CREATE INDEX idx_orders_status     ON orders(status);
CREATE INDEX idx_orders_number     ON orders(order_number);
CREATE INDEX idx_orders_not_deleted ON orders(deleted_at) WHERE deleted_at IS NULL;
SELECT attach_updated_at_trigger('orders');

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users create own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: order_items
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         UUID          NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  variant_id       UUID          REFERENCES product_variants(id) ON DELETE SET NULL,
  product_snapshot JSONB         NOT NULL,
  quantity         INT           NOT NULL CHECK (quantity > 0),
  unit_price       NUMERIC(10,2) NOT NULL,
  total_price      NUMERIC(10,2) NOT NULL
);

CREATE INDEX idx_order_items_order ON order_items(order_id);

ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own order items" ON order_items
  FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
  );

-- ─────────────────────────────────────────────────────────────
-- TABLE: order_status_history (timeline of order changes)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_status_history (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id   UUID        NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status     TEXT        NOT NULL,
  note       TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_status_history_order ON order_status_history(order_id);

ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own order history" ON order_status_history
  FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
  );

-- ─────────────────────────────────────────────────────────────
-- TABLE: favorites
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS favorites (
  user_id    UUID        NOT NULL REFERENCES profiles(id)  ON DELETE CASCADE,
  product_id UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, product_id)
);

CREATE INDEX idx_favorites_user ON favorites(user_id);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own favorites" ON favorites
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: reviews
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id  UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  order_id    UUID        REFERENCES orders(id),
  rating      INT         NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title       TEXT,
  body        TEXT,
  is_approved BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);

CREATE INDEX idx_reviews_product  ON reviews(product_id);
CREATE INDEX idx_reviews_user     ON reviews(user_id);
CREATE INDEX idx_reviews_approved ON reviews(is_approved) WHERE is_approved = TRUE;
SELECT attach_updated_at_trigger('reviews');

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Approved reviews are public"   ON reviews FOR SELECT USING (is_approved = TRUE);
CREATE POLICY "Users create own reviews"      ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users update own reviews"      ON reviews FOR UPDATE USING (auth.uid() = user_id);

-- Auto-update product avg_rating when a review is approved
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET
    avg_rating   = (SELECT ROUND(AVG(rating)::NUMERIC, 2) FROM reviews WHERE product_id = NEW.product_id AND is_approved = TRUE),
    review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = NEW.product_id AND is_approved = TRUE)
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_update_product_rating
AFTER INSERT OR UPDATE OF is_approved ON reviews
FOR EACH ROW WHEN (NEW.is_approved = TRUE)
EXECUTE FUNCTION update_product_rating();

-- ─────────────────────────────────────────────────────────────
-- TABLE: review_images
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS review_images (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  url       TEXT NOT NULL
);

ALTER TABLE review_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Review images are public" ON review_images FOR SELECT USING (TRUE);

-- ─────────────────────────────────────────────────────────────
-- TABLE: notifications
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type       TEXT        NOT NULL,
  title_en   TEXT        NOT NULL,
  title_ar   TEXT        NOT NULL,
  body_en    TEXT,
  body_ar    TEXT,
  data       JSONB,
  is_read    BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user   ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: app_settings (key-value config for admin control)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS app_settings (
  key        TEXT        PRIMARY KEY,
  value      JSONB       NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "App settings are public" ON app_settings FOR SELECT USING (TRUE);

-- Default settings
INSERT INTO app_settings (key, value) VALUES
  ('free_shipping_threshold', '{"amount": 200}'),
  ('shipping_fee',            '{"amount": 15}'),
  ('minimum_order_amount',    '{"amount": 0}'),
  ('maintenance_mode',        '{"enabled": false}')
ON CONFLICT (key) DO NOTHING;

-- ─────────────────────────────────────────────────────────────
-- STORAGE BUCKETS (run after schema)
-- ─────────────────────────────────────────────────────────────
-- INSERT INTO storage.buckets (id, name, public) VALUES ('avatars',  'avatars',  true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('products', 'products', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('reviews',  'reviews',  true);

-- ─────────────────────────────────────────────────────────────
-- ORDER NUMBER GENERATOR
-- Generates human-readable order numbers like: ORD-2026-00001
-- ─────────────────────────────────────────────────────────────
CREATE SEQUENCE IF NOT EXISTS order_number_seq;

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
  seq_val INT;
BEGIN
  seq_val := nextval('order_number_seq');
  RETURN 'ORD-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(seq_val::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- =============================================================
-- ORDERS SCHEMA
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- TABLE: orders
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  order_number     TEXT        NOT NULL UNIQUE DEFAULT generate_order_number(),
  status           TEXT        NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  payment_method   TEXT        NOT NULL,
  subtotal         NUMERIC     NOT NULL DEFAULT 0,
  shipping_cost    NUMERIC     NOT NULL DEFAULT 0,
  tax              NUMERIC     NOT NULL DEFAULT 0,
  total            NUMERIC     NOT NULL DEFAULT 0,
  shipping_address JSONB       NOT NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

SELECT attach_updated_at_trigger('orders');

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert their own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view their own orders" ON orders FOR SELECT USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: order_items
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         UUID        NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id       TEXT        NOT NULL,
  product_name_en  TEXT        NOT NULL,
  product_name_ar  TEXT        NOT NULL,
  product_image    TEXT        NOT NULL,
  quantity         INT         NOT NULL DEFAULT 1 CHECK (quantity > 0),
  price_at_purchase NUMERIC    NOT NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert order items for their orders" ON order_items FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);
CREATE POLICY "Users can view their own order items" ON order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);

-- =============================================================
-- FAVORITES & REVIEWS SCHEMA
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- TABLE: favorites
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS favorites (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert their own favorites" ON favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view their own favorites" ON favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own favorites" ON favorites FOR DELETE USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TABLE: reviews
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating      INT         NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Reviews are public" ON reviews FOR SELECT USING (TRUE);
CREATE POLICY "Authenticated users can write reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own reviews" ON reviews FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own reviews" ON reviews FOR DELETE USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- TRIGGER: auto-update product average rating and review count
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_product_ratings()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET 
    avg_rating = COALESCE((SELECT ROUND(AVG(rating), 2) FROM reviews WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)), 0),
    review_count = COALESCE((SELECT COUNT(*) FROM reviews WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)), 0)
  WHERE id = COALESCE(NEW.product_id, OLD.product_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_update_product_ratings
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_product_ratings();

-- =============================================================
-- END OF SCHEMA
-- =============================================================
