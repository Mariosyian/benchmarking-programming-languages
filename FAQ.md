# FAQ
These are possible problems that someone may run into whilst running or setting up the project:

## [Docker] Got permission denied
---
### Problem
Attempts to run the Docker container but receives `docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock...`

### Solution
Ensure that the Docker group exists and your user is assigned to it (may require a machine reboot):
```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
```
Ensure that the `docker.sock` file has the correct permissions:
```
$ sudo chmod 666 /var/run/docker.sock
```
