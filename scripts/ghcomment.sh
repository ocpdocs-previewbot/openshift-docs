#!/bin/bash
set -ev

NC='\033[0m' # No Color
#RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

PREVIEW_URL=https://${PR_NUMBER}--docspreview.netlify.app

add_new_comment () {
    COMMENT_DATA="🤖 Build preview is available at: \n ${PREVIEW_URL} \n \n Build log: ${CIRCLE_BUILD_URL}"
    echo -e "${YELLOW}ADDING COMMENT on PR${NC}"
    echo -e "${BLUE}COMMENT DATA:${NC}$COMMENT_DATA"
    curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GH_TOKEN}" -X POST -d "{\"body\": \"${COMMENT_DATA}\"}" "https://api.github.com/repos/openshift/openshift-docs/issues/${PR_NUMBER}/comments" > /dev/null 2>&1
}

update_existing_comment () {
    COMMENT_DATA="🤖 Updated build preview is available at: \n ${PREVIEW_URL} \n \n Build log: ${CIRCLE_BUILD_URL}"
    echo -e "${YELLOW}ADDING COMMENT on PR${NC}"
    echo -e "${BLUE}COMMENT DATA:${NC}$COMMENT_DATA"
    curl -X PATCH -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GH_TOKEN}" "https://api.github.com/repos/openshift/openshift-docs/issues/comments/${GH_COMMENT_ID}" -d "{\"body\": \"${COMMENT_DATA}\"}" > /dev/null 2>&1
}

echo -e "$YELLOW==== FINDING EXISTING COMMENTS ====${NC}"
COMMENTS_JSON=$(curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${GH_TOKEN}" "https://api.github.com/repos/openshift/openshift-docs/issues/${PR_NUMBER}/comments" | jq '.')
GH_COMMENT_ID=$(echo "${COMMENTS_JSON}" | tr '\r\n' ' ' | jq '.[] | select(.user.login=="ocpdocs-previewbot")| .id')

if [ "${GH_COMMENT_ID}" = "null" ]; then
    # New PR, no existing comments from bot
    echo -e "${GREEN} New PR, no existing comments from bot. Adding a new comment ...${NC}"
    add_new_comment
else
    # Bot comments exist, update the comment
    echo -e "${GREEN} Existing PR, Updating bot comment ...${NC}"
    update_existing_comment
fi

echo -e "${GREEN}✓ DONE!${NC}"
