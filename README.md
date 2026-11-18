# Shared database and Umami

This directory is retained because its Docker Compose project owns the shared
PostgreSQL container, database volume, Docker network and Umami instance used
by the other personal services.

The GoAccess / Traffic Report feature was retired on 2026-11-18 at the
operator's request. Its report generator, cron entry, `/traffic/` nginx route,
site-index entry and status checks have been removed.

## Running services

- `traffic-monitor-db-1`: shared PostgreSQL, including the photo diary database.
- `traffic-monitor-umami-1`: analytics dashboard at `/umami/`.
- `traffic-monitor_default`: network shared by the remaining applications.

Do not delete this directory or remove its database volume when cleaning up the
retired report feature. `.env` contains private runtime configuration and must
not be committed.
