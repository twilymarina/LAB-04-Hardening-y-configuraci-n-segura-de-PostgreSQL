SELECT version();

SHOW port;
SHOW listen_addresses;
SHOW ssl;
SHOW password_encryption;

SELECT pid, usename, datname, client_addr, client_port, application_name
FROM pg_stat_activity;

SHOW config_file;
SHOW hba_file;
SHOW ident_file;
SHOW data_directory;
SHOW log_directory;
SHOW log_connections;
SHOW log_disconnections;

SELECT rule_number, line_number, type, database, user_name, address, netmask, auth_method, error
FROM pg_hba_file_rules;

SHOW max_connections;
SHOW superuser_reserved_connections;
SHOW statement_timeout;
SHOW idle_in_transaction_session_timeout;
