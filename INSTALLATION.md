# GCC + GNU make
```
$ sudo apt install make build-essential
```

# Optional
# Unix `column` command (for benchmark script)
```
$ wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.35/util-linux-2.35-rc1.tar.gz
$ tar xfz util-linux-2.35-rc1.tar.gz
$ cd util-linux-2.35-rc1
$ ./configure
$ make column
$ cp .libs/column /bin/
```

# Python
```
$ sudo apt install python3 pip
# Change directory to the root of the project
$ pip install -r requirements_dev.txt --user
```

# Java
```
$ sudo apt install default-jdk-headless
```

# Rust
```
$ sudo apt install rustc
```

# Install GoLang
```
$ wget https://go.dev/dl/go1.17.8.linux-amd64.tar.gz
$ rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.8.linux-amd64.tar.gz
# For Ubuntu users (Update ~/.bashrc)
$ echo -e "\nexport PATH="/usr/local/go/bin:$PATH" >> ~/.bashrc
# Optional
$ rm go1.17.8.linux-amd64.tar.gz
```

# Install Haxe, Haxelib, and Neko VM
```
# Change directory to where you want to download this file. 
# Install Haxe and Haxelib
$ wget https://github.com/HaxeFoundation/haxe/releases/download/4.2.5/haxe-4.2.5-linux64.tar.gz
$ tar xfz haxe-4.2.5-linux64.tar.gz
$ mv haxe_20220306074705_e5eec31/ /usr/local/haxe
# For Ubuntu users (Update ~/.bashrc)
$ echo -e "\nexport PATH="/usr/local/haxe:$PATH" >> ~/.
# Optional
$ rm haxe-4.2.5-linux64.tar.gz

# Install Neko (Haxe VM)
$ add-apt-repository ppa:haxe/snapshots
$ sudo apt update
$ sudo apt install neko
```
