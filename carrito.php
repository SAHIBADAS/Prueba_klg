<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carrito de la compra</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="./js/carrito.js"></script>
</head>
<body>
    <?php include ("header.php") ?>
	<h2>Cesta de la compra</h2>
    <div id="productos">
        <hr class="line">
        <section class="total">
            <div>Total del Carrito:</div>
            <div id="precio"></div>
        </section>
    </div>
    <?php include ("footer.php") ?>
</body>
</html>