# ModSecurity Configuration Area

This directory will hold custom WAF configuration layered on top of OWASP CRS.

## Planned Layout

```text
configs/modsecurity/
  README.md
  rules/
    REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
    RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
    custom/
      410-app-sqli.conf
      420-app-xss.conf
      430-app-csrf.conf
```

## Usage Plan

- Keep vendor CRS behavior as close to upstream as possible.
- Store only local exclusions and custom rules here.
- Promote rule changes from lab to staging to production through version control.
- Favor narrowly scoped exclusions over disabling broad CRS protections.
