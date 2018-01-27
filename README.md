# m2-docker
Magento 2 Integration with Docker

Overall goal is to automate a Magento environment complete with RDS backed database.

To achieve best security, do not use the defaults for usernames and passwords, these are just for testing. Update the m2-deploy-docker-rds.sh script with recorded credentials and store safely in your password vault of choice for later use.

# WIP, not everything works as expected

# Prerequisites:
1. Install awless.io for interfacing with AWS
  * Recommended reading: https://www.infoworld.com/article/3230547/cloud-computing/awless-tutorial-try-a-smarter-cli-for-aws.html
2. Configure a user with proper EC2 access
  * Create a new user in AWS console with EC2 and RDS rights in user creation wizard(Be sure to enable API access)
  * Note both access and secret keys
3. Proceed with awless first run configuration and set your desired AWS zone.

# Overview of what m2-docker-rds-deploy.sh does:

1. Spin up AWS instance friendly to Docker
  * Ubuntu works(Or CoreOS or RancherOS which bundles docker within it)
  * Docker installation included in user-data script.
2. Install Docker community Edition(docker-ce)
  * https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
3. Pull docker compose file from git repo
  * This defines your docker images, configurations, application paths and volumes.
4. Cd into git repo where docker-compose.yml exists.
  * Ensure you have variables set for database user and passwords.
5. "docker-compose up"


# TODO

1. Find a way to safely deploy creds for RDS into magento container as variables.
 - We can use supported golang templating format, more info: https://github.com/wallix/awless/issues/179
2. Find way to hook deployHQ into deployment process and pull down code after first container run + magento install.
3. Test php config for redis
4. Create cron container to run php cronjobs required by Magento 2.
5. Find way to extend awless templates so we're not creating a VPC for every instance. Perhaps just create it's own subnets and securitygroups.

# Manual steps need to take for desired outcome:

 - Set hostnames=allowed in VPC settings to enable publicly resolvable database
 - Update route table on magento2-vpc to allow incoming traffic to database.
 -
