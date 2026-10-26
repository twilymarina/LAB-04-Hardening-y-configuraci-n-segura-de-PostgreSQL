ALTER SYSTEM SET password_encryption = 'scram-sha-256';

ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;

ALTER SYSTEM SET idle_in_transaction_session_timeout = '5min';
ALTER SYSTEM SET statement_timeout = '60s';

ALTER SYSTEM SET ssl_min_protocol_version = 'TLSv1.2';

ALTER SYSTEM SET listen_addresses = 'localhost,10.10.10.20';

SELECT pg_reload_conf();
