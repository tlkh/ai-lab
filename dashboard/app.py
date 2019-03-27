import flask
from flask import Flask, render_template

from dockerctl import DockerCTL

app = Flask(__name__)

dctl = DockerCTL()


@app.route('/')
@app.route('/index')
def index():
    return render_template("index.html")


@app.route('/start', methods=["POST"])
def start_server():
    print("[INFO  ] Starting container")
    try:
        port = flask.request.args.get("port")
        vol = flask.request.args.get("vol")
        tag = flask.request.args.get("tag")

        container = dctl.start_cnt(port, vol, tag)

        print("[INFO  ] Started container")

    except Exception as e:
        print("[ERROR ] "+str(e))

    return render_template("index.html")


@app.route('/stop', methods=["POST"])
def end_server():
    print("[INFO  ] Stopping container")
    try:
        dctl.stop_cnt()
        print("[INFO  ] Stopped container")
    except Exception as e:
        print("[ERROR ] "+str(e))

    return render_template("index.html")


@app.route('/query', methods=["GET"])
def get_server_data():
    try:
        container = dctl.get_cnt()

        #print("\n",container.attrs,"\n")

        port_binding = container.attrs["HostConfig"]["PortBindings"]["8888/tcp"][0]["HostPort"]
        vol_mount = container.attrs["HostConfig"]["Binds"]
        state = container.attrs["State"]["Status"]

        logs = str(container.logs())

        print("[INFO  ] Container state:", state)
        print("[INFO  ] Port binding:", port_binding)
        print("[INFO  ] Volume mount:", vol_mount)

        response = {"state": state,
                    "port": port_binding,
                    "vol": vol_mount,
                    "logs": logs}

    except Exception as e:
        response = {"state": "Not running",
                    "port": "Not running",
                    "vol": "Not running",
                    "logs": "No logs", 
                    "error": str(e)}

    return flask.jsonify(response)


if __name__ == "__main__":
    app.run(debug=True)
