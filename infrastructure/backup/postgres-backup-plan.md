# PostgreSQL Backup And Disaster Recovery

Use managed PostgreSQL backups when available. For self-managed PostgreSQL, use WAL-G or pgBackRest with encrypted S3-compatible storage.

## Schedule

- Continuous: archive WAL files for point-in-time recovery.
- Daily: full backup.
- Every 1-6 hours: incremental backup if database size requires faster restore.
- Weekly: restore the latest backup into staging and run smoke checks.
- Monthly: disaster recovery drill and RTO/RPO measurement.

## Target Defaults

- RPO: 5 minutes or less.
- RTO: 30-120 minutes, depending on database size.
- Hot retention: 30 days.
- Cold retention: 90-180 days.

## PostgreSQL Settings

```conf
wal_level = replica
archive_mode = on
archive_command = 'wal-g wal-push %p'
archive_timeout = 60
```

## WAL-G Environment

```bash
export WALG_S3_PREFIX=s3://company-postgres-backups/prod
export AWS_REGION=ap-south-1
export WALG_COMPRESSION_METHOD=brotli
```

## Commands

```bash
wal-g backup-push /var/lib/postgresql/data
wal-g backup-list
wal-g backup-fetch /var/lib/postgresql/data LATEST
```

## Restore Drill

1. Provision a clean PostgreSQL instance.
2. Fetch the latest base backup.
3. Replay WAL to the chosen timestamp.
4. Run application migrations.
5. Verify users, campaigns, outbound messages, and recent delivery logs.
6. Record actual restore time and any manual steps.
