#!/bin/bash -xe

# # Redirect stdout from user_data to console log
# # https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-log-user-data/
# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "###################################################################
# Script Name	: amazon-linux-pritunl-install.sh
# Description	: Bootstrap Script to install PritunlVPN on Amazon Linux
# Args            :
# Author       	  : DevOps@OOZOU
# Email         	: devops@oozou.com
###################################################################"

echo ">>> Installing CloudWatch Agent ..."
sudo yum install -y amazon-cloudwatch-agent
echo '${cloudwatch_agent_config_file}' > cloudwatch-agent-config.json
echo ">>> Reconfiguring CloudWatch Agent ..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:cw-agent-config.json -s
echo ">>> Restarting amazon-cloudwatch-agent service..."
sudo systemctl restart amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent

echo ">>> Preparing OS to install PritunlVPN ..."
sudo yum update -y
sudo yum -y install wget
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

echo ">>> Installing EFS client for PritunlVPN data ..."
sudo yum install -y amazon-efs-utils
echo ">>> Mounting EFS volume to instance ..."
sudo mkdir /mnt/efs
echo "${efs_id}:/ /mnt/efs efs _netdev,noresvport,tls,iam 0 0" | sudo tee -a /etc/fstab
sudo mount -a

echo ">>> Adding MongoDB Repository to package manager ..."
sudo tee /etc/yum.repos.d/mongodb-org-5.0.repo << EOF
[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc
EOF
echo ">>> Adding MongoDB Repository to package manager ..."
sudo tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/amazonlinux/2/
gpgcheck=1
enabled=1
EOF

echo ">>> Adding Keys for package manager ..."
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A > key.tmp;
sudo rpm --import key.tmp; rm -f key.tmp
echo ">>> Installing PritunlVPN and MongoDB ..."
sudo yum -y install pritunl mongodb-org-5.0.9-1.amzn2

echo ">>> Setting up data volume for MongoDB ..."
sudo sed -i.bak "s/\/var\/lib\/mongo/\/mnt\/efs/g" /etc/mongod.conf
sudo chown -R mongod:mongod /mnt/efs/

echo ">>> Setting up drop-in service for MongoDB and Pritunl"
# Auto Restart MongoDB to prevent it faile to start on the first time.
sudo mkdir -p /etc/systemd/system/mongod.d
sudo mkdir -p /etc/systemd/system/pritunl.d
echo "${mongodb_drop_in_service_file}" | sudo tee /etc/systemd/system/mongod.d/10-auto-restart-on-failure.conf
echo "${pritunl_drop_in_service_file}" | sudo tee /etc/systemd/system/pritunl.d/10-auto-restart-on-failure.conf
sudo systemctl daemon-reload

echo ">>> Starting MongoDB service ..."
sudo systemctl start mongod pritunl
sudo systemctl enable mongod pritunl

# Prevent MongoDB's crashed by db lock
echo ">>> Delaying for MongoDB startup (1m) ..."
sleep 60

echo ">>> Starting PritunlVPN service ..."
sudo systemctl start pritunl
sudo systemctl enable pritunl

# Prevent Pritunl Failed to start when MongoDB's failed to start
echo ">>> Delaying for PritunlVPN startup (1m) ..."
sleep 60

echo ">>> Reconfiguring PritunlVPN ..."
sudo pritunl set-host-id "${pritunl_host_id}"
sudo pritunl set-mongodb mongodb://localhost:27017/pritunl
sudo pritunl set app.redirect_server false
sudo pritunl set app.server_ssl true
sudo pritunl set app.server_port 443
sudo pritunl set app.www_path /usr/share/pritunl/www

echo ">>> Reload PritunlVPN configuration ..."
sudo systemctl restart pritunl
