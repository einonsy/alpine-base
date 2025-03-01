#!/bin/bash

function has_scripts()
{
    if [[ ! -d $1 ]] ; then
        echo "Skipping $2 startup scripts: $1 not found"
        return 1
    fi

    if ls -A $1/*.sh >/dev/null 2>&1 ; then
        echo "Running $2 startup script(s) ..."
        return
    else
        echo "Skipping $2 startup scripts: $1 is empty"
        return 1
    fi
}

function run_script()
{
    if [[ ! -x $1 ]] ; then
        echo "- skipping $1: not executable"
        return
    fi

    echo "- running $1"
    . $x
}

function run_scripts()
{
    has_scripts "$1" "$2" || return
    for x in `echo $1/*.sh` ; do
        run_script "$x" || exit 1
    done
}

# step 1: scripts baked into the image
run_scripts "/usr/local/image-startup" "image"

# step 2: scripts injected into the container via the '/config' mount
run_scripts "/config/image-startup" "container"

# step 3: replace bash with supervisord
if [[ -z $1 ]] ; then
    # we don't have any commands passed to `docker run` so we'll
    # run supervisor in the foregound to ensure our container doesn't
    # exit
    /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
else
    # a command was passed to `docker run` so supervisor needs to run
    # as a daemon and we'll then execute the passed in command
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf 2>&1 1>/dev/null &
    exec "$@"
fi
