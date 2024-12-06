#!/bin/bash -x

sudo amazon-linux-extras install -y epel
sudo yum update -y
sudo yum install -y wget certbot python2-certbot-dns-route53
if [[ "$(python3 -V 2>&1)" =~ ^(Python 3.6.*) ]]; then
    sudo wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.5.*) ]]; then
    sudo wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.4.*) ]]; then
    sudo wget https://bootstrap.pypa.io/pip/3.4/get-pip.py -O /tmp/get-pip.py
else
    sudo wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
fi
sudo python3 /tmp/get-pip.py
sudo /usr/local/bin/pip3 install botocore
sudo yum install -y amazon-efs-utils
sudo mkdir /mnt/efs
echo "${efs_id}:/ /mnt/efs efs _netdev,noresvport,tls,iam,accesspoint=${efs_access_point_id} 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo tee /etc/yum.repos.d/mongodb-org-5.0.repo << EOF
[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc
EOF
sudo tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/amazonlinux/2/
gpgcheck=1
enabled=1
EOF
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A > key.tmp;
sudo rpm --import key.tmp; rm -f key.tmp
sudo wget https://rpmfind.net/linux/epel/8/Everything/x86_64/Packages/p/pkcs11-helper-1.22-7.el8.x86_64.rpm
sudo yum install pkcs11-helper-1.22-7.el8.x86_64.rpm
sudo rm -f pkcs11-helper-1.22-7.el8.x86_64.rpm
sudo yum -y install pritunl mongodb-org-5.0.9-1.amzn2

sudo sed -i.bak "s/\/var\/lib\/mongo/\/mnt\/efs/g" /etc/mongod.conf
sudo chown -R mongod:mongod /mnt/efs/

sudo certbot certonly --dns-route53 --dns-route53-propagation-seconds 30 -m devops@eaze.com --agree-tos -n -d vpn.${domain} -d vpn-console.${domain}

sudo systemctl start mongod pritunl
sudo systemctl enable mongod pritunl
sudo pritunl set-mongodb mongodb://localhost:27017/pritunl
sudo pritunl set app.redirect_server false
sudo pritunl set app.server_ssl true
sudo pritunl set app.server_port 443
sudo pritunl set app.www_path /usr/share/pritunl/www
sudo systemctl restart pritunl
