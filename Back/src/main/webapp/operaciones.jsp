<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <!-- General meta information -->
        <title>Operaciones</title>
        <meta name="keywords" content="" />
        <meta name="description" content="" />
        <meta name="robots" content="index, follow" />
        <meta charset="utf-8" />
        <!-- // General meta information -->
        <!-- Load Javascript -->
        <script type="text/javascript" src="./js/jquery.js"></script>
        <script type="text/javascript" src="./js/jquery.query-2.1.7.js"></script>
        <script type="text/javascript" src="./js/rainbows.js"></script>
        <script type="text/javascript" src="./js/operaciones.js"></script>
        <!-- // Load Javascipt -->
        <!-- Load stylesheets -->
        <link type="text/css" rel="stylesheet" href="css/style.css" media="screen" />
        <!-- // Load stylesheets -->

        <!--Esta funcion permite opacar el boton con un hover
        <script>
                $(document).ready(function(){ 
                $("#submit1").hover(
                        function() {
                        $(this).animate({"opacity": "0"}, "slow");
                        },
                        function() {
                        $(this).animate({"opacity": "1"}, "slow");
                        });
                });
        </script>	-->
    </head>
    <body>
        <div id="wrapperOperaciones">                     
            <div id="existentes">
                <h2>Libros Existentes</h2>
                <form action="#" method="post">
                    <table class="tablaExistentes">
                        <tbody><tr>
                                <td>Titulo</td><td>En stock</td><td>Valor</td><td>Agregar Cantidad al Carro</td>
                            </tr>
                            <tr>
                                <td>Core Java</td><td>5</td><td>USD. 30</td><td><input type="text" name="q" value="0"></td>
                            </tr>
                            <tr>
                                <td>Ruby for Rails</td><td>12</td><td>USD. 20</td><td><input type="text" name="q" value="0"></td>
                            </tr>
                            <tr>
                                <td>Python Cookbook</td><td>7</td><td>USD. 35</td><td><input type="text" name="q" value="0"></td>
                            </tr>
                        </tbody>
                    </table>
                    <br/>
                    <div align="center">
                        <input type="button" class="btnOperaciones" value="Agregar" onclick="addToCart()"/> 
                        <input type="button" class="btnOperaciones" value="Limpiar" onclick="clearCart()"/>
                        <input type="button" class="btnOperaciones" value="Salir" onclick="location.href = 'index.jsp'"/>
                    </div>
                </form>                
            </div>
            <div id="miCarro">
                <h2>Mi Carro de Compras</h2>
                <div id="tablaCarro">
                    <table class="tablaExistentes">
                        <tbody>
                            <tr>
                                <td>Titulo</td>
                                <td>Cantidad</td>
                                <td>Valor Unidad</td>
                                <td>Valor Total</td>
                            </tr>
                        </tbody>
                    </table>
                </div>    
                <br/>
                <br/>
                <div align="center">
                    Grand Total: <input type="text" id="total" value="0"/> 
                </div>
            </div>
            <div id="powered">
                <p><a href="http://www.qvision.us/index.php/">Q-Vision Technologies</a></p>
            </div>            
        </div>        
    </body>
</html>