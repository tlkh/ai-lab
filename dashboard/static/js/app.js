
var inputport1 = document.getElementById("inputport1")
var inputvolume1 = document.getElementById("inputvolume1")
var inputtag1 = document.getElementById("inputtag1")

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
    var volume_mount = inputvolume1.value;
    var tag_mount = inputtag1.value;
    path = path + "?port=" + port_mount + "&vol=" + volume_mount + "&tag=" + tag_mount;
    console.log(path);
    post(path);
}

document.getElementById("stopContainer").onclick = function () {
    console.log("Stopping container");
    var path = "/stop";
    console.log(path);
    post(path);
}


