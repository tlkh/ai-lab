from tkinter import *
from tkinter import filedialog, messagebox
import os
import shlex
import subprocess
import webbrowser

import time

try:
    import docker
    client = docker.from_env()
except Exception as e:
    messagebox.showerror("Error: Port number", str(e)+":\nEither Docker or Docker python API or both not installed")

def start_notebook():
    lbl_output.config(text="Launching Jupyter Notebook")
    try:
        container = client.containers.get("ai-lab-gui")
    except Exception as e:
        print(e)
        start_server()
        time.sleep(1)
    port_num = str(int(txt_port.get()))
    webbrowser.open_new_tab("http://localhost:"+port_num+"/tree?")
    lbl_output.config(text="Launched Jupyter Notebook")


def start_lab():
    lbl_output.config(text="Launching JupyterLab")
    try:
        container = client.containers.get("ai-lab-gui")
    except Exception as e:
        print(e)
        start_server()
        time.sleep(1)
    port_num = str(int(txt_port.get()))
    webbrowser.open_new_tab("http://localhost:"+port_num+"/lab")
    lbl_output.config(text="Launched JupyterLab")


def start_server():
    lbl_output.config(text="Starting server")
    try:
        container = client.containers.get("ai-lab-gui")
    except Exception as e:
        print(e)
        try:
            try:
                port_num = int(txt_port.get())
                ports_dict = {'8888/tcp': port_num}

            except Exception as e:
                messagebox.showerror("Error: Port number", str(
                    e)+":\nCheck if your port is a valid port!")

            vol_mount = str(txt_volume.get())
            if vol_mount == "":
                messagebox.showerror("Error: Volume mount",
                                     "Volume mount cannot be empty!")

            vols_dict = {vol_mount: {'bind': '/home/jovyan', 'mode': 'rw'}}

            tag_version = str(txt_tag.get())
            if tag_version == "":
                tag_version = "latest"

            cnt_name = 'nvaitc/ai-lab:'+tag_version

            pull_image(cnt_name)

            container = client.containers.run(cnt_name, auto_remove=True, detach=True,
                                              name="ai-lab-gui",
                                              ports=ports_dict, remove=True, shm_size="1g",
                                              volumes=vols_dict)

            lbl_output.config(text="Started container "+cnt_name)

        except Exception as e:
            messagebox.showerror("Unable to start container", str(e))


def pull_image(cnt_name="nvaitc/ai-lab:latest"):
    lbl_output.config(text="Pulling image "+cnt_name)
    client.images.pull(cnt_name)
    lbl_output.config(text="Pulled image "+cnt_name)


def stop_server():
    lbl_output.config(text="Stopping Server")
    try:
        container = client.containers.get("ai-lab-gui")
        container.stop()
        lbl_output.config(text="Stopped Server")
    except Exception as e:
        messagebox.showerror("Unable to stop container", str(e))


def choose_folder():
    window.directory = filedialog.askdirectory()
    vol_dir = str(window.directory)
    txt_volume.delete(0, END)
    txt_volume.insert(0, vol_dir)


def show_about():
    webbrowser.open_new_tab("https://nvaitc.github.io/ai-lab/")


def show_tags():
    webbrowser.open_new_tab("https://hub.docker.com/r/nvaitc/ai-lab/tags")


def show_help():
    webbrowser.open_new_tab(
        "https://github.com/NVAITC/ai-lab/blob/master/INSTRUCTIONS.md")


window = Tk()

window.title("AI Lab Control Panel")

#

lbl_heading = Label(window, text="\nAI Lab Container Settings\n",
                    font=("Helvetica", 16, "bold"))
lbl_heading.grid(column=1, row=0)

#

lbl_volume = Label(window, text="Volume Mount:")
lbl_volume.grid(column=0, row=1)
txt_volume = Entry(window, width=20)
txt_volume.grid(column=1, row=1)

btn_notebook = Button(window, text="Choose Folder", command=choose_folder)
btn_notebook.grid(column=2, row=1)

#

lbl_port = Label(window, text="Port mapping:")
lbl_port.grid(column=0, row=2)
txt_port = Entry(window, width=20)
txt_port.insert(0, "8888")
txt_port.grid(column=1, row=2)

#

lbl_tag = Label(window, text="Tag (version):")
lbl_tag.grid(column=0, row=3)
txt_tag = Entry(window, width=20)
txt_tag.grid(column=1, row=3)

btn_notebook = Button(
    window, text="Launch Jupyter Notebook", command=start_notebook)
btn_notebook.grid(column=1, row=100)
btn_notebook = Button(window, text="Launch JupyterLab", command=start_lab)
btn_notebook.grid(column=1, row=101)

btn_notebook = Button(window, text="Stop Container", command=stop_server)
btn_notebook.grid(column=2, row=100)

lbl_output = Label(window, text="")
lbl_output.grid(column=1, row=199)

lbl_foot = Label(window, text="\nAn Open Source initiative by NVAITC")
lbl_foot.grid(column=1, row=200)

menu = Menu(window)

main_menu = Menu(menu)
main_menu.add_command(label='Reset All Options')
main_menu.add_command(label='Pull Latest Container', command=pull_image)
main_menu.add_command(label='About nvaitc/ai-lab', command=show_about)
menu.add_cascade(label='Menu', menu=main_menu)

help_menu = Menu(menu)
help_menu.add_command(label='Quick start guide', command=show_help)
help_menu.add_command(label='Check available tags', command=show_tags)
menu.add_cascade(label='Help', menu=help_menu)

window.config(menu=menu)

window.mainloop()
