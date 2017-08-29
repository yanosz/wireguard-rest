wireguard-rest
==================================

Simple RestAPI for uploading public keys similar to https://www.mullvad.net/guides/wireguard-and-mullvad-vpn/

All keys are stored witin a SQLite Database. Wireguard configuration is generated and apllied on the fly.

Deployment (on Debian) 
-----------------------------------

1. Install needed packages: `apt-get install ruby-sinatra ruby-sinatra-contrib  ruby-sqlite3 git ruby-rack bundler ruby-activerecord`
2. Create an application user `useradd wireguard-rest -m -d /srv/wireguard-rest`
3. checkout `sudo -i wireguard-rest git clone ... /srv/wireguard-rest`
4. Start it (ie using apache 2)
 - `apt-get install libapache2-mod-passenger` 
 - `cat > /etc/apache2/conf-available/wg.conf  <<EOF
Alias /wg /srv/wireguard-rest/public
<Directory /srv/wireguard-rest/public>
   PassengerBaseURI /wg
   PassengerAppRoot /srv/wireguard-rest
   Require all granted
   Order allow,deny
   Allow from all
   Options -MultiViews
</Directory>
EOF`
 - ` ln -s  /etc/apache2/conf-available/wg.conf  /etc/apache2/conf-enabled/wg.conf && apache2ctl restart`
