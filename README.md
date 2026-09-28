# Campus Connect — Administración web

Panel web administrativo en Laravel 12 + Blade, API REST y PostgreSQL.

## Ejecutar con Docker

```bash
docker compose up --build
```

Abra `http://localhost:8000`. Credenciales: administrativo `admin@campus.edu` / `password`; estudiante `estudiante@campus.edu` / `password`.

La API queda en `GET /api/solicitudes`, `GET /api/solicitudes/{id}` y `PATCH /api/solicitudes/{id}`.
# solicitues-univalle
