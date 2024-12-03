## Actualización

### Actualizar el sistema y sus programas

```shell
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove && sudo apt autoclean -y
```
* **update:** actualiza la lista de paquetes para comprobar si hay nuevos.
* **full-upgrade:** actualiza tanto los paquetes instalados como otros del sistema como el kernel y los paquetes snap.
* **autoclean:** eliminan la caché local de paquetes.

[Más información sobre clean y autoclean](https://askubuntu.com/a/3169)

### Limitar el total de paquetes instalados por snap

En este caso no solamente limita la cantidad de versiones de un mismo paqueto
sino que además desinstala las versiones antiguas.

Listamos los paquetes. Este comando no requiere `sudo`:

```shell
snap list
```

#### Mantener solamente dos versiones de tus paquetes instalados

El mínimo es dos, pero puedes poner los que quieras.

```shell
sudo snap set system refresh.retain=2
```

## Eliminación

### Eliminar paquetes innecesarios y sus configuraciones

```shell
sudo apt autoremove --purge
```

* **autoremove:** elimina todos los paquetes que ya no son necesarios.
Suele ocurrir cuando se desinstala algún programa y quedan dependencias de este que ya no se usan.

* **--purge:** elimina todos los ficheros relacionados (configuración, etc.) de los paquetes desinstalados.
**Usar con precaución**, dependiendo de lo que borres podrías eliminar ficheros importantes (no suele ser normal).
