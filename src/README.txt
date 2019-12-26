
# Important Note

If you see this file, you have not mounted any persistent storage (aka volume) to this Docker container.

None of your files will be saved after you exit the container!

You can use the -v argument to specify a folder to mount as a volume as follows

nvidia-docker run --rm -it \
 -v /home/$USER:/home/jovyan \
 nvaitc/ai-lab:19.11-batch bash



