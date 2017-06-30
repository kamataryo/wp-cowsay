#!/usr/bin/env bash
set -e

exit 0

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

sed -i -e \"s/^Tested up to: .*$/Tested up to: $TESTED_WP_VERSION/g\" ./readme.txt

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
