# Mi Windows Development Setup

- [Optimizar el sistema](#optimizar-el-sistema)
- [Laragon](#laragon)
- [Mobile Frameworks](#mobile-frameworks)
- [OpenJDK](#openjdk)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)

  
## Optimizar el sistema

Optimizar el sistema no siempre significa desactivar todo, hay funciones como la indizacion de archivos que si bien consume recursos, suele ser enormemente util cuando manejamos muchos archivos y proyectos a la vez. Otras funciones como la telemetría o las actualizaciones sin control que reinician el sistema sin nuestro permiso sin son necesarias desactivarlas para mejorar nuestra productividad en Windows y acelerar un poco el sistema.

Que deshabilitaremos entonces?
- Postergamos por 365 dia las actualizaciones del S.O. [WinSecurityOnly](https://gist.github.com/ctrbts/1e5061da8370bca85e3fca93dec3164c#file-win_security_only-reg) 
- Limitamos el uso de RAM de algunos procesos y tareas del sistema. [RAM Reducer](https://gist.github.com/ctrbts/0652898bf1eeb7b535f3d0bcecefa6b0#file-ram_reducer-reg) 
...
- Deshabilitar Cortana
- Desinstalar OneDrive

## Laragon
Laragon es un entorno de desarrollo universal portátil, aislado, rápido y potente para PHP, Node.js, Python, Java, Go, Ruby. Es rápido, liviano, fácil de usar y fácil de extender. Es ideal para crear y administrar aplicaciones web modernas. Se centra en el rendimiento, diseñado en torno a la estabilidad, la simplicidad, la flexibilidad y la libertad. 

Laragon es muy ligero, el binario central en sí tiene menos de 2 MB y utiliza menos de 4 MB de RAM cuando se ejecuta.

Laragon no usa los servicios de Windows. Tiene su propio service orchestration que administra los servicios de forma asincrónica y sin bloqueo, por lo que encontrará que las cosas funcionan rápido y sin problemas.

Para descargar el paquete completo [click aqui](https://github.com/leokhoa/laragon/releases/download/5.0.0/laragon-wamp.exe) o la versión portable desde [
aqui](https://github.com/leokhoa/laragon/releases/download/5.0.0/laragon-portable.zip)


## Mobile Frameworks

`npm i -g cordova framework7-cli @ionic/cli`


## OpenJDK

Instalamos el ***JDK*** desde https://adoptopenjdk.net/installation.html#installers


## Netbeans IDE

Development Environment, Tooling Platform and Application Framework.
To download > https://netbeans.apache.org/download/index.html

## Android Studio

Select the "SDK Platforms" tab from within the SDK Manager, then check the box next to "Show Package Details" in the bottom right corner. Look for and expand the Android 10 (Q) entry, then make sure the following items are checked:

- Android SDK Platform 29
- Intel x86 Atom_64 System Image or Google APIs Intel x86 Atom System Image

Next, select the "SDK Tools" tab and check the box next to "Show Package Details" here as well. Look for and expand the **Android SDK Build-Tools** entry, then make sure that **29.0.2** is selected.

Finally, click "Apply" to download and install the Android SDK and related build tools.
