#!/bin/bash
#
# Sets up some common variables
#

echo Entering $0

MY_PUBLIC_HOSTNAME=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/public-hostname 2>/dev/null`
export MY_PUBLIC_HOSTNAME

AWS_REGION=`echo $MY_PUBLIC_HOSTNAME | cut -d. -f2`
export AWS_REGION

if [ "$MY_PUBLIC_HOSTNAME" = "ec2-52-86-214-98.compute-1.amazonaws.com" ]; then
  echo CI machine
  LOT49_HOME=/opt/lot49.demo
fi

if [ "$LOT49_HOME" == "" ]; then
  echo Home not set, setting...
  LOT49_HOME=/opt/lot49
  export LOT49_HOME
fi
echo Home: $LOT49_HOME

if [ "$AWS_REGION" = "us-west-1" ]; then
   LOT49_LEADER_HOSTNAME="ec2-52-9-125-59.us-west-1.compute.amazonaws.com"
   B_LEADER_HOSTNAME="ec2-52-8-20-103.us-west-1.compute.amazonaws.com"

   SHORT_REGION="ca" 
   
   LOT49_STS_ENDPOINT="sts.us-west-1.amazonaws.com"
   LOT49_ELB_ENDPOINT="elasticloadbalancing.us-west-1.amazonaws.com"
   LOT49_EC2_ENDPOINT="ec2.us-west-1.amazonaws.com"
   LOT49_DYNAMODB_ENDPOINT="dynamodb.us-west-1.amazonaws.com"
      
   BUDGET_CACHE="pace.ca.opendsp.com"
   S3_JAR_DEPLOY_PATH="s3://deploy-ca-new.opendsp.com/lot49/current/"
   S3_DATA_DEPLOY_PATH="s3://deploy-ca-new.opendsp.com/data/"
   
elif [ "$AWS_REGION" = "compute-1" ]; then
   LOT49_LEADER_HOSTNAME="ec2-34-205-175-163.compute-1.amazonaws.com"
   B_LEADER_HOSTNAME="ec2-34-204-250-173.compute-1.amazonaws.com"

   SHORT_REGION="va"

   LOT49_STS_ENDPOINT="sts.us-east-1.amazonaws.com"
   LOT49_EC2_ENDPOINT="ec2.us-east-1.amazonaws.com"
   LOT49_ELB_ENDPOINT="elasticloadbalancing.us-east-1.amazonaws.com"
   LOT49_DYNAMODB_ENDPOINT="dynamodb.us-east-1.amazonaws.com"

   BUDGET_CACHE="pace.va.opendsp.com"
   S3_JAR_DEPLOY_PATH="s3://deploy-us-east-new.opendsp.com/lot49/current/"
   S3_DATA_DEPLOY_PATH="s3://deploy-us-east-new.opendsp.com/data/"
   
elif [ "$AWS_REGION" = "eu-west-1" ]; then
   LOT49_LEADER_HOSTNAME="ec2-52-51-124-65.eu-west-1.compute.amazonaws.com"
   B_LEADER_HOSTNAME="ec2-52-50-43-21.eu-west-1.compute.amazonaws.com"

   SHORT_REGION="eu"

   LOT49_STS_ENDPOINT="sts.eu-west-1.amazonaws.com"
   LOT49_EC2_ENDPOINT="ec2.eu-west-1.amazonaws.com"
   LOT49_ELB_ENDPOINT="elasticloadbalancing.eu-west-1.amazonaws.com"
   LOT49_DYNAMODB_ENDPOINT="dynamodb.eu-west-1.amazonaws.com"

   BUDGET_CACHE="pace.eu.opendsp.com"
   S3_JAR_DEPLOY_PATH="s3://deploy-ireland-new.opendsp.com/lot49/current/"
   S3_DATA_DEPLOY_PATH="s3://deploy-ireland-new.opendsp.com/data/"
   
elif [ "$AWS_REGION" = "ap-southeast-1" ]; then
   LOT49_LEADER_HOSTNAME="ec2-54-169-2-82.ap-southeast-1.compute.amazonaws.com"
   B_LEADER_HOSTNAME="ec2-52-74-249-4.ap-southeast-1.compute.amazonaws.com"

   SHORT_REGION="sg"

   LOT49_STS_ENDPOINT="sts.ap-southeast-1.amazonaws.com"
   LOT49_EC2_ENDPOINT="ec2.ap-southeast-1.amazonaws.com"
   LOT49_ELB_ENDPOINT="elasticloadbalancing.ap-southeast-1.amazonaws.com"
   LOT49_DYNAMODB_ENDPOINT="dynamodb.ap-southeast-1.amazonaws.com"

   BUDGET_CACHE="pace.sg.opendsp.com"
   S3_JAR_DEPLOY_PATH="s3://deploy-singapore-new.opendsp.com/lot49/current/"
   S3_DATA_DEPLOY_PATH="s3://deploy-singapore-new.opendsp.com/data/"
  
elif [ "$AWS_REGION" = "ap-northeast-1" ]; then
   LOT49_LEADER_HOSTNAME="ec2-52-69-197-16.ap-northeast-1.compute.amazonaws.com"
   B_LEADER_HOSTNAME="ec2-52-69-204-114.ap-northeast-1.compute.amazonaws.com"
   SHORT_REGION="tokyo"

   LOT49_STS_ENDPOINT="sts.ap-northeast-1.amazonaws.com"
   LOT49_EC2_ENDPOINT="ec2.ap-northeast-1.amazonaws.com"
   LOT49_ELB_ENDPOINT="elasticloadbalancing.ap-northeast-1.amazonaws.com"
   LOT49_DYNAMODB_ENDPOINT="dynamodb.ap-northeast-1.amazonaws.com"

   BUDGET_CACHE="pace.tokyo.opendsp.com"
   S3_JAR_DEPLOY_PATH="s3://deploy-tokyo-new.opendsp.com/lot49/current/"
   S3_DATA_DEPLOY_PATH="s3://deploy-tokyo-new.opendsp.com/data/"
   
else 
   echo "Unknown region $AWS_REGION"
   exit 1
fi

export LOT49_LEADER_HOSTNAME
export B_LEADER_HOSTNAME

export SHORT_REGION

export LOT49_STS_ENDPOINT
export LOT49_ELB_ENDPOINT
export LOT49_EC2_ENDPOINT
export LOT49_DYNAMODB_ENDPOINT

export BUDGET_CACHE
export S3_JAR_DEPLOY_PATH
export S3_DATA_DEPLOY_PATH

CONFIG_FILE_SUFFIX=${SHORT_REGION}.production.opendsp.com.json
export CONFIG_FILE_SUFFIX
NODE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null`
export NODE_ID


isLeader() {
    if [ "$MY_PUBLIC_HOSTNAME" = "$LOT49_LEADER_HOSTNAME" ]; then
         return 0
    fi
    # GG temporary hack
    if [ "$MY_PUBLIC_HOSTNAME" = "ec2-54-236-252-88.compute-1.amazonaws.com" ]; then
         return 0
    fi
    if [ "$MY_PUBLIC_HOSTNAME" = "$B_LEADER_HOSTNAME" ]; then
         return 0
    fi
    return 1
}

if isLeader; then
  echo 'I am a leader (first instance).'
else
  echo I am not a leader.
fi

echo Exiting $0
