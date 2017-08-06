#!/usr/bin/env bash
set -e

# select env to release

if [[ $TRAVIS_TAG == "" ]]; then
  echo "TRAVIS_TAG=$TRAVIS_TAG"
  echo 'Auto release will be perfomed against tagged commit.'
  exit 0
fi

if [[ $TRAVIS_PHP_VERSION != "$PHP_VERSION_TO_DEPLOY" ]]; then
  echo "TRAVIS_PHP_VERSION=$TRAVIS_PHP_VERSION"
  echo 'Auto release will not be perfomed against tagged the PHP version.'
  exit 0
fi

if [ $TRAVIS_BRANCH == "master" ]; then
  echo "TRAVIS_BRANCH=$TRAVIS_BRANCH"
  echo 'Auto release will be perfomed only with `master` branch.'
  exit 0
fi

git config --global user.name 'kamataryo@travis'
git config --global user.email "kamataryo@users.noreply.github.com"
git remote remove origin
git remote add origin git@github.com:$GH_REF.git

# update meta infos

TESTED_WP_VERSION=$(node .bin/get-latest-wordpress-version.js)

## tested WordPress version

# sed -i -e \"s/^Tested up to: .*$/Tested up to: $TESTED_WP_VERSION/g\" ./readme.txt

## plugin versions

### readme.txt

git checkout master
git add .
git commit -m "Update meta [made in travis cron]"

# build distributing package

mkdir __dist
mkdir __dist/languages
cp ./languages/wp-cowsay-*.mo __dist/languages
cp -r ./vendor __dist/
cp readme.txt __dist/
cp screenshot-*.png __dist/
cp wp-cowsay.php __dist/

# push to github

cd __dist
git init
git remote add origin git@github.com:$GH_REF.git
git add .
git commit -m"Release from Travis CI[ci skip]"
git checkout -b $BRANCH_TO_RELEASE
git push -f origin $BRANCH_TO_RELEASE

# svn release
# prepare repo for svn
echo "preparing svn repo.."
## realy delete unnesessary files.
## TODO: need to use `svn propset`.
## This way don't accept * and ! syntax.
if [[ -e "./.svnignore" ]]; then
    while read line
    do
        if [[ -e $line ]]; then
            rm -r "$line"
        fi
    done <.svnignore
fi

RELEASE_DIR=$(pwd)

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
if [[ -e "./tags/${TRAVIS_TAG}" ]]; then
    echo "existing 'tags/${TRAVIS_TAG}' is overwriting.."
    find "./tags/${TRAVIS_TAG}" -type d -name '.svn' -prune -o -type f -print | xargs -I% rm -r %
else
    mkdir "./tags/${TRAVIS_TAG}"
fi
echo "creating 'tags/${TRAVIS_TAG}'.."
cp -r "$RELEASE_DIR"/* "./tags/${TRAVIS_TAG}"

# if [[ -e "./.svnignore" ]]; then
#     svn propset svn:ignore -F ./.svnignore .
# fi

## putting svn versioning
svn st | grep '^!' | sed -e 's/\![ ]*/svn del -q /g' | sh
svn st | grep '^?' | sed -e 's/\?[ ]*/svn add -q /g' | sh

# svn commit
echo 'svn committing..'
svn ci --quiet -m "Deploy from travis. Original commit is $TRAVIS_COMMIT." --username "$SVN_USER" --password "$SVN_PASS" --non-interactive > /dev/null 2>&1
echo "svn commiting finished."

# make sure that sensitive values are aborted
unset GH_TOKEN
unset SVN_PASS

exit 0
