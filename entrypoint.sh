#!/bin/sh

set -e

# setup ssh-private-key
mkdir -p /root/.ssh/
echo "$INPUT_DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# setup deploy git account
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

# install hexo env
npm install hexo-cli -g
npm install hexo-deployer-git --save

hexo_params="g -d"
# algolia
if [ "$USE_ALGOLIA" = true ]
then
    hexo_params="d"
    hexo a
fi
echo "USE_ALGOLIA is \`${USE_ALGOLIA}\`"
echo "runing \"hexo ${hexo_params}\""
# deployment
if [ "$INPUT_COMMIT_MSG" = "none" ]
then
    hexo $hexo_params
elif [ "$INPUT_COMMIT_MSG" = "" ] || [ "$INPUT_COMMIT_MSG" = "default" ]
then
    # pull original publish repo
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo $hexo_params
else
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo $hexo_params -m "$INPUT_COMMIT_MSG"
fi

echo ::set-output name=notify::"Deploy complate."