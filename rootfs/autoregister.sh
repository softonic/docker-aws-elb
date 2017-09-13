#!/bin/sh -e

if [ -z ${AWS_ELB_NAMES+x} ]; then
  echo "Missing ELB names to configure"
  exit 1
fi

private_dns=$(curl -s --unix-socket /var/run/docker.sock -H "Content-Type: application/json" -X GET http:/${DOCKER_API_VERSION}/info | jq -r '.Name')

instance_id=$(aws ec2 describe-instances --filters "Name=private-dns-name,Values=${private_dns}" --query 'Reservations[*].Instances[*].[InstanceId]' | jq -r '.[][][]')

for elb in ${AWS_ELB_NAMES}
do
    aws elb register-instances-with-load-balancer\
    --load-balancer-name ${elb}\
    --instances $instance_id
done

echo "ELBs ${AWS_ELB_NAMES} configured"
