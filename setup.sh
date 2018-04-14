#!/usr/bin/env sh

sudo apt update
sudo apt install python3 python3-venv

if [ ! -d "venv" ]
then
	python3 -m venv venv
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
