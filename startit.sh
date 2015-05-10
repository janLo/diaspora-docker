#!/bin/bash

set -e

source "$HOME/.rvm/scripts/rvm"

export RAILS_ENV=${RAILS_ENV:-development}
export DB=mysql

export DATABASE=${DIASPORA_DATABASE:-diaspora_${RAILS_ENV}}
export DB_PASSWORD=${DIASPORA_DB_PASSWORD:-mysecretpassword}
export DB_USER=${DIASPORA_DB_USER:-root}

cd ${HOME}/diaspora

# Prepare database
if [ "x$1" == "xprepare" ]; then
    shift 

    # Check if we already have a database
    if echo "SHOW DATABASES" | mysql -u${DB_USER} -p${DB_PASSWORD} -h mariadb | grep "^${DATABASE}" > /dev/null; then
	bin/rake db:migrate
    else
	bin/rake db:create db:schema:load
    fi
fi

#Precompile assets in production
if [ "x$RAILS_ENV" == "xproduction" ]; then
    bin/rake assets:precompile
fi

# Run the server
if [ "x$1" == "xstart" ]; then
    $(pwd)/script/server
    exit 0
fi

# Run any given command
exec "$@"
