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

        print("[INFO  ] Started container:")
        print(container.attrs)
        print("[INFO  ] Port binding:", container.attrs["HostConfig"]["PortBindings"]["8888/tcp"])
        print("[INFO  ] Volume mount:", container.attrs["HostConfig"]["Binds"])


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


if __name__ == "__main__":
    app.run(debug=True)
