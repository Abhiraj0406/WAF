# WAF Project

This project implements a working open-source Web Application Firewall lab using `Nginx + ModSecurity + OWASP CRS`, with custom rules, live monitoring, audit analysis, performance testing, and blocking-mode verification.

## Stack

- `backend`: demo web app behind the WAF
- `waf`: Nginx + ModSecurity + OWASP CRS
- `nginx-exporter`: Prometheus exporter for WAF metrics
- `prometheus`: metrics collection and alert rules
- `grafana`: dashboard UI
- `k6`: on-demand performance testing service

## Current Structure

```text
WAF/
  .env.example
  .gitignore
  docker-compose.yml
  README.md
  configs/
    modsecurity/
      README.md
      rules/
        .gitkeep
    monitoring/
      grafana/
        dashboards/
          waf-overview.json
        provisioning/
          dashboards/
            dashboard.yml
          datasources/
            prometheus.yml
      prometheus/
        alerts.yml
        prometheus.yml
    nginx-templates/
      location_common.conf.template
      modsecurity-override.conf.template
  logs/
    .gitkeep
  performance/
    load-test.js
  scripts/
    analyze-audit.ps1
    run-performance-test.ps1
    start-lab.ps1
    test-blocking-mode.ps1
    test-lab.ps1
```

## What Is Working

- WAF traffic is served on `http://127.0.0.1:8080`
- ModSecurity runs with OWASP CRS in `DetectionOnly` by default
- Local verification, high-value path, and CSRF-style rules are loaded through `modsecurity-override.conf`
- SQLi and XSS detections are visible in `logs/modsec_audit.log`
- Prometheus scrapes the WAF exporter successfully
- Grafana provisions a `WAF Overview` dashboard automatically
- `k6` performance tests compare direct backend traffic with WAF-fronted traffic
- Blocking mode is verified with an automated `403` probe test

## Ports

- WAF: `8088`
- Prometheus exporter: `9113`
- Prometheus: `9090`
- Grafana: `3000`

These are configurable through `.env`.

## First Run

1. Copy `.env.example` to `.env`
2. Change `GRAFANA_ADMIN_PASSWORD`
3. Start the stack:

```powershell
docker compose up -d
```

Or:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-lab.ps1
```

## Main Commands

Start the lab:

```powershell
docker compose up -d
```

Stop the lab:

```powershell
docker compose down
```

Check services:

```powershell
docker compose ps
```

Test normal and attack traffic:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-lab.ps1
```

Analyze audit events:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\analyze-audit.ps1
```

Run performance comparison:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-performance-test.ps1
```

Verify blocking mode:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-blocking-mode.ps1
```

## Monitoring

Prometheus:

```text
http://127.0.0.1:9090
```

Grafana:

```text
http://127.0.0.1:3000
```

Default Grafana credentials come from `.env`:

- user: `GRAFANA_ADMIN_USER`
- password: `GRAFANA_ADMIN_PASSWORD`

Provisioned dashboard:

- `WAF Overview`

## Verification Workflow

1. Use `test-lab.ps1` to generate clean and suspicious requests.
2. Use `analyze-audit.ps1` to confirm rule hits and targeted URIs.
3. Open Grafana to watch request and connection metrics.
4. Run `run-performance-test.ps1` to compare backend-direct vs WAF-fronted traffic.
5. Run `test-blocking-mode.ps1` to verify the WAF enforces `403` in blocking mode and then returns to detection mode.

## Current Performance Snapshot

From the latest verified run:

- backend direct avg latency: about `0.91 ms`
- WAF fronted avg latency: about `5.58 ms`
- added average latency: about `4.67 ms`
- backend direct p95 latency: about `1.79 ms`
- WAF fronted p95 latency: about `14.05 ms`
- added p95 latency: about `12.26 ms`
- both paths completed with `0` request failures in the smoke test

## Configuration Notes

- Detection mode is controlled by `MODSEC_RULE_ENGINE` in `.env`
- Local ModSecurity rules are injected through:
  [modsecurity-override.conf.template](e:\Desktop\WAF\configs\nginx-templates\modsecurity-override.conf.template)
- Metrics endpoint allowlist is controlled through:
  [location_common.conf.template](e:\Desktop\WAF\configs\nginx-templates\location_common.conf.template)
- Monitoring configuration lives under:
  [configs](e:\Desktop\WAF\configs)

## Next Recommended Work

- replace demo backend with the real target application
- tune CRS exclusions for application-specific false positives
- rotate Grafana credentials from defaults immediately
- add alertmanager or notification routing if you want alert delivery beyond Prometheus rules
- add staging and production environment overlays if this moves beyond the lab
