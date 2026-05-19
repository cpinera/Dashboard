-- ════════════════════════════════════════════════════════════════
-- TOBIN DASHBOARD — Tablas nuevas en Supabase
-- Crear estas tablas en el SQL Editor del proyecto Supabase
-- compartido con tobin-bot y tobin-health.
-- ════════════════════════════════════════════════════════════════


-- ── 1. daily_notes ──────────────────────────────────────────────
-- Notas y checklist del día (panel "Notas del día" del dashboard).
-- Una fila por día. El array `items` contiene los items vigentes
-- (no completados o creados/arrastrados hoy). El array `archive`
-- contiene los items completados hoy con su timestamp de cierre.
-- ────────────────────────────────────────────────────────────────
create table if not exists daily_notes (
  fecha date primary key,
  items jsonb not null default '[]'::jsonb,
  archive jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- Estructura sugerida de items[]:
-- [
--   { "id": "i_abc123", "tipo": "texto", "texto": "Preparar pitch", "creado_en_fecha": "2026-05-18" },
--   { "id": "i_def456", "tipo": "check", "texto": "Revisar memo", "completado": false, "creado_en_fecha": "2026-05-17" }
-- ]
--
-- Estructura sugerida de archive[]:
-- [
--   { "id": "i_xyz789", "texto": "Revisar mails", "completado_at": "08:32" }
-- ]


-- ── 2. event_notes ──────────────────────────────────────────────
-- Notas asociadas a eventos del Google Calendar.
-- Una fila por evento. Se guarda snapshot del título y la hora del
-- evento para que la nota sobreviva si el evento se borra/edita.
-- ────────────────────────────────────────────────────────────────
create table if not exists event_notes (
  event_id text primary key,
  event_title text,
  event_start timestamptz,
  preparacion text not null default '',
  durante text not null default '',
  updated_at timestamptz not null default now()
);

-- Índice para búsqueda por texto en notas pasadas
create index if not exists event_notes_search_idx
  on event_notes using gin (
    to_tsvector('spanish', coalesce(event_title, '') || ' ' || coalesce(preparacion, '') || ' ' || coalesce(durante, ''))
  );

-- Índice para ordenar por fecha del evento (vista de notas pasadas)
create index if not exists event_notes_start_idx
  on event_notes (event_start desc);


-- ── 3. Función auxiliar — carryover diario ──────────────────────
-- Esta función se puede llamar con un cron de Supabase (Edge Function
-- o pg_cron) cada día a las 00:01 hora Chile para:
--   1. Archivar las "items completadas hoy" en la fila del día anterior.
--   2. Crear la fila del día nuevo arrastrando los items no completados.
--
-- Por ahora el carryover se puede hacer también desde el frontend al
-- cargar el dashboard si la fila del día no existe — pero hacerlo en
-- el server es más limpio.
-- ────────────────────────────────────────────────────────────────
-- (Pendiente — implementar cuando se cablee con el backend)
