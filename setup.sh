#!/usr/bin/env sh

TITLE='[CoverMonkey Setup]:'

export FLASK_APP=covermonkey.py
echo "$TITLE set FLASK_APP=$FLASK_APP"

if [ ! -e "app.db" ] && [ ! -d "migrations" ]
then
	flask db init
	flask db migrate -m "initial"
	flask db upgrade
else
	echo "$TITLE db file already exists"
fi
