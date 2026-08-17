# Redis Persistence For BullMQ

Redis is not the database of record, but BullMQ depends on it for queues, retries, delayed jobs, and stalled job recovery.

## Recommended Settings

```conf
appendonly yes
appendfsync everysec

save 900 1
save 300 10
save 60 10000

maxmemory-policy noeviction
```

## Production Guidance

- Prefer managed Redis with Multi-AZ failover.
- Enable automatic backups.
- Monitor memory, fragmentation, command latency, and rejected connections.
- Do not use an eviction policy that can delete BullMQ queue keys.
- Keep message payloads small and load full records from PostgreSQL by ID.

## Recovery

If Redis is lost, rebuild pending queue jobs from PostgreSQL:

```sql
SELECT id
FROM outbound_messages
WHERE status IN ('queued', 'processing')
   OR (status = 'failed' AND next_retry_at <= now());
```

Re-enqueue each returned `id` into `message-send-queue`.
