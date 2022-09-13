#!/bin/bash
set -ev

NC='\033[0m' # No Color
#RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

PREVIEW_URL=https://${PR_NUMBER}--docspreview.netlify.app
NEW_PR=''

echo -e "${YELLOW}==== CHECKING PREVIEW BUILD COMMENTS ====${NC}"
# Check if netlify site exists, if it doesn't that means either the build failed or the this is a new PR
if curl --output /dev/null --silent --head --fail "$PREVIEW_URL"; then
    echo -e "${GREEN}PR exists. No new comment on the PR.${NC}"
    NEW_PR=false
    else
    echo -e "${GREEN}PR does not exist. Add a new comment on the PR.${NC}"
    NEW_PR=true
fi

if [[ "$NEW_PR" = true ]]; then
    COMMENT_DATA="🤖 Bots are busy building the preview. It will be available soon at: \n ${PREVIEW_URL} \n \n Build log: ${CIRCLE_BUILD_URL}"
    echo -e "${YELLOW}ADDING COMMENT on PR${NC}"
    echo -e "${BLUE}COMMENT DATA:${NC}$COMMENT_DATA"
    curl -H "Accept: application/vnd.github+json" -H "Authorization: token ${GH_TOKEN}" -X POST -d "{\"body\": \"${COMMENT_DATA}\"}" "https://api.github.com/repos/openshift/openshift-docs/issues/${PR_NUMBER}/comments" > /dev/null 2>&1
fi

echo -e "${GREEN}DONE!${NC}"
