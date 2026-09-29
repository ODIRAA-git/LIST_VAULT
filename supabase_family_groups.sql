-- ============================================
-- FAMILY GROUPS (shared across devices)
-- ============================================
--
-- Run this ONCE in Supabase: Dashboard > SQL Editor > New query >
-- paste everything below > Run.
-- It lets a family created on one device be joined from any other
-- device using its short join code.
-- ============================================

CREATE TABLE IF NOT EXISTS public.family_groups (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    join_code TEXT NOT NULL UNIQUE,
    created_by TEXT NOT NULL,
    max_members INTEGER DEFAULT 10,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.family_members (
    id TEXT PRIMARY KEY,
    family_group_id TEXT NOT NULL REFERENCES public.family_groups(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_color TEXT,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.family_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;

-- Same open access model as the items/weekly_lists tables
CREATE POLICY "Allow all operations on family_groups" ON public.family_groups
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on family_members" ON public.family_members
    FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_family_members_group ON public.family_members(family_group_id);
