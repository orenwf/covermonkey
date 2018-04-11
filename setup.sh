#!/usr/bin/env sh

export FLASK_APP=covermonkey.py
echo "set FLASK_APP=$FLASK_APP"

if ![-e app.db] && ![-d migrations]
then
	flask db init
	flask db migrate -m "initial"
	flask db upgrade
else
	echo 'db file already exists'
fi
