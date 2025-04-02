# Mantenimiento de Ubuntu

- [Todo en un script](#todo-en-un-script)

## Actualizar todo el sistema

```shell
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean
```
* **update:** actualiza la lista de paquetes para comprobar si hay nuevos.
* **full-upgrade:** actualiza tanto los paquetes instalados como otros del sistema como el kernel y los paquetes snap.
* **autoclean:** eliminan la caché local de paquetes.

[Más información sobre clean y autoclean](https://askubuntu.com/a/3169)

## Limitar snap instalados

Limitamos la cantidad de versiones de un mismo paquete y desinstalamos las versiones antiguas.

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

* **autoremove:** elimina todos los paquetes que ya no son necesarios.
Suele ocurrir cuando se desinstala algún programa y quedan dependencias de este que ya no se usan.

* **--purge:** elimina todos los ficheros relacionados (configuración, etc.) de los paquetes desinstalados.
**Usar con precaución**, dependiendo de lo que borres podrías eliminar ficheros importantes (no suele ser normal).

## Todo en un script
```shell
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean && sudo snap set system refresh.retain=2 && sudo apt autoremove --purge
```