// Servidor mínimo para servir el dashboard en Railway.
// No tiene lógica de negocio — toda la data se obtiene desde
// tobin-bot y tobin-health vía las APIs documentadas en BACKEND.md.

const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // necesario para que Railway pueda llegar al server

// Endpoint de salud para healthchecks (opcional pero útil)
app.get('/_health', (req, res) => res.json({ ok: true }));

app.use(express.static(__dirname));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, HOST, () => {
  console.log(`Tobin Dashboard escuchando en ${HOST}:${PORT}`);
});
