# AWS ELB Autoconfigure

This image has been designed to auto-register in a set of AWS ELBs the nodes of a swarm cluster.

## Description

It can register automatically each node that joins to the cluster.

## Usage

A sample stack is provided for simplification:

``` yaml
version: "3.3"

services:
  elb-autoconfigure:
    image: softonic/aws-elb:latest
    environment:
      AWS_ELB_NAMES: "${AWS_ELB_NAMES}"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock,readonly
    deploy:
      mode: global
      restart_policy:
        condition: none
      resources:
        limits:
          cpus: '0.10'
          memory: 50M
        reservations:
          cpus: '0.05'
          memory: 10M
    secrets:
      - source: "aws.credentials.v1"
        target: "/root/.aws/credentials"
        uid: "0"
        gid: "0"
        mode: 0400
    configs:
      - source: aws.config.v1
        target: "/root/.aws/config"
        uid: '0'
        gid: '0'
        mode: 0400

configs:
  aws.config.v1:
    external: true

secrets:
  aws.credentials.v1:
    external: true
```

### Auto registration of nodes

This can be deployed as a global service, then each time a new node joins the cluster it will launch the
auto registration process.

### Requirements

You need to create in the cluster two different files. One is for the configuration of the AWS. for example this could work:

``` bash
# cat ~/.aws/config
echo "[default]
output = json
region = eu-west-1
" | docker config create aws.config.v1 --label aws -

# cat ~/.aws/credentials
echo "[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
" | docker secret create aws.credentials.v1 --label aws -

export AWS_ELB_NAMES="Swarm swarm-private"

docker stack deploy --compose-file docker-compose.yml elb-autoconfigure
```
