# Backend — Endpoints que hay que agregar

Este documento lista los endpoints que **tobin-bot** y **tobin-health** necesitan exponer para que el dashboard funcione con datos reales. Cuando estén listos, basta con flipear `CONFIG.useMockData = false` y setear `CONFIG.botApiBase` y `CONFIG.healthApiBase` al inicio de `index.html`.

---

## En `tobin-bot` (Express en Railway)

### `GET /calendar/today`

Devuelve los eventos del Google Calendar de Cristobal para el día actual.

**Response:**
```json
[
  { "id": "evt_abc123", "start": "09:30", "end": "10:15", "title": "Reunión equipo", "hasNote": true }
]
```

`hasNote` debe ser `true` si existe una fila en `event_notes` con ese `event_id` y al menos un campo (`preparacion` o `durante`) no vacío.

---

### `POST /calendar/event`

Crea un nuevo evento en el Google Calendar.

**Body:**
```json
{ "title": "Call con Acme", "start": "11:00", "end": "11:30", "descripcion": "Dealflow" }
```

`start` y `end` vienen como HH:MM — el server los combina con la fecha de hoy en hora Chile antes de crear el evento.

**Response:** `{ "ok": true, "id": "evt_xyz" }`

---

### `GET /tasks?limit=N&offset=M`

Versión paginada del endpoint actual `/tasks`. Devuelve solo tasks con `estado = 'Pendiente'`, ordenadas por urgencia (Alta > Media > Baja) y luego por `created_at` ascendente.

**Response:**
```json
{ "items": [ { "id": 1, "nombre": "…", "urgencia": "Alta", "estado": "Pendiente" } ], "total": 12 }
```

---

### `PATCH /tasks/:id`

Actualizar el estado de una task. El dashboard solo lo usa para marcar `estado = 'Completada'`, pero conviene aceptar también `nombre`, `urgencia`, etc., para futuro.

**Body:** `{ "estado": "Completada" }`

---

### `GET /daily-notes/:fecha`

Devuelve la fila de `daily_notes` para esa fecha. Si no existe, la crea con `items` igual a los items no completados del día anterior (carryover automático).

**Response:**
```json
{ "items": [ ... ], "archive": [ ... ] }
```

---

### `PUT /daily-notes/:fecha`

Guardado completo (overwrite) de los items y el archivo del día. El frontend manda el estado actual cada vez que cambia algo (con debounce de ~600ms).

**Body:** `{ "items": [...], "archive": [...] }`

---

### `GET /event-notes/:event_id`

Devuelve la nota asociada al evento. Si no existe, devuelve `{ "prep": "", "durante": "" }`.

---

### `PUT /event-notes/:event_id`

Guarda la nota. El body incluye `event_title` y `event_start` para refrescar el snapshot (por si cambió el evento).

**Body:**
```json
{ "prep": "…", "durante": "…", "event_title": "Call con Acme", "event_start": "2026-05-18T11:00:00-04:00" }
```

---

### `GET /event-notes?search=&limit=20&offset=0`

Lista de notas pasadas para la vista de "Notas de reuniones". Filtra por `search` (matcheando título, fecha o contenido) y ordena por `event_start` descendente.

**Response:**
```json
[
  { "event_id": "evt_p1", "title": "Revisión semanal", "date": "2026-05-15", "preview": "Primera línea de la nota…" }
]
```

`preview` debe ser las primeras ~80 caracteres del contenido (preparación + durante concatenado, con saltos de línea reemplazados por ` · `).

---

## En `tobin-health` (Express en Railway)

### `POST /garmin/refresh`

Dispara una llamada en vivo a Garmin Connect, sincroniza las actividades de hoy, recalcula los acumulados de 7 días por categoría agrupada, y devuelve el estado completo de salud. Toma 10-30 seg.

### `POST /whoop/refresh`

Igual que el anterior pero para Whoop. Sincroniza recovery, sueño y sesiones de strength/functional training (la categoría "Gym" del dashboard).

### `GET /health/today`

Versión rápida que devuelve lo cacheado (lo último que se sincronizó). Se usa en el load inicial del dashboard.

**Response (los tres endpoints devuelven la misma estructura):**
```json
{
  "recovery": 78,
  "recovery_zone": "Zona verde",
  "sleep_hours": 7,
  "sleep_minutes": 23,
  "sleep_score": 89,
  "activities": [
    { "categoria": "Trote", "icon": "run",  "hoy": { "unit": "km", "val": 6.5 }, "semana": { "unit": "km", "val": 28.4 } },
    { "categoria": "Bici",  "icon": "bike", "hoy": null,                          "semana": { "unit": "km", "val": 42 } },
    { "categoria": "Gym",   "icon": "gym",  "hoy": { "unit": "sesión", "val": 1 }, "semana": { "unit": "sesión", "val": 4 }, "source": "Whoop" }
  ]
}
```

**Reglas de agrupación de Garmin a aplicar en el server:**

| Categoría Garmin                          | Va a categoría dashboard |
|-------------------------------------------|--------------------------|
| `running`, `track_running`, `treadmill_running` | `Trote` (km)             |
| `road_biking`, `cycling`, `virtual_ride` (Zwift) | `Bici` (km)              |
| `lap_swimming`, `open_water_swimming`     | `Nado` (km)              |

**Reglas de agrupación de Whoop:**

| Sport name Whoop                         | Va a categoría dashboard |
|------------------------------------------|--------------------------|
| `Strength Training`, `Functional Training` | `Gym` (sesiones)         |

**Reglas de visibilidad** (a aplicar en el server o en el frontend — actualmente en frontend):
- Si una categoría tiene `hoy = null` y `semana = null` (o ambos 0), no incluirla en `activities[]`.
- Si solo tiene `semana > 0`, dejar `hoy: null`.
- Si solo tiene `hoy > 0`, dejar `semana: null`.

---

## Autenticación

El dashboard manda el header `x-api-key` si `CONFIG.apiKey` está seteado. Recomendación: usar el mismo `API_SECRET` que ya está en tobin-bot (`process.env.API_SECRET || "tobin2024"`).

CORS debe permitir el origen del dashboard (el dominio que Railway le asigne, ej. `tobin-dashboard.up.railway.app`).
