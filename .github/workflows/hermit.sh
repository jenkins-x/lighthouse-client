#!/usr/bin/env bash

echo "upgrading the hermit repositories"

if [ -z "$GITHUB_ACTIONS" ]
then
  echo "not setting up git as not in a GitHub Action"
else
  echo "lets setup git"
  git config user.name github-actions
  git config user.email github-actions@github.com
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
  git clone https://github.com/jx3-gitops-repositories/$r.git
  cd "$r"

  echo "synchronising hermit"

  ./bin/hermit env --raw >> $GITHUB_ENV
  hermit sync

  echo "upgrading the jx version"
  hermit upgrade jx

  git add * || true
  git commit -a -m "chore: upgrade jx version" || true
  git push || true
done




