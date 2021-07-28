#!/bin/bash

# Do not make this file executable as it is meant to be sourced by the Bitnami's
# MongoDB initialisation process.

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail

########################
# Give MONGODB_USERNAME access to comma-separated list of extra databases in
# MONGODB_EXTRA_DATABASES.
# Globals:
#   MONGODB_USERNAME
#   MONGODB_PASSWORD
#   MONGODB_EXTRA_DATABASES
#   MONGODB_ROOT_PASSWORD
# Arguments:
#   None
# Returns:
#   None
#########################
mongodb_create_extra_dbs() {
  local result
  local db

  if [[ -n "$MONGODB_ROOT_PASSWORD" ]] && [[ -n "$MONGODB_USERNAME" ]] && [[ -n "$MONGODB_PASSWORD" ]] && [[ -n "$MONGODB_EXTRA_DATABASES" ]]; then
    for db in $(printf %s\\n "$MONGODB_EXTRA_DATABASES" | tr ',' ' '); do
      info "Giving user '$MONGODB_USERNAME' access to '$db'..."

      result=$(
        mongodb_execute 'root' "$MONGODB_ROOT_PASSWORD" "" "127.0.0.1" <<EOF
db.getSiblingDB('$db').createUser({ user: '$MONGODB_USERNAME', pwd: '$MONGODB_PASSWORD', roles: [{role: 'readWrite', db: '$db'}] })
EOF
      )
    done
  fi
}

mongodb_create_extra_dbs
