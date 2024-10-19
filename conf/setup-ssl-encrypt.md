Cómo proteger Nginx con Let´s Encrypt en Ubuntu

Introducción
Let’s Encrypt es una entidad de certificación (CA) que proporciona una manera sencilla de obtener e instalar certificados de TLS/SSL gratuitos, lo que permite usar HTTPS cifrado en servidores web. Simplifica el proceso al proporcionar un cliente de software, Certbot, que intenta automatizar la mayoría (cuando no todos) de los pasos requeridos. Actualmente, todo el proceso de obtención e instalación de un certificado está totalmente automatizado en Apache y Nginx.

En este tutorial, usará Certbot para obtener un certificado SSL gratuito para Nginx en Ubuntu 20.04 y configurará su certificado para que se renueve automáticamente.

Este tutorial usará un archivo de configuración del servidor Nginx en vez del archivo predeterminado. Recomendamos crear nuevos archivos de bloque de servidor Nginx para cada dominio porque ayuda a evitar errores comunes y mantiene los archivos predeterminados como configuración de reserva.

Requisitos previos
Para este tutorial, necesitará lo siguiente:

Un servidor de Ubuntu 20.04 configurado conforme a este tutorial de configuración inicial del servidor para Ubuntu 20.04, incluyendo un usuario sudo no root y un firewall.

Un nombre de dominio registrado. En este tutorial, se utilizará example.com en todo momento. Puede adquirir un nombre de dominio en Namecheap, obtener uno gratuito en Freenom o utilizar un registrador de dominios de su elección.

Los dos registros DNS que se indican a continuación se configuraron para su servidor. Si está usando DigitalOcean, consulte nuestra documentación DNS para obtener más información sobre cómo añadirlos.

Un registro A con example.com​​​ orientado a la dirección IP pública de su servidor.
Un registro A con example.com​​​ ​​orientado a la dirección IP pública de su servidor.
Nginx instalado conforme a Cómo instalar Apache en Ubuntu 20.04. Asegúrese de tener un bloque server para su dominio. En este tutorial, utilizará /etc/nginx/sites-available/example como ejemplo.

Paso 1: Instalar Certbot
El primer paso para utilizar Let’s Encrypt para obtener un certificado SSL es instalar el software Certbot en su servidor.

Instalar Certbot y su complemento de Nginx con apt:

sudo apt install certbot python3-certbot-nginx
Certbot estará listo para utilizarse, pero para que configure SSL automáticamente para Nginx debemos verificar parte de la configuración de Nginx.

Paso 2: Confirmar la configuración de Nginx
Certbot debe poder encontrar el bloque server correcto en su configuración de Nginx para que pueda configurar SSL automáticamente. De forma específica, lo hace buscando una directiva server_name que coincida con el dominio para el que está solicitando el certificado.

Si siguió el paso de configuración del bloque server en el tutorial de instalación de Nginx, debería tener un bloque server para su dominio en /etc/nginx/sites-available/example.com con la directiva server_name configurada de forma apropiada.

Para comprobarlo, abra el archivo de configuración para su dominio usando nano o su editor de texto favorito:

sudo nano /etc/nginx/sites-available/example.com
Encuentre la línea server_name existente. Debería tener el siguiente aspecto:

/etc/nginx/sites-available/example.com
...
server_name example.com www.example.com;
...
Si esto sucede, salga de su editor y continúe con el paso siguiente.

De lo contrario, actualícelo para que coincida. A continuación, guarde el archivo, cierre el editor y verifique la sintaxis de las modificaciones de la configuración:

sudo nginx -t
Si obtiene un error, vuelva a abrir el archivo del bloque server y compruebe si hay algún error ortográfico o faltan caracteres. Una vez que la sintaxis de su archivo de configuración sea correcta, vuelva a abrir Nginx para cargar la configuración nueva:

sudo systemctl reload nginx
Ahora, Certbot podrá encontrar el bloque server correcto y actualizarlo automáticamente.

A continuación, actualizaremos el firewall para permitir el tráfico de HTTPS.

Paso 3: Habilitar HTTPS a través del firewall
Si tiene habilitado el firewall de ufw, como se recomienda en las guías de los requisitos previos, deberá ajustar la configuración para permitir el tráfico de HTTPS. Afortunadamente, Nginx registra algunos perfiles con ufw después de la instalación.

Puede ver la configuración actual escribiendo lo siguiente:

sudo ufw status
Probablemente tendrá este aspecto, lo cual significa que solo se permite el tráfico de HTTP al servidor web:

Output
Status: active

To                         Action      From
--                         ------      ----
OpenSSH                    ALLOW       Anywhere                  
Nginx HTTP                 ALLOW       Anywhere                  
OpenSSH (v6)               ALLOW       Anywhere (v6)             
Nginx HTTP (v6)            ALLOW       Anywhere (v6)
Para permitir de forma adicional el tráfico de HTTPS, habilite el perfil de Nginx Full y elimine el permiso de perfil redundante HTTP de Nginx.

sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
Ahora, su estado debería tener el siguiente aspecto:

sudo ufw status
Output
Status: active

To                         Action      From
--                         ------      ----
OpenSSH                    ALLOW       Anywhere
Nginx Full                 ALLOW       Anywhere
OpenSSH (v6)               ALLOW       Anywhere (v6)
Nginx Full (v6)            ALLOW       Anywhere (v6)
A continuación, ejecutaremos Certbot y buscaremos nuestros certificados.

Paso 4: Obtener un certificado SSL
Certbot ofrece varias alternativas para obtener certificados SSL a través de complementos. El complemento de Nginx se encargará de reconfigurar Nginx y volver a cargar la configuración cuando sea necesario. Para utilizar este complemento, escriba lo siguiente:

sudo certbot --nginx -d example.com -d www.example.com
Esto ejecuta certbot con el complemento --nginx, usando -d para especificar los nombres de dominio para los que queremos que el certificado sea válido.

Si es la primera vez que ejecuta certbot, se le pedirá que ingrese una dirección de correo electrónico y que acepte las condiciones de servicio. Después de esto, certbot se comunicará con el servidor de Let’s Encrypt y realizará una comprobación a fin de verificar que usted controle el dominio para el cual solicite un certificado.

Si la comprobación se realiza correctamente, certbot le preguntará cómo desea configurar sus ajustes de HTTPS:

Output
Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
new sites, or if you're confident your site works on HTTPS. You can undo this
change by editing your web server's configuration.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel):
Seleccione su elección y luego ENTER. La configuración se actualizará y Nginx se volverá a cargar para aplicar los ajustes nuevos. certbot concluirá con un mensaje que le indicará que el proceso tuvo éxito e indicará la ubicación de almacenamiento de sus certificados:

Output
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/example.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/example.com/privkey.pem
   Your cert will expire on 2020-08-18. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
Así, sus certificados se quedarán descargados, instalados y cargados. Intente volver a cargar su sitio web utilizando https:// y observe el indicador de seguridad de su navegador. Debería indicar que el sitio cuenta con la protección correcta, en general, con un ícono de un candado. Si prueba su servidor utilizando SSL Labs Server Test, obtendrá una calificación A.

Terminaremos con una prueba del proceso de renovación.

Paso 5: Verificar la renovación automática de Certbot
Los certificados de Let’s Encrypt son válidos únicamente por noventa días. El propósito de esto es incentivar a los usuarios a automatizar sus procesos de renovación de certificados. El paquete certbot que instalamos se ocupa de esto por nosotros añadiendo un temporizador systemd que se ejecutará dos veces al día y renovará automáticamente cualquier certificado que vaya a vencer en los próximos 30 días.

Puede consultar el estado del temporizador con systemctl:

sudo systemctl status certbot.timer
Output
● certbot.timer - Run certbot twice daily
     Loaded: loaded (/lib/systemd/system/certbot.timer; enabled; vendor preset: enabled)
     Active: active (waiting) since Mon 2020-05-04 20:04:36 UTC; 2 weeks 1 days ago
    Trigger: Thu 2020-05-21 05:22:32 UTC; 9h left
   Triggers: ● certbot.service
Para probar el proceso de renovación, puede hacer un simulacro con certbot:

sudo certbot renew --dry-run
Si no ve errores, estará listo. Cuando sea necesario, Certbot renovará sus certificados y volverá a cargar Nginx para registrar los cambios. Si el proceso de renovación automática falla, Let’s Encrypt enviará un mensaje a la dirección de correo electrónico que especificó en el que se le advertirá cuándo se aproxime la fecha de vencimiento de sus certificados.

Conclusión
En este tutorial, instaló el certbot del cliente Let’s Encrypt, descargó certificados SSL para su dominio, configuró Nginx para utilizarlos y definió la renovación automática de certificados. Si tiene preguntas adicionales sobre la utilización de Certbot, la documentación oficial es un buen punto de partida.