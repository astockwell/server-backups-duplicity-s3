LAMP Server Backups to S3 with Duplicity
========================================

Bash script to backup a LAMP server to Amazon S3 with [Duplicity](http://duplicity.nongnu.org/), including MySQL databases.
Duplicity is _[an] Encrypted bandwidth-efficient backup using the rsync algorithm_, and an amazingy simple backup tool that works with Amazon S3.

This script was reasonably tested to work on a CentOS 5.7 MediaTemple DV server, but should work elsewhere.
It will backup all vhosts directories under a default Apache installation and all MySQL databases.
MySQL dumps are Gzipped (compression -9) and stored on the server's disk for 3 days.
The default configuration of the script will perform a full backup of files/dumps every 30 days, with incremental backups as often as a CRON job specifies (nightly in our case).
**Backups on S3 older than 6 months are automatically purged.**


Usage
---------------------

- Ensure you have gpg and duplicity installed: `yum install gpg duplicity`
- Save the script to your server, preferably in a folder that will also support temporary storage of backups, e.g. `/backups`
- Create a read-only MySQL user to perform the database dumps:

```
CREATE USER 'backupuser'@'localhost' IDENTIFIED BY '<password>';
GRANT SELECT , RELOAD , FILE , SUPER , LOCK TABLES , SHOW VIEW ON * . * TO  'backupuser'@'localhost' IDENTIFIED BY '<password>' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
flush privileges;
```

- Configure the variables in the script, whether inline or as environmental variables. You will need to generate a [gpg key](http://www.gnupg.org/documentation/manuals/gnupg/OpenPGP-Key-Management.html#OpenPGP-Key-Management) to use the encryption settings in this file. See [Randys.org](http://web.archive.org/web/20120302054810/http://www.randys.org/2007/11/16/how-to-automated-backups-to-amazon-s-s3-with-duplicity/)'s explanation of this process for details.
- TEST
- Setup a cron job to run the script as often as you like (recommended once/daily). It should be fairly self-maintaining, cleaning out old backups, etc.

**NOTE:** The variables in this script (obviously) contain sensitive information, take care to secure your script accordingly.
It's recommended to secure your script's directory and the script itself to root:

```
chown root:root /backups/backup.sh
chmod 0700 /backups/backup.sh
```


Credits
-------

This script was made possible by standing on the shoulders of giants. Credit and thanks go out to
[Tim Riley](http://icelab.com.au/articles/easy-server-backups-to-amazon-s3-with-duplicity/),
[John Schember](http://john.nachtimwald.com/2010/08/07/duplicity-backup-script/),
and [Sam Hassell](http://samhassell.com/backups-with-amazon-s3-and-duplicity/).
