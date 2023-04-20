# About
This is a simple tutorial<br>
I will only be explaining how to configure an `Apache` server, without explaining too much of the technical details<br>
At the end you will understand how host services work *(it's not exactly like this, but you will get the idea)*

*(This tutorial is a simplified and error-corrected version of [this](https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-20-04) tutorial)*
>*(No SSL included)*


# Installing and adjusting the firewall
Install `Apache`
```sh
sudo apt install apache2
```

It’s necessary to modify the `Firewall` settings to allow outside access to the default web ports<br>
By typing:
```sh
sudo ufw app list
```

You must see something like this:
```
Available applications:
  Apache
  Apache Full
  Apache Secure
```


- **Apache:** This profile opens only **port 80** *(normal, unencrypted web traffic)*
- **Apache Full:** This profile opens both **port 80** *(normal, unencrypted web traffic)* and **port 443** *(TLS/SSL encrypted traffic)*
- **Apache Secure:** This profile opens only **port 443** *(TLS/SSL encrypted traffic)*


It is recommended that you enable the most restrictive profile that will still allow the traffic you’ve configured. Right now, we will only need to allow traffic on **port 80**.
```sh
sudo ufw allow 'Apache'
```

Then you can verify:
```sh
sudo ufw status
```

# Checking
By typing
```sh
sudo systemctl status apache2
```

You can check if `Apache` is running<br>
But let's see the page!

First you need you public IPv4, to get this you can google "Wotz my ip?", or, typing this:
```sh
hostname -I
```
>(*IPv4 is the first one*)<br><br>

Enter it into your browser’s address bar: `http://your_server_ip` *(The server runs in Port 8)*
>Alternatively, you can access the page by typing in your browser `localhost` or `127.0.0.1`



# Setting up Virtual Hosts (cool part)
When using the `Apache` web server, you can use virtual hosts *(similar to server blocks in Nginx)* to encapsulate configuration details and host more than one domain from a single server

The default page *(the one we saw before)* is located in `/var/www/html` directory. But that's too boring *(if you want just one simple page, this is fine)*, let's learn how to make a new one

First we create the domain directory: *(obviously you will replace `your_domain` with your domain name. Without http/s, www., .com, etc.)*
```sh
sudo mkdir /var/www/your_domain
```

Next, assign ownership of the directory with the $USER environment variable:
```sh
sudo chown -R $USER:$USER /var/www/your_domain
```

To ensure that your permissions are correct and allow the owner to read, write, and execute the files while granting only read and execute permissions to groups and others, you can input the following command:
```sh
sudo chmod -R 755 /var/www/your_domain
```

Next, create a sample index.html page using nano or your favorite editor:
```sh
sudo nano /var/www/your_domain/index.html
```


Add this sample inside:
```html
<html>
    <head>
        <title>Welcome to Your_domain!</title>
    </head>
    <body>
        <h1>Success! The your_domain virtual host is working!</h1>
    </body>
</html>
```

In order for `Apache` to serve this content, it’s necessary to create a virtual host file with the correct directives. Instead of modifying the default configuration file located at `/etc/apache2/sites-available/000-default.conf` directly, let’s make a new one at `/etc/apache2/sites-available/your_domain.conf`:
```sh
sudo nano /etc/apache2/sites-available/your_domain.conf
```

Paste in the following configuration block, which is similar to the default, but updated for our new directory and domain name:

```html
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName your_domain
    ServerAlias www.your_domain
    DocumentRoot /var/www/your_domain
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

- **Notice** that we’ve updated the `DocumentRoot` to our new directory
- **ServerAdmin** to an email that the `your_domain` site administrator can access
- **ServerName** which establishes the base domain that should match for this virtual host definition
- **ServerAlias** which defines further names that should match as if they were the base name

# Almost done
Let’s enable the file with the `a2ensite` tool:
```sh
sudo a2ensite your_domain.conf
```

Disable the default site defined in `000-default.conf`:
```sh
sudo a2dissite 000-default.conf
```

Next, let’s test for configuration errors:
```sh
sudo apache2ctl configtest
```

You should receive the following output:
```sh
Syntax OK
```

Reload apache:
```sh
sudo systemctl reload apache2
```

`Apache` should now be serving your domain name. You can test this by navigating to `http://your_domain`
>If you don't have a domain, you can access the site by typing in your browser `localhost` or `127.0.0.1`


# new-apache.sh
For each new page you need to repeat this whole new process, that's why I made `new-apache.sh`

To use just type:
```sh
sudo bash new-apace.sh your_domain
```

# Possible erros
## Error AH00558
If you get this error:
```sh
Error AH00558: Could not reliably determine the server’s fully qualified domain name
```

Add a line containing `ServerName 127.0.0.1` to the end of the file:
```sh
sudo nano /etc/apache2/apache2.conf
```

Restart apache2
```sh
sudo systemctl restart apache2
```

## "Could not reliably determine the server's fully qualified domain name"
Type:
```sh
sudo nano /etc/apache2/apache2.conf
```

Add to the end of the file:
```
ServerName localhost
```

Then restart `Apache` by typing into the terminal:
```
sudo systemctl reload apache2
```


## Cant acess the website via IP but not Domain

Add this code
```sh
127.0.0.1	www.yourdomain.com
127.0.0.1	yourdomain.com
```

to

```sh
sudo nano /etc/hosts
```

You need to add the two lines to be able to access the two URLs<br><br>
What these lines basically say is *"If the user accesses via `your_domain.com`, load `127.0.0.1`"*<br>
**WARNING:** this does not *"create"* a domain, this line just means *"If I access `www.yourdomain.com` or `yourdomain.com`, load whatever is at `127.0.0.1`"*

Finally restart `Apache`
```sh
sudo systemctl restart apache2
```



# Apache Files and Directories
## Content
- `/var/www/html`: The actual web content, which by default only consists of the default `Apache` page you saw earlier, is served out of the `/var/www/html` directory. This can be changed by altering `Apache` configuration files.

## Server Configuration
- `/etc/apache2`: The `Apache` configuration directory. All of the Apache configuration files reside here.
- `/etc/apache2/apache2.conf`: The main `Apache` configuration file. This can be modified to make changes to the `Apache` global configuration. This file is responsible for loading many of the other files in the configuration directory.
- `/etc/apache2/ports.conf`: This file specifies the ports that `Apache` will listen on. By default, `Apache` listens on **port 80** and additionally listens on **port 443** when a module providing SSL capabilities is enabled.
- `/etc/apache2/sites-available/`: The directory where per-site virtual hosts can be stored. `Apache` will not use the configuration files found in this directory unless they are linked to the `sites-enabled` directory. Typically, all server block configuration is done in this directory, and then enabled by linking to the other directory with the `a2ensite` command.
- `/etc/apache2/sites-enabled/`: The directory where enabled per-site virtual hosts are stored. Typically, these are created by linking to configuration files found in the `sites-available` directory with the `a2ensite`. `Apache` reads the configuration files and links found in this directory when it starts or reloads to compile a complete configuration.
- `/etc/apache2/conf-available/`, `/etc/apache2/conf-enabled/`: These directories have the same relationship as the `sites-available` and sites-enabled directories, but are used to store configuration fragments that do not belong in a virtual host. Files in the conf-available directory can be enabled with the `a2enconf` command and disabled with the `a2disconf` command.
- `/etc/apache2/mods-available/`, `/etc/apache2/mods-enabled/`: These directories contain the available and enabled modules, respectively. Files ending in .load contain fragments to load specific modules, while files ending in .conf contain the configuration for those modules. Modules can be enabled and disabled using the `a2enmod` and `a2dismod` command.

## Server Logs
- `/var/log/apache2/access.log`: By default, every request to your web server is recorded in this log file unless `Apache` is configured to do otherwise.
- `/var/log/apache2/error.log`: By default, all errors are recorded in this file. The LogLevel directive in the `Apache` configuration specifies how much detail the error logs will contain.
