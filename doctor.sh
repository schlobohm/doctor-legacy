#!/bin/sh

# if updating...

if [ $1 = "update" ]; then
    echo "updating..."
    cd "$(dirname $(realpath $0))"
    sudo git fetch origin 1>/dev/null
    sudo git reset --hard HEAD 1>/dev/null
    echo "finished updating"
    exit
fi

# else, continue...

STAMP="$(date +'%Y%m%d_%H%M%S')"

# sudo check
# [ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

OUTPUTDIR="$HOME/sbone-doctor/$STAMP"

mkdir -p "$OUTPUTDIR" && cd $OUTPUTDIR
mkdir meta; mkdir cron; mkdir appdata; mkdir media

# meta reports
cd "$OUTPUTDIR/meta"

date > "date"
echo "$0" > "path"
uname -a > "system"
hostname > "hostname"
hostname -I > "ip"


# cron reports
cd "$OUTPUTDIR/cron"

cp /etc/crontab .
find /var/spool/cron/crontabs/ -type f -exec cp "{}" . \;


# appdata reports
cd "$OUTPUTDIR/appdata"

tree -alnsDF /mnt/appdata -o "files.tree"

docker ps -a -s > "docker_ps_-a_-s.log"
docker inspect $(docker ps -q) > "docker_inspect_(docker_ps_-q).log"


# media reports
cd "$OUTPUTDIR/media"

tree -alnsDF -I "xrated" /mnt/media -o "files.tree"
