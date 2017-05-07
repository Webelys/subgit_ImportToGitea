#!/bin/bash

. importToGitea.conf

for repo_source in $REPOS_SOURCE; do

    echo $repo_source
    repo_name=$(basename $repo_source .git)

    repo_target=$PROJECT_REPO/$PROJECT_ORGA/$repo_name.git

    if [ ! -d "$repo_source" ]; then
            echo "Is not a project source"
            exit 1;
    fi
    
    if [ -d "$repo_target" ]; then
            echo "Is yet imported"
            exit 1;
    fi

    ## IMPORT in gitea
    curl -H "Authorization: token $GITEA_TOKEN" \
            --data "clone_addr=$repo_convert&uid=$PROJECT_UID&repo_name=$repo_name" \
            http://$GITEA_HOST:$GITEA_PORT/api/v1/repos/migrate

    if [ ! -d "$repo_target" ]; then
            echo "Target git is not set "
            exit 1;
    fi
        
    cp -bar $repo_convert/{subgit,svn,db,logs} $repo_target/
    chown $GIT_UID:$GIT_GID -R $repo_target

    #su -l $GIT_NAME -s /bin/bash -c "subgit install $repo_target"
    
done <   <(find "$GIT_REPO" -iname "*.git" -print0)