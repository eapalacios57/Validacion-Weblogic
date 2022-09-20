function addToCart() {
    var s = "<table class='tablaExistentes' id='added'><tr><td>Titulo</td><td>Cantidad</td><td>Valor Unidad</td><td>Valor Total</td></tr>";
    var sum = 0;
    for (var i = 0; i < books.length; i++) {
        var book = books[i];
        var el = document.getElementsByTagName("INPUT")[book.i];
        var val = parseInt(el.value);
        if (val > 0) {
            s += "<tr><td>" + book.t + "</td><td>" + el.value + "</td><td>USD." + book.q + "</td><td> USD." + (val * book.q) + "</td></tr>";
            sum += val * book.q;
        }
    }
    s += "</table>";
    //alert(document.getElementById("cartDiv").innerHTML);
    document.getElementById("tablaCarro").innerHTML = s;
    document.getElementById("total").value = sum;
}

var books = [{"t": "Core Java", "q": 30, "i": 0}, {"t": "Ruby for Rails", "q": 20, "i": 1}, {"t": "Python Cookbook", "q": 35, "i": 2}];

function clearCart() {
    for (var i = 0; i < books.length; i++) {
        document.getElementsByTagName("INPUT")[i].value = "";
    }
    addToCart();
}


