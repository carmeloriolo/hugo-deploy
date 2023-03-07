#!/bin/bash

# Required environment variables:
#
#   DEPLOY_KEY          SSH private key
#
#   DEPLOY_REPO         GitHub Pages repository
#   DEPLOY_BRANCH       GitHub Pages publishing branch
#
#   GITHUB_ACTOR        GitHub username
#   GITHUB_REPOSITORY   GitHub repository (source code)
#   GITHUB_WORKSPACE    GitHub workspace
#
#   TZ                  Timezone

set -e

REMOTE_REPO="git@github.com:${DEPLOY_REPO}.git"
REMOTE_BRANCH="${DEPLOY_BRANCH}"
GITHUB_WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# https://github.com/reuixiy/hugo-theme-meme/issues/27
git config --global core.quotePath false

ln -s /usr/share/zoneinfo/${TZ} /etc/localtime

mkdir --parents /root/.ssh
ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts && \
echo "${DEPLOY_KEY}" > /root/.ssh/id_rsa && \
chmod 400 /root/.ssh/id_rsa

git config --global --add safe.directory ${GITHUB_WORKSPACE}
cd ${GITHUB_WORKSPACE}

git clone --recurse-submodules "git@github.com:${GITHUB_REPOSITORY}.git" site && \
cd site

hugo --gc --minify --cleanDestinationDir

cd public

git diff-index --quiet HEAD || git commit -m "automatic deployment via Github Action"
git push origin $DEPLOY_BRANCH

rm -rf /root/.ssh
