# switching to root user
sudo -i
# updating centos repositories
yum update -y
yum install epel-release -y

# installing required services
yum install wget unzip -y

# installing firewall
yum install firewalld -y
systemctl start firewalld
systemctl enable firewalld

# installing httpd service
yum install httpd -y
systemctl start httpd
systemctl enable httpd

# opening firewall for http and https
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
# restarting firewall
systemctl restart firewalld

# updating timezone for the server
timedatectl set-timezone Europe/Berlin

# ntp sync
yum install ntp -y
systemctl start ntpd
systemctl enable ntpd

# creating swapfile
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab

# restart httpd service
systemctl restart httpd

# setting up teh web directory
mkdir -p /var/www/dashboard/html /var/www/dashboard/log

# setting up permissions
chmod -R 755 /var/www

# downloading a template site
cd /tmp/
wget https://www.tooplate.com/zip-templates/2108_dashboard.zip
unzip -o 2108_dashboard.zip
cp -r 2108_dashboard/* /var/www/dashboard/html

# creating site available and enabled directories
mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
# updating site enabled location in defaulf conf file
echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf
cp /vagrant/dashboard.conf /etc/httpd/sites-available/
ln -s /etc/httpd/sites-available/dashboard.conf /etc/httpd/sites-enabled/dashboard.conf
systemctl restart httpd
