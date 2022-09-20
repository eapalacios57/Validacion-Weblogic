<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <!-- General meta information -->
        <title>Login Form</title>
        <meta name="keywords" content="" />
        <meta name="description" content="" />
        <meta name="robots" content="index, follow" />
        <meta charset="utf-8" />
        <!-- // General meta information -->
        <!-- Load Javascript -->
        <script type="text/javascript" src="./js/jquery.js"></script>
        <script type="text/javascript" src="./js/jquery.query-2.1.7.js"></script>
        <script type="text/javascript" src="./js/rainbows.js"></script>
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
        <script>
            function login() {
                if (document.loginForm.user.value === "qmatic@qvision.com.co" && document.loginForm.password.value === "secret") {
                    window.location.href = 'operaciones.jsp';
                } else {
                    document.getElementById('errorMessage').style.display = 'block';
                }
            }
        </script>
    </head>
    <body>
        <div id="wrapper">
            <div id="logoSura"></div>
            <div id="wrappertop"></div>
            <div id="wrappermiddle">                
                <h2>Hola equipo 28/05/2021</h2>                
                <form method="post" action="GestionSesiones" name="loginForm" >
                    <div id="username_input">
                        <div id="username_inputleft"></div>
                        <div id="username_inputmiddle">					
                            <input type="email" name="user" id="url" autocomplete="off" placeholder="E-mail"/>
                            <img id="url_user" src="./images/mailicon.png" alt=""/>					
                        </div>
                        <div id="username_inputright"></div>
                    </div>
                    <div id="password_input">
                        <div id="password_inputleft"></div>
                        <div id="password_inputmiddle">
                            <input type="password" name="password" id="url" placeholder="Password"/>
                            <img id="url_password" src="./images/passicon.png" alt="" />					
                        </div>
                        <div id="password_inputright"></div>
                    </div>
                    <div id="submit" align="center">				
                        <input name="btnLogin" class="btnOperaciones" style="width: 100%" type="submit" src="./images/submit.png" id="submit1" value="Iniciar" />
                        <!--<input type="image" src="./images/submit.png" id="submit2" value="Sign In">				-->
                    </div>
                </form>
                <%
                    if (request.getAttribute("Error") != null) {
                        String noti = (String) request.getAttribute("Error");
                %>
                <div id="errorMessage" align="center" style="display:block;color:#ff9900;font-family:helvetica, sans-serif;font-size:12px;">
                    <%=noti%>
                </div>
                <%
                    }
                %>
                <div id="links_left">
                    <a href="#">Olvidaste tu Contraseña?</a>
                </div>
                <div id="links_right"><a href="#">Aún no estas Registrado?</a></div>
            </div>
            <div id="wrapperbottom"></div>		
            <div id="powered">
                <p><a href="http://www.qvision.us/index.php/">Q-Vision Technologies</a></p>
            </div>
            <div id="datos" align="center">
                <br/>
                <br/>
                <br/>
                <p>Email: qmatic@qvision.com.co</p>
                <p>Pass: secret</p>
            </div>
        </div>        
    </body>
</html>