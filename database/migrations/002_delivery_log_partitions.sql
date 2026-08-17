DO $$
DECLARE
  start_month DATE := date_trunc('month', now())::date;
  partition_start DATE;
  partition_end DATE;
  partition_name TEXT;
BEGIN
  FOR month_offset IN 0..12 LOOP
    partition_start := start_month + (month_offset || ' months')::interval;
    partition_end := partition_start + interval '1 month';
    partition_name := 'delivery_logs_' || to_char(partition_start, 'YYYY_MM');

    EXECUTE format(
      'CREATE TABLE IF NOT EXISTS %I PARTITION OF delivery_logs FOR VALUES FROM (%L) TO (%L)',
      partition_name,
      partition_start,
      partition_end
    );

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON %I(user_id, received_at DESC)',
      partition_name || '_user_time_idx',
      partition_name
    );

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON %I(outbound_message_id)',
      partition_name || '_message_idx',
      partition_name
    );

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON %I(provider_message_id)',
      partition_name || '_provider_idx',
      partition_name
    );
  END LOOP;
END $$;
