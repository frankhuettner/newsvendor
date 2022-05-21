#!/bin/bash

######################################################################
# Get your repository
# git clone https://github.com/frankhuettner/newsvendor

# Give permission to this script
# chmod +x game/gamedemoserver_setup/server_setup/setup-demo-server.sh
######################################################################
######################################################################



######################################################################
# Install NGINX
###################################
sudo apt-get update
sudo apt install nginx
# sudo systemctl status nginx
sudo cp game/gamedemoserver_setup/server_setup/nginx-default /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Start firewall
sudo ufw allow http comment 'Open access Nginx port 80'
sudo ufw allow https comment 'Open all to access Nginx port 443'
# sudo ufw allow ssh comment 'Open access OpenSSH port 22'
sudo ufw enable
sudo ufw reload



######################################################################
# Get SSH Certificate
###################################
sudo apt install snapd
sudo snap install core
sudo snap refresh core
sudo apt remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
# This requires that the URL (A Record) in nginx-default refers to the IP of the server
sudo certbot --nginx


######################################################################
# Install and run Julia as root
###################################
wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.2-linux-x86_64.tar.gz
tar zxvf julia-1.7.2-linux-x86_64.tar.gz
rm julia-1.7.2-linux-x86_64.tar.gz
ln -s `pwd`/julia-1.7.2/bin/julia /usr/local/bin/julia
# Install PlutoSliderServer
julia -e "import Pkg; Pkg.add(\"PlutoSliderServer\")"




######################################################################
# Create the reload demo notebooks script
######################################################################
TEMPFILE=$(mktemp)
cat > $TEMPFILE << __EOF__
#!/bin/bash
find /root/newsvendor/game/gamedemoserver_setup/watchdir -maxdepth 1 -type f -exec rm -f {} \;
sleep 2
cp -R -f /root/newsvendor/game/gamedemoserver_setup/source/* /root/newsvendor/demo/watchdir
__EOF__
sudo mv $TEMPFILE /usr/local/bin/reload-demo-notebooks.sh

# Create a service to reload demo notebooks
TEMPFILE=$(mktemp)
cat > $TEMPFILE << __EOF__
[Unit]
Description=Reload demo notebooks
After=pluto-server.service

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
ExecStart=/bin/bash /usr/local/bin/reload-demo-notebooks.sh
Restart=always
RestartSec=600s
__EOF__
sudo mv $TEMPFILE /etc/systemd/system/reload-demo-notebooks.service

#Permission Stuff
sudo chmod 744 /usr/local/bin/reload-demo-notebooks.sh
sudo chmod 664 /etc/systemd/system/reload-demo-notebooks.service

# Start & enable
sudo systemctl daemon-reload
sudo systemctl start reload-demo-notebooks
sudo systemctl enable reload-demo-notebooks

# To see quick status (running/failed and memory):
# systemctl -l status reload-demo-notebooks

# To browse the logs:
# sudo journalctl -u reload-demo-notebooks

######################################################################
# Create the startup script
###################################
TEMPFILE=$(mktemp)
cat > $TEMPFILE << __EOF__
#!/bin/bash
cd /root/newsvendor/game/gamedemoserver_setup/watchdir
julia --project="pluto-slider-server-environment" -e "import Pkg; Pkg.instantiate(); import PlutoSliderServer; PlutoSliderServer.run_git_directory(\".\", Export_offer_binder=false)"
__EOF__

sudo mv $TEMPFILE /usr/local/bin/pluto-slider-server.sh


# Run PlutoSliderServer
# change line 106 in /root/.julia/packages/PlutoSliderServer/KB1e6/src/Export.jl    to         
# To start the demo, click the link below (the server restarts the demo every 10 min, which might be loading a minute or two)
sed -i '106s/.*/ To start the demo, click the link below (the server restarts the demo every 10 min, which might be loading a minute or two) /' /root/.julia/packages/PlutoSliderServer/KB1e6/src/Export.jl


# Create a service
TEMPFILE=$(mktemp)
cat > $TEMPFILE << __EOF__
[Unit]
After=network.service

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
ExecStart=/usr/local/bin/pluto-slider-server.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
__EOF__

sudo mv $TEMPFILE /etc/systemd/system/pluto-server.service



# Permissions stuff
sudo chmod 744 /usr/local/bin/pluto-slider-server.sh
sudo chmod 664 /etc/systemd/system/pluto-server.service

# Start & enable
sudo systemctl daemon-reload
sudo systemctl start pluto-server
sudo systemctl enable pluto-server

# View logs
# To see quick status (running/failed and memory):
# systemctl -l status pluto-server
# To browse the logs:
# sudo journalctl -u pluto-server


# Start manually
# cd /root/newsvendor/game/gamedemoserver_setup
# tmux
# julia --project="pluto-slider-server-environment" -e "import Pkg; Pkg.instantiate(); import PlutoSliderServer; PlutoSliderServer.run_git_directory(\".\", Export_offer_binder=false)"
# ctrl b   and d
