# AGENTS — How to work with this repository

Checklist for an AI coding agent working here:
- [ ] Read `README.md` and `config/squid.conf` for high-level behavior and ACLs
- [ ] Use the three-step script flow: `1_build_squid.sh` → `2_setup_squid.sh` → `3_start_squid.sh`
- [ ] Avoid touching `squid-ca.key` unless implementing explicit CA-related tooling
- [ ] Use Docker volumes and host networking patterns in `docker-compose.yml` when testing

Quick start (core commands you will need):
- Build image: `./1_build_squid.sh` (or `docker build -t squid-ssl-arm64 .`)
- Setup dirs & cert DB: `./2_setup_squid.sh`
- Start service: `./3_start_squid.sh start`
- Reload config: `docker exec squid-proxy squid -k reconfigure`
- View logs/stats: `./3_start_squid.sh logs` / `./3_start_squid.sh stats`

Project layout (important files and why they matter):
- `config/squid.conf` — authoritative source of behavior: ports, SSL bumping rules, ACLs, cache limits, upstream peers.
- `config/storeid.conf` — store-id deduplication rules; key to improving cache hit rates by stripping query strings for static assets.
- `docker-compose.yml` & `Dockerfile` — container config uses host networking and persistent volumes; agents must preserve mount paths when testing.
- `squid-ca.crt` / `squid-ca.key` (and `old/`) — CA materials for dynamic cert generation. Treat `squid-ca.key` as sensitive; do not expose or regenerate casually.
- `1_build_squid.sh`, `2_setup_squid.sh`, `3_start_squid.sh` — canonical developer workflow scripts (build, prepare runtime directories & cert DB, control lifecycle).
- `install_ca.bat`, `install_ca.sh`, `windows-10-installation.bat` — helper install scripts for client CA installation; useful for Windows-focused testing.

Patterns and conventions an agent must follow (concrete, repository-specific):
- Three-step script workflow: tests/changes should be reproducible by running the three scripts in order rather than ad-hoc container rebuilds.
- Use `ssl_db` initialization via `security_file_certgen` (see `README.md` lines showing `-c -s /var/lib/squid/ssl_db/ssl_db -M 16MB`). If you modify certificate logic, update `2_setup_squid.sh` accordingly.
- No-bump domains are enumerated in `config/squid.conf` (search for `acl no_bump_domains dstdomain`). These domains are explicitly spliced — do not attempt to inspect them in code changes unless the change mentions privacy implications.
- Store-id rules live in `config/storeid.conf` and are regex-driven. Any change to caching logic must reference that file and explain hit-rate implications.
- Logging and rotation are configured in `squid.conf` and expected to be checked with `./3_start_squid.sh logs` — debugging steps should prefer log analysis + `squidclient` for cache info.

Integration points and external dependencies:
- Upstream proxy (optional) typically at `192.168.88.100:10808` (V2Ray). Look in `config/squid.conf` for `cache_peer` entries.
- DNS: `dns_nameservers` set in `config/squid.conf` (1.1.1.1, 8.8.8.8). If adding DNS changes, validate network reachability inside container.
- Host volumes: `/srv/appdata/squid` layout is expected by scripts and `docker-compose.yml` (config, cache, ssl, ssl_db, logs). Tests must mount or mock these paths.

Testing & debugging recommendations (project-specific):
- Reinitialize cert DB when debugging SSL issues: see README example using `security_file_certgen` and `squid -k reconfigure`.
- Check cache behavior with `squidclient` and `curl` via proxy (`curl -x http://192.168.88.110:3128 ...`).
- Use `docker exec squid-proxy` for in-container troubleshooting (logs in `/var/log/squid/`).
- When changing cache sizing or replacement policy, update `config/squid.conf` and run `docker exec squid-proxy squid -k reconfigure` rather than full container rebuild unless directories or DB schema changed.

Safety & operational constraints:
- Never commit private key material (`squid-ca.key`) to remote or public remotes. If you must modify CA handling, create tests that mock the key usage rather than using real keys.
- Preserve ACLs restricting access to `192.168.88.0/24` unless explicitly expanding test networks; the CI/dev environment expects local network constraints.

Guidance for PRs and code changes:
- Small, targeted changes are preferred: update `squid.conf` and `storeid.conf` together when touching caching/ACL logic.
- Include reproduction steps in PR body that use the three scripts and the minimal `docker compose` commands from `README.md`.
- Cite `README.md` snippets (e.g., cert DB init and `no_bump_domains`) when the change affects runtime behavior.

Where to look next (file pointers to inspect while coding):
- `README.md` (root) — workflow examples and debug commands
- `config/squid.conf` — main logic
- `config/storeid.conf` — cache dedup rules
- `1_build_squid.sh`, `2_setup_squid.sh`, `3_start_squid.sh` — developer scripts
- `docker-compose.yml`, `Dockerfile` — containerization details

Minimal examples to copy-paste when automating tests or reproducing locally:
- Initialize cert DB (from README):
  docker run --rm -v "$PWD/ssl_db:/var/lib/squid/ssl_db" -v "$PWD/cache:/var/spool/squid" squid-ssl-arm64 bash -c '/usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db/ssl_db -M 16MB && squid -z'

- Reload config without restart:
  docker exec squid-proxy squid -k reconfigure

---

Last updated: May 2026 — Author: Younes Rahimi
