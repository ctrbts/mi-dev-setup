# Mi Windows Development Setup

- [Optimizar el sistema](#optimizar-el-sistema)
- [Laragon](#laragon)
  - [Node modules](#node-modules)
- [Netbeans IDE](#netbeans-ide)
- [Android Studio](#android-studio)

  
## Optimizar el sistema

Copiar y pegar la siguiente línea en una ventana de poweshell con privilegios de administrador

    iwr -useb https://christitus.com/win | iex

Que puede hacer este script
- Instala cualquier programa de la lista en el que haga clic con WinGet
- Telemetría eliminada
- Desactiva Cortana
- Elimina varias tareas programadas que reflotan el sistema
- Soluciona problemas causados ​​por otros scripts (bloqueo de pantalla y opciones de personalización restringidas)


## Laragon
Laragon es un entorno de desarrollo universal portátil, aislado, rápido y potente para PHP, Node.js, Python, Java, Go, Ruby. Es rápido, liviano, fácil de usar y fácil de extender. Es ideal para crear y administrar aplicaciones web modernas. Se centra en el rendimiento, diseñado en torno a la estabilidad, la simplicidad, la flexibilidad y la libertad. 

Laragon es muy ligero, el binario central en sí tiene menos de 2 MB y utiliza menos de 4 MB de RAM cuando se ejecuta.

Laragon no usa los servicios de Windows. Tiene su propio service orchestration que administra los servicios de forma asincrónica y sin bloqueo, por lo que encontrará que las cosas funcionan rápido y sin problemas.

Para descargar el paquete [click aqui](https://github.com/leokhoa/laragon/releases)

## Node modules

    npm i -g cordova framework7-cli @ionic/cli express-generator yarn

## Netbeans IDE

Development Environment, Tooling Platform and Application Framework.
To download > https://netbeans.apache.org/download/index.html

## Android Studio

Select the "SDK Platforms" tab from within the SDK Manager, then check the box next to "Show Package Details" in the bottom right corner. Look for and expand the Android 10 (Q) entry, then make sure the following items are checked:

- Android SDK Platform 29
- Intel x86 Atom_64 System Image or Google APIs Intel x86 Atom System Image

Next, select the "SDK Tools" tab and check the box next to "Show Package Details" here as well. Look for and expand the **Android SDK Build-Tools** entry, then make sure that **29.0.2** is selected.

Finally, click "Apply" to download and install the Android SDK and related build tools.
