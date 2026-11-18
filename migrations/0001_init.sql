PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS leads (
 id TEXT PRIMARY KEY, source_key TEXT NOT NULL UNIQUE, name TEXT NOT NULL, niche TEXT,
 city TEXT, region TEXT, address TEXT, phone TEXT, website TEXT, website_status TEXT NOT NULL DEFAULT 'unknown',
 telegram TEXT, vk TEXT, whatsapp TEXT, socials_json TEXT NOT NULL DEFAULT '[]',
 source TEXT NOT NULL DEFAULT 'openstreetmap', source_url TEXT, lat REAL, lon REAL,
 contact_status TEXT NOT NULL DEFAULT 'unchecked', status TEXT NOT NULL DEFAULT 'new',
 favorite INTEGER NOT NULL DEFAULT 0, notes TEXT NOT NULL DEFAULT '', first_seen TEXT NOT NULL, last_checked TEXT NOT NULL,
 raw_json TEXT NOT NULL DEFAULT '{}'
);
CREATE INDEX IF NOT EXISTS idx_leads_city ON leads(city);
CREATE INDEX IF NOT EXISTS idx_leads_niche ON leads(niche);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_favorite ON leads(favorite);
CREATE TABLE IF NOT EXISTS searches (
 id TEXT PRIMARY KEY, query TEXT NOT NULL, city TEXT NOT NULL, niches_json TEXT NOT NULL,
 source TEXT NOT NULL DEFAULT 'openstreetmap', status TEXT NOT NULL DEFAULT 'queued',
 total_found INTEGER NOT NULL DEFAULT 0, without_website INTEGER NOT NULL DEFAULT 0,
 processed_steps INTEGER NOT NULL DEFAULT 0, total_steps INTEGER NOT NULL DEFAULT 0,
 error TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS search_steps (
 id TEXT PRIMARY KEY, search_id TEXT NOT NULL REFERENCES searches(id) ON DELETE CASCADE,
 niche TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'queued', attempts INTEGER NOT NULL DEFAULT 0,
 error TEXT, UNIQUE(search_id, niche)
);
CREATE TABLE IF NOT EXISTS settings (
 key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS search_leads (
 search_id TEXT NOT NULL REFERENCES searches(id) ON DELETE CASCADE,
 lead_id TEXT NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
 PRIMARY KEY(search_id, lead_id)
);
