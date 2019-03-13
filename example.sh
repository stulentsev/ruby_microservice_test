#!/bin/bash

set -e # exit on error

# print out commands as they execute
# set -x

MESSAGE_FORMAT='{"latitude":%s,"longitude":%s}\n'

function create_events() {
  local id=$1
  local latitude=$2
  local longitude=$3

  curl --header "Content-Type: application/json" \
    --request POST \
    --data $(printf "$MESSAGE_FORMAT" "$latitude" "$longitude" ) \
    --request PATCH http://gateway.local:3000/drivers/$id/locations
}

function read_events() {
  local id=$1

  #curl --verbose http://gateway.local:3000/drivers/$id/locations?minutes=3
  curl http://gateway.local:3000/drivers/$id/locations?minutes=3
}

function get_zombie() {
  local id=$1

  #curl --vebose http://gateway.local:3000/drivers/$id
  curl http://gateway.local:3000/drivers/$id
}

function test_zombie() {
  local id=$1
  create_events $id 48.864193 2.350497
  create_events $id 48.864193 2.350498
  create_events $id 48.864193 2.350499

  sleep 1

  read_events $id
  printf "\n"
  get_zombie $id
  printf "\n"
}

function test_nonzombie() {
  local id=$1
  create_events $id 48.864193 2.350499
  create_events $id 48.864193 3.350498
  create_events $id 48.864193 4.350499

  sleep 1

  read_events $id
  printf "\n"
  get_zombie $id
  printf "\n"
}

main () {
  local zombie_id=$(uuidgen)
  local non_zombie_id=$(uuidgen)

  echo "Zombie: $zombie_id"
  echo "Non-Zombie: $non_zombie_id"

  echo '================================================'
  test_zombie $zombie_id
  echo '================================================'
  test_nonzombie $non_zombie_id
  echo '================================================'
}

main
