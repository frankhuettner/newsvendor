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




# Start manually
cd /root/newsvendor/ownserver
tmux
begin
           import Pluto
           server = Pluto.Configuration.ServerOptions(host="127.0.0.1", port=2345)
           opt = Pluto.Configuration.Options(server=server)
           s = Pluto.ServerSession(secret="",options = opt)
           Pluto.run(s)
       end
       # ctrl b   and d
