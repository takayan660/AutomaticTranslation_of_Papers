#!/bin/sh

set -u

AUTOTRANSPAPER_DIR=`pwd`

#atexit() {
#    [[ -d ${TMP_R} ]] && rm -rf "${TMP_R}"
#}
TMP_R=`mktemp -d`
#trap atexit EXIT
#trap '[[ -d ${TMP_R} ]] && rm -rf "${TMP_R}"' SIGHUP SIGINT SIGTERM

sudo apt-get update
sudo apt-get install git tar wget poppler-utils evince texlive texlive-lang-cjk xdvik-ja

cd $TMP_R

### Gawk install ###
wget http://ftp.gnu.org/gnu/gawk/gawk-4.0.1.tar.gz
tar xfvz gawk-4.0.1.tar.gz
cd gawk-4.0.1/
./configure
make
make check
sudo make install

cd ../

### translate-shell install ###
git clone https://github.com/soimort/translate-shell.git
cd translate-shell/
sudo make install

### autotranspaper install ###
sudo cp ${AUTOTRANSPAPER_DIR}/autotranspaper /usr/local/bin
