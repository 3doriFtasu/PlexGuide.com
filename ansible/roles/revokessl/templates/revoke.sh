## Initial Development of this Script: By l3uddz from https://github.com/Cloudbox/Cloudbox
## Custom Modifications: http://plexguide.com
#!/bin/bash

domain={{domain}}

cd /opt/nginx-proxy

sudo docker stop $(docker ps -aq)

for i in *.${domain}.chain.pem;
  do
    base=${i%%??????????}
    sudo certbot revoke --cert-path ${base}/fullchain.pem --key-path ${base}/key.pem
done

sudo chown -R 1000:1000 /opt/nginx
