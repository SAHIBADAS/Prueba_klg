<?php
include_once("config.php");
if (!empty($_POST)) {
    try {
        $email = $_POST["email"];
        $tipo = 'invitado';

        $sql = "INSERT INTO USUARIO (email, tipo) VALUES (:email, :tipo)";

        $sentencia = $conn->prepare($sql);

        $sentencia->bindParam(':email', $email);
        $sentencia->bindParam(':tipo', $tipo);

        if ($sentencia->execute()) {
            header("refresh:2;url=index.php");
            exit;
        } else {
            echo "Error al registrar";
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
    <title>Registro invitado</title>
    <script src="js/registro.js"></script>
    <link rel="stylesheet" href="css/style.css">

</head>

<body>
    <?php include "header.php"; ?>
    <form action="registroInvitado.php" method="post">
        <label for="email">Email:</label>
        <input type="email" name="email" id="email" required>
        <span id="emailUsado" class="error hide">Este email ya está en uso.</span>
        <span id="emailNoValido" class="error hide">Introduzca un email válido.</span>
        <input type="submit" name="registrar" value="Registrarse">
    </form>
    <?php include "footer.php"; ?>
</body>

</html>