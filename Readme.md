## wireguard-rest


Simple RestAPI for uploading public keys similar to https://www.mullvad.net/guides/wireguard-and-mullvad-vpn/

All keys are stored witin a SQLite Database. Wireguard configuration is generated and apllied on the fly.

### Deployment (on Debian) 

#### 1. Install needed packages

`apt-get install ruby-sinatra ruby-sinatra-contrib ruby-sqlite3 git ruby-rack ruby-activerecord`

#### 2. Create an application user 
`useradd wireguard-rest -m -d /srv/wireguard-rest`

#### 3. Clone / Checkout
`sudo -u wireguard-rest git clone https://github.com/yanosz/wireguard-rest.git /srv/wireguard-rest`

#### 4. Configure Webserver (here: apache2)
1. Install modules 
```apt-get install passenger```
 
2. Create configuration:
```
cat > /etc/apache2/conf-available/wg.conf  <<EOF
Alias /wg /srv/wireguard-rest/public
<Directory /srv/wireguard-rest/public>
   PassengerBaseURI /wg
   PassengerAppRoot /srv/wireguard-rest
   Require all granted
   Order allow,deny
   Allow from all
   Options -MultiViews
</Directory>
EOF
```
3.  Link configuration

`ln -s  /etc/apache2/conf-available/wg.conf  /etc/apache2/conf-enabled/wg.conf`

4. Restart Apache

`apache2ctl restart`