<?php
include_once("config.php");
if (!empty($_POST)) {
    try {
        $nombre = $_POST["nombre"];
        $apellidos = $_POST["apellidos"];
        $email = $_POST["email"];
        $clave = password_hash($_POST["clave"], PASSWORD_DEFAULT);
        $tipo = 'registrado';

        $sql = "SELECT id, tipo FROM USUARIO WHERE email = :email";

        $sentencia = $conn->prepare($sql);
        $sentencia->bindParam(':email', $email);
        $sentencia->execute();
        $usuario = $sentencia->fetch(PDO::FETCH_ASSOC);

        if ($usuario) {
            if ($usuario["tipo"] == "invitado") {
                $sql = "UPDATE USUARIO SET nombre = :nombre, apellidos = :apellidos, clave = :clave, tipo = :tipo WHERE email = :email";

                $sentencia = $conn->prepare($sql);
                $sentencia->bindParam(':nombre', $nombre);
                $sentencia->bindParam(':apellidos', $apellidos);
                $sentencia->bindParam(':email', $email);
                $sentencia->bindParam(':clave', $clave);
                $sentencia->bindParam(':tipo', $tipo);

                if ($sentencia->execute()) {
                    header("refresh:2;url=index.php");
                    exit;
                } else {
                    echo "Error al registrar";
                }
            }
        } else {
            $sql = "INSERT INTO USUARIO (nombre, apellidos, email, clave, tipo) VALUES (:nombre, :apellidos, :email, :clave, :tipo)";

            $sentencia = $conn->prepare($sql);

            $sentencia->bindParam(':nombre', $nombre);
            $sentencia->bindParam(':apellidos', $apellidos);
            $sentencia->bindParam(':email', $email);
            $sentencia->bindParam(':clave', $clave);
            $sentencia->bindParam(':tipo', $tipo);

            if ($sentencia->execute()) {
                header("refresh:2;url=index.php");
                exit;
            } else {
                echo "Error al registrar";
            }
        }
    } catch (Exception $e) {
        echo "Error DB";
    }
}

?>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro</title>
    <script src="js/registro.js"></script>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>
    <?php include "header.php"; ?>
    <main>
        <form action="registro.php" method="post" id="registro">

            <label for="nombre">Nombre</label>
            <input type="text" name="nombre" id="nombre" required>
            <span id="errornombre" class="error hide">Este campo no puede estar vacío.</span>

            <label for="apellidos">Apellidos</label>
            <input type="text" name="apellidos" id="apellidos" required>
            <span id="errorapellidos" class="error hide">Este campo no puede estar vacío.</span>

            <label for="email">Email</label>
            <input type="email" name="email" id="email" required>
            <span id="emailUsado" class="error hide">Este email ya está en uso.</span>
            <span id="emailNoValido" class="error hide">Introduzca un email válido.</span>
            <label for="clave">Clave</label>
            <input type="password" name="clave" id="clave" required>
            <span id="errorClave" class="error hide">Esta clave es inválida.</span>
            <button type="submit" name="registrar">Registrar</button>
        </form>
        <button type="button">Iniciar sesión</button>
    </main>

    <?php include "footer.php"; ?>
</body>

</html>