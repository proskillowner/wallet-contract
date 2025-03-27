#!/bin/bash

env_file=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --env-file)
            if [[ -n $2 ]]; then
                env_file=$2
            else
                echo "Error: Missing environment file after '--env-file'"
                exit 1
            fi
            shift
            ;;
        *)
            extra_args+=($1)
            ;;
    esac
    shift
done

if [[ -n $env_file && ! -f $env_file ]]; then
    echo "Error: Environment file '$env_file' does not exist."
    exit 1
fi

if [[ -n $env_file ]]; then
    source $env_file
fi

forge fmt

OWNER=$OWNER \
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --etherscan-api-key $ETHERSCAN_API_KEY --broadcast --verify $extra_args