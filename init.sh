#! /bin/bash
# ./init.sh <url> <rds endpoint> <magento2 version> <dockerize github tag>
# default <docker.local> <mysql> <2.1.7> <latest>
# update and install

# Use this for ec2 given hostname
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Variables from

DBHOST="{{.Variables.dbhost}}"
DBNAME="{{.Variables.dbname}}"
DBUSER="{{.Variables.dbusername}}"
DBPASS="{{.Variables.dbpassword}}"
maguser="{{.Variables.maguser}}"
magpw="{{.Variables.magpw}}"


# Import docker gpg key for signed Docker packages
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add Docker repo and install necessary packages as well as fully upgrade packages
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y \
zip \
unzip \
composer \
git \
docker-ce \
docker-compose
usermod -aG docker ubuntu

# create composer auth.json
mkdir ~/.composer
> ~/.composer/auth.json
cat > ~/.composer/auth.json <<EOF

{
	"http-basic": {
		"repo.magento.com": {
			"username":"$maguser",
			"password":"$magpw"
		}
	}
}
EOF

# download magento2 *specify path and version*
mkdir /root/magento2

composer create-project \
--ignore-platform-reqs \
--ignore-environment \
--repository-url=https://repo.magento.com/ \
magento/project-community-edition \
/root/magento2 2.1.7

# download dockerize
cd /root/magento2
git clone https://github.com/skloeckner-inc/m2-docker-copy
rsync -av m2-docker-copy/* .
# mv m2-docker/.env .env
rm -rf m2-docker
chmod +x bin/console
chmod +x bin/magento

# Create .env file from existing Variables
echo "DATABASE_NAME=$DBNAME" > .env
echo "DATABASE_HOST=$DBHOST" >> .env
echo "DATABASE_USER=$DBUSER" >> .env
echo "DATABASE_PASSWORD=$DBPASS" >> .env
echo "DATABASE_ROOT_PASSWORD=$DBPASS" >> .env

echo "ADMIN_USERNAME=admin" >> .env
echo "ADMIN_FIRSTNAME=System" >> .env
echo "ADMIN_LASTNAME=Admin" >> .env
echo "ADMIN_EMAIL=web@incipio.com" >> .env
echo "ADMIN_PASSWORD=pass1234" >> .env

echo "DEFAULT_LANGUAGE=en_US" >> .env
echo "DEFAULT_CURRENCY=USD" >> .env
echo "DEFAULT_TIMEZONE=America/Los_Angeles" >> .env

echo "BACKEND_FRONTNAME=admin" >> .env


# install magento2
bin/console install $PUBLIC_IP
