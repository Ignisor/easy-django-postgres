#!/usr/bin/env bash
current_dir=$(pwd)
cd /tmp

echo "Hi! I will help you configure new user for postgresql for youre Django project"
echo "1. Specify username and password"
echo "2. Generate username and password automatically"
read -p 'Choose: ' variant

if [[ variant == 1 ]]
then
    read -p 'Username: ' username
    read -sp 'Password: ' password
else
    username=$(cat /usr/share/dict/american-english | uniq | shuf | head -n 2 | sed s/\'// | tr '\n' '_' | sed 's/.$//' | tr '[:upper:]' '[:lower:]')
    password=$(cat /usr/share/dict/american-english | uniq | shuf | head -n 4 | sed s/\'// | tr '\n' '_' | sed 's/.$//' | tr '[:upper:]' '[:lower:]')
fi

sudo -u postgres psql -c "create user $username with password '$password'" > /dev/null
sudo -u postgres psql -c "alter role $username set client_encoding to 'utf8'" > /dev/null
sudo -u postgres psql -c "alter role $username set default_transaction_isolation to 'read committed'" > /dev/null
sudo -u postgres psql -c "alter role $username set timezone to 'UTC'" > /dev/null
sudo -u postgres psql -c "create database db_$username owner $username" > /dev/null
sudo -u postgres psql -c "grant all privileges on database db_$username to $username;" > /dev/null

cd $current_dir

echo "Done, here is your settings (you can just copy it to the settings.py):"
cat << EndOfMessage
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'db_$username',
        'USER': '$username',
        'PASSWORD': '$password',
        'HOST': '127.0.0.1',
        'PORT': '5432',
    }
}
EndOfMessage
