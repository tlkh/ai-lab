import docker


class DockerCTL(object):

    def __init__(self, cnt_name="nvaitc/ai-lab"):
        self.cnt_name = cnt_name
        self.client = docker.from_env()

    def pull_cnt(self, tag):
        self.client.images.pull(self.cnt_name+":"+tag)

    def start_cnt(self, port, vol, tag):
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
