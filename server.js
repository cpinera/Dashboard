// Servidor mínimo para servir el dashboard en Railway.
// No tiene lógica de negocio — toda la data se obtiene desde
// tobin-bot y tobin-health vía las APIs documentadas en BACKEND.md.

const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(__dirname));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Tobin Dashboard corriendo en http://localhost:${PORT}`);
});
