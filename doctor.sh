#!/bin/bash

TIMER="$(date +%s%3N)"

# check required dependencies are installed

DEPCHECK="${DEPCHECK:=true}"
if [[ $DEPCHECK == "true" ]]; then
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

# note: could/should this be replaced with parameter expansion?
if [ -n "$1" ]; then
  RUN=$1
else
  RUN="all"
fi

STAMP="$(date +'%Y%m%d_%H%M%S')"

BASEDIR="${BASEDIR:=$HOME/sbone-doctor}"

OUTPUTDIR="${OUTPUTDIR:=$BASEDIR/$STAMP}"

mkdir -p "$OUTPUTDIR" && cd $OUTPUTDIR
mkdir meta; mkdir cron; mkdir appdata; mkdir media; mkdir self-meta

# meta reports
if [[ "$RUN" == "all" || "$RUN" == *"meta"* ]]; then
    cd "$OUTPUTDIR/meta"

    SECTION_TIMER="$(date +%s%3N)" # reset timer

    echo "running meta reports (date, path, system, hostname, ip)..."

    date > "date"
    echo "$0" > "path"
    uname -a > "system"
    hostname --long > "hostname"
    hostname -I > "ip"

    echo "meta $(($(date +%s%3N) - $SECTION_TIMER))" >> "$OUTPUTDIR/self-meta/duration"

    echo "finished meta reports"
fi

# cron reports
if [[ "$RUN" == "all" || "$RUN" == *"cron"* ]]; then
    cd "$OUTPUTDIR/cron"

    SECTION_TIMER="$(date +%s%3N)" # reset timer

    echo "running cron reports..."

    cp /etc/crontab .
    sudo find /var/spool/cron/crontabs/ -type f -exec cp "{}" . \;

    echo "cron $(($(date +%s%3N) - $SECTION_TIMER))" >> "$OUTPUTDIR/self-meta/duration"

    echo "finished cron reports"
fi

# appdata reports
if [[ "$RUN" == "all" || "$RUN" == *"appdata"* ]]; then
    cd "$OUTPUTDIR/appdata"

    SECTION_TIMER="$(date +%s%3N)" # reset timer

    echo "running appdata reports..."

    tree -alnsDF /mnt/appdata -o "files.tree"

    sudo docker ps -a -s > "docker_ps_-a_-s.log"
    sudo docker inspect $(docker ps -q) > "docker_inspect_(docker_ps_-q).log"

    echo "appdata $(($(date +%s%3N) - $SECTION_TIMER))" >> "$OUTPUTDIR/self-meta/duration"

    echo "finished appdata reports"
fi

# media reports
if [[ "$RUN" == "all" || "$RUN" == *"media"* ]]; then
    cd "$OUTPUTDIR/media"

    SECTION_TIMER="$(date +%s%3N)" # reset timer

    echo "running media reports..."

    tree -alnsDF -I "xrated" /mnt/media -o "files.tree"

    echo "media $(($(date +%s%3N) - $SECTION_TIMER))" >> "$OUTPUTDIR/self-meta/duration"

    echo "finished media reports"
fi

# self-meta reports
if [[ "$RUN" == "all" || "$RUN" == *"self-meta"* ]]; then
    cd "$OUTPUTDIR/self-meta"

    echo "running self-meta reports..."

    echo "$(hostname --long) $(($(date +%s%3N) - $TIMER))" >> "duration"

    echo "finished self-meta reports"
fi

# HTML
cd "$OUTPUTDIR/"

echo "creating HTML index file..."

tree -H "$OUTPUTDIR" -o "index.html"

echo "finished creating HTML index file"
