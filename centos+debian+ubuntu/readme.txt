Compilation method for n2n_v2_dev (Run under SSH):

cd /opt
git clone https://github.com/ntop/n2n.git
cd n2n
./autogen.sh
./configure
make

Now the main program (edge & supernode) has been generated, in the /opt/n2n directory.

You may need to install some plug-ins as follows before you compile
apt-get update
apt-get install git cmake make autoconf automake libtool subversion build-essential libssl-dev
