<VirtualHost *:80>
   ServerName thedomain.com
ServerAdmin webmaster@thedomain.com
   DocumentRoot /var/www/html/test-laravel/public
   <Directory /var/www/html/test-laravel/public>
      AllowOverride All
   </Directory>
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>