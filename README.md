# LAB-04 — Hardening y configuración segura de PostgreSQL

## Objetivo
Aplicar un proceso básico de hardening a PostgreSQL 16 en un entorno académico aislado: identificar configuraciones inseguras, reducir la superficie de exposición y documentar una línea base de seguridad, comparando el estado inicial con el estado posterior.

## Entorno
- **Motor:** PostgreSQL 16
- **Sistema operativo:** Linux (Ubuntu Server)
- **Servidor / IP:** 10.10.10.20, puerto 5432
- **Base de datos de laboratorio:** basedatos_app
- **Cliente:** psql
- **Alcance:** entorno académico aislado, sin servidores institucionales ni de producción.

## Superficie de ataque inicial

| Elemento | Estado actual | ¿Es necesario? | Riesgo |
|----------|---------------|----------------|--------|
| Puerto PostgreSQL | 5432, accesible desde una red demasiado amplia | Sí, pero limitado por firewall a redes autorizadas | Exposición del servicio a escaneo y fuerza bruta |
| Interfaces de escucha | Todas las interfaces (`listen_addresses = '*'`) | Solo localhost y la IP privada de la aplicación | Escuchar en interfaces innecesarias amplía la superficie |
| Conexiones remotas | Aceptadas desde cualquier origen | Solo desde la red autorizada 10.10.10.0/24 | Acceso desde redes no confiables |
| Usuarios administrativos | Cuentas administrativas usadas en algunas conexiones | Pocas, nominales y solo para administración | Una cuenta comprometida da control total |
| SSL/TLS | Disponible, sin exigirse en las reglas de acceso | Sí, para toda conexión remota | Credenciales y datos expuestos en tránsito |
| Métodos de autenticación | Reglas amplias en `pg_hba.conf` | scram-sha-256 con reglas específicas | Reglas permisivas facilitan accesos indebidos |

## Hallazgos
- PostgreSQL escuchaba en todas las interfaces, aunque la aplicación solo necesita una.
- El puerto 5432 estaba disponible desde una red demasiado amplia.
- `pg_hba.conf` contenía reglas permisivas (todas las bases, todos los usuarios, rangos como `0.0.0.0/0`).
- Algunas conexiones utilizaban cuentas administrativas en lugar de cuentas con privilegios mínimos.
- No existía documentación de la configuración segura, checklist de hardening ni política de actualización.
- Los archivos de configuración y el directorio de datos no habían sido revisados.
- No se conocía con precisión qué conexiones remotas eran realmente necesarias.

## Cambios realizados
El detalle de cada cambio, con su estado antes y después, está en `configuracion/cambios.md`. En resumen:

1. Se limitó `listen_addresses` a `localhost` y a la IP privada necesaria.
2. Se reemplazaron las reglas amplias de `pg_hba.conf` por reglas específicas con `hostssl` y `scram-sha-256`.
3. Se separaron las cuentas en DBA, aplicación y consulta, con mínimo privilegio.
4. Se activó el registro de conexiones y desconexiones.
5. Se definieron límites de sesión (`idle_in_transaction_session_timeout` y `statement_timeout`).
6. Se restringieron los permisos de los archivos de configuración y del directorio de datos.
7. Se documentó una regla de firewall que permite 5432 solo desde la red autorizada.

## Justificación de los cambios
- **Restringir `listen_addresses`:** el servidor solo escucha donde la aplicación realmente se conecta, lo que reduce la exposición.
- **Reglas específicas en `pg_hba.conf`:** cada acceso queda limitado por base de datos, usuario, origen y método, en lugar de permitir todo desde cualquier lugar.
- **Separar cuentas:** aplica el principio de mínimo privilegio y limita el daño si una cuenta de aplicación se compromete.
- **Registro de conexiones y timeouts:** permite detectar accesos sospechosos y evita el consumo indefinido de recursos.
- **Permisos del sistema operativo:** protege la configuración y los datos aunque alguien intente eludir los controles de PostgreSQL.
- **Firewall:** actúa como capa complementaria a `pg_hba.conf`; bloquea el tráfico antes de que llegue al servicio.

## Verificación
Con `sql/04-verificacion.sql` y los comandos del sistema operativo se comprobó que:

- `listen_addresses` quedó limitado a las interfaces necesarias.
- Ninguna regla de `pg_hba.conf` usa `0.0.0.0/0` ni `::/0`.
- `password_encryption` es `scram-sha-256`.
- Las conexiones y desconexiones se registran en el log.
- Las sesiones tienen límites de tiempo configurados.
- Una conexión desde el origen autorizado funciona y una desde un origen no autorizado es rechazada.
- La aplicación no usa cuentas SUPERUSER.
- Los archivos de configuración y el directorio de datos no son legibles por otros usuarios del sistema.

Las capturas correspondientes están en `evidencias/`.

## Checklist de hardening

| # | Control | Verificado | Evidencia |
|---|---------|------------|-----------|
| 1 | Puerto documentado | ☑ | 01-superficie-ataque.png |
| 2 | Interfaces de escucha justificadas | ☑ | 02-listen-addresses.png |
| 3 | pg_hba.conf revisado | ☑ | 03-pg-hba.png |
| 4 | Redes autorizadas restringidas | ☑ | 03-pg-hba.png |
| 5 | Autenticación segura (scram-sha-256) | ☑ | 06-verificacion.png |
| 6 | Superusuarios identificados | ☑ | 04-roles.png |
| 7 | Cuentas de aplicación separadas | ☑ | 04-roles.png |
| 8 | Privilegios mínimos | ☑ | 04-roles.png |
| 9 | Extensiones revisadas | ☑ | 01-superficie-ataque.png |
| 10 | TLS verificado | ☑ | 05-tls.png |
| 11 | Configuración protegida | ☑ | cambios.md |
| 12 | Directorio de datos protegido | ☑ | cambios.md |
| 13 | Firewall documentado | ☑ | cambios.md |
| 14 | Actualizaciones documentadas | ☑ | baseline.md |
| 15 | Configuración registrada | ☑ | cambios.md |
| 16 | Logs de conexión habilitados | ☑ | 06-verificacion.png |
| 17 | Timeouts de sesión definidos | ☑ | 06-verificacion.png |

## Comparativa antes / después

| Control | Antes | Después | Justificación |
|---------|-------|---------|---------------|
| listen_addresses | `*` (todas las interfaces) | `localhost,10.10.10.20` | Escuchar solo en las interfaces necesarias reduce la exposición |
| pg_hba.conf | Reglas amplias (all/all, 0.0.0.0/0) | Reglas `hostssl` por base, usuario y red 10.10.10.0/24 | Acceso específico y con el mínimo alcance posible |
| Método de autenticación | Reglas amplias sin criterio de origen | scram-sha-256 | Más robusto que métodos heredados como md5 |
| Usuarios administrativos | Usados también en conexiones normales | Solo `dba_user` para administración | Menos cuentas con privilegios reduce el impacto de un compromiso |
| Cuentas de aplicación | Cuenta administrativa | `app_user` y `consulta_user` con mínimo privilegio | La aplicación no necesita privilegios administrativos |
| Puerto | 5432 expuesto a red amplia | 5432 documentado y limitado por firewall | Cambiar el número no sustituye autenticación ni firewall |
| TLS | Disponible, no exigido | Exigido con `hostssl` y TLS 1.2 como mínimo | Protege credenciales y datos en tránsito |
| Permisos SO | Sin revisar | Directorio de datos 700, configuración sin lectura para otros, propietario `postgres` | Evita la lectura de configuración por otros usuarios |
| Extensiones | Sin revisar | Solo las necesarias, documentadas | Habilitar solo la funcionalidad necesaria |
| Conexiones | Sin límites de tiempo | Timeouts definidos y registro de conexiones | Evita consumo indefinido de recursos y mejora la trazabilidad |

## Conclusiones
Con este laboratorio se redujo la superficie de exposición de PostgreSQL al limitar las interfaces de escucha, las redes y las cuentas con acceso, y se documentó el estado antes y después de los cambios. El hardening no se limita a tener contraseñas fuertes: combina red, autenticación, autorización, configuración, sistema operativo y monitoreo. Como trabajo pendiente queda mantener una política de actualización de PostgreSQL y del sistema operativo, y revisar periódicamente las reglas de `pg_hba.conf`, los roles, las extensiones y los logs de conexión.

## Evidencias
`evidencias/01-superficie-ataque.png`, `02-listen-addresses.png`, `03-pg-hba.png`, `04-roles.png`, `05-tls.png`, `06-verificacion.png`.

## Estructura
```
lab-04-hardening/
├── README.md
├── informe.md
├── sql/
├── configuracion/
└── evidencias/
```
