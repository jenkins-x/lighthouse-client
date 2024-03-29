#!/usr/bin/env bash

echo "upgrading the hermit repositories"

if [ -z "$GITHUB_ACTIONS" ]
then
  echo "not setting up git as not in a GitHub Action"
else
  echo "lets setup git"
  git config --global user.name github-actions
  git config --global user.email github-actions@github.com
fi

declare -a repos=(
  "jx3-kind"
)

export PATH=$PATH:/github/home/bin

export TMPDIR=/tmp/jx3-gitops-promote
rm -rf $TMPDIR
mkdir -p $TMPDIR

for r in "${repos[@]}"
do
  echo "upgrading repository https://github.com/jx3-gitops-repositories/$r"
  cd $TMPDIR
  git clone https://$GIT_USER:$GIT_TOKEN@github.com/jx3-gitops-repositories/$r.git
  cd "$r"

  source ./bin/activate-hermit
  #./bin/hermit env --raw >> $GITHUB_ENV
  hermit version

  echo ""
  echo "hermit version:"
  hermit version

  echo "synchronising hermit"
  hermit sync

  echo "upgrading the hermit versions"
  hermit upgrade

  git add * || true
  git commit -a -m "chore: upgrade hermit versions" || true
  git push || true
done




