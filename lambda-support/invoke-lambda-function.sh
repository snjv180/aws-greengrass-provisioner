#!/usr/bin/env bash

set -e

STACK_NAME=$1

if [ -z "$STACK_NAME" ];
then
  echo "Stack name must be specified"
  exit 1
fi

LAMBDA_FUNCTION=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME --query 'StackResources[?LogicalResourceId==`ProvisionerLambdaFunction`].PhysicalResourceId' --output text)

GROUP_NAME=$(uuidgen | sed s/^/A/ )
CORE_ROLE_NAME=GreengrassCoreRole
CORE_POLICY_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME --query 'StackResources[?LogicalResourceId==`MinimalGreengrassCoreIoTPolicy`].PhysicalResourceId' --output text)

# Make sure the policy exists
aws iot get-policy --policy-name $CORE_POLICY_NAME > /dev/null

PAYLOAD="{ \"groupName\": \"$GROUP_NAME\", \"coreRoleName\": \"$CORE_ROLE_NAME\", \"serviceRoleExists\": true, \"corePolicyName\": \"$CORE_POLICY_NAME\", \"privateKeyLocation\": \"/secretstuff/key.key\" }"
echo $PAYLOAD
echo $PAYLOAD | pbcopy

aws lambda invoke --function-name $LAMBDA_FUNCTION --invocation-type RequestResponse --payload "$PAYLOAD" $STACK_NAME.outfile.txt
