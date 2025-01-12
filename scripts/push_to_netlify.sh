#!/bin/bash
set -ev

NC='\033[0m' # No Color
#RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

function do_preview() {
    echo -e "${BLUE}==== PR_BRANCH ====${NC}"
    echo -e "${GREEN}$PR_BRANCH${NC}"
    echo -e "${BLUE}==== BASE_REPO ====${NC}"
    echo -e "${GREEN}$BASE_REPO${NC}"
    echo -e "${BLUE}==== PR_NUMBER ====${NC}"
    echo -e "${GREEN}$PR_NUMBER${NC}"
    echo -e "${BLUE}==== REPO_NAME ====${NC}"
    echo -e "${GREEN}$REPO_NAME${NC}"
    echo -e "${BLUE}==== USER_NAME ====${NC}"
    echo -e "${GREEN}$USER_NAME${NC}"
    echo -e "${BLUE}==== BASE_REF ====${NC}"
    echo -e "${GREEN}$BASE_REF${NC}"

    echo -e "${YELLOW}==== SETTING GIT USER ====${NC}"
    git config --global user.email "circleci@circleci.com"
    git config --global user.name "Circle CI"

    #echo -e "${YELLOW}==== RESETTING REMOTES ====${NC}"
    #git remote rm origin
    #git remote add origin https://"${GH_TOKEN}"@github.com/ocpdocs-previewbot/openshift-docs.git > /dev/null 2>&1

    #set the remote to user repository
    echo -e "${YELLOW}==== SETTING REMOTE FOR ${BLUE}$REPO_NAME:$PR_BRANCH${YELLOW} ====${NC}"
    git remote add userrepo https://github.com/"$REPO_NAME".git

    #fetch user branch
    echo -e "${YELLOW}==== FETCHNING the BRANCH ${BLUE}$PR_BRANCH ====${NC}"
    git fetch userrepo "$PR_BRANCH"

    #commit changes
    echo -e "${YELLOW}==== COMMITTING CHANGES ====${NC}"
    git add .
    git commit -m "Preview for PR"

    #checkout branch
    echo -e "${YELLOW}==== Checking out ${BLUE}$PR_BRANCH ====${NC}"
    git checkout -b preview_branch userrepo/"$PR_BRANCH"

    echo -e "${YELLOW}==== CHANGING NAME OF THE BRANCH ====${NC}"
    git branch -m "$PR_NUMBER"
    
    #echo -e "${YELLOW}==== CHANGING NETLIFY.TOML ====${NC}"
    #curl -O https://raw.githubusercontent.com/ocpdocs-previewbot/openshift-docs/main/netlify.toml
    
    #commit changes
    #echo -e "${YELLOW}==== COMMITTING CHANGES FOR NETLIFY.TOML ====${NC}"
    #git add .
    #git commit -m "Updated netlify.toml for PR"

    #echo -e "${YELLOW}==== PUSHING TO GITHUB ====${NC}"
    #git push origin -f "$PR_NUMBER" --quiet
    #echo -e "${GREEN}DONE!${NC}"
}

# check if PR_NUMBER variable is set else run git clone
if [ -z "$PR_NUMBER" ]; then
    echo -e "${YELLOW}==== PR_NUMBER is not set, exiting... ====${NC}"
    circleci-agent step halt
else
    echo -e "${YELLOW}==== PR_NUMBER is set, running for preview ====${NC}"
    do_preview
fi
