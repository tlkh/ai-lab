import os
from notebook.utils import url_path_join as ujoin
from jupyter_server_proxy.handlers import AddSlashHandler, SuperviseAndProxyHandler

class NoVNCHandler(SuperviseAndProxyHandler):
    '''Supervise novnc, websockify, and a VNC server.'''
    def initialize(self, state):
        print("NoVNCHandler Init: %s" % state)
        if not 'vnc' in state:
             state['vnc'] = True
             os.system('/opt/TurboVNC/bin/vncserver -SecurityTypes None :1')
        super().initialize(state)

    def get_cmd(self):
        return ['/opt/noVNC/utils/websockify/run',
                 str(self.port),
                 'localhost:5901',
                 '--web=/opt/noVNC'] 
    
    async def get(self, path):
        '''
        When clients visit novnc/, actually get novnc/vnc.html.

        vnc_lite.html (fomerly vnc_auto.html) was described as an example of
        how to use novnc, rather than a supported frontend, so we do not use
        it.
        '''
        if len(path) == 0:
            path = 'vnc.html'
        return await super().get(path)

def setup_handlers(web_app):
    web_app.add_handlers('.*', [
        (ujoin(web_app.settings['base_url'], 'novnc/(.*)'), NoVNCHandler,
            dict(state={})),
        (ujoin(web_app.settings['base_url'], 'novnc'), AddSlashHandler)
    ])
