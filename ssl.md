# Setting up SSL 

1) Install Certbot
- SSH into the server
```
# Install snapd
$ sudo snap install core; sudo snap refresh core
# Install certbot using snapd
$ sudo snap install --classic certbot
$ sudo ln -s /snap/bin/certbot /usr/bin/certbot
```
2) Get an SSL Certificate

 ```
 $ sudo certbot --nginx -d example.com
 
 # Will prompt you for an email address, and ask you to agree to its terms of service
 ```
3) Configure and Confirm Nginx

- Copy paste the nginx configuration from [here](https://github.com/mcetn/shiny-app-aws/blob/main/nginx.conf) make sure to update any 'example.com' with your domain name

```
$ sudo nano /etc/nginx/sites-available/example.com
$ sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
$ sudo systemctl restart nginx.service 

```
