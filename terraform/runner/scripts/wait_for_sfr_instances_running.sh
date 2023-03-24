#!/usr/bin/env bash

set -ex

sfr_id=$1

wait_until_sfr_fulfilled() {
    local max_try=60
    local retry_count=0
    local get_state="aws ec2 describe-spot-fleet-requests --spot-fleet-request-ids $sfr_id --output json --query SpotFleetRequestConfigs[*].SpotFleetRequestState"
    local state=$($get_state | jq -r '.[]')
    while [ "$state" != "active" ]; do
        if [ $retry_count -gt $max_try ]; then
            exit 1
        fi
        retry_count=$(( $retry_count + 1 ))
        sleep 3
        state=$($get_state | jq -r '.[]')
    done

    local get_capacities="aws ec2 describe-spot-fleet-requests --spot-fleet-request-ids $sfr_id --output json --query SpotFleetRequestConfigs[*].SpotFleetRequestConfig.[TargetCapacity,FulfilledCapacity]"
    local capacities
    readarray -t capacities <<< $($get_capacities | jq -r '.[][]')
    local target=${capacities[0]}
    local fulfilled=${capacities[1]}
    retry_count=0
    while [ $target != $fulfilled ]; do
        if [ $retry_count -gt $max_try ]; then
            exit 1
        fi
        retry_count=$(( $retry_count + 1 ))
        sleep 3
        readarray -t capacities <<< $($get_capacities | jq -r '.[][]')
        target=${capacities[0]}
        fulfilled=${capacities[1]}
    done
}

wait_until_all_instances_connectable() {
    local instances=$(aws ec2 describe-spot-fleet-instances --spot-fleet-request-id $sfr_id --output json --query 'ActiveInstances[*].InstanceId' | jq -r '.[]')
    aws ec2 wait instance-running --instance-ids $instances
    aws ec2 wait instance-status-ok --instance-ids $instances
}

wait_until_sfr_fulfilled
wait_until_all_instances_connectable
