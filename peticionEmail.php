<?php
    include_once("config.php");

    // Obtener datos del cuerpo de la petición
    $jsonInput = file_get_contents('php://input');
    $data = json_decode($jsonInput, true);

    if (isset($data["email"])) {
        $email = $data["email"];

        try {
            $sql = "SELECT tipo FROM USUARIO WHERE email = :email";
            $sentencia = $conn->prepare($sql);
            $sentencia->bindParam(':email', $email);
            $sentencia->execute();
            $usuario = $sentencia->fetch(PDO::FETCH_ASSOC);
            header('Content-Type: application/json');
            if ($usuario) {
                $json = [
                    "existe" => true,
                    "tipo" => $usuario["tipo"]
                ];
                echo json_encode($json);
                exit;
            } else {
                echo json_encode(['existe' => false]);
            }
        } catch (PDOException $e) {
            echo json_encode(['error' => $e->getMessage()]);
        }
    }
    
?>