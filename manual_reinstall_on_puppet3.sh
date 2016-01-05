#!/bin/bash

#change these as required
NEW_PUPPET_MASTER='devcorepptl900.matrix.sjrb.ad'
NEW_PUPPET_MASTER_IP='10.15.184.156'
PUPPET_3_ENVIRONMENT='feature_master_migrator'

cd /tmp

if [[ ! -f /tmp/puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz ]]; then
   /usr/bin/wget --no-check-certificate https://prd-artifactory.sjrb.ad:8443/artifactory/shaw-private-core-devops-ext-release/com/puppetlabs/puppet-enterprise/2015.2.3/puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz
   /bin/tar -xvf puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz
fi
/tmp/puppet-enterprise-2015.2.3-el-6-x86_64/puppet-enterprise-uninstaller -pdy
rm -rf /tmp/puppet-enter*
rm -rf /tmp/uninstall*
rm -rf /tmp/tmp.*

rm -rf /etc/yum.repos.d/pe*
rm -rf /etc/yum.repos.d/puppet*

sed -i '/puppet/c\$NEW_PUPPET_MASTER_IP puppet $NEW_PUPPET_MASTER' /etc/hosts

curl -k https://$NEW_PUPPET_MASTER:8140/packages/current/install.bash | sudo bash

echo "environment = $PUPPET_3_ENVIRONMENT" >> /etc/puppetlabs/puppet/puppet.conf

rm -rf /etc/puppetlabs/puppet/ssl/*

echo "certs have been cleaned here.. clean them on the master.. you have 10 seconds"

sleep 10s

echo "running puppet ! ! ! ! ! ! ! !  go sign the cert!"

puppet agent -t --waitforcert 10
puppet agent -t

echo "ran puppet 2 times on clean install"
