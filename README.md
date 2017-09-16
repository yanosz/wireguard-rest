# Wireguard Rest

This rails application implements a webserivce (REST) API for wireguard --- similar to (Mullvad's)[https://www.mullvad.net/guides/wireguard-and-mullvad-vpn/].

It allows users --- identified by there account number --- to manage wireguard public keys.
In return, it generates network configuration just like Mullvad.

This application does not implement any busy logic - it is uses in the Freifunk KBU network in order to provide a tinkering alternative to mullvad
within the (Freifunk KBU)[https://kbu.freifunk.net] network.

This application provides CRUD functionality for public keys. When running on wireguard-VPN-servers, it may be used as a backend service,
being called from frontend endpoints (registration portal, etc.).


## Supported calls:

Please note:

* Users are identified by a secret account ID (ie generating via makepasswd: `makepasswd --chars=20`). By specifying an account ID, keys can be deleted. Thus, it should kept secret. Account ID are unique.
* Documents contain comments and additional information: In order to keep the database schema simple, all additional information is supposed to be stored using a json encoded document (NoSQL-Style).
* On errors, HTTP 422 (Unprocessable Entity) and a short text is returned.

### Uploading public keys

* Example call: `curl -sSL https://<endpoint> -d account="<account id>" -d document="Some text data" --data-urlencode pubkey="<publickey>"`
* Example result: `192.168.1.1, fc00:1234::1/128`

### Get a list of all public keys

For debugging (by users) all public keys can be retrieved. Account ID and Document remain hidden.

* Example call: `curl -sSL https://<endpoint>`
* Result (JSON): `[{id: 1, pubkey: AA.., created_at: '2017-01-01 18:25'},{id: 2, pubkey: BB.., created_at: '2017-01-01 19:25'}]`

### Delete a public keys

* Example call: `curl -X "DELETE" https://<endpoint> -d account="<account id>"`
* Result: HTTP 204 (No Content)

## Deployment

This application can be deployed as a standard ruby on rails application. For simplicity, the Debian rails package as of Debian 9.0 / Stretch can be used.

Please note, that the deployment instructions are rather brief and assume general knowledge on deploying Ruby on Rails applications.

In addition, (ansible-wireguard-rest)[https://github.com/yanosz/ansible-wireguard-rest] can be used for ansible based deployments on Debian 9. It configures this application and
a network interface accordingly.

As usual, mod_rails / phusion passenger can be used as well.

### 1. Install packages

`apt-get install rails git puma sudo ruby-dev`

### 2. Create User

`useradd -m wireguard-rest -s /bin/bash; su - wireguard-rest`

### 3. Enable sudo

The users created previously must be able to apply wireguard configuration:

`wireguard-rest  ALL=(root) NOPASSWD: /usr/bin/setconf wg-rest /etc/wireguard/rest.conf`

### 4. Create Network interface

Create a network interface on your system (default: `wg-rest`) according to your neddes

### 5. Clone / Checkout

`git clone https://github.com/yanosz/wireguard-rest.git`

### 6. Configuration

- `config/app.yml` and `config/rest.erb.conf` according to your needs.
-  When not using sqlite3, adjust `config/database.yml`. Install additional packages if needed.

### 7. Init

- Database: `rake db:migrate RAILS_ENV=production`
- Wireguard configuration:  `rake init:wg_conf RAILS_ENV=production`

Make sure, that `/etc/wireguard/rest.conf` (default location, configurable) is correct and applicable: `sudo /usr/bin/setconf wg-rest /etc/wireguard/rest.conf`

### 8. Start server

`rails s -e production`


## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
