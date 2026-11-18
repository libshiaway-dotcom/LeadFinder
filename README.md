# LeadFinder

LeadFinder is a React + TypeScript frontend with a Cloudflare Worker API and Cloudflare D1 storage. The first real data adapter uses OpenStreetMap through Nominatim (city geocoding) and Overpass API (POI search). Yandex and 2GIS are intentionally not represented as active integrations until official API credentials and a suitable data-use license are configured.

## Current implementation

- Search one Russian city by one or more built-in niches, with progress stored in D1.
- Custom niche search uses a name match in OSM (results may be less accurate).
- OSM organizations are upserted by stable OSM element ID, preventing duplicates across repeat searches.
- Leads, favorites, notes, statuses, search history, and CSV export are persisted in D1.
- The UI distinguishes `not_listed_in_source` from an affirmative claim that a business has no website. Website URLs are not crawled or declared dead.
- WhatsApp links are generated only from plausible phone numbers. Telegram/VK/social links are shown only when present in OSM tags.

## Requirements

- Node.js 20+
- npm
- Cloudflare account and Wrangler CLI access
- GitHub account (for source control / deployment workflow)

## Run locally

```bash
npm install
npx wrangler d1 create leadfinder-db
```

Copy the returned database ID into `wrangler.toml` in place of `REPLACE_WITH_YOUR_D1_DATABASE_ID`, then initialize the local database:

```bash
npm run db:local
npm run dev
```

For local development, keep two terminals open. First build the static assets and run the Worker on port 8787:

```bash
npm run build
npx wrangler dev --port 8787
```

In the second terminal, run Vite on port 5173. Its `/api` requests are proxied to the Worker:

```bash
npm run dev
```

## Deploy to Cloudflare

1. Create a D1 database: `npx wrangler d1 create leadfinder-db`.
2. Put the returned ID in `wrangler.toml`.
3. Apply the schema: `npm run db:remote`.
4. Authenticate Wrangler: `npx wrangler login`.
5. Deploy: `npm run deploy`.

The Worker serves the built Vite assets and `/api/*` routes. Add your repository to GitHub and push the project. For repeat deployments, GitHub Actions can run `npm ci`, `npm run build`, and `npx wrangler deploy` after adding `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` as repository secrets. Never commit these secrets.

## API

- `GET /api/health`
- `GET /api/niches`
- `POST /api/searches` — `{ "city": "Казань", "niches": ["Барбершопы"] }`
- `POST /api/searches/:id/step` — process one niche; call sequentially until `status=completed`
- `GET /api/searches/:id`
- `GET /api/searches`
- `GET /api/leads?q=&city=&niche=&website=no|yes&favorite=1&limit=&offset=`
- `PATCH /api/leads/:id` — update `status`, `favorite`, or `notes`
- `DELETE /api/leads/:id`
- `GET /api/export.csv`

## Important production limitations

1. **No authentication is included yet.** Do not expose this deployment publicly with a writable database. Put Cloudflare Access in front of the app or add proper user authentication and per-user ownership before production.
2. Public Nominatim and Overpass instances are community services with usage policies, rate limits, and variable availability. This app processes searches sequentially and pauses between niche steps, but a commercial or nationwide high-volume deployment should use a permitted regional OSM extract and its own geocoder/Overpass infrastructure. Set `APP_CONTACT` in `wrangler.toml` to a real contact email/URL so the geocoder User-Agent identifies the operator.
3. OSM coverage is incomplete and varies by city and category. Phone, website, Telegram, VK, and address fields only appear when mapped in OSM.
4. `website_status=not_listed_in_source` means only that no website tag was found in the source. It does **not** prove that the business has no website. No website availability checker is implemented.
5. The current search supports one city per job. “All cities / all Russia” needs a curated city/region dataset and queued batch orchestration; it is not implemented as a pretend single search.
6. Yandex and 2GIS are shown as inactive connectors in Settings. Add them only with official credentials and licensing that explicitly permits the intended storage/use. Do not scrape map pages or bypass platform protections.
7. D1 and Workers have plan limits. Review Cloudflare's current quotas before running large jobs.

## Data attribution

OpenStreetMap data is © OpenStreetMap contributors and is available under the Open Database License (ODbL). Include attribution and follow ODbL obligations when publishing derived databases. See https://www.openstreetmap.org/copyright.
