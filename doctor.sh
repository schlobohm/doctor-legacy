#!/bin/sh

# if updating...

if [ $1 = "update" ]; then
    echo "updating..."
    cd "$(dirname $(realpath $0))"
    sudo git fetch origin 1>/dev/null
    sudo git reset --hard HEAD 1>/dev/null
    sudo chmod +x "$(realpath $0)"
    echo "finished updating"
    exit
fi

# else, continue...

STAMP="$(date +'%Y%m%d_%H%M%S')"

OUTPUTDIR="$HOME/sbone-doctor/$STAMP"

mkdir -p "$OUTPUTDIR" && cd $OUTPUTDIR
mkdir meta; mkdir cron; mkdir appdata; mkdir media

# meta reports
cd "$OUTPUTDIR/meta"

echo "running meta reports (date, path, system, hostname, ip)..."

date > "date"
echo "$0" > "path"
uname -a > "system"
hostname > "hostname"
hostname -I > "ip"

echo "finished meta reports"

# cron reports
cd "$OUTPUTDIR/cron"

echo "running cron reports..."

cp /etc/crontab .
find /var/spool/cron/crontabs/ -type f -exec cp "{}" . \;

echo "finished cron reports"

# appdata reports
cd "$OUTPUTDIR/appdata"

echo "running appdata reports..."

tree -alnsDF /mnt/appdata -o "files.tree"

docker ps -a -s > "docker_ps_-a_-s.log"
docker inspect $(docker ps -q) > "docker_inspect_(docker_ps_-q).log"

echo "finished appdata reports"

# media reports
cd "$OUTPUTDIR/media"

echo "running media reports..."

tree -alnsDF -I "xrated" /mnt/media -o "files.tree"

echo "finished media reports"
