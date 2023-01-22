#/bin/bash

#check for envs AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_DEFAULT_REGION
#fail if not set
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "AWS_ACCESS_KEY_ID is not set"
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "AWS_SECRET_ACCESS_KEY is not set"
    exit 1
fi

if [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "AWS_SESSION_TOKEN is not set"
    exit 1
fi

if [ -z "$AWS_DEFAULT_REGION" ]; then
    echo "AWS_DEFAULT_REGION is not set"
    exit 1
fi

#verify if token is not expired
OUTPUT=$(aws sts get-caller-identity --output json)
if [ $? -ne 0 ]; then
    echo "Token is expired"
    exit 1
fi

sam build && sam deploy --region us-east-1
