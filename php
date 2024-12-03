<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Informe de Salud</title>
</head>
<body>
    <?php
    if ($_SERVER['REQUEST_METHOD'] === 'GET' && !empty($_GET)) {
        // Capturar los datos del formulario
        $peso = floatval($_GET['peso']);
        $altura_cm = intval($_GET['altura']);
        $fecha_nacimiento = $_GET['fecha_nacimiento'];
        $email = $_GET['email'];
        $sexo = $_GET['sexo'];
        $actividad = $_GET['actividad'];
        $objetivo = $_GET['objetivo'];

        // Calcular el IMC
        $altura_m = $altura_cm / 100;
        $imc = round($peso / ($altura_m * $altura_m), 1);

        // Interpretación del IMC
        if ($imc < 18) {
            $interpretacion = "Tu peso es inferior al saludable. Te recomendamos seguir nuestro programa para ganar masa muscular y mejorar tu salud.";
        } elseif ($imc < 20) {
            $interpretacion = "Tu peso se encuentra en la banda más baja del peso saludable. Te recomendamos seguir nuestro programa para ganar masa muscular y mejorar tu salud.";
        } elseif ($imc < 23) {
            $interpretacion = "Enhorabuena. Tu peso es el óptimo. Te recomendamos seguir nuestro programa para ganar masa muscular, perfeccionar algunas zonas de tu cuerpo y mejorar tu salud.";
        } elseif ($imc < 25) {
            $interpretacion = "Tu peso se encuentra en la banda alta del peso normal. Te recomendamos seguir nuestro programa para reducir tu peso, ganar masa muscular, perfeccionar algunas zonas de tu cuerpo y mejorar tu salud.";
        } elseif ($imc < 28) {
            $interpretacion = "Tienes exceso de peso. Reducir tu peso es beneficioso para tu salud y te permitirá encontrarte más ágil y conseguir un físico más juvenil.";
        } elseif ($imc < 30) {
            $interpretacion = "Tienes exceso de peso. Reducir tu peso es necesario para tu salud y te permitirá encontrarte más ágil y mejorar tu físico. Es el momento de tomar medidas.";
        } else {
            $interpretacion = "Tienes peso muy superior a lo aconsejable. Reducir tu peso es necesario para tu salud y te permitirá encontrarte más ágil y mejorar tu físico. Es el momento de tomar medidas.";
        }

        // Recomendaciones según objetivo
        $recomendacion = match ($objetivo) {
            "Perder peso" => "Cambiar tus hábitos es clave. Una dieta balanceada y actividad física te ayudarán a lograr tus objetivos.",
            "Mejorar mi salud" => "Adoptar hábitos saludables puede mejorar tu bienestar general y prevenir enfermedades.",
            "Ganar peso/músculo" => "Un plan de entrenamiento adecuado y una dieta rica en proteínas son fundamentales para ganar masa muscular."
        };

        // Mensaje motivacional
        $motivacion = "Toma el control de tu salud ahora. Cada paso que des hacia un estilo de vida saludable marcará la diferencia.";
        ?>

        <h1>Informe de Salud</h1>
        <p><strong>Resumen de datos:</strong></p>
        <ul>
            <li>Sexo: <?= htmlspecialchars($sexo) ?></li>
            <li>Altura: <?= $altura_cm ?> cm</li>
            <li>Peso: <?= $peso ?> kg</li>
        </ul>

        <p><strong>Índice de Masa Corporal (IMC):</strong></p>
        <p>Tu índice de masa corporal (IMC) es: <?= $imc ?></p>

        <p><strong>Interpretación del IMC:</strong></p>
        <p><?= $interpretacion ?></p>

        <p><strong>Recomendaciones generales:</strong></p>
        <p><?= $recomendacion ?></p>

        <p><strong>Motivación adicional:</strong></p>
        <p><?= $motivacion ?></p>

    <?php } else { ?>
        <p>No se han enviado datos. Por favor, regresa al <a href="formulario.html">formulario</a>.</p>
    <?php } ?>
</body>
</html>
