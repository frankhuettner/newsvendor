#!/bin/bash




# Get your repository
# git clone https://github.com/frankhuettner/newsvendor



# Install and run Julia as root
wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.0-linux-x86_64.tar.gz
tar zxvf julia-1.8.0-linux-x86_64.tar.gz
rm julia-1.8.0-linux-x86_64.tar.gz
ln -s `pwd`/julia-1.8.0/bin/julia /usr/local/bin/julia



# Run PlutoSliderServer
# change line 106 in /root/.julia/packages/PlutoSliderServer/KB1e6/src/Export.jl    to         <h1>The server restarts the debrief every 10 min (might be loading a minute or two):</h1>





######################################################################
# Install NGINX
###################################
sudo apt-get update
sudo apt install nginx
# sudo systemctl status nginx
sudo cp ownserver/server_setup/nginx-default /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Start firewall
sudo ufw allow http comment 'Open access Nginx port 80'
sudo ufw allow https comment 'Open all to access Nginx port 443'
# sudo ufw allow ssh comment 'Open access OpenSSH port 22'
sudo ufw enable
sudo ufw reload



### Next, set a A record that refers to the ip of your server
# e.g. Namecheap > Advanced DNS > Add A record > class.myurl.com refer to the ip


###    !!!!!!! adjust  the nginx-default file!!!!!


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






# Start manually
cd /root/newsvendor/ownserver
tmux
julia
begin
           import Pkg
           Pkg.add("Pluto")
           import Pluto
           server = Pluto.Configuration.ServerOptions(host="127.0.0.1", port=2345)
           opt = Pluto.Configuration.Options(server=server)
           s = Pluto.ServerSession(secret="",options = opt)
           Pluto.run(s)
       end
       # ctrl b   and d
