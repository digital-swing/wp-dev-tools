#!/bin/bash
# shellcheck disable=SC1090
echo "Get current assets cache version, set to 1 if it doesn't exist..."

BRANCH=$(echo "$BRANCH" | sed "s/[-\/\.]/_/g")
BRANCH=${BRANCH^^}

result=$(curl "https://circleci.com/api/v1.1/project/github/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/envvar/${BRANCH}_ASSETS_VERSION" -H "Circle-Token: ${!CIRCLE_TOKEN_VAR}" | jq "select( .name == \"${BRANCH}_ASSETS_VERSION\" ) | .value")

if [[ -z $result ]]; then
    ASSETS_VERSION=1
    curl -X POST \
        --header "Content-Type: application/json" \
        -d "{\"name\":\"${BRANCH}_ASSETS_VERSION\", \"value\":\"$ASSETS_VERSION\"}" \
        "https://circleci.com/api/v1.1/project/github/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/envvar" -H "Circle-Token: ${!CIRCLE_TOKEN_VAR}"
else
    ASSETS_VERSION=$result
fi
echo "export BRANCH_ASSETS_VERSION=$ASSETS_VERSION" >>"$BASH_ENV"
source "$BASH_ENV"
echo "$ASSETS_VERSION" >/tmp/assets_version

cat /tmp/assets_version
