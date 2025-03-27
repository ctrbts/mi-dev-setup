# Docker Development Setup

### Primeros pasos

Agregar um usuario con permisos de administrador

    adduser NOMBRE_DE_USUARIO && usermod -aG sudo NOMBRE_DE_USUARIO

Desactivar el inicio de sesión SSH para root:

Abrimos una terminal y ejecutamos el siguiente comando para editar el archivo sshd_config con privilegios de superusuario:
    
    sudo nano /etc/ssh/sshd_config

Buscamos la línea que dice `PermitRootLogin yes` o `#PermitRootLogin prohibit-password`. Cambiamos *yes* a *no* o descomentamos la linea y dejamos `PermitRootLogin prohibit-password`.
Si no existe la linea, la agregamosa.
Guarda los cambios y reiniciamos el servicio SSH:

    sudo systemctl restart sshd

## Docker

Actualizamos el sistema y agregamos algunas herramientas necesarias

    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    sudo apt install curl git zsh mc nmap ssh htop -y

Seteamos el timezone

    sudo timedatectl set-timezone TU_TIMEZONE
[//]: # (sudo timedatectl set-timezone America/Argentina/Buenos_Aires) 

Actualizamos los paquertes de y agregamos las claves y el repo:

    # Agregar  la Docker's official GPG key:
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Agregamos el repositorio a apt:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

Instalamos la última versión

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Después d einstalar agregamos nuestro usuario a Docker para evitar problemas con permisos

    sudo usermod -aG docker $USER

Verificamos que la instalacion haya teni éxito corriendo la imágen `hello-world`:

    sudo docker run hello-world
