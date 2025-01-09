from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse

# Configuración del servidor
HOST = "0.0.0.0"
PORT = 8080

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Ruta del archivo index.html
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            # Lee el archivo index.html y lo envía como respuesta
            with open("index.html", "r") as file:
                self.wfile.write(file.read().encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"404 Not Found")
    
    def do_POST(self):
        # Procesar los datos del formulario
        content_length = int(self.headers["Content-Length"])
        post_data = self.rfile.read(content_length)
        data = urllib.parse.parse_qs(post_data.decode("utf-8"))

        # Guardar los datos en un archivo de texto
        with open("form_data.txt", "a") as file:
            file.write(str(data) + "\n")

        # Responder al cliente
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"Datos recibidos. Gracias.")

# Inicia el servidor
if __name__ == "__main__":
    print(f"Servidor escuchando en http://{HOST}:{PORT}")
    server = HTTPServer((HOST, PORT), SimpleHTTPRequestHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServidor detenido.")
        server.server_close()
