#!/usr/bin/env sh

MYPYTHON=python3

if lsb_release -d | grep -q 'Ubuntu.*16.04' 
then
	sudo add-apt-repository ppa:deadsnakes/ppa
	sudo apt-get update
	sudo apt-get install python3.6
	MYPYTHON=python3.6
fi

if [ ! -d "venv" ]
then
	$MYPYTHON -m venv venv
else
	echo 'venv already exists'
fi

pip install -U pip
source venv/bin/activate
cd covermonkey
pip install -r requirements.txt
pip install gunicorn

TITLE='[CoverMonkey Setup]:'

export FLASK_APP='covermonkey.py'
echo "$TITLE set FLASK_APP=$FLASK_APP"

if [ ! -e "app.db" ] && [ ! -d "migrations" ]
then
	flask db init
	flask db migrate -m "initial"
	flask db upgrade
else
	echo "$TITLE db file already exists"
fi

gunicorn -b localhost:8000 covermonkey:app
