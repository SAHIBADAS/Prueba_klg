<?php
//Incluimos la conexión
include_once("config.php");
//Desactivar para que PHP devuelva errores y warnings
error_reporting(0);

//Obtengo los datos enviados al servidor
$peticionJSON = file_get_contents('php://input');

//Proceso el JSON y lo convierto en array asociativo (true). Acceso a valores $obj["campo"];
//Si quiero objeto no poner el true. Acceso a valores $obj->{'nombre'};
$peticion = json_decode($peticionJSON, true);

// Comprobación de la petición
if(empty($peticion)){
	echo json_encode($myArray);
	die("Petición mal formulada");
}

// Extracción de la variable articulo y busqueda
$id=$peticion['articulo'];
$modelo=$peticion['busqueda'];

header('Content-Type: application/json; charset=utf-8;');

//Esto deberás cambiarlo para que se obtengan todas las zapatillas de la base de datos o se realice la búsqueda
try{
	$query = ("SELECT * FROM zapatilla");
	$stmt = $connection->prepare($query);
	$stmt -> execute();
	$myArray = $stmt->fetchAll(PDO::FETCH_ASSOC);

if(!empty($id)){
	if($id==-1){
		$myJSON = json_encode($myArray);
		echo $myJSON;
	}else{
		foreach($myArray as $actual){
			if($id==$actual->id){
				$myJSON = json_encode($actual);
				echo $myJSON;
			}
		}
	}
}else if(!empty($modelo)){
	$respuesta = array();
	for($i=0;$i<count($myArray);$i++){
		if(strpos(strtoupper($myArray[$i]["modelo"]), strtoupper($modelo))!==false){
			array_push($respuesta,$myArray[$i]);
		}
	}

	$myJSON = json_encode($respuesta);
	echo $myJSON;
}
}catch(PDOException $e){
	echo $e->getMessage();
}

?>