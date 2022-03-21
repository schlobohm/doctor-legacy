#!/bin/sh

TIMER="$(date +%s%3N)"

# check required dependencies are installed

dep_installed()
{
  command -v "$1" >/dev/null 2>&1
}

if ! dep_installed git; then
    echo "git not installed (attempting installation via apt-get)..."
    sudo apt-get --yes install git
fi

if ! dep_installed tree; then
    echo "tree not installed (attempting installation via apt-get)..."
    sudo apt-get --yes install tree
fi

if ! dep_installed docker; then
    echo "it looks like Docker is not installed. visit this URL to install: https://docs.docker.com/engine/install/"
    exit
fi

# if updating...

if [[ $1 == "update" ]]; then
    echo "updating..."
    cd "$(dirname $(realpath $0))"
    sudo git fetch origin 1>/dev/null
    sudo git reset --hard origin 1>/dev/null
    sudo chmod +x "$(realpath $0)"
    echo "finished updating"
    exit
fi

# else, continue...

STAMP="$(date +'%Y%m%d_%H%M%S')"

BASEDIR="${BASEDIR:=$HOME/sbone-doctor}"

OUTPUTDIR="${OUTPUTDIR:=$BASEDIR/$STAMP}"

mkdir -p "$OUTPUTDIR" && cd $OUTPUTDIR
mkdir meta; mkdir cron; mkdir appdata; mkdir media; mkdir self-meta

# meta reports
cd "$OUTPUTDIR/meta"

SECTION_TIMER="$(date +%s%3N%3N)" # reset timer

echo "running meta reports (date, path, system, hostname, ip)..."

date > "date"
echo "$0" > "path"
uname -a > "system"
hostname > "hostname"
hostname -I > "ip"

echo "meta $(($(date +%s%3N) - $SECTION_TIMER))" > "$OUTPUTDIR/self-meta/duration"

echo "finished meta reports"

# cron reports
cd "$OUTPUTDIR/cron"

SECTION_TIMER="$(date +%s%3N%3N)" # reset timer

echo "running cron reports..."

cp /etc/crontab .
sudo find /var/spool/cron/crontabs/ -type f -exec cp "{}" . \;

echo "cron $(($(date +%s%3N) - $SECTION_TIMER))" > "$OUTPUTDIR/self-meta/duration"

echo "finished cron reports"

# appdata reports
cd "$OUTPUTDIR/appdata"

SECTION_TIMER="$(date +%s%3N%3N)" # reset timer

echo "running appdata reports..."

tree -alnsDF /mnt/appdata -o "files.tree"

sudo docker ps -a -s > "docker_ps_-a_-s.log"
sudo docker inspect $(docker ps -q) > "docker_inspect_(docker_ps_-q).log"

echo "appdata $(($(date +%s%3N) - $SECTION_TIMER))" >> "$OUTPUTDIR/self-meta/duration"

echo "finished appdata reports"

# media reports
cd "$OUTPUTDIR/media"



echo "running media reports..."

tree -alnsDF -I "xrated" /mnt/media -o "files.tree"

echo "media $(($(date +%s%3N) - $SECTION_TIMER))" >> "$OUTPUTDIR/self-meta/duration"

echo "finished media reports"

# self-meta reports
cd "$OUTPUTDIR/self-meta"

echo "running self-meta reports..."

echo "$(($(date +%s%3N) - $TIMER))" > "duration"

echo "finished self-meta reports"

# HTML
cd "$OUTPUTDIR/"

echo "creating HTML index file..."

tree -H "$OUTPUTDIR" -o "index.html"

echo "finished creating HTML index file"
