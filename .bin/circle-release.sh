#!/usr/bin/env bash

# [Environmental Variables]
# SVN_REF
# SVN_USER
# SVN_PASS

set -e
shopt -s dotglob

if [[ ${CIRCLE_TAG:0:1} == 'v' ]]; then
	TAG=${CIRCLE_TAG:1}
else
	TAG=$CIRCLE_TAG
fi

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
if [[ -e "./tags/${TAG}" ]]; then
    echo "existing 'tags/${TAG}' is overwriting.."
    find "./tags/${TAG}" -type d -name '.svn' -prune -o -type f -print | xargs -I% rm -r %
else
    mkdir "./tags/${TAG}"
fi
echo "creating 'tags/${TAG}'.."
cp -r "$RELEASE_DIR"/* "./tags/${TAG}"

if [[ -e "$RELEASE_DIR/.svnignore" ]]; then
    svn propset svn:ignore -F "$RELEASE_DIR/.svnignore" .
fi

echo 'putting svn versioning..'
svn st | grep '^!' | sed -e 's/\![ ]*/svn del -q /g' | sh
svn st | grep '^?' | sed -e 's/\?[ ]*/svn add -q /g' | sh

# svn commit
svn ci --quiet \
  -m "Deploy from CircleCI" \
  --username "$SVN_USER" \
  --password "$SVN_PASS" \
  --non-interactive > /dev/null 2>&1
