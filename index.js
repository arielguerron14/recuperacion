const http = require("http");

// Cambiado a 3000 para evitar error EACCES
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.end("Hola Mundo desplegado en múltiples instancias EC2!");
});

server.listen(PORT, () => console.log(`Corriendo en puerto ${PORT}`));
