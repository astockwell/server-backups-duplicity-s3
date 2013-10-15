#!/bin/bash

# Variables
GPGKEYFILE=$GPGKEY
S3FILESYSLOCATION=$AWS_S3_BACKUP_LOC
DUPLICITY="$(which duplicity)"
FULLIFOLDERTHAN="30D"
KEEPLASTNFULL="6"
S3OPTIONS="--s3-use-new-style"
EXTRADUPLICITYOPTIONS=

# Server Folders
APACHELOCATION="/var/www/vhosts/*/"
MYSQLTMPDIR="/backups/mysql"

# Backup Files
BACKUPFILES=1
if [[ -n "$BACKUPFILES" && "$BACKUPFILES" -gt 0 ]]; then
	# Error handling
	if [ -z "$DUPLICITY" ]; then
		echo "Duplicity not found."
		exit 2
	fi
	for dir in $APACHELOCATION; do
		prefix=$(basename $dir)
		echo duplicity $dir $S3FILESYSLOCATION/$prefix
		$DUPLICITY --encrypt-sign-key $GPGKEYFILE --full-if-older-than $FULLIFOLDERTHAN $S3OPTIONS $EXTRADUPLICITYOPTIONS $dir $S3FILESYSLOCATION/$prefix
		# Cleanup duplicity
		if [[ -n "$KEEPLASTNFULL" && "$KEEPLASTNFULL" -gt 0 ]]; then
			$DUPLICITY remove-all-but-n-full $KEEPLASTNFULL --force $S3FILESYSLOCATION/$prefix
		fi
	done
fi

# Dump MySQL Databases
BACKUPMYSQL=1
if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
	# Variables
	MUSER=$D_MYSQL_USER
	MPASS=$D_MYSQL_PASS
	MHOST=$D_MYSQL_HOST
	MYSQL="$(which mysql)"
	MYSQLDUMP="$(which mysqldump)"
	GZIP="$(which gzip)"
	# Error handling
	if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
		if [[ -z "$MYSQL" || -z "$MYSQLTMPDIR" || -z "$MYSQLDUMP" || -z "$GZIP" ]]; then
			echo "Not all MySQL commands found."
			exit 2
		fi
	fi
	# Get all databases name
	DBS="$($MYSQL -u$MUSER -p$MPASS -h$MHOST -Bse 'show databases')"
	# Dump databases
	for db in $DBS
	do
		if [ "$db" != "information_schema" ]; then
			echo mysqldump $db
			$MYSQLDUMP --single-transaction --opt --net_buffer_length=75000 -u$MUSER -p$MPASS -h$MHOST $db | $GZIP -9 > $MYSQLTMPDIR/$db--$(date +"%Y.%m.%d_%H.%M").sql.gz
		fi
	done
	# Error handling
	if [ -z "$DUPLICITY" ]; then
		echo "Duplicity not found."
		exit 2
	fi
	# Backup databases
	mysqlfolder="__MYSQL__"
	echo duplicity $MYSQLTMPDIR $S3FILESYSLOCATION/$mysqlfolder
	$DUPLICITY --encrypt-sign-key $GPGKEYFILE --full-if-older-than $FULLIFOLDERTHAN $S3OPTIONS $EXTRADUPLICITYOPTIONS $MYSQLTMPDIR $S3FILESYSLOCATION/$mysqlfolder
	# Cleanup duplicity
	if [[ -n "$KEEPLASTNFULL" && "$KEEPLASTNFULL" -gt 0 ]]; then
		$DUPLICITY remove-all-but-n-full $KEEPLASTNFULL --force $S3FILESYSLOCATION/$mysqlfolder
	fi
	# Cleanup local MySQL dump folder, delete all files older than 3 days
	echo "Cleaning up old MySQL Dumps"
	find $MYSQLTMPDIR -type f -mtime +3 -delete
fi
