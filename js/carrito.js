document.addEventListener("DOMContentLoaded", () => {
    const productos = document.getElementById("productos");
    actCarrito();
    mostrarCarrito();
    setInterval(actCarrito,1000);
});

//Función DOM
function mostrarCarrito() {
    productos = document.getElementById("productos");
    if (!productos) {
        console.error("Error: No se encontró el elemento #productos en el DOM.");
        return;
    }

    const articles = Array.from(productos.children);
    const totaldiv = document.getElementById("precio");

    let total = 0;

    for (let article of articles) {
        if (article.tagName === "ARTICLE") {
            productos.removeChild(article);
        }
    }

    recuperar();

    if (carrito.length != 0) {
        for (let articulo of carrito) {
            let articuloDiv = document.createElement("article");
            let img = document.createElement("img");
            let content = document.createElement("div");
            let butt = document.createElement("div");
            let div1 = document.createElement("div");
            let div2 = document.createElement("div");
            let div3 = document.createElement("div");
            let div4 = document.createElement("div");
            let input = document.createElement("input");
            let button = document.createElement("button");

            img.src = articulo.imagen;
            div1.textContent = articulo.modelo;
            div2.textContent = articulo.description;
            div3.textContent = articulo.precio;

            content.classList.add("content");
            div1.classList.add("desc");
            div2.classList.add("tipo");
            butt.classList.add("butt");

            div4.textContent = "Cantidad:";
            button.textContent = "Borrar";
            total += (articulo.precio * articulo.cantidad);

            input.setAttribute("type", "number");
            input.setAttribute("value", articulo.cantidad);

            button.addEventListener("click", () => deleteElement(articulo.id));
            input.addEventListener("change", () => {
                for (let i = 0; i < carrito.length; i++) {
                    if (carrito[i].id === articulo.id) {
                        carrito[i].cantidad = parseInt(input.value);
                        if (carrito[i].cantidad < 1) {
                            deleteElement(articulo.id)
                        }
                        guardar();
                        mostrarCarrito();
                        actCarrito();
                    }
                }
            });

            content.appendChild(div1);
            content.appendChild(div2);
            content.appendChild(div3);
            butt.appendChild(div4);
            butt.appendChild(input);
            butt.appendChild(button);
            articuloDiv.appendChild(img);
            articuloDiv.appendChild(content);
            articuloDiv.appendChild(butt);

            productos.appendChild(articuloDiv);
            totaldiv.innerHTML = total.toFixed(2) + "€";
            console.log(total);
        }
    } else {
        productos.innerHTML = "Su carrito de compra está vacio.";
    }
}

//Eliminacion de producto

function deleteElement(id) {
    recuperar();
    for (let i = 0; i < carrito.length; i++) {
        if (carrito[i].id === id) {
            carrito.splice(i, 1);
            guardar();
            mostrarCarrito();
            actCarrito();
        }
    }
}

//Funcion actualizar cabecera carrito
function actCarrito() {
    recuperar();
    const cantcarr = document.getElementById("cantcarr");
    let c = 0;
    for (let elemento of carrito) {
        c += elemento.cantidad;
    }
    cantcarr.innerHTML = c;
}

//Local Storage
function recuperar() {
    JSONcarrito = localStorage.getItem("carrito");
    if (JSONcarrito != null) {
        carrito = JSON.parse(JSONcarrito);
    } else {
        carrito = new Array();
    }
}

function guardar() {
    localStorage.setItem("carrito", JSON.stringify(carrito));
}
