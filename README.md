# LAB-04-Hardening-y-configuraci-n-segura-de-PostgreSQL

# LAB-04 — Hardening y configuración segura de PostgreSQL

## Objetivo
Aplicar un proceso básico de hardening a PostgreSQL 16 en un entorno académico aislado: identificar configuraciones inseguras, reducir la superficie de exposición y documentar una línea base de seguridad.

## Entorno
- **Motor:** PostgreSQL 16
- **Sistema operativo:** [completar]
- **Servidor / IP:** [completar]
- **Base de datos de laboratorio:** [completar]
- **Cliente:** psql [versión]

## Superficie de ataque inicial

| Elemento | Estado actual | ¿Es necesario? | Riesgo |
|----------|---------------|----------------|--------|
| Puerto PostgreSQL | [completar] | [completar] | [completar] |
| Interfaces de escucha | [completar] | [completar] | [completar] |
| Conexiones remotas | [completar] | [completar] | [completar] |
| Usuarios administrativos | [completar] | [completar] | [completar] |
| SSL/TLS | [completar] | [completar] | [completar] |
| Métodos de autenticación | [completar] | [completar] | [completar] |

## Hallazgos
[Resume qué encontraste con `sql/01-inspeccion.sql` y `sql/02-roles.sql`: reglas permisivas, superusuarios, extensiones, permisos del SO, puertos expuestos.]

## Cambios realizados
Ver `configuracion/cambios.md`.

## Justificación de los cambios
[Para cada cambio: qué riesgo reduce y por qué es suficiente sin romper el servicio.]

## Verificación
Resultados de `sql/04-verificacion.sql` y capturas en `evidencias/`.

## Checklist de hardening

| # | Control | Verificado | Evidencia |
|---|---------|------------|-----------|
| 1 | Puerto documentado | ☐ | |
| 2 | Interfaces de escucha justificadas | ☐ | |
| 3 | pg_hba.conf revisado | ☐ | |
| 4 | Redes autorizadas restringidas | ☐ | |
| 5 | Autenticación segura (scram-sha-256) | ☐ | |
| 6 | Superusuarios identificados | ☐ | |
| 7 | Cuentas de aplicación separadas | ☐ | |
| 8 | Privilegios mínimos | ☐ | |
| 9 | Extensiones revisadas | ☐ | |
| 10 | TLS verificado | ☐ | |
| 11 | Configuración protegida | ☐ | |
| 12 | Directorio de datos protegido | ☐ | |
| 13 | Firewall documentado | ☐ | |
| 14 | Actualizaciones documentadas | ☐ | |
| 15 | Configuración registrada | ☐ | |
| 16 | Logs de conexión habilitados | ☐ | |
| 17 | Timeouts de sesión definidos | ☐ | |

## Comparativa antes / después

| Control | Antes | Después | Justificación |
|---------|-------|---------|---------------|
| listen_addresses | | | |
| pg_hba.conf | | | |
| Método de autenticación | | | |
| Usuarios administrativos | | | |
| Cuentas de aplicación | | | |
| Puerto | | | |
| TLS | | | |
| Permisos SO | | | |
| Extensiones | | | |
| Conexiones | | | |

## Conclusiones
[Qué reducción de exposición lograste y qué queda pendiente.]

## Evidencias esperadas
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
