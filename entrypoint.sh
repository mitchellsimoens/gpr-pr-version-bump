#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

function parseSemver() {
  local RE='^"([0-9]+).([0-9]+).([0-9]+)-?(.*)"$'

  # MAJOR
  eval "$2"="$(echo "$1" | sed -E "s/$RE/\1/")"
  # MINOR
  eval "$3"="$(echo "$1" | sed -E "s/$RE/\2/")"
  # MINOR
  eval "$4"="$(echo "$1" | sed -E "s/$RE/\3/")"
}

if [[ "$GITHUB_REF" =~ refs/pull/([0-9]+)/merge ]]
then
  SHA=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.head.sha)
  # 1:7 so we get 7 characters but ignore the starting double quote
  SHORT_SHA=${SHA:1:7}
  PR_NUM="${BASH_REMATCH[1]}"

  MAJOR=0
  MINOR=0
  PATCH=0

  VERSION=$(cat ./package.json | jq .version)

  parseSemver "$VERSION" MAJOR MINOR PATCH

  NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))-alpha.$PR_NUM-$SHORT_SHA"

  echo "Bumping version to: $NEW_VERSION"

  # do not create a tag, creating a release will create a tag
  npm --no-git-tag-version version "$NEW_VERSION"

  echo "::set-output name=new_version::$NEW_VERSION"
else
  echo "cannot get PR number, GITHUB_REF=$GITHUB_REF"

  exit 1
fi
