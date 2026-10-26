# Registro de cambios — LAB-04

## Respaldo previo

```bash
sudo cp /etc/postgresql/16/main/postgresql.conf /etc/postgresql/16/main/postgresql.conf.bak-$(date +%F)
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.bak-$(date +%F)
```

## Cambio 1 — listen_addresses
- **Antes:** `*` (todas las interfaces)
- **Después:** `localhost,10.10.10.20`
- **Justificación:** solo se escucha en las interfaces que la aplicación necesita.
- **Requiere reinicio:** sí.
- **Verificación:** `SHOW listen_addresses;` y `ss -lnt | grep 5432`.

## Cambio 2 — pg_hba.conf
- **Regla anterior:** `host all all 0.0.0.0/0 scram-sha-256`
- **Regla nueva:**

```
# TIPO    BASE_DE_DATOS    USUARIO         ORIGEN           MÉTODO
local     all              postgres                         peer
hostssl   basedatos_app    app_user        10.10.10.0/24    scram-sha-256
hostssl   basedatos_app    consulta_user   10.10.10.0/24    scram-sha-256
hostssl   all              dba_user        10.10.10.0/24    scram-sha-256
```

- **Justificación:** base de datos + usuario + origen + método, lo más específico posible.
- **Aplicación:** `SELECT pg_reload_conf();`
- **Verificación:** consulta `pg_hba_file_rules` y prueba una conexión permitida y una denegada.

## Cambio 3 — Cuentas
- **Antes:** la aplicación se conectaba con una cuenta administrativa.
- **Después:** `app_user` (mínimos), `consulta_user` (solo lectura), `dba_user` (administración).
- **Justificación:** mínimo privilegio; si la aplicación se compromete, el daño queda limitado.

## Cambio 4 — Registro y límites
- `log_connections = on`, `log_disconnections = on`
- `idle_in_transaction_session_timeout = 5min`
- `statement_timeout = 60s`
- **Justificación:** permite detectar accesos sospechosos y evita el consumo indefinido de recursos.

## Cambio 5 — Permisos del sistema operativo
- **Antes:** permisos sin revisar; los archivos de configuración podían ser legibles por otros usuarios (`-rw-r--r-- postgres postgres`).
- **Después:** directorio de datos `drwx------ postgres postgres`, archivos de configuración `-rw------- postgres postgres`.

```bash
sudo chmod 700 /var/lib/postgresql/16/main
sudo chmod 600 /etc/postgresql/16/main/postgresql.conf /etc/postgresql/16/main/pg_hba.conf
sudo chown postgres:postgres /var/lib/postgresql/16/main /etc/postgresql/16/main/postgresql.conf /etc/postgresql/16/main/pg_hba.conf
```

- **Justificación:** evita que otros usuarios del sistema lean la configuración o los datos.

## Cambio 6 — TLS
- **Antes:** disponible, pero no exigido en las reglas de acceso.
- **Después:** exigido con reglas `hostssl` y `ssl_min_protocol_version = TLSv1.2`.
- **Justificación:** protege credenciales y datos en tránsito.
