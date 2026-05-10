-- Ponchi orders schema.
-- Stores submitted orders and their cart line items.

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'preparing', 'completed', 'cancelled')),
  total_price INTEGER NOT NULL CHECK (total_price >= 0),
  comment TEXT,
  pickup_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id
ON public.orders(user_id);

CREATE INDEX IF NOT EXISTS idx_orders_status_created_at
ON public.orders(status, created_at DESC);

CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  name TEXT NOT NULL,
  price INTEGER NOT NULL CHECK (price >= 0),
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  size TEXT,
  toppings JSONB,
  comment TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id
ON public.order_items(order_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
ON public.order_items(product_id);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
