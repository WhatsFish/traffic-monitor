# Traffic Monitor

A small self-hosted analytics stack for [WhatsFish/personal-site](https://github.com/WhatsFish/personal-site),
running on the same Azure VM and exposed under the existing public IP via Nginx
reverse proxy.

Two complementary tools:

| Tool       | What it answers                                         | Source of truth        |
| ---------- | ------------------------------------------------------- | ---------------------- |
| Umami      | Visitor behavior: pageviews, sessions, browsers, refs   | JS snippet on the site |
| GoAccess   | Raw HTTP traffic: every request, status code, bytes     | Nginx access log       |

Umami needs a one-line script tag in the blog. GoAccess needs nothing — it just
reads `/var/log/nginx/*.access.log`.

## Layout

```
traffic-monitor/
├── docker-compose.yml      Umami + Postgres
├── .env.example            Copy to .env and fill in
├── nginx/
│   └── traffic-monitor.conf  Snippet to include in the main site server block
├── goaccess/
│   ├── goaccess.conf       GoAccess config (log format, output path)
│   ├── run-report.sh       Generate / refresh report/index.html
│   └── report/             Generated HTML (gitignored)
└── scripts/
    └── install-cron.sh     Install a cron entry to refresh the report
```

## Endpoints

Both are proxied through the existing Nginx on port 80:

- `http://<host>/analytics/`  → Umami dashboard
- `http://<host>/traffic/`    → GoAccess HTML report

## Quick start

```bash
cd ~/src/traffic-monitor
cp .env.example .env
# edit .env if you want to change the Postgres password / Umami secret
docker compose up -d

# Generate the GoAccess report once, then install the cron job
./goaccess/run-report.sh
./scripts/install-cron.sh

# Wire it into Nginx (one-time)
sudo ln -sf "$PWD/nginx/traffic-monitor.conf" /etc/nginx/snippets/traffic-monitor.conf
# Then add `include snippets/traffic-monitor.conf;` inside the
# personal-site server block (see nginx/README inside the file) and reload:
sudo nginx -t && sudo systemctl reload nginx
```

After the stack is up, log in to Umami at `/analytics/` with the default
admin / umami credentials and **change the password immediately**, then create
a website entry and copy the tracker snippet into the blog template.

## Why these choices

- **Docker Compose** keeps Postgres and Node out of the host package set; I can
  blow the whole stack away with `docker compose down -v`.
- **Subpath routing** avoids needing a new inbound rule in the Azure NSG —
  port 80 is already open and the existing Nginx fronts everything.
- **No geo lookup** for now. MaxMind/GeoLite2 needs a (free) license file and
  daily updates; not worth it until I actually have traffic.
- **Two layers, on purpose.** Umami sees only what the JS snippet sees (and
  ad-blockers may strip it). The Nginx log sees every byte. They cross-check
  each other.

## Security notes

- The Umami default `admin/umami` credentials must be rotated on first login.
- The GoAccess HTML report is served from a static directory. If you do not
  want the world to see your raw traffic, restrict `/traffic/` in Nginx with
  `auth_basic` (see commented block in `nginx/traffic-monitor.conf`).
- `.env` is gitignored. Never commit it.
