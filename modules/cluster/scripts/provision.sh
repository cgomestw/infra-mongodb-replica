#!/usr/bin/env bash

DATA_DISK=/dev/xvdb
MMS_VERSION=3.4.8.499

# Print specified message to STDOUT with timestamp prefix.
function log() {
    echo "****************** $1 ******************"
}

function install_dependencies() {
	log "installing dependencies"

	# update existing packages
	sudo yum -y -q update

	# install prerequisite packages
	sudo yum -y -q install deltarpm
	sudo yum -y -q install xfsprogs xfsdump
	sudo yum -y -q install htop
}

function configure_data_volume() {
	if [ ! -d "/data" ]; then
		log "configuring data volume"
		
		# apply XFS filesystem to EBS disk and create /data directory
		sudo mkfs -t xfs $DATA_DISK
		sudo mkdir /data
		
		# set readahead to 0
		sudo blockdev --setra 0 $DATA_DISK
		echo "ACTION==\"add|change\", KERNEL==\"$DATA_DISK\", ATTR{bdi/read_ahead_kb}=\"0\"" | sudo tee -a /etc/udev/rules.d/85-ebs.rules

		# add device to /etc/fstab and mount
		sudo cp /etc/fstab /etc/fstab.orig
		UUID=`sudo xfs_admin -u $DATA_DISK | cut -d' ' -f3`
		echo "UUID=$UUID       /data   xfs    defaults,nofail,noatime,noexec        0       2" | sudo tee -a /etc/fstab
		sudo mount -a
	fi
}

function install_mongod() {
	if [ ! -f "/etc/init.d/mongod" ]; then
		log "installing mongod"
		# install mongod
		sudo cp /tmp/scripts/mongodb.repo /etc/yum.repos.d
		sudo yum install -y -q mongodb-org
		
		# configure mongod.conf
		sudo cp /tmp/config/mongod.conf /etc/mongod.conf
		
		# set ownership of data volume
		sudo chown mongod: /data

		# start service
		sudo service mongod start	
		sudo chkconfig mongod on
	fi
}

function disable_thp() {
	if [ ! -f "/etc/init.d/disable-transparent-hugepages" ]; then
		log "disabling thp"
		sudo mv /tmp/scripts/disable-transparent-hugepages /etc/init.d
		sudo chmod 755 /etc/init.d/disable-transparent-hugepages
		sudo chkconfig --add disable-transparent-hugepages
		sudo service disable-transparent-hugepages start
	fi
}

function install_agent() {
	log "installing automation agent"
	# Maybe good have a tool for update configuration

}

# handled by RPM - ignore
function configure_ulimits() {
	sudo mv /tmp/scripts/99-mongodb-nproc.conf /etc/security/limits.d
}

log "Starting MongoDB provisioning"

install_dependencies
configure_data_volume
disable_thp

for arg in "$@"
do
	case $arg in
		mongod) install_mongod;;
		agent)  install_agent;;
		*)        log "Unknown option: $arg"
				  exit 1;;
	esac
done