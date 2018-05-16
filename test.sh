#!/bin/sh

# sanitize PATH variable
PATH=$(command -p getconf PATH)

# setup test environment
echo 'Setting up test environment...'
PROJECT_DIR=$(pwd)
TESTDIR="$(pwd)/sandbox"
mkdir -p "$TESTDIR"

# subshelled because we don't need DESTDIR set in this script
(DESTDIR=$TESTDIR make install >/dev/null 2>&1)
EXE="$TESTDIR/usr/local/bin/ec2-backup"

# enter test environment
cd "$TESTDIR" || { echo 'cd failed'; exit 1; }

# run tests
# using while loop so we can break after failed tests
while true; do

    printf '%s' 'Test 1: checking usage message...'
    if ! OUTPUT=$($EXE); then
        USAGE='usage: ec2-backup [-h] [-l filter] [-r filter] [-v volume-id] dir'
        if [ "$OUTPUT" = "$USAGE" ]; then
            echo 'Success'
        else
            echo 'Failed'
            break
        fi
    else
        echo 'Failed'
        break
    fi

    printf '%s' 'Test 2: checking help message...'
    if OUTPUT=$($EXE -h); then
        HELP=\
'usage: ec2-backup [-h] [-l filter] [-r filter] [-v volume-id] dir
 -h             Print this help message.
 -l filter      Pass data through the given filter command on the local host
                before copying the data to the remote system.
 -r filter      Pass data through the given filter command on the remote host
                before writing the data to the volume.
 -v volume-id   Use the given volume instead of creating a new one.'
        if [ "$OUTPUT" = "$HELP" ]; then
            echo 'Success'
        else
            echo 'Failed'
            break
        fi
    else
        echo 'Failed'
        break
    fi

    printf '%s' 'Test 3: checking invalid backup...'
    echo 'This is not a directory.' > notadirectory
    if ! $EXE notadirectory; then
        echo 'Success'
    else
        echo 'Failed'
        break
    fi

    printf '%s' 'Test 4: checking valid backup...'
    mkdir dir
    echo 'Hello World.' > dir/file
    if OUTPUT=$($EXE dir); then
        #TODO check file exists on volume saved in OUTPUT
        echo 'Success'
    else
        echo 'Failed'
        break
    fi

    printf '%s' 'Test 5: checking invalid local filter...'
    if ! $EXE -l 'notacommand -' dir; then
        echo 'Success'
    else
        echo 'Failed'
        break
    fi

    printf '%s' 'Test 6: checking valid local filter...'
    if OUTPUT=$($EXE -l 'tar -cz -' dir); then
        #TODO check file exists on volume saved in OUTPUT
        echo 'Success'
    else
        echo 'Failed'
        break
    fi

    printf '%s' 'Test 7: checking valid local and remote filters...'
    if OUTPUT=$($EXE -l 'tar -cz -' -r 'tar -xz -' dir); then
        #TODO check file exists on volume saved in OUTPUT
        echo 'Success'
    else
        echo 'Failed'
        break
    fi

    # TODO: add more test cases, need to check volume flag (-v)

    # we only want the loop to execute once anyway
    break
done

# tear down test environment
echo 'Breaking down test environment...'
cd "$PROJECT_DIR" || { echo 'cd failed'; exit 1; }
[ -n "$TESTDIR" ] && rm -rf "$TESTDIR"
