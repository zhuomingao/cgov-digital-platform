#!/bin/bash



export DOCROOT="/var/www/html/web"
export GRPID=$(stat -c "%g" /var/lib/mysql/)
export DRUSH="/.composer/vendor/drush/drush/drush"
export HOSTIP=$(/sbin/ip route | awk '/default/ { print $3 }')
echo "${HOSTIP} dockerhost" >> /etc/hosts


# Start supervisord
supervisord -c /etc/supervisor/conf.d/supervisord.conf -l /tmp/supervisord.log




# Clear caches and reset files perms
chown -R www-data:${GRPID} ${DOCROOT}/
chown -R mysql:${GRPID} /var/lib/mysql/
chmod -R ug+w ${DOCROOT}/ /var/lib/mysql/
find -type d -exec chmod +xr {} \;
(sleep 3; drush --root=${DOCROOT}/ cache-rebuild 2>/dev/null) &

echo
echo "------------------------------ STARTING SERVICES ---------------------------------------"

tail -f /tmp/supervisord.log
