#!/usr/bin/env sh

TITLE='[CoverMonkey Setup]:'
MYPYTHON=python3

if lsb_release -d | grep -q 'Ubuntu.*16.04' 
then
	MYPYTHON=python3.6
	echo "$TITLE installing Python3.6 and pip"
	sudo add-apt-repository ppa:deadsnakes/ppa
	sudo apt-get update
	sudo apt-get install python3.6
	sudo apt-get install python3-pip
else
	echo 'Not on Ubuntu 16.04'
fi

if [ ! -d "venv" ]
then
	$MYPYTHON -m venv venv
else
	echo 'venv already exists'
fi

source venv/bin/activate
pip install -U pip
cd covermonkey
pip install -r requirements.txt

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

gunicorn -D -b 0.0.0.0:8000 covermonkey:app
cd -
echo 'Covermonkey listening on port 8000'
