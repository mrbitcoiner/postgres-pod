#!/usr/bin/env bash
####################
set -e
####################
readonly CERT_DIR="/app/data/certs/adminer"
readonly CFG_DIR="/app/data/haproxy"
####################

if ! [ -e /app/data/haproxy ]; then
  su -c 'mkdir -p /app/data/haproxy' ${CONTAINER_USER}
fi

if ! [ -e "${CFG_DIR}/haproxy.conf" ]; then 
su -c "cat << 'EOF' > ${CFG_DIR}/haproxy.conf
defaults
	timeout connect 10s
    	timeout client 30s
    	timeout server 30s
    	log global
    	mode http
    	option httplog
    	maxconn 3000

frontend http_adminer
	mode http
	bind *:8080 ssl crt ${CERT_DIR}/server.pem alpn h2,http/1.1 ssl-min-ver TLSv1.2 
	redirect scheme https code 301 if !{ ssl_fc }
	default_backend http_adminer

backend http_adminer
	mode http
	balance roundrobin
 	http-response set-header X-Frame-Options SAMEORIGIN
      	http-response set-header X-XSS-Protection 1;mode=block
      	http-response set-header X-Content-Type-Options nosniff
      	default-server check maxconn 50
      	server adminer adminer_postgres:8080
EOF
" ${CONTAINER_USER}
fi
	
	



