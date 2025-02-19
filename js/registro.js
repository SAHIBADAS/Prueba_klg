window.addEventListener("load", function () {
    const inputEmail = document.getElementById("email");
    inputEmail.addEventListener("blur", comprobarEmail);

    const inputNombre = document.getElementById("nombre");
    inputNombre.addEventListener("blur", function () {
        validarCamposVacios(inputNombre);
    });

    const inputApellidos = document.getElementById("apellidos");
    inputApellidos.addEventListener("blur", function () {
        validarCamposVacios(inputApellidos);
    });

    const inputClave = document.getElementById("clave");
    inputClave.addEventListener("blur", function () {
        validarClave(inputClave);
    });
    
    const formRegistro = document.getElementById("registro");
    formRegistro.addEventListener("submit", function (e) {
        // Evita el envío del formulario si algún campo no es válido
        if (!comprobarEmail() || !validarCamposVacios(inputNombre) || !validarCamposVacios(inputClave) || !validarClave(inputClave)) {
            e.preventDefault();
        }
    })
});

// Función que hace una petición fetch para comprobar si un email ya existe en la base de datos
function comprobarEmail() {
    let email = document.getElementById("email");

    let jsonData = {
        email: email.value
    };

    let options = {
        method: "POST",
        headers: { "Content-type": "application/json" },
        body: JSON.stringify(jsonData)
    }

    fetch("peticionEmail.php", options)
        .then(response => {
            if (response.ok) {
                return response.json();
            }
            throw new Error(response.status);
        })
        .then(data => {
            console.log(data);
            let existe = data["existe"];
            if (!existe) {
                validarEmail(email);
                console.log("no encontrado");
            } else if (existe && data["tipo"] == "invitado") {
                console.log("invitado");
            } else {
                let spanNoValido = document.getElementById("emailNoValido");
                spanNoValido.classList.add('hide');
                let span = document.getElementById("emailUsado");
                span.classList.remove('hide');
                console.log("encontrado");
            }
        })
}

// Función que valida el email introducido en el formulario
function validarEmail(input) {
    let spanUsado = document.getElementById("emailUsado");
    spanUsado.classList.add('hide');
    let span = document.getElementById("emailNoValido");
    let patron = /^[\w-]{3,20}@[\w]{3,20}\.[A-Za-z]{2,3}$/;
    let variable = input.value;
    let verificacion = patron.test(variable);

    console.log(variable, verificacion);

    if (!verificacion) {
        span.classList.remove('hide');
    } else {
        span.classList.add('hide');
    }
    return verificacion;
}

// Función que valida que los campos en el formulario no se encuentren vacios
function validarCamposVacios(input) {
    let campo = input.id;
    let spanVacio = document.getElementById("error"+campo);
    spanVacio.classList.add('hide');
    if (input.value.trim() == "") {
        spanVacio.classList.remove('hide');
        return false;
    }
    return true;
}

// Función que valida la clave introducida en el formulario
function validarClave(input) {
    let clave = input.value;
    let spanClave = document.getElementById("errorClave");
    spanClave.classList.add('hide');
    let mayor_a_8 = clave.length >= 8;
    let mayus = /[A-Z]/.test(clave);
    let minus = /[a-z]/.test(clave);
    let alfanum = /[\w>]/.test(clave);
    let num = /[\d]/.test(clave);
    if (!mayor_a_8 || !mayus || !minus || !alfanum || !num) {
        spanClave.classList.remove('hide');
        return false;
    }
    return true;
}