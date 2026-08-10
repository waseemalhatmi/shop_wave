-- =============================================================
-- ShopWave Full Database Schema Setup
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/vpzidqrsnbjfpkvmoanr/sql/new
-- =============================================================

-- Utility for auto-updating updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION attach_updated_at_trigger(tbl TEXT)
RETURNS VOID AS $$
BEGIN
  EXECUTE format(
    'CREATE TRIGGER trg_%s_updated_at
     BEFORE UPDATE ON %I
     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()',
    tbl, tbl
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$ LANGUAGE plpgsql;

-- 1. PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
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

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  ) ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
CREATE TRIGGER trg_on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Users can view own profile') THEN
    CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='profiles' AND policyname='Users can update own profile') THEN
    CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END $$;

-- 2. CATEGORIES
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
SELECT attach_updated_at_trigger('categories');
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='categories' AND policyname='Categories are public') THEN
    CREATE POLICY "Categories are public" ON categories FOR SELECT USING (TRUE);
  END IF;
END $$;

-- 3. BRANDS
CREATE TABLE IF NOT EXISTS brands (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL,
  slug        TEXT        UNIQUE NOT NULL,
  logo_url    TEXT,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
SELECT attach_updated_at_trigger('brands');
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='brands' AND policyname='Brands are public') THEN
    CREATE POLICY "Brands are public" ON brands FOR SELECT USING (TRUE);
  END IF;
END $$;

-- 4. PRODUCTS
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
  GENERATED ALWAYS AS (
    ROUND(base_price * (1 - discount_percent / 100), 2)
  ) STORED AS final_price NUMERIC(10,2)
);
SELECT attach_updated_at_trigger('products');
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='products' AND policyname='Active products are public') THEN
    CREATE POLICY "Active products are public" ON products FOR SELECT USING (is_active = TRUE AND deleted_at IS NULL);
  END IF;
END $$;

-- 5. PRODUCT IMAGES
CREATE TABLE IF NOT EXISTS product_images (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url         TEXT        NOT NULL,
  alt_text    TEXT,
  sort_order  INT         NOT NULL DEFAULT 0,
  is_primary  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='product_images' AND policyname='Product images are public') THEN
    CREATE POLICY "Product images are public" ON product_images FOR SELECT USING (TRUE);
  END IF;
END $$;

-- 6. BANNERS
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
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='banners' AND policyname='Active banners are public') THEN
    CREATE POLICY "Active banners are public" ON banners FOR SELECT USING (is_active = TRUE AND (starts_at IS NULL OR starts_at <= NOW()) AND (ends_at IS NULL OR ends_at >= NOW()));
  END IF;
END $$;

-- 7. ADDRESSES
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
SELECT attach_updated_at_trigger('addresses');
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='addresses' AND policyname='Users manage own addresses') THEN
    CREATE POLICY "Users manage own addresses" ON addresses USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- 8. FAVORITES
CREATE TABLE IF NOT EXISTS favorites (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID        NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='favorites' AND policyname='Users can view their own favorites') THEN
    CREATE POLICY "Users can view their own favorites" ON favorites FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='favorites' AND policyname='Users can insert their own favorites') THEN
    CREATE POLICY "Users can insert their own favorites" ON favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='favorites' AND policyname='Users can delete their own favorites') THEN
    CREATE POLICY "Users can delete their own favorites" ON favorites FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- 9. REVIEWS
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
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='reviews' AND policyname='Reviews are public') THEN
    CREATE POLICY "Reviews are public" ON reviews FOR SELECT USING (TRUE);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='reviews' AND policyname='Authenticated users can write reviews') THEN
    CREATE POLICY "Authenticated users can write reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='reviews' AND policyname='Users can update their own reviews') THEN
    CREATE POLICY "Users can update their own reviews" ON reviews FOR UPDATE USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='reviews' AND policyname='Users can delete their own reviews') THEN
    CREATE POLICY "Users can delete their own reviews" ON reviews FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- 10. ORDERS
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
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='orders' AND policyname='Users can view their own orders') THEN
    CREATE POLICY "Users can view their own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='orders' AND policyname='Users can insert their own orders') THEN
    CREATE POLICY "Users can insert their own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- 11. ORDER ITEMS
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
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='order_items' AND policyname='Users can view their own order items') THEN
    CREATE POLICY "Users can view their own order items" ON order_items FOR SELECT USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='order_items' AND policyname='Users can insert order items for their orders') THEN
    CREATE POLICY "Users can insert order items for their orders" ON order_items FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()));
  END IF;
END $$;

-- 12. NOTIFICATIONS
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
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='notifications' AND policyname='Users see own notifications') THEN
    CREATE POLICY "Users see own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='notifications' AND policyname='Users update own notifications') THEN
    CREATE POLICY "Users update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END $$;

-- 13. APP SETTINGS
CREATE TABLE IF NOT EXISTS app_settings (
  key        TEXT        PRIMARY KEY,
  value      JSONB       NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='app_settings' AND policyname='App settings are public') THEN
    CREATE POLICY "App settings are public" ON app_settings FOR SELECT USING (TRUE);
  END IF;
END $$;

-- 14. FAVORITES
CREATE TABLE IF NOT EXISTS public.favorites (
  user_id     UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id  UUID        NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, product_id)
);
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='favorites' AND policyname='Users can view own favorites') THEN
    CREATE POLICY "Users can view own favorites" ON public.favorites FOR SELECT USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='favorites' AND policyname='Users can insert own favorites') THEN
    CREATE POLICY "Users can insert own favorites" ON public.favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='favorites' AND policyname='Users can delete own favorites') THEN
    CREATE POLICY "Users can delete own favorites" ON public.favorites FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Clear existing sample data first to prevent duplicate slug issues
DELETE FROM public.product_images;
DELETE FROM public.products;
DELETE FROM public.categories;

-- 1. Insert Categories with hardcoded IDs
INSERT INTO public.categories (id, name_en, name_ar, slug, sort_order) VALUES
  ('c0000000-0000-0000-0000-000000000001', 'Electronics', 'إلكترونيات', 'electronics', 1),
  ('c0000000-0000-0000-0000-000000000002', 'Clothing', 'ملابس', 'clothing', 2),
  ('c0000000-0000-0000-0000-000000000003', 'Home & Garden', 'المنزل والحديقة', 'home-garden', 3),
  ('c0000000-0000-0000-0000-000000000004', 'Sports', 'رياضة', 'sports', 4)
ON CONFLICT (id) DO UPDATE SET 
  name_en = EXCLUDED.name_en, 
  name_ar = EXCLUDED.name_ar, 
  slug = EXCLUDED.slug, 
  sort_order = EXCLUDED.sort_order;

-- 2. Insert 20 Products with hardcoded IDs
INSERT INTO public.products (id, name_en, name_ar, description_en, description_ar, slug, category_id, base_price, discount_percent, sku, is_active, is_featured, is_new_arrival, is_on_sale, avg_rating, review_count, sold_count) VALUES
  -- Electronics
  ('b0000000-0000-0000-0000-000000000001', 'Wireless Noise-Cancelling Headphones', 'سماعات رأس لاسلكية عازلة للضوضاء', 
   'Experience premium sound quality with active noise cancellation, 40-hour battery life, and comfortable over-ear design.', 
   'استمتع بجودة صوت استثنائية مع ميزة إلغاء الضوضاء النشطة، وعمر بطارية يصل إلى 40 ساعة، وتصميم مريح فوق الأذن.', 
   'wireless-noise-cancelling-headphones', 'c0000000-0000-0000-0000-000000000001', 299.00, 15.00, 'SKU-ELECT-001', TRUE, TRUE, TRUE, TRUE, 4.8, 128, 450),

  ('b0000000-0000-0000-0000-000000000002', 'Pro GPS Smartwatch', 'ساعة ذكية رياضية بـ GPS', 
   'Track your workouts, heart rate, sleep patterns, and location with this waterproof, long-lasting smart companion.', 
   'تتبع تمارينك الرياضية، ومعدل ضربات القلب، وأنماط النوم، وموقعك الجغرافي مع هذا الرفيق الذكي المقاوم للماء طويل الأمد.', 
   'pro-gps-smartwatch', 'c0000000-0000-0000-0000-000000000001', 599.00, 10.00, 'SKU-ELECT-002', TRUE, TRUE, TRUE, TRUE, 4.6, 95, 310),

  ('b0000000-0000-0000-0000-000000000003', 'Portable Bluetooth Speaker', 'مكبر صوت بلوتوث محمول', 
   'Waterproof outdoor speaker with deep bass, 360-degree sound projection, and 12 hours of continuous playback.', 
   'مكبر صوت خارجي مقاوم للماء مع صوت جهير عميق، وإسقاط صوتي بزاوية 360 درجة، و 12 ساعة من التشغيل المستمر.', 
   'portable-bluetooth-speaker', 'c0000000-0000-0000-0000-000000000001', 199.00, 20.00, 'SKU-ELECT-003', TRUE, FALSE, TRUE, TRUE, 4.5, 64, 215),

  ('b0000000-0000-0000-0000-000000000004', 'Mechanical Gaming Keyboard', 'لوحة مفاتيح ميكانيكية للألعاب', 
   'RGB backlit keyboard with custom mechanical switches, anti-ghosting keys, and durable aluminum top plate.', 
   'لوحة مفاتيح بإضاءة خلفية RGB مع مفاتيح ميكانيكية مخصصة، ومفاتيح مضادة للظلال، ولوحة علوية متينة من الألومنيوم.', 
   'mechanical-gaming-keyboard', 'c0000000-0000-0000-0000-000000000001', 349.00, 0.00, 'SKU-ELECT-004', TRUE, TRUE, FALSE, FALSE, 4.7, 43, 110),

  ('b0000000-0000-0000-0000-000000000005', 'Wireless Precision Gaming Mouse', 'ماوس ألعاب لاسلكي عالي الدقة', 
   'High-precision optical gaming mouse with customizable weight, RGB lighting, and 16,000 DPI sensor.', 
   'ماوس ألعاب بصري عالي الدقة مع وزن قابل للتخصيص، وإضاءة RGB، ومستشعر بدقة 16,000 DPI.', 
   'wireless-precision-gaming-mouse', 'c0000000-0000-0000-0000-000000000001', 149.00, 25.00, 'SKU-ELECT-005', TRUE, FALSE, FALSE, TRUE, 4.4, 82, 340),

  -- Clothing
  ('b0000000-0000-0000-0000-000000000006', 'Premium Organic Cotton T-Shirt', 'تيشيرت قطن عضوي فاخر', 
   'Breathable, soft-touch crewneck t-shirt made from 100% organic cotton. Perfect for daily casual wear.', 
   'تيشيرت بياقة مستديرة ناعم الملمس وجيد التهوية مصنوع من القطن العضوي 100%. مثالي للارتداء اليومي غير الرسمي.', 
   'premium-organic-cotton-tshirt', 'c0000000-0000-0000-0000-000000000002', 89.00, 0.00, 'SKU-CLOTH-001', TRUE, TRUE, TRUE, FALSE, 4.7, 210, 850),

  ('b0000000-0000-0000-0000-000000000007', 'Classic Denim Jacket', 'جاكيت جينز كلاسيكي', 
   'Durable denim button-down jacket with comfortable chest pockets and adjustable button waist tabs.', 
   'جاكيت جينز متين بأزرار وجيوب صدر مريحة وألسنة خصر قابلة للتعديل بأزرار.', 
   'classic-denim-jacket', 'c0000000-0000-0000-0000-000000000002', 249.00, 30.00, 'SKU-CLOTH-002', TRUE, TRUE, FALSE, TRUE, 4.5, 76, 180),

  ('b0000000-0000-0000-0000-000000000008', 'Lightweight Running Shorts', 'شورت جري خفيف الوزن', 
   'Moisture-wicking athletic shorts with zipper key pockets and reflective elements for evening runs.', 
   'شورت رياضي طارد للرطوبة مع جيوب بسحاب للمفاتيح وعناصر عاكسة للجري المسائي.', 
   'lightweight-running-shorts', 'c0000000-0000-0000-0000-000000000002', 79.00, 15.00, 'SKU-CLOTH-003', TRUE, FALSE, TRUE, TRUE, 4.3, 34, 120),

  ('b0000000-0000-0000-0000-000000000009', 'Tailored Formal Suit Blazer', 'سترة بدلة رسمية مفصلة', 
   'Slim-fit structural formal blazer, designed with double vents and custom notch lapels for business attire.', 
   'سترة رسمية ضيقة، مصممة بفتحتين مزدوجتين وياقة مخصصة للملابس الرسمية وملابس العمل.', 
   'tailored-formal-suit-blazer', 'c0000000-0000-0000-0000-000000000002', 899.00, 10.00, 'SKU-CLOTH-004', TRUE, TRUE, FALSE, TRUE, 4.9, 18, 45),

  ('b0000000-0000-0000-0000-000000000010', 'Soft Knit Woolen Scarf', 'وشاح صوفي محبوك ناعم', 
   'Keep warm with this soft, long knitted woolen scarf. Cozy accessory suitable for cold winter days.', 
   'حافظ على دفئك مع هذا الوشاح الصوفي الطويل والناعم. إكسسوار دافئ ومناسب لأيام الشتاء الباردة.', 
   'soft-knit-woolen-scarf', 'c0000000-0000-0000-0000-000000000002', 49.00, 0.00, 'SKU-CLOTH-005', TRUE, FALSE, FALSE, FALSE, 4.6, 52, 98),

  -- Home & Garden
  ('b0000000-0000-0000-0000-000000000011', 'Minimalist Ceramic Flower Vase', 'مزهرية زهور سيراميك مبسطة', 
   'Modern minimalist vase made of high-quality ceramic, ideal for holding flowers or as a standalone decor piece.', 
   'مزهرية عصرية مبسطة مصنوعة من السيراميك عالي الجودة، مثالية للزهور أو كقطعة ديكور مستقلة.', 
   'minimalist-ceramic-flower-vase', 'c0000000-0000-0000-0000-000000000003', 119.00, 15.00, 'SKU-HOME-001', TRUE, TRUE, TRUE, TRUE, 4.6, 62, 190),

  ('b0000000-0000-0000-0000-000000000012', 'Lavender Scented Soy Candle', 'شمعة صويا معطرة باللافندر', 
   'Slow-burning relaxing aromatherapy candle infused with premium natural lavender oils, 50 hours burn time.', 
   'شمعة علاج عطري مريحة وبطيئة الاحتراق غنية بزيوت اللافندر الطبيعية الممتازة، تحترق لمدة 50 ساعة.', 
   'lavender-scented-soy-candle', 'c0000000-0000-0000-0000-000000000003', 39.00, 0.00, 'SKU-HOME-002', TRUE, FALSE, TRUE, FALSE, 4.8, 142, 530),

  ('b0000000-0000-0000-0000-000000000013', 'Adjustable LED Desk Lamp', 'مصباح مكتب LED قابل للتعديل', 
   'Eye-caring study lamp with adjustable brightness levels, multiple color modes, and wireless charging base.', 
   'مصباح دراسة مريح للعين مع مستويات سطوع قابلة للتعديل، وأنماط ألوان متعددة، وقاعدة شحن لاسلكية.', 
   'adjustable-led-desk-lamp', 'c0000000-0000-0000-0000-000000000003', 149.00, 20.00, 'SKU-HOME-003', TRUE, TRUE, FALSE, TRUE, 4.7, 39, 142),

  ('b0000000-0000-0000-0000-000000000014', 'Modern Wooden Wall Clock', 'ساعة حائط خشبية عصرية', 
   'Silent, non-ticking decorative wall clock made from sustainable oak, perfect for living rooms.', 
   'ساعة حائط مزخرفة صامتة بدون صوت عقارب مصنوعة من خشب البلوط المستدام، مثالية لغرف المعيشة.', 
   'modern-wooden-wall-clock', 'c0000000-0000-0000-0000-000000000003', 89.00, 5.00, 'SKU-HOME-004', TRUE, FALSE, FALSE, TRUE, 4.2, 28, 75),

  ('b0000000-0000-0000-0000-000000000015', 'Lush Potted Peace Lily', 'نبتة زنبق السلام المنزلية', 
   'Easy-to-grow air-purifying houseplant potted in a minimalist self-watering ceramic pot.', 
   'نبتة منزلية سهلة النمو لتنقية الهواء مزروعة في وعاء سيراميك مبسط ذاتي الري.', 
   'lush-potted-peace-lily', 'c0000000-0000-0000-0000-000000000003', 69.00, 0.00, 'SKU-HOME-005', TRUE, TRUE, FALSE, FALSE, 4.5, 59, 210),

  -- Sports
  ('b0000000-0000-0000-0000-000000000016', 'Air-Cushioned Running Shoes', 'حذاء جري مبطن بالهواء', 
   'Professional athletic footwear with shock absorption system, flexible mesh, and slip-resistant sole.', 
   'أحذية رياضية احترافية مع نظام امتصاص الصدمات، وشبكة مرنة، ونعل مقاوم للانزلاق.', 
   'air-cushioned-running-shoes', 'c0000000-0000-0000-0000-000000000004', 349.00, 25.00, 'SKU-SPOR-001', TRUE, TRUE, TRUE, TRUE, 4.7, 185, 620),

  ('b0000000-0000-0000-0000-000000000017', 'Non-Slip Thick Yoga Mat', 'سجادة يوغا سميكة مانعة للانزلاق', 
   'High-density eco-friendly TPE yoga mat with alignment lines, 6mm thickness for maximum cushioning.', 
   'سجادة يوغا TPE عالية الكثافة وصديقة للبيئة مع خطوط محاذاة، وسمك 6 مم لأقصى درجات الراحة.', 
   'non-slip-thick-yoga-mat', 'c0000000-0000-0000-0000-000000000004', 99.00, 0.00, 'SKU-SPOR-002', TRUE, FALSE, TRUE, FALSE, 4.6, 94, 430),

  ('b0000000-0000-0000-0000-000000000018', 'Adjustable Dumbbell Set (20kg)', 'طقم دمبل قابل للتعديل (20 كجم)', 
   'Durable steel dumbbells with spinlock collars and comfortable rubber grips, ideal for home gym exercises.', 
   'دمبلز فولاذية متينة مع أطواق قفل دوارة ومقابض مطاطية مريحة، مثالية لتمارين الصالة الرياضية المنزلية.', 
   'adjustable-dumbbell-set-20kg', 'c0000000-0000-0000-0000-000000000004', 299.00, 15.00, 'SKU-SPOR-003', TRUE, TRUE, FALSE, TRUE, 4.8, 77, 250),

  ('b0000000-0000-0000-0000-000000000019', 'Stainless Steel Water Bottle', 'زجاجة مياه رياضية من الستانلس ستيل', 
   'Double-walled vacuum insulated thermal flask. Keeps water ice cold for 24 hours or hot for 12 hours.', 
   'قارورة حرارية معزولة بالتفريغ الهوائي ثنائية الجدار. تحافظ على الماء بارداً كالثلج لمدة 24 ساعة أو ساخناً لـ 12 ساعة.', 
   'stainless-steel-water-bottle', 'c0000000-0000-0000-0000-000000000004', 59.00, 10.00, 'SKU-SPOR-004', TRUE, FALSE, FALSE, TRUE, 4.4, 114, 480),

  ('b0000000-0000-0000-0000-000000000020', 'Waterproof Sports Gym Backpack', 'حقيبة ظهر رياضية مقاومة للماء', 
   'Multi-compartment travel gym bag featuring shoe compartment, laptop sleeve, and dry-wet separation pocket.', 
   'حقيبة سفر رياضية متعددة الأقسام تتميز بقسم للأحذية، وحافظة لابتوب، وجيب للفصل بين الأشياء الجافة والرطبة.', 
   'waterproof-sports-gym-backpack', 'c0000000-0000-0000-0000-000000000004', 179.00, 20.00, 'SKU-SPOR-005', TRUE, TRUE, FALSE, TRUE, 4.5, 49, 160)
ON CONFLICT (id) DO UPDATE SET 
  name_en = EXCLUDED.name_en, 
  name_ar = EXCLUDED.name_ar, 
  description_en = EXCLUDED.description_en, 
  description_ar = EXCLUDED.description_ar, 
  base_price = EXCLUDED.base_price, 
  discount_percent = EXCLUDED.discount_percent, 
  sku = EXCLUDED.sku, 
  is_active = EXCLUDED.is_active, 
  is_featured = EXCLUDED.is_featured, 
  is_new_arrival = EXCLUDED.is_new_arrival, 
  is_on_sale = EXCLUDED.is_on_sale;

-- 3. Insert Product Images (Multiple images per product!)
INSERT INTO public.product_images (product_id, url, sort_order, is_primary) VALUES
  -- 1. Wireless Headphones
  ('b0000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800', 1, TRUE),
  ('b0000000-0000-0000-0000-000000000001', 'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=800', 2, FALSE),

  -- 2. Smart Watch
  ('b0000000-0000-0000-0000-000000000002', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800', 1, TRUE),
  ('b0000000-0000-0000-0000-000000000002', 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800', 2, FALSE),

  -- 3. Portable Speaker
  ('b0000000-0000-0000-0000-000000000003', 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=800', 1, TRUE),

  -- 4. Mechanical Keyboard
  ('b0000000-0000-0000-0000-000000000004', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800', 1, TRUE),

  -- 5. Gaming Mouse
  ('b0000000-0000-0000-0000-000000000005', 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=800', 1, TRUE),

  -- 6. Cotton T-Shirt
  ('b0000000-0000-0000-0000-000000000006', 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800', 1, TRUE),

  -- 7. Denim Jacket
  ('b0000000-0000-0000-0000-000000000007', 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=800', 1, TRUE),

  -- 8. Running Shorts
  ('b0000000-0000-0000-0000-000000000008', 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800', 1, TRUE),

  -- 9. Formal Blazer
  ('b0000000-0000-0000-0000-000000000009', 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800', 1, TRUE),

  -- 10. Woolen Scarf
  ('b0000000-0000-0000-0000-000000000010', 'https://images.unsplash.com/photo-1520903738403-36d47455d83c?w=800', 1, TRUE),

  -- 11. Ceramic Vase
  ('b0000000-0000-0000-0000-000000000011', 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=800', 1, TRUE),

  -- 12. Soy Candle
  ('b0000000-0000-0000-0000-000000000012', 'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=800', 1, TRUE),

  -- 13. Desk Lamp
  ('b0000000-0000-0000-0000-000000000013', 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=800', 1, TRUE),

  -- 14. Wall Clock
  ('b0000000-0000-0000-0000-000000000014', 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=800', 1, TRUE),

  -- 15. Peace Lily
  ('b0000000-0000-0000-0000-000000000015', 'https://images.unsplash.com/photo-1545241047-6083a3684587?w=800', 1, TRUE),

  -- 16. Air-Cushioned Running Shoes
  ('b0000000-0000-0000-0000-000000000016', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800', 1, TRUE),
  ('b0000000-0000-0000-0000-000000000016', 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800', 2, FALSE),

  -- 17. Yoga Mat
  ('b0000000-0000-0000-0000-000000000017', 'https://images.unsplash.com/photo-1592432678016-e910b452f9a2?w=800', 1, TRUE),

  -- 18. Dumbbell Set
  ('b0000000-0000-0000-0000-000000000018', 'https://images.unsplash.com/photo-1638536532686-d610adfc8e5c?w=800', 1, TRUE),

  -- 19. Water Bottle
  ('b0000000-0000-0000-0000-000000000019', 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800', 1, TRUE),

  -- 20. Gym Backpack
  ('b0000000-0000-0000-0000-000000000020', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800', 1, TRUE)
ON CONFLICT (id) DO NOTHING;
