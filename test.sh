#!/bin/bash
cd /home/eytech
echo 'optionally enable the EPEL'
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
subscription-manager repos --enable "rhel-*-optional-rpms"
yum -y install yum-utils
echo "install git"
yum install -y git
echo "conf git"
echo 'export PATH="$HOME/usr/git/bin:$PATH"' >>.bashrc

yum-config-manager --enable "rhel-*-optional-rpms"
subscription-manager repos --enable "rhel-*-optional-rpms"

echo 'add the codeready builder tools:'
export ARCH=$( /bin/arch )
subscription-manager repos --enable "codeready-builder-for-rhel-8-${ARCH}-rpms"

echo 'export R_VERSION=3.6.2'
export R_VERSION=3.6.2

echo 'Download and install R'
curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm
sudo yum -y install R-${R_VERSION}-1-1.x86_64.rpm
/opt/R/${R_VERSION}/bin/R --version
ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

echo 'Verify R installation'
/opt/R/${R_VERSION}/bin/R --version

echo 'install rstudio-connect'
wget https://rstudio-connect.s3.amazonaws.com/rstudio-connect-1.8.2-10.el.x86_64.rpm
yum -y install rstudio-connect-1.8.2-10.el.x86_64.rpm
curl -O https://rsamplediag.blob.core.windows.net/rsample/rstan.tar.gz?sp=r&st=2020-05-22T09:56:53Z&se=2020-05-22T17:56:53Z&spr=https&sv=2019-10-10&sr=b&sig=ZlyVl3GvX%2FJF9kU%2FRw5ivMTLCVfaV4NlNwblzXd02kM%3D
cp rstan.tar.gz?sp=r rstan.tar.gz
tar -xvf rstan.tar.gz .
mv rstan /opt/R/3.6.2/lib/R/library/
/usr/local/bin/R -e "install.packages('png', repos='http://cran.us.r-project.org')"
mkdir /etc/rstudio-connect/cert/
cd /home/eytech && mv *.crt server.cert && mv *.key server.key && mv server.* /etc/rstudio-connect/cert/

echo 'start FW'
systemctl enable firewalld
systemctl start firewalld.service
systemctl enable firewalld.service

echo 'status rstudio'
systemctl restart rstudio-connect

echo "clean"
ls | grep rpm | xargs rm
ls | grep  rstan | xargs rm
rm -rf /home/eytech/*

cat /var/log/rstudio-connect.log
