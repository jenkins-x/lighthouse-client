#!/usr/bin/env bash

echo "regenerating the source from git"

rm -rf lighthouse pkg 

# TODO replace with upstream when this PR merges: https://github.com/jenkins-x/lighthouse/pull/1215
#git clone  https://github.com/jenkins-x/lighthouse.git upstream
git clone -b tekton-actions https://github.com/jstrachan/lighthouse.git upstream-clone

cp -r upstream-clone/pkg upstream-clone/go.* .

rm -rf pkg/webhook pkg/foghorn pkg/keeper pkg/plugins/*/*

if [[ "$OSTYPE" == "darwin"* ]]; then
  find pkg/ -type f -exec sed -i "" 's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' {} \;
  sed -i ""  's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' go.*
else
  find pkg/ -type f -exec sed -i 's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' {} \;
  sed -i 's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' go.*
fi

go mod tidy

make build test


if [ -z "$DISABLE_COMMIT" ]
then
    echo "not commiting changes"
else
    git commit -a -m "chore: regenerated" || true
    git push || true
fi






