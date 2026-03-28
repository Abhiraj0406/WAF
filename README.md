# WAF Project

This project is a practical Web Application Firewall lab built with open-source tools. It puts an `OWASP ModSecurity CRS` WAF in front of a sample backend using `Nginx`, so you can start testing, tuning, and extending real web attack protections such as SQL injection, XSS, and basic CSRF-related request checks.

## What the Project Does

- Runs a backend demo application in Docker.
- Runs a WAF proxy in front of that backend.
- Uses `ModSecurity` with the `OWASP Core Rule Set (CRS)`.
- Loads local custom rules from this repository.
- Writes audit and error logs to the local `logs/` folder.
- Gives you simple PowerShell scripts to start and test the lab.

Right now, the WAF starts in `DetectionOnly` mode, which means it is meant for safe tuning first. The custom rules are already wired into the container config so the project is ready for further hardening and testing.

## Current Folder Structure

```text
WAF/
  .gitignore
  docker-compose.yml
  README.md
  configs/
    modsecurity/
      custom-before.conf
      custom-after.conf
      README.md
      rules/
        .gitkeep
    monitoring/
      .gitkeep
    nginx-templates/
      setup.conf.template
  logs/
    .gitkeep
    modsec_audit.log
    modsec_error.log
  scripts/
    start-lab.ps1
    test-lab.ps1
```

## Main Files

- `docker-compose.yml`
  Starts the backend service and the WAF service.

- `configs/modsecurity/custom-before.conf`
  Pre-CRS tuning and request-allowance settings.

- `configs/modsecurity/custom-after.conf`
  Local custom detection rules for high-value paths, SQLi, XSS, and state-changing requests without `Origin` and `Referer`.

- `configs/nginx-templates/setup.conf.template`
  ModSecurity include template so the container loads the local custom rule files.

- `logs/modsec_audit.log`
  JSON audit log written by ModSecurity.

- `logs/modsec_error.log`
  Error and warning log for the WAF service.

- `scripts/start-lab.ps1`
  Starts the Docker lab and shows container status.

- `scripts/test-lab.ps1`
  Sends normal and suspicious test requests to the WAF.

## Requirements

- Windows with PowerShell
- Docker Desktop installed
- Docker Desktop running
- Port `8080` free on the host

Check Docker:

```powershell
docker --version
docker compose version
docker info
```

## How To Run The Project

From the project root:

```powershell
docker compose up -d
docker compose ps
```

Or use the helper script:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-lab.ps1
```

When the stack is running:

- WAF endpoint: `http://127.0.0.1:8080/`
- WAF container name: `waf-waf-1`
- Backend container name: `waf-backend-1`

Stop the project:

```powershell
docker compose down
```

## How To Use The Project

### 1. Check normal traffic

```powershell
curl.exe -i http://127.0.0.1:8080/
```

You should get the backend response through the WAF.

### 2. Send suspicious requests

```powershell
curl.exe -i "http://127.0.0.1:8080/?test=%3Cscript%3Ealert(1)%3C%2Fscript%3E"
curl.exe -i "http://127.0.0.1:8080/?id=1%20OR%201=1"
```

Or run the test script:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-lab.ps1
```

### 3. View WAF logs

Container logs:

```powershell
docker compose logs -f waf
```

Audit log on disk:

```powershell
Get-Content .\logs\modsec_audit.log -Tail 50
```

Error log on disk:

```powershell
Get-Content .\logs\modsec_error.log -Tail 50
```

## Current WAF Behavior

- Backend is proxied through the WAF on port `8080`.
- `ModSecurity` is enabled.
- `OWASP CRS` is enabled.
- Audit logging is enabled in JSON format.
- Local custom rules are included through the Nginx template override.
- Current rule engine mode is `DetectionOnly`.

That means this project is currently best used for:
- lab validation,
- rule testing,
- false-positive tuning,
- preparing for later enforcement with `MODSEC_RULE_ENGINE: "On"`.

## How To Change The Project

### Update the backend target

In [docker-compose.yml](e:\Desktop\WAF\docker-compose.yml), change:

```yaml
BACKEND: http://backend:80
```

Examples:

- Another Compose service:
  `http://myapp:3000`
- Host machine app:
  `http://host.docker.internal:8081`
- Internal server:
  `http://10.0.0.50:80`

Then restart:

```powershell
docker compose up -d
```

### Update custom rules

Edit:

- [custom-before.conf](e:\Desktop\WAF\configs\modsecurity\custom-before.conf)
- [custom-after.conf](e:\Desktop\WAF\configs\modsecurity\custom-after.conf)

Then recreate the stack:

```powershell
docker compose up -d --force-recreate
```

### Switch from detection to blocking

In [docker-compose.yml](e:\Desktop\WAF\docker-compose.yml), change:

```yaml
MODSEC_RULE_ENGINE: DetectionOnly
```

to:

```yaml
MODSEC_RULE_ENGINE: "On"
```

Then restart:

```powershell
docker compose up -d --force-recreate
```

Do this only after you are comfortable with the rule behavior.

## Troubleshooting

### Docker is installed but not working

Start Docker Desktop, then check:

```powershell
docker info
```

### Port 8080 is already in use

Change the published port in [docker-compose.yml](e:\Desktop\WAF\docker-compose.yml):

```yaml
ports:
  - "8081:8080"
```

Then access the WAF at `http://127.0.0.1:8081/`.

### Containers start but traffic does not work

Check:

```powershell
docker compose ps
docker compose logs --tail=100 waf
docker compose logs --tail=100 backend
```

### Logs are empty or incomplete

Check:

```powershell
Get-Content .\logs\modsec_audit.log -Tail 100
Get-Content .\logs\modsec_error.log -Tail 100
```

## Next Implementation Steps

- Tighten end-to-end verification for external request audit visibility.
- Add stronger app-specific rules and exclusions.
- Point the WAF to a real application backend.
- Add monitoring dashboards and metrics collection.
- Move from `DetectionOnly` to controlled blocking mode.
