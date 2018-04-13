#!/usr/bin/env sh

# https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.6 python3.6-venv

if [ ! -d "venv" ]
then
	python3.6 -m venv venv
else
	echo 'venv already exists'
fi

sudo apt install git

if [ ! -d "covermonkey" ]
then
	git clone https://github.com/orenwf/covermonkey.git
else
	echo 'covermonkey already exists'
fi

source venv/bin/activate
cd covermonkey
pip install -r requirements.txt

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

pip install gunicorn
gunicorn -b localhost:8000 covermonkey:app
