#!/bin/sh

set -e

echo "Waiting for database..."
while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do 
    echo "Database not available yet... waiting"
    sleep 1
done
echo "Database is now available"

# Create config file dynamically
cat > /tmp/odoo.conf << EOF
[options]
addons_path = /mnt/extra-addons
admin_passwd = ${ADMIN_PASSWORD:-admin}
db_host = ${ODOO_DATABASE_HOST}
db_port = ${ODOO_DATABASE_PORT}
db_user = ${ODOO_DATABASE_USER}
db_password = ${ODOO_DATABASE_PASSWORD}
db_name = ${ODOO_DATABASE_NAME}
proxy_mode = True
workers = 4
limit_time_real = 1800
EOF

# Execute Odoo with all environment variables
exec odoo \
    --config=/tmp/odoo.conf \
    --http-port="${PORT}" \
    --smtp="${ODOO_SMTP_HOST}" \
    --smtp-port="${ODOO_SMTP_PORT_NUMBER}" \
    --smtp-user="${ODOO_SMTP_USER}" \
    --smtp-password="${ODOO_SMTP_PASSWORD}" \
    --email-from="${ODOO_EMAIL_FROM}" 2>&1
