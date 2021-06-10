echo "Nginx prometheus exporter installer"

cat > /etc/nginx/sites-available/exporter <<- 'EOF'
server {
        listen localhost:80;
        location /nginx_status {
                stub_status;
        }
}
EOF
ln -s /etc/nginx/sites-available/exporter /etc/nginx/sites-enabled/
nginx -t
nginx -s reload

mkdir /srv/nginxexporter
cd /srv/nginxexporter
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.9.0/nginx-prometheus-exporter_0.9.0_linux_amd64.tar.gz
tar -xvf nginx-prometheus-exporter_0.9.0_linux_amd64.tar.gz

cat > /etc/systemd/system/nginxexporter.service <<- 'EOF'
[Unit]
Description=Nginx exporter
After=nginx.service

[Service]
User=root
Group=root
WorkingDirectory=/srv/nginxexporter
ExecStart=/srv/nginxexporter/nginx-prometheus-exporter -nginx.scrape-uri=http://localhost:80/nginx_status

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now nginxexporter
SERVER_IP=$(curl -s http://checkip.amazonaws.com)

echo "Connect this ip to prometheus: $SERVER_IP with port 9113"
