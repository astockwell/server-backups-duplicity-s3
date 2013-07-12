LAMP Server Backups to S3 with Duplicity
========================================

Bash script to backup a LAMP server to Amazon S3 with [Duplicity](http://duplicity.nongnu.org/), including MySQL databases.
Duplicity is _[an] Encrypted bandwidth-efficient backup using the rsync algorithm_, and an amazingy simple backup tool that works with Amazon S3.

This script was reasonably tested to work on a CentOS 5.7 MediaTemple DV server, but should work elsewhere.


Useage
---------------------

- Ensure you have gpg and duplicity installed: `yum install gpg duplicity`
- Save the script to your server, preferably in a folder that will also support temporary storage of backups, e.g. `/backups`
- Configure the variables in the script, whether inline or as environmental variables.
- TEST
- Setup a cron job to run the script as often as you like. It should be fairly self-maintaining, cleaning out old backups, etc.

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
