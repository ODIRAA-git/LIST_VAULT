-- ============================================
-- SUPABASE DATABASE SETUP FOR FAMILY LIST APP
-- ============================================
--
-- INSTRUCTIONS:
-- 1. Go to https://supabase.com/dashboard
-- 2. Open your project
-- 3. Click "SQL Editor" on the left
-- 4. Click "New query"
-- 5. Copy ALL the text below and paste it
-- 6. Click "Run"
-- ============================================

-- Create items table
CREATE TABLE IF NOT EXISTS public.items (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    category TEXT DEFAULT 'Other',
    added_by TEXT NOT NULL,
    is_done BOOLEAN DEFAULT false,
    family_group_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create weekly_lists table
CREATE TABLE IF NOT EXISTS public.weekly_lists (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    week_number INTEGER NOT NULL,
    year INTEGER NOT NULL,
    status TEXT DEFAULT 'active',
    family_group_id TEXT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    items JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_lists ENABLE ROW LEVEL SECURITY;

-- Create policies to allow all operations
CREATE POLICY "Allow all operations on items" ON public.items
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on weekly_lists" ON public.weekly_lists
    FOR ALL USING (true) WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_items_family_group ON public.items(family_group_id);
CREATE INDEX IF NOT EXISTS idx_weekly_lists_family_group ON public.weekly_lists(family_group_id);

-- ============================================
-- DONE! Your database is now ready.
-- Go back to your phone and try adding an item.
-- ============================================
