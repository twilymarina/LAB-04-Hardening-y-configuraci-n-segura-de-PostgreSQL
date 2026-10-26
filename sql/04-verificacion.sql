SHOW listen_addresses;
SHOW password_encryption;
SHOW log_connections;
SHOW log_disconnections;
SHOW idle_in_transaction_session_timeout;
SHOW statement_timeout;
SHOW ssl;
SHOW ssl_min_protocol_version;

SELECT rule_number, line_number, type, database, user_name, address, netmask, auth_method, error
FROM pg_hba_file_rules;

SELECT rule_number, type, database, user_name, address, netmask
FROM pg_hba_file_rules
WHERE address IN ('0.0.0.0', '::') OR netmask IN ('0.0.0.0', '::');

SELECT rolname FROM pg_roles WHERE rolsuper AND rolcanlogin;

SELECT pid, usename, client_addr, ssl, version, cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();
