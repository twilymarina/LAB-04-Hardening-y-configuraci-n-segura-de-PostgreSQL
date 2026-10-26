Preguntas de las actividades
A1. ¿Por qué conocer la superficie de ataque debe preceder al hardening? Porque no se puede proteger ni reducir lo que no se conoce. Primero hay que saber qué puertos, interfaces, cuentas, reglas y servicios existen para decidir cuáles son necesarios y cuáles se restringen o eliminan.

A2. ¿Por qué es importante conocer la ubicación física de estos archivos? Porque cada tipo de archivo (datos, configuración, autenticación, logs) tiene un riesgo distinto y requiere permisos propios. Si no sé dónde están, no puedo revisar sus permisos, respaldarlos ni auditar los cambios.

A3. Comparación de arquitecturas. La segunda arquitectura reduce mejor la exposición: el servidor queda dentro de una red privada, detrás del firewall, y no es alcanzable directamente desde Internet. En la primera, el puerto 5432 queda expuesto y cualquier atacante puede intentar conectarse. Menos puntos de entrada significa menos cosas que proteger.

A5. Análisis de host all all 0.0.0.0/0 scram-sha-256
• Bases de datos: todas.
• Usuarios: todos.
• Origen: cualquier dirección IPv4.
• Autenticación: scram-sha-256.
• Por qué es exposición innecesaria: cualquier equipo puede intentar autenticarse con cualquier usuario contra cualquier base. La contraseña es la única barrera.
• Qué necesito para restringirla: qué aplicaciones o personas se conectan, desde qué IP o red, a qué base y con qué usuario.

A7. Autenticación
• Autenticación vs. autorización: la primera verifica quién eres; la segunda define qué puedes hacer.
• Qué protege scram-sha-256: protege la contraseña durante la autenticación y su almacenamiento, sin enviarla ni guardarla en claro, y resiste mejor ataques que md5.
• Por qué no es cifrado reversible: lo que se almacena es un verificador derivado de la contraseña, del que no se puede recuperar la contraseña original. El cifrado es reversible con una clave.
• Cuenta con permisos excesivos y contraseña fuerte: sigue siendo un riesgo. Si se compromete la aplicación o se filtra la credencial, el atacante hereda todos los permisos.

A8. ¿Por qué no usar SUPERUSER como cuenta de una aplicación? Porque un compromiso de la aplicación (por ejemplo, inyección SQL) daría al atacante control total: leer y borrar cualquier dato, crear roles y omitir permisos. Una cuenta con mínimo privilegio limita el daño.

A9. ¿Qué riesgo hay si la aplicación usa una cuenta administrativa? Que cualquier vulnerabilidad de la aplicación se convierte en control administrativo de la base de datos, rompiendo el principio de mínimo privilegio.

A11. ¿Por qué es un problema mantener conexiones abiertas indefinidamente? Cada conexión consume memoria y ocupa un lugar de max_connections. Si se acumulan conexiones inactivas o transacciones abiertas, se agotan recursos, se bloquean limpiezas y nuevos usuarios legítimos no pueden conectarse (problema de disponibilidad).

A12. ¿Por qué no basta con GRANT y REVOKE? Porque esos controles actúan dentro de PostgreSQL. Si un usuario del sistema operativo puede leer pg_hba.conf, certificados o los archivos del directorio de datos, puede obtener información o eludir los controles sin pasar por PostgreSQL.

A14. ¿Por qué pg_hba.conf y el firewall no son equivalentes? El firewall filtra tráfico de red por origen, destino y puerto antes de llegar al servicio. pg_hba.conf decide dentro de PostgreSQL si una conexión puede autenticarse según base, usuario, origen y método. Son capas complementarias.

Informe (10 preguntas)

1. Principal superficie de ataque: el puerto 5432 accesible desde redes amplias, con escucha en todas las interfaces y reglas permisivas en pg_hba.conf. (Ajusta con lo que encontraste.)

2. Mayor riesgo: una regla como host all all 0.0.0.0/0, porque permite intentar entrar a cualquier base con cualquier usuario desde cualquier IPv4.

3. Cambio que más redujo la exposición: restringir listen_addresses y reemplazar la regla amplia por reglas específicas (base + usuario + red + método), apoyadas en el firewall.

4. Firewall vs. pg_hba.conf: el firewall controla el acceso de red al puerto; pg_hba.conf controla la autenticación dentro de PostgreSQL según usuario, base, origen y método.

5. Autenticación vs. autorización: una verifica la identidad, la otra define los permisos de esa identidad.

6. Por qué la cuenta de aplicación no debe ser SUPERUSER: si la aplicación se compromete, el atacante hereda control total de la base.

7. Por qué cambiar el puerto no basta: solo reduce ruido de escaneos automáticos; un escaneo lo encuentra y no sustituye autenticación, autorización ni firewall.

8. Por qué listen_addresses='*' puede ser innecesario: hace escuchar al servicio en todas las interfaces, aunque la aplicación solo use una, ampliando la superficie sin beneficio.

9. Papel del sistema operativo: protege los archivos de configuración, el directorio de datos y las credenciales; sin eso, los permisos de PostgreSQL pueden eludirse.

10. Controles a revisar periódicamente: reglas de pg_hba.conf, firewall, roles y privilegios, superusuarios, extensiones, permisos de archivos, parches, configuración de TLS y logs de conexión.

Caso integral (mínimo 10 problemas)

#
Problema
Riesgo
Control propuesto
1
Acepta conexiones desde cualquier IPv4
Escaneo y fuerza bruta desde Internet
Allowlist de redes concretas
2
La aplicación usa cuenta administrativa
Compromiso de la app = control total
Cuenta de aplicación con mínimo privilegio
3
Escucha en todas las interfaces
Exposición en interfaces innecesarias
listen_addresses limitado a la IP necesaria
4
Firewall permite 5432 desde cualquier origen
Exposición pública del puerto
Permitir solo redes autorizadas
5
pg_hba.conf all/all desde 0.0.0.0/0
Cualquier usuario puede intentar entrar a cualquier base
Reglas por base, usuario y origen
6
Se confía solo en contraseñas fuertes
Un solo control, sin defensa en profundidad
Controles en capas
7
Sin segmentación de red
Servidor alcanzable desde zonas no confiables
Red privada o segmento de base de datos
8
No se verifica TLS
Credenciales y datos expuestos en tránsito
hostssl y TLS 1.2+
9
Sin monitoreo de conexiones
Intentos de intrusión no detectados
log_connections y revisión de logs
10
Archivos de configuración sin revisar
Lectura por otros usuarios del SO
Propietario postgres y permisos restrictivos
11
Superusuario posiblemente accesible remotamente
Cuenta más valiosa expuesta a la red
Restringirla a conexión local o red DBA
12
Sin límites ni timeouts
Agotamiento de recursos
max_connections y timeouts

¿Es suficiente tener contraseñas fuertes? No. Protegen solo la autenticación. No limitan lo que la cuenta puede hacer (autorización), no reducen quién alcanza el servidor (red), no corrigen parámetros inseguros (configuración), no protegen los archivos (sistema operativo) y no permiten detectar abusos (monitoreo). La seguridad depende de varias capas.
