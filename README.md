# Tobin Dashboard

Dashboard de inicio del día para Cristobal. Una sola pantalla con agenda, top to-dos, salud y notas. Se cuelga de los proyectos existentes `tobin-bot` y `tobin-health`.

## Cómo probarlo localmente (sin deploy)

1. Abre `index.html` con doble click en Finder.
2. Listo — verás el dashboard con datos de ejemplo (mock).

El frontend está completo y funcional con datos falsos. Puedes:

- Hacer click en el icono de nota de cualquier evento → se abre el popup.
- Marcar checkboxes en los to-dos → se "completan" (solo en memoria mientras esté en mock).
- Apretar los refresh de Whoop y Garmin → carga visual con pequeño delay.
- Escribir notas en el panel de abajo, marcar checkboxes → se actualizan.
- Apretar "Notas pasadas" arriba a la derecha → se abre la vista de archivo con búsqueda.

## Estructura del repo

```
tobin-dashboard/
├── index.html        ← todo el frontend en un solo archivo (HTML + CSS + JS)
├── server.js         ← servidor mínimo Express para Railway
├── package.json      ← deps (solo Express)
├── supabase.sql      ← SQL de las tablas nuevas
├── BACKEND.md        ← specs de los endpoints que faltan agregar
└── README.md         ← este archivo
```

## Para pasar a producción

### Paso 1 — Crear las tablas en Supabase

Entra al proyecto Supabase compartido con tobin-bot y tobin-health, abre el SQL Editor, y corre el contenido de `supabase.sql`.

### Paso 2 — Agregar endpoints en tobin-bot y tobin-health

Sigue las specs de `BACKEND.md`. Son ~8 endpoints nuevos repartidos entre los dos servidores. Quien implemente puede usar el mismo patrón que ya está en esos repos (Express + Supabase via fetch + Google APIs).

### Paso 3 — Conectar el frontend a los endpoints reales

Abre `index.html`, busca el bloque `CONFIG` cerca del inicio del `<script>` (línea ~510) y reemplaza:

```js
const CONFIG = {
  useMockData: false,                               // cambiar a false
  botApiBase: 'https://tobin-bot.up.railway.app',   // URL real de tobin-bot
  healthApiBase: 'https://tobin-health.up.railway.app', // URL real de tobin-health
  apiKey: process.env.API_SECRET || 'tobin2024',    // o el secret real
};
```

### Paso 4 — Subir a GitHub

```bash
cd ~/Desktop/tobin-dashboard
git init
git add .
git commit -m "MVP del dashboard"
git remote add origin https://github.com/<tu-usuario>/tobin-dashboard.git
git push -u origin main
```

### Paso 5 — Deployar a Railway

1. Entra a railway.app → New Project → Deploy from GitHub repo.
2. Selecciona el repo `tobin-dashboard`.
3. No requiere variables de entorno especiales (excepto `PORT`, que Railway setea solo).
4. Railway te asigna un dominio tipo `tobin-dashboard-production.up.railway.app`.
5. Listo — abre esa URL en el celular y guarda como pantalla de inicio para acceso rápido.

## Notas para quien venga después

- Todo el frontend es vanilla JS, sin build, sin framework. Es intencional para que sea fácil de mantener y deployar.
- Los iconos son SVG inline (sin librería). Si se agregan muchos más, conviene moverlos a un objeto `ICONS` o usar una fuente de iconos.
- El `MOCK_DATA` se queda como referencia útil de la forma esperada de los responses — no borrar al pasar a producción.
- Para hacer PWA (instalable como app en el celular): agregar `manifest.json` y un Service Worker mínimo. Eso es Fase 7.

## Contexto del proyecto

Documentación completa, decisiones tomadas e historial de cambios:
`~/Desktop/ClaudeMemoria/proyectos/tobin-dashboard.md`
