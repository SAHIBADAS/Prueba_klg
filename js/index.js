document.addEventListener("DOMContentLoaded", () => {
    let input = document.getElementById("nombre");
    
    input.addEventListener("input", search_index);

    search_index();
    actCarrito();
    setInterval(actCarrito,1000);
});

//Funcion actualizar cabecera carrito
function actCarrito(){
    recuperar();
    let cantcarr = document.getElementById("cantcarr");
    c = 0;
    for(let elemento of carrito){
        c+=elemento.cantidad;
    }
    cantcarr.innerHTML = c;
}

//Ajax->mostrar productos index
function search_index() {
    let input = document.getElementById("nombre");
    let valor = -1;

    if(input.value==""){
        valor = -1;
    }else{
        valor = "";
    } 

    const JSONsearch = { articulo: valor, busqueda: input.value };

    const options = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(JSONsearch)
    }

    fetch("productos.php",options).then(response => {
        return response.text();
    }).then(data => {
        let arrAll = JSON.parse(data);
        mostrar_index(arrAll);
        console.log(data);
    }).catch(error => {
        console.error("Fallo", error);
    });
}

//Funcion Dom
function mostrar_index(data) {
    const main = document.getElementsByTagName("main")[0];
    main.innerHTML="";
    if(data.length != 0) {
        for (let element of data) {
            
            let article = document.createElement("article");
            let img = document.createElement("img");
            let div1 = document.createElement("div");
            let div2 = document.createElement("div");
            let div3 = document.createElement("div");
            let div4 = document.createElement("div");
            let button = document.createElement("button");
    
            img.src = element.imagen;
            div2.textContent = element.modelo;
            div3.textContent = element.description;
            div4.textContent = element.precio + "€";
    
            div1.classList.add("datos-productos");
            div2.classList.add("modelo");
            div3.classList.add("descripcion");
            div4.classList.add("precio");
            button.classList.add("addcesta");
    
            button.addEventListener("click", () => {
                cesta(element);
            });
    
            div1.appendChild(div2);
            div1.appendChild(div3);
            div1.appendChild(div4);
            article.appendChild(button);
            article.appendChild(img);
            article.appendChild(div1);
            main.appendChild(article);
        }
    }else{
        main.innerHTML = "Lo sentimos, no se han encontrado resultados con el criterio de búsqueda.";
    }
}

//Local Storage
function recuperar(){
    JSONcarrito = localStorage.getItem("carrito");
    if(JSONcarrito!=null){
        carrito = JSON.parse(JSONcarrito);
    }else{
        carrito = new Array();
    }
}

function guardar(){
    localStorage.setItem("carrito",JSON.stringify(carrito));
}

function cesta(element) {
    recuperar();
    for(let i=0; i<carrito.length; i++){
        if(carrito[i].id == element.id){
            carrito[i].cantidad += 1;
            guardar();
            actCarrito();
            return;
        }        
    }
    carrito.push({
        id : element.id,
        imagen : element.imagen,
        modelo : element.modelo,
        description : element.description,
        precio : element.precio,
        cantidad : 1
    });
    guardar();
    actCarrito();
}