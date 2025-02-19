<?php
    $usuario="root";
    $dsn="mysql:dbname=proyecto;host=127.0.0.1";
    // $clave="";

    try{
        $connection = new PDO($dsn,$usuario);
        $connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    }catch(PDOException $e){
        echo $e->getMessage();
    }
?>