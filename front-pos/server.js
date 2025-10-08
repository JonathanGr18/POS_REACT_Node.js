const express = require('express');
const path = require('path');

const app = express();
<<<<<<< HEAD
const PORT = process.env.PORT || 3001;
=======
const PORT = 3000;
>>>>>>> 0423949a6e9463fb24a6a377b2310e309be8e491

// Servir la carpeta de build
app.use(express.static(path.join(__dirname, 'build')));

// Cualquier ruta, devolver index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Frontend corriendo en http://localhost:${PORT}`);
});
