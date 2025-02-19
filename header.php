<script src="js/carrito.js"></script>
<script src="js/index.js"></script>
<header>
    <nav>
        <section id="izq">
            <a href="index.php" class="logo">Step<span>Up</span></a>
            <a href="registro.php">Registro</a>
            <a href="">Login</a>
        </section>
        <section>
            <?php
                session_start();
                if(isset($_SESSION["user"])){
                    echo "<button>Cerrar Sesión</button>";
                }else{
                    echo "<button>Iniciar Sesión</button>";
                }
            ?>
            <button class="carr" onclick= "window.location.href='carrito.php'"></button>
            <div id="cantcarr"></div>
        </section>
    </nav>
</header>
