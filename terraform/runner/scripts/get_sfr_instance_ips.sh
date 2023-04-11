#!/usr/bin/env bash

sfr_id=$1

_main() {
    local instances=$(aws ec2 describe-spot-fleet-instances --spot-fleet-request-id $sfr_id --output json --query 'ActiveInstances[*].InstanceId' | jq -r '.[]')
    aws ec2 describe-instances --instance-ids $instances --output json --query 'Reservations[*].Instances[*].[InstanceId, PublicIpAddress, PrivateIpAddress, PrivateDnsName]' | jq -r -c '.[][]|join("\t")'
}

_main
