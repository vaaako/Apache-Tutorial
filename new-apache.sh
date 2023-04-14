if [ $# -eq 0 ]; then
	echo "You need to specify the domain (without http/s, www., .com, etc.)"
	exit 0;
fi

DOMAIN=$1


sudo mkdir /var/www/$DOMAIN

#sudo chown -R $USER:$USER /var/www/$DOMAIN # Assign ownership of the directory with the $USER environment variable
#sudo chmod -R 755 /var/www/$DOMAIN


sudo touch /var/www/$DOMAIN/index.html
sudo echo "<html>
    <head>
        <title>Welcome to $DOMAIN!</title>
    </head>
    <body>
        <h1>Success! The $DOMAIN virtual host is working!</h1>
    </body>
</html>" > /var/www/$DOMAIN/index.html



# In order for Apache to serve this content, it’s necessary to create a virtual host file with the correct directives. Instead of modifying the default configuration file located at /etc/apache2/sites-available/000-default.conf directly, let’s make a new one at /etc/apache2/sites-available/your_domain.conf
sudo touch /etc/apache2/sites-available/$DOMAIN.conf
sudo echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot /var/www/$DOMAIN
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$DOMAIN.conf


# Enable the file
sudo a2ensite $DOMAIN.conf

# Disable the default site
sudo a2dissite 000-default.conf

# Restart Apache
sudo systemctl restart apache2
