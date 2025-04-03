# Mantenimiento de Ubuntu

## Configuración inicial de un servidor Ubuntu

### Crear un usuario administrador

```shell
adduser NOMBRE_DE_USUARIO && usermod -aG sudo NOMBRE_DE_USUARIO
```

### Setear el timezone

```shell
sudo timedatectl set-timezone America/Argentina/Buenos_Aires
```

### Desactivar el inicio de sesión SSH para root:

Abrimos una terminal y ejecutamos el siguiente comando para editar el archivo sshd_config con privilegios de superusuario:

```shell
sudo nano /etc/ssh/sshd_config
```

Buscamos la línea que dice `PermitRootLogin yes` o `#PermitRootLogin prohibit-password`. Cambiamos _yes_ a _no_ o descomentamos la linea y dejamos `PermitRootLogin prohibit-password`.
Si no existe la linea, la agregamosa.
Guarda los cambios y reiniciamos el servicio SSH:

```shell
sudo systemctl restart sshd
```

## Actualizar todo el sistema

```shell
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean
```

- **update:** actualiza la lista de paquetes para comprobar si hay nuevos.
- **full-upgrade:** actualiza tanto los paquetes instalados como otros del sistema como el kernel y los paquetes snap.
- **autoclean:** eliminan la caché local de paquetes.

[Más información sobre clean y autoclean](https://askubuntu.com/a/3169)

### Agregamos alguna heramientas útiles para nuestro sevidor

```shell
sudo apt install curl git zsh mc nmap ssh htop -y
```

## Limitar snap instalados

Limitarmos la cantidad de versiones de un mismo paquete y desinstalamos las versiones antiguas.

Primero listamos los paquetes. Este comando no requiere `sudo`:

```shell
snap list
```

Establecemos el mínimo en dos.

```shell
sudo snap set system refresh.retain=2
```

## Eliminamos por completo paquetes innecesarios

```shell
sudo apt autoremove --purge
```

- **autoremove:** elimina todos los paquetes que ya no son necesarios.
  Suele ocurrir cuando se desinstala algún programa y quedan dependencias de este que ya no se usan.

- **--purge:** elimina todos los ficheros relacionados (configuración, etc.) de los paquetes desinstalados.
  **Usar con precaución**, dependiendo de lo que borres podrías eliminar ficheros importantes (no suele ser normal).
