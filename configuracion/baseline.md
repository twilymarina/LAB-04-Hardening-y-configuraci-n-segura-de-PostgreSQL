• Red: escuchar solo en localhost y la IP privada necesaria; firewall que permita 5432 solo desde redes autorizadas (ej. 10.10.10.0/24); sin 0.0.0.0/0.

• Autenticación: scram-sha-256, contraseñas largas y únicas fuera del repositorio, pocas cuentas administrativas nominales.

• Autorización: roles separados (DBA, aplicación, consulta) con mínimo privilegio y sin SUPERUSER en aplicaciones.

• Configuración: log_connections y log_disconnections activos, idle_in_transaction_session_timeout y statement_timeout definidos, extensiones solo las necesarias, max_connections acorde a la carga.

• Sistema operativo: archivos propiedad de postgres, directorio de datos 700, configuración sin lectura para otros.

• Cifrado: ssl = on, ssl_min_protocol_version = TLSv1.2, reglas hostssl, credenciales fuera del código.

• Mantenimiento: política de actualización documentada, revisión periódica de reglas, roles y logs, cambios registrados.
