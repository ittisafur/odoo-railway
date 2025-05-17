#!/bin/sh

set -e

# Validate required environment variables
if [ -z "${ODOO_DATABASE_HOST}" ] || [ -z "${ODOO_DATABASE_PORT}" ]; then
    echo "Error: Database host or port is not set. Exiting."
    exit 1
fi

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
workers = 0  # Single-threaded mode for minimal resource usage
limit_time_real = 600
limit_time_cpu = 300
logfile = /var/log/odoo/odoo.log
EOF

# Set up log rotation
cat > /etc/logrotate.d/odoo << EOF
/var/log/odoo/odoo.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 640 odoo odoo
}
EOF

# Execute Odoo with all environment variables
exec odoo \
    --config=/tmp/odoo.conf \
    --http-port="${PORT:-8069}" \
    --smtp="${ODOO_SMTP_HOST}" \
    --smtp-port="${ODOO_SMTP_PORT_NUMBER}" \
    --smtp-user="${ODOO_SMTP_USER}" \
    --smtp-password="${ODOO_SMTP_PASSWORD}" \
    --email-from="${ODOO_EMAIL_FROM}" 2>&1
