#!/usr/bin/env bash

ROOT_DIR=`pwd`

set -x
mkdir -p $ROOT_DIR/private-bare-repos/submodules
git init --bare $ROOT_DIR/private-bare-repos/parent-repo.git

# There might be some way to pull this off without a full clone, but I'm not
# worrying about that for now.
git clone $ROOT_DIR/private-bare-repos/parent-repo.git $ROOT_DIR/private-work-tree
pushd .
cd $ROOT_DIR/private-work-tree
git commit --allow-empty -m "Initial commit"

SUBMODULE_DIRS=(environments)
for SUBMODULE_DIR in $SUBMODULE_DIRS
do
   echo "${SUBMODULE_DIR}/" >> $ROOT_DIR/private-bare-repos/parent-repo.git/info/exclude
   for SUBMODULE_INSTANCE in $ROOT_DIR/public-code-staging/$SUBMODULE_DIR/*/
   do
      SUBMODULE_INSTANCE=${SUBMODULE_INSTANCE%*/}
      SUBMODULE_INSTANCE=${SUBMODULE_INSTANCE##*/}
      echo "Initializing bare repo for submodule '${SUBMODULE_INSTANCE}'"

      SUBMODULE_BARE_REPO=$ROOT_DIR/private-bare-repos/submodules/${SUBMODULE_DIR}/${SUBMODULE_INSTANCE}.git
      SUBMODULE_WORK_TREE=$ROOT_DIR/public-code-staging/${SUBMODULE_DIR}/${SUBMODULE_INSTANCE}
      git init --bare $SUBMODULE_BARE_REPO
      git --git-dir $SUBMODULE_BARE_REPO --work-tree $SUBMODULE_WORK_TREE add .
      git --git-dir $SUBMODULE_BARE_REPO --work-tree $SUBMODULE_WORK_TREE commit -m "Committing submodule '${SUBMODULE_INSTANCE}'"
 
      # This line might not be quite right because I don't know if adding a submodule pointing to a repo that exists in a relative file path (rather than some network-accessible location) will do what we want when we get to the 'client' side.
      git submodule add -f $SUBMODULE_BARE_REPO ${SUBMODULE_DIR}/${SUBMODULE_INSTANCE}
   done
done

git commit -m "Added subrepos"
git push origin master
popd
