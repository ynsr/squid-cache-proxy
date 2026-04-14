# 1. Upload and run scripts
ssh root@192.168.88.110

# Make scripts executable
chmod +x build_squid.sh setup_squid.sh start_squid.sh

# Step 1: Build image (~5-10 min first time)
bash 1_build_squid.sh

# Step 2: Setup CA, SSL DB, configs
bash 2_setup_squid.sh

# Step 3: Launch
bash 3_start_squid.sh start

# Serve CA cert for easy Windows download
cp /srv/appdata/squid/ssl/squid-ca.crt /www/squid-ca.crt
# Open on Windows: http://192.168.88.110/squid-ca.crt