
var inputport1 = document.getElementById("inputport1");
var inputvolume1 = document.getElementById("inputvolume1");
var inputtag1 = document.getElementById("inputtag1");

var display_port = document.getElementById("display_port");
var display_vol = document.getElementById("display_vol");
var display_state = document.getElementById("display_state");
var display_output = document.getElementById("display_output");

var open_nb = document.getElementById("open_nb");
var open_lab = document.getElementById("open_lab");

var port;

function post(path, method) {
    method = method || "post";

    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    document.body.appendChild(form);
    form.submit();
}

document.getElementById("startContainer").onclick = function () {
    console.log("Starting container");
    var path = "/start";
    var port_mount = inputport1.value;
    if (port_mount=="") {
        port_mount="8888";
    }
    var tag_mount = inputtag1.value;
    if (tag_mount=="") {
        tag_mount="latest";
    }
    var volume_mount = inputvolume1.value;
    if (volume_mount=="") {
        alert("Volume mount cannot be empty");
    } else {
        path = path + "?port=" + port_mount + "&vol=" + volume_mount + "&tag=" + tag_mount;
        console.log(path);
        post(path);
    }
}

document.getElementById("stopContainer").onclick = function () {
    console.log("Stopping container");
    var path = "/stop";
    console.log(path);
    post(path);
}

function update_display() {
    var Http = new XMLHttpRequest();
    var url = '/query';
    Http.open("GET", url);
    Http.send();
    Http.onreadystatechange = (e) => {
        //console.log(Http.responseText)
        var response = JSON.parse(Http.responseText);
        display_port.innerHTML = "<code>" + response["port"] + "</code>";
        port = response["port"];
        open_nb.href = "http://localhost:" + port + "/tree"
        open_lab.href = "http://localhost:" + port + "/lab"

        var volume_mount = response["vol"].toString();
        display_vol.innerHTML = "<code>" + volume_mount.split(":")[0] + "</code>";

        var logs = response["logs"].toString().replace(/'/g,"").replace(/\\n/g,"<br>");
        display_output.innerHTML = "<pre><code>"+logs.substring(logs.length - 2000, logs.length)+"</code></pre>";

        var state = response["state"]
        if (state == "running") {
            display_state.classList.remove("badge-danger");
            display_state.classList.remove("badge-warning");
            display_state.classList.add("badge-success");
        } else {
            if (state == "Not running") {
                display_state.classList.remove("badge-success");
                display_state.classList.remove("badge-warning");
                display_state.classList.add("badge-danger");
            }
            else {
                display_state.classList.remove("badge-success");
                display_state.classList.remove("badge-danger");
                display_state.classList.add("badge-warning");
            }
        }
        display_state.innerHTML = response["state"];

    }
}

window.onload = function () {
    update_display();
}

function poll_loop() {
    update_display();

    setTimeout(poll_loop, 5000);
}

poll_loop();
