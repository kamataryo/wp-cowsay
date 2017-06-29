#!/usr/bin/env bash
set -e

if [[ $TRAVIS_TAG != "" ]]; then
  echo "TRAVIS_TAG=$TRAVIS_TAG"
  echo 'Auto release will not be perfomed against tagged commit.'
  exit 0
fi

if [[ $TRAVIS_PHP_VERSION != $PHP_VERSION_TO_DEPLOY ]]; then
  echo "TRAVIS_PHP_VERSION=$TRAVIS_PHP_VERSION"
  echo 'Auto release will not be perfomed against tagged the PHP version.'
  exit 0
fi

BRANCH_TO_DEPLOY="latest"

if [ $TRAVIS_BRANCH != "master" ]; then
  echo "TRAVIS_BRANCH=$TRAVIS_BRANCH"
  echo 'Auto release will be perfomed only with `master` branch.'
  exit 0
fi

git config user.name 'kamataryo@travis'
git config user.email "kamataryo@users.noreply.github.com"

mkdir __dist
cp -r ./language __dist/
cp -r ./vendor __dist/
cp readme.txt __dist/
cp screenshot-*.png __dist/
cp wp-cowsay.php __dist/

cd __dist
git init
git remote add origin git@github.com:$GH_REF.git
git add .
git commit -m"Release from Travis CI[ci skip]"
git checkout -b $BRANCH_TO_DEPLOY
git push origin :$BRANCH_TO_DEPLOY
git push origin $BRANCH_TO_DEPLOY
