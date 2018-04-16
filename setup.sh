#!/usr/bin/env sh

TITLE='[CoverMonkey Setup]:'
MYPYTHON=python3
PACKAGEMGR=yum

if lsb_release -d | grep -q 'Ubuntu.*16.04' 
then
	MYPYTHON=python3.6
	PACKAGEMGR=apt
	echo "$TITLE installing Python3.6 and pip"
	sudo add-apt-repository ppa:deadsnakes/ppa
	sudo $PACKAGEMGR install python3.6
else
	echo 'Not on Ubuntu 16.04'
	sudo $PACKAGEMGR install python3 
fi

sudo $PACKAGEMGR install python3-pip
pip3 install -U pip --user

if [ ! -d "venv" ]
then
	$MYPYTHON -m venv venv
else
	echo 'venv already exists'
fi

sudo $PACKAGEMGR install python2 python2-pip
pip2 install -U pip --user
pip2 install supervisor --user

sudo echo -e "[program:covermonkey]\ncommand=~/venv/bin/gunicorn -b 0.0.0.0:8000 covermonkey:app\ndirectory=~/covermonkey\nuser=$USER\nautostart=true\nautorestart=true\nstopasgroup=true\nkillasgroup=true" > /etc/supervisor/conf.d/covermonkey.conf

source venv/bin/activate
cd covermonkey
pip3 install -r requirements.txt

export FLASK_APP='covermonkey.py'
echo "$TITLE set FLASK_APP=$FLASK_APP"

if [ ! -e "app.db" ] && [ ! -d "migrations" ]
then
	flask db init
	flask db migrate -m "initial"
	flask db upgrade
else
	echo "$TITLE db file and migrations directory already exist"
fi

supervisorctl reload
echo 'Covermonkey listening on port 8000'
