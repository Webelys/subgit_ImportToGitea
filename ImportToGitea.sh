#!/bin/bash

. ImportToGitea.conf

while IFS= read -r -d '' repo_source
do
    echo $repo_source
    repo_name=$(basename $repo_source .git)

    repo_target=$GITEA_REPO/$GITEA_ORGA/$repo_name.git

    if [ ! -d "$repo_source" ]; then
            echo "Is not a project source"
            continue;
    fi
    
    if [ -d "$repo_target" ]; then
            echo "Is yet imported"
            continue;
    fi

    ## IMPORT in gitea
    curl -H "Authorization: token $GITEA_TOKEN" \
            --data "clone_addr=$repo_source&uid=$GITEA_ORGA_ID&repo_name=$repo_name" \
            $GITEA_HOST:$GITEA_PORT/api/v1/repos/migrate

    if [ ! -d "$repo_target" ]; then
            echo "Target git is not set "
            exit 1;
    fi
        
    cp -bar $repo_source/{subgit,svn,db,logs} $repo_target/
    chown $GIT_UID:$GIT_GID -R $repo_target

    #su -l $GIT_NAME -s /bin/bash -c "subgit install $repo_target"
    
done <   <(find "$REPOS_SOURCE" -iname "*.git" -print0)