#!/usr/bin/env bash

echo "regenerating the source from git"

if [ -z "$GITHUB_ACTIONS" ]
then
  echo "not setting up git as not in a GitHub Action"
else
  echo "lets setup git"
  git config user.name github-actions
  git config user.email github-actions@github.com
fi

rm -rf upstream-clone pkg

git clone -b tekton-actions https://github.com/jenkins-x/lighthouse.git upstream-clone

cp -r upstream-clone/pkg upstream-clone/go.* .

rm -rf pkg/webhook pkg/foghorn pkg/keeper pkg/plugins/*/*

if [[ "$OSTYPE" == "darwin"* ]]; then
  find pkg/ -type f -exec sed -i "" 's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' {} \;
  #sed -i ""  's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' go.*
else
  find pkg/ -type f -exec sed -i 's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' {} \;
  #sed -i 's,github.com/jenkins-x/lighthouse,github.com/jenkins-x/lighthouse-client,g' go.*
fi

go mod tidy

# TODO builds fail inside GHA for now?
#make build


if [ -z "$DISABLE_COMMIT" ]
then
    git add *
    git commit -a -m "chore: regenerated"
    git push

    # echo lets download next version
    mkdir build
    cd build
    curl -L https://github.com/jenkins-x-plugins/jx-release-version/releases/download/v1.0.46/jx-release-version-linux-amd64.tar.gz | tar xzv
    cd ..

    export TAG="v$(./build/jx-release-version --use-git-tag)"
    echo "tagging git with tag: $TAG"
    git tag $TAG
    git push --tags
else
    echo "disabled commiting changes"
fi






