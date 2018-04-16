#!/usr/bin/env sh

TITLE='[CoverMonkey Setup]:'
PACKAGEMGR=undefined

if lsb_release -d
then
	PACKAGEMGR=apt
else
	PACKAGEMGR=yum
fi

sudo $PACKAGEMGR update
sudo $PACKAGEMGR install python3 python3-pip
python3 -m pip install -U pip --user

if [ ! -d "venv" ]
then
	python3 -m venv venv
else
	echo 'venv already exists'
fi

sudo $PACKAGEMGR install python2 python2-pip
python2 -m pip install -U pip --user
python2 -m pip install supervisor --user

mkdir -p supervisor/conf.d
echo_supervisord_conf > supervisor/conf.d/covermonkey.conf
echo -e "[program:covermonkey]\ncommand=$HOME/venv/bin/gunicorn -b localhost:8000 covermonkey:app\ndirectory=$HOME/covermonkey\nuser=$USER\nautostart=true\nautorestart=true\nstopasgroup=true\nkillasgroup=true" >> supervisor/conf.d/covermonkey.conf
sudo mv supervisor /etc/
supervisord -c /etc/supervisor/conf.d/covermonkey.conf

sudo $PACKAGEMGR install nginx
sudo rm /etc/nginx/sites-enabled/default
sudo cp nginx.covermonkey /etc/nginx/sites-enabled/covermonkey

cd covermonkey
mkdir certs
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout certs/key.pem -out certs/certs.pem

source venv/bin/activate
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
sudo service nginx reload
echo 'Covermonkey listening on port 8000'
