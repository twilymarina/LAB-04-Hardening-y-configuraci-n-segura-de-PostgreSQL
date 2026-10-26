SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin
FROM pg_roles
ORDER BY rolname;

SELECT extname, extversion
FROM pg_extension
ORDER BY extname;

CREATE ROLE app_user LOGIN PASSWORD 'App#Lab04_Seg2026'
  NOSUPERUSER NOCREATEDB NOCREATEROLE;
GRANT CONNECT ON DATABASE basedatos_app TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_user;

CREATE ROLE consulta_user LOGIN PASSWORD 'Consulta#Lab04_Seg2026'
  NOSUPERUSER NOCREATEDB NOCREATEROLE;
GRANT CONNECT ON DATABASE basedatos_app TO consulta_user;
GRANT USAGE ON SCHEMA public TO consulta_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO consulta_user;

CREATE ROLE dba_user LOGIN PASSWORD 'Dba#Lab04_Seg2026'
  CREATEROLE CREATEDB;
