---
name: pedobraz-pipeline-check
description: Diagnose and fix PedObraz news pipeline issues: check DB status, Temporal workflows, service health, and restart components.
---

# PedObraz News Pipeline Troubleshooting

Check pipeline status, identify stuck/failed items, verify Temporal workflows, and restart components as needed. For the PedObraz educational news automation system.

## Prerequisites

- `.env` file in project root with `SYSTEM_SUDO_PASSWORD`, `TIMEWEB_SSH_PASSWORD`, `TIMEWEB_SSH_USER`, `ROUTER_PASS`
- `news/.env` with `NEWS_DATABASE_URL` or construct it from DB credentials
- Python venv at `.venv/` with sqlalchemy, psycopg, temporalio

## Procedure

### Step 1: Check pipeline status (DB query)

```bash
cd /home/borm/VibeCoding/PedObraz
set -a; source .env; set +a
NEWS_DATABASE_URL="${NEWS_DATABASE_URL:-postgresql+ psycopg://news:change-me-news-postgres@192.168.122.1:15432/newsautomation}"
.venv/bin/python3 - <<'EOF'
import os, sys
os.environ.setdefault("NEWS_DATABASE_URL", "postgresql+psycopg://news:change-me-news-postgres@192.168.122.1:15432/newsautomation")
from sqlalchemy import create_engine, text
engine = create_engine(os.environ["NEWS_DATABASE_URL"])
with engine.connect() as conn:
    # Recent publications
    result = conn.execute(text("""
        SELECT id, status, current_stage, updated_at, title
        FROM publications
        WHERE updated_at > NOW() - INTERVAL '24 hours'
        ORDER BY updated_at DESC
        LIMIT 20
    """))
    for row in result:
        print(f"{row.id} | {row.status} | {row.current_stage} | {row.updated_at} | {row.title[:60]}")
    
    # Stuck items (processing > 30 min)
    stuck = conn.execute(text("""
        SELECT id, status, current_stage, updated_at
        FROM publications
        WHERE status = 'processing' AND updated_at < NOW() - INTERVAL '30 minutes'
        ORDER BY updated_at
    """))
    stuck_rows = list(stuck)
    if stuck_rows:
        print(f"\n⚠️ {len(stuck_rows)} STUCK items:")
        for row in stuck_rows:
            print(f"  {row.id} | {row.current_stage} | stuck since {row.updated_at}")
    else:
        print("\n✅ No stuck items")
EOF
```

### Step 2: Check Temporal workflows

```bash
cd /home/borm/VibeCoding/PedObraz
set -a; source .env; set +a
.venv/bin/python3 - <<'EOF'
import asyncio
from temporalio.client import Client

async def main():
    client = await Client.connect("192.168.122.1:7233")
    # List running workflows
    async for wf in client.list_workflows():
        print(f"{wf.id} | {wf.workflow_type} | {wf.status}")

asyncio.run(main())
EOF
```

### Step 3: Check service health

```bash
# Check if temporal worker is running
PASS=$(grep '^SYSTEM_SUDO_PASSWORD=' .env | cut -d= -f2- | tr -d '"')
printf '%s\n' "$PASS" | sudo -S -p '' systemctl status pedobraz-news-temporal-gpu1060-vm.service 2>/dev/null | head -15

# Check llama.cpp server
printf '%s\n' "$PASS" | sudo -S -p '' systemctl status pedobraz-llamacpp-heavy.service 2>/dev/null | head -15

# Check if DB is reachable
PGPASSWORD=change-me-news-postgres psql -h 192.168.122.1 -p 15432 -U news -d newsautomation -c "SELECT 1;" 2>&1
```

### Step 4: Restart if needed

```bash
# Restart temporal worker
PASS=$(grep '^SYSTEM_SUDO_PASSWORD=' .env | cut -d= -f2- | tr -d '"')
printf '%s\n' "$PASS" | sudo -S -p '' systemctl restart pedobraz-news-temporal-gpu1060-vm.service

# Restart llama.cpp
printf '%s\n' "$PASS" | sudo -S -p '' systemctl restart pedobraz-llamacpp-heavy.service
```

### Step 5: Trigger pipeline manually (if needed)

```bash
cd /home/borm/VibeCoding/PedObraz
set -a; source .env; set +a; source news/.env 2>/dev/null
NEWS_DATABASE_URL="postgresql+psycopg://news:change-me-news-postgres@192.168.122.1:15432/newsautomation" \
PIPELINE_RUNTIME_MODE=distributed_active \
NEWS_PIPELINE_PROFILE=production \
.venv/bin/python -c "
import sys; sys.path.insert(0, '.')
from news.automation.runtime import create_runtime
from news.automation.pipeline import run_pipeline
import asyncio
asyncio.run(run_pipeline(create_runtime()))
"
```

## Common Issues

| Symptom | Likely cause | Fix |
|---|---|---|
| No publications for hours | Temporal worker crashed | Restart `pedobraz-news-temporal-gpu1060-vm.service` |
| Items stuck in "processing" | Worker lost connection or OOM | Restart worker, check dmesg for OOM |
| llama_down alert | GPU process crashed | Restart `pedobraz-llamacpp-heavy.service` |
| DB connection refused | PostgreSQL container down | Check docker: `docker compose -f news/docker-compose.yml ps` |
| Telegram bot not sending | Router/network issue | Check router config, SSH to router |
| All materials in "новости" | Category routing broken | Check `news/automation/routing.py` logic |

## Router SSH (for network issues)

```bash
cd /home/borm/VibeCoding/PedObraz
set -a; source <(grep -E '^ROUTER_' .env); set +a
SSH="sshpass -p $ROUTER_PASS ssh -o StrictHostKeyChecking=no -o ConnectTimeout=8 -o UserKnownHostsFile=/dev/null root@10.1.1.1"
$SSH "cat /etc/config/podkop" 2>/dev/null
```

## Monitoring Alerts

If a Monit alert arrives (e.g., `[llama_down]`), the typical response is:
1. Check service status
2. Restart the failed service
3. Wait ~90s for model reload
4. Verify health endpoint returns OK
