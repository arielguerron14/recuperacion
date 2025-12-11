const http = require("http");

const PORT = process.env.PORT || 80;

const server = http.createServer((req, res) => {
  res.end("Hola Mundo desplegado en múltiples instancias EC2!");
});

server.listen(PORT, () => console.log(`Corriendo en puerto ${PORT}`));
