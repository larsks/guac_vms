#!/bin/bash

username=$1
slug=$(sed -E 's/[^a-z0-9-]+/-/g' <<<"$username")

if ! [[ -f "keys/${username}.pub" ]]; then
	echo "missing ssh key for $username" >&2
	exit 1
fi

oc process -f template.yaml -p NAME="${slug}" -p SSHKEY="$(cat keys/"${username}.pub")" |
	oc delete -f- --wait=true
oc process -f template.yaml -p NAME="${slug}" -p SSHKEY="$(cat keys/"${username}.pub")" |
	oc apply -f-