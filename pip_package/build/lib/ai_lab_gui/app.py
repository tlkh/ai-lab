import flask
from flask import Flask, render_template

import docker


class DockerCTL(object):

    def __init__(self, cnt_name="nvaitc/ai-lab"):
        self.cnt_name = cnt_name
        self.client = docker.from_env()

    def pull_cnt(self, tag):
        self.client.images.pull(self.cnt_name+":"+tag)

    def start_cnt(self, port, vol, tag):
        try:
            container = self.client.containers.get("ai-lab-gui")
            self.stop_cnt()
        except Exception as e:
            print("[INFO  ] Expected: ", str(e),
                  " i.e. Container does not exist")

        cnt_name = self.cnt_name+":"+tag
        ports_dict = {'8888/tcp': port}
        vols_dict = {vol: {'bind': '/home/jovyan', 'mode': 'rw'}}
        container = self.client.containers.run(cnt_name, auto_remove=True, detach=True,
                                               name="ai-lab-gui",
                                               ports=ports_dict, remove=True, shm_size="1g",
                                               volumes=vols_dict)
        return container

    def stop_cnt(self):
        container = self.client.containers.get("ai-lab-gui")
        container.stop()

    def get_cnt(self):
        try:
            container = self.client.containers.get("ai-lab-gui")
        except Exception:
            container = None
        return container


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


@app.route('/pull', methods=["POST"])
def pull_image():
    print("[INFO  ] Pulling image")
    try:
        tag = flask.request.args.get("tag")

        dctl.pull_cnt(tag)

        print("[INFO  ] Pulled image")
        response = {"status": "ok"}

    except Exception as e:
        print("[ERROR ] "+str(e))
        response = {"status": str(e)}

    return flask.jsonify(response)


@app.route('/query', methods=["GET"])
def get_server_data():
    try:
        container = dctl.get_cnt()

        #print("\n", container.attrs, "\n")

        port_binding = container.attrs["HostConfig"]["PortBindings"]["8888/tcp"][0]["HostPort"]
        vol_mount = container.attrs["HostConfig"]["Binds"]
        runtime = container.attrs["HostConfig"]["Runtime"]
        image = container.attrs["Config"]["Image"]
        state = container.attrs["State"]["Status"]

        env = container.attrs["Config"]["Env"]
        cuda_version = "unknown"
        nccl_version = "unknown"
        for item in env:
            if "CUDA_VERSION" in item:
                cuda_version = item.replace("_VERSION", "")
            elif "NCCL_VERSION" in item:
                nccl_version = item.replace("_VERSION", "")

        logs = str(container.logs())[-4000:]

        print("[INFO  ] Container state:", state)
        print("[INFO  ] Port binding:", port_binding)
        print("[INFO  ] Volume mount:", vol_mount)

        response = {"state": state,
                    "cuda": cuda_version,
                    "nccl": nccl_version,
                    "image": image,
                    "runtime": runtime,
                    "port": port_binding,
                    "vol": vol_mount,
                    "logs": logs}

    except Exception as e:
        response = {"state": "not running",
                    "cuda": "unknown",
                    "nccl": "unknown",
                    "image": "none",
                    "runtime": "none",
                    "port": "none",
                    "vol": "none",
                    "logs": "No logs: "+str(e)}

    return flask.jsonify(response)


def main():
    import threading
    import webbrowser
    port = 5050
    url = "http://0.0.0.0:"+str(port)
    try:
        threading.Timer(1.25, lambda: webbrowser.open(url)).start()
    except Exception as e:
        print("[ERROR ] "+str(e))
    app.run(debug=False, port=port, host='0.0.0.0')


if __name__ == "__main__":
    main()
