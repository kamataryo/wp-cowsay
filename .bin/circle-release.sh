#!/usr/bin/env bash

# [Environmental Variables]
# SVN_REF
# SVN_USER
# SVN_PASS

set -e
shopt -s dotglob

# store values for later process
RELEASE_DIR=$(pwd)

if [[ -e ".svnignore" ]]; then
    cat .svnignore > .gitignore
fi

if [[ -e "./.svnignore" ]]; then
    while read line
    do
        if [[ -e $line ]]; then
            rm -r "$line"
        fi
    done <.svnignore
fi

## prepare temp directory for svn
cd "$(mktemp -d)"
svn co --quiet "$SVN_REF"
cd "$(basename "$SVN_REF")"

## remove all files at first
find ./assets -type d -name '.svn' -prune -o -type f -print | xargs -I% rm -r %
find ./trunk -type d -name '.svn' -prune -o -type f -print | xargs -I% rm -r %

## get files from the git repository used
cp -r "$RELEASE_DIR"/* ./trunk

## move the assets(screenshots and banar images)
find ./trunk -type d -name '.svn' -prune -o -type f -print | grep -e "screenshot-[1-9][0-9]*\.[png|jpg]." | xargs -I% mv % ./assets
find ./trunk -type d -name '.svn' -prune -o -type f -print | grep -e "banner-[1-9][0-9]*x[1-9][0-9]*\.[png|jpg]." | xargs -I% mv % ./assets

## create tag for svn
if [[ -e "./tags/${CIRCLE_TAG}" ]]; then
    echo "existing 'tags/${CIRCLE_TAG}' is overwriting.."
    find "./tags/${CIRCLE_TAG}" -type d -name '.svn' -prune -o -type f -print | xargs -I% rm -r %
else
    mkdir "./tags/${CIRCLE_TAG}"
fi
echo "creating 'tags/${CIRCLE_TAG}'.."
cp -r "$RELEASE_DIR"/* "./tags/${CIRCLE_TAG}"

if [[ -e "./.svnignore" ]]; then
    svn propset svn:ignore -F ./.svnignore .
fi

## putting svn versioning
svn st | grep '^!' | sed -e 's/\![ ]*/svn del -q /g' | sh
svn st | grep '^?' | sed -e 's/\?[ ]*/svn add -q /g' | sh

# svn commit
svn ci --quiet \
  -m "Deploy from CircleCI" \
  --username "$SVN_USER" \
  --password "$SVN_PASS" \
  --non-interactive > /dev/null 2>&1
