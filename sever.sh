#!/bin/bash

PORT=8080
FILE="formulario.txt"

# Función para manejar las solicitudes POST y almacenar los datos en el archivo
handle_post() {
    while true; do
        # Aceptar conexión entrante y leer la solicitud
        REQUEST=$(nc -l -p $PORT)

        # Verificar si es una solicitud POST al formulario
        if echo "$REQUEST" | grep -q "POST /submit"; then
            # Extraer los datos del formulario (esto es muy básico, sin validación adecuada)
            NAME=$(echo "$REQUEST" | grep -oP 'name=\K[^&]*' | sed 's/%20/ /g')  # Decodificar espacios
            EMAIL=$(echo "$REQUEST" | grep -oP 'email=\K[^&]*' | sed 's/%20/ /g')  # Decodificar espacios

            # Guardar los datos en el archivo
            echo "Nombre: $NAME" >> $FILE
            echo "Correo electrónico: $EMAIL" >> $FILE
            echo "-------------------------" >> $FILE

            # Responder con un mensaje al usuario
            echo -ne "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
            echo "<html><body><h1>Gracias, $NAME!</h1><p>Hemos recibido tu correo: $EMAIL</p></body></html>"
        fi
    done
}

# Mostrar mensaje de inicio y ejecutar el servidor
echo "Servidor HTTP corriendo en http://localhost:$PORT"
echo "Los datos del formulario se guardarán en '$FILE'."
handle_post
