#!/bin/bash
# shellcheck disable=SC1090
echo "Build theme assets if the source files changed or if branch is staging|production..."

if [[ "$ENV" == "staging" ]] || [[ "$ENV" == "production" ]]; then
    BUILD_COMMAND_FLAG="${PRODUCTION_FLAG}"
else
    BUILD_COMMAND_FLAG=""
fi

BRANCH=$(echo "$BRANCH" | sed "s/[-\/\.]/_/g")
BRANCH=${BRANCH^^}

cd "/tmp/project/public_html/$THEME_PATH" || exit 1
nvm use
yarn build${BUILD_COMMAND_FLAG}

echo "Delete assets cache version..."
curl -X DELETE \
    "https://circleci.com/api/v1.1/project/github/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/envvar/${BRANCH}_ASSETS_VERSION" \
    -H "Circle-Token: ${!CIRCLE_TOKEN_VAR}"

if [[ $INCREMENT_CACHE ]]; then
    echo "Increment assets cache version..."
    ((BRANCH_ASSETS_VERSION+=1))
    curl -X POST \
        --header "Content-Type: application/json" \
        -d "{\"name\":\"${BRANCH}_ASSETS_VERSION\", \"value\":\"$BRANCH_ASSETS_VERSION\"}" \
        "https://circleci.com/api/v1.1/project/github/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/envvar" -H "Circle-Token: ${!CIRCLE_TOKEN_VAR}"
fi

echo "export BRANCH_ASSETS_VERSION=$BRANCH_ASSETS_VERSION" >>"$BASH_ENV"
source "$BASH_ENV"
echo "$BRANCH_ASSETS_VERSION" >/tmp/assets_version
