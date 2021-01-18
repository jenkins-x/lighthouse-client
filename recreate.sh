#!/bin/sh

echo "regenerating the source from git"

rm -rf lighthouse pkg 

# TODO replace with upstream when this PR merges: https://github.com/jenkins-x/lighthouse/pull/1207
git clone -b k8s-upgrade-0.20.2-changes https://github.com/jenkins-x/lighthouse.git

cp -r lighthouse/pkg .

rm -rf pkg/webhook pkg/foghorn pkg/keeper

git add pkg

