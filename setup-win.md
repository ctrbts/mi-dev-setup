# Mi Windows Development Setup

- [Optimizar el sistema](#optimizar-el-sistema)
- [Laragon](#laragon)
- [Mobile Frameworks](#mobile-frameworks)
- [OpenJDK](#openjdk)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)

  
## Optimizar el sistema

[win10script](https://github.com/ChrisTitusTech/win10script) Es un script powershell de Windows 10 creado a partir de múltiples scripts de debloat y gists de github. Es una navaja suiza para máquinas nuevas o modificar existentes, ahorrando tiempo de configuración y fundamentalmente recursos del sistema operativo.

Que hace este script:
- Instala programas de uso habitual
- Elimina la telemetría
- Desactiva Cortana
- Elimina varias tareas programadas que ralentizan el sistema

Para ejecutarlo alcanza con copiar y pegar el siguiente script en una sesión de administrador de PowerShell

    iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/JJ8R4'))

Y si se necesita restaurar las acciones anteriores con el siguiente

    iex ((New-Object System.Net.WebClient).DownloadString('https://git.io/JTbKD'))

Esta basado en estos dos proyectos muy interesantes
- https://github.com/Sycnex/Windows10Debloater
- https://github.com/farag2/Windows-10-Setup-Script

La manera óptima de utilizar esta herramienta es en las siguientes condiciones:
- Antes de que se cree el perfil de usuario (puede ejecutar el script y después agregar un nuevo perfil)
- Con elscritorio vacío y descargas vacías (algunas configs han eliminado archivos del escritorio y descargas)
- Después de instalar las actualizaciones de nuevas funciones en Windows Update

Mi recomendación es:
- Deshabilitar Cortana
- Desinstalar OneDrive
- Ejecutar ajustes esenciales
- Siempre habilito el modo oscuro e instalo 3.5 .NET.


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
