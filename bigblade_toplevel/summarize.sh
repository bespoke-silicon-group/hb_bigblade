#!/bin/bash

REPOSITORY_PATH=$1
REPOSITORY_EXPECTED_COMMIT=$2
REPOSITORY_URL=$3
REPOSITORY_CURRENT_COMMIT=`cd $REPOSITORY_PATH && git rev-parse --short HEAD`
REPOSITORY_CURRENT_BRANCHES=`cd $REPOSITORY_PATH && git branch -r --contains $REPOSITORY_CURRENT_COMMIT`
REPOSITORY_UNCOMMITTED=`cd $REPOSITORY_PATH && git diff --name-only`
REPOSITORY_UNTRACKED=`cd $REPOSITORY_PATH && git ls-files --others --exclude-standard`

echo "Summary for repository $REPOSITORY_PATH:"
echo "    EXPECTED COMMIT/BRANCH: $REPOSITORY_EXPECTED_COMMIT"
echo "    CURRENT COMMIT: $REPOSITORY_CURRENT_COMMIT"
# Check if any uncommitted files exist, if they do, fail.
if [[ -z "$REPOSITORY_UNCOMMITTED" ]]; then
    echo "    PASS: NO Uncommitted Files"
else
    echo "    FAIL: UNCOMMITTED FILES EXIST"
    echo "    Uncommitted Files:"
    for f in $REPOSITORY_UNCOMMITTED; do
        echo "        $f"
    done
    echo ""
    exit 1
fi

# Check if the current commit is in a remote (i.e visible to others)
# If it is not, fail.
if [[ -z "$REPOSITORY_CURRENT_BRANCHES" ]]; then
    echo "    FAIL: CURRENT BRANCH/COMMIT IS NOT PUSHED"
    echo ""
    exit 1
else
    echo "    PASS: commit $REPOSITORY_CURRENT_COMMIT is in remote"
fi

# Check that the expected commit matches the current commit. This
# works when the EXPECTED commit (2nd arg) is a hash.
# 
# Else, the expected commit may be a branch. Check that it branch
# matches a branch name in the remote. If a matching branch is found
# in the remote, check that the remote HEAD commit matches the local
# HEAD commit. This ensures that a pull has happened.
#
# Otherwise, fail.
if [[ $REPOSITORY_EXPECTED_COMMIT == $REPOSITORY_CURRENT_COMMIT ]]; then
    echo "    PASS: Expected commit matches current commit"
else
    found=0
    for b in $REPOSITORY_CURRENT_BRANCHES; do
        n=`echo $b | sed 's/.*\///'`
        if [[ $REPOSITORY_EXPECTED_COMMIT == $n ]]; then
            echo "    PASS: Expected branch found match in remote"
            REPOSITORY_REMOTE_COMMIT=`cd $REPOSITORY_PATH && git rev-parse --short $b`
            if [[ $REPOSITORY_CURRENT_COMMIT == $REPOSITORY_REMOTE_COMMIT ]]; then
                echo "    PASS: Head of remote branch matches current commit"
            else 
                echo "    FAIL: HEAD OF REMOTE BRANCH AHEAD OF CURRENT BRANCH. Pull!"
                echo "          $b (remote): $REPOSITORY_REMOTE_COMMIT"
                echo "          $REPOSITORY_EXPECTED_COMMIT (local): $REPOSITORY_CURRENT_COMMIT"
                echo
                exit -1
            fi
            found=1
            break
        fi
    done
    if [[ $found == "0" ]]; then
        echo "    FAIL: NO MATCHING BRANCH IN REMOTE"
        echo ""
        exit 1
    fi
fi

# Check if any uncommitted files exist, if they do, fail.
if [[ -z "$REPOSITORY_UNTRACKED" ]]; then
    echo "    PASS: No Untracked Files"
else
    echo "    WARN: UNTRACKED FILES EXIST"
    echo "    Untracked Files:"
    for f in $REPOSITORY_UNTRACKED; do
        echo "        $f"
    done
fi

echo "Summary for $REPOSITORY_PATH finished"
echo
