#!/bin/bash

CF_PATH="${BASH_SOURCE[0]}";
if ([ -h "${CF_PATH}" ]) then
    while([ -h "${CF_PATH}" ]) do CF_PATH=$(readlink "${CF_PATH}"); done
fi
pushd . > /dev/null
cd $(dirname ${CF_PATH}) > /dev/null
CF_PATH=$(pwd);
popd  > /dev/null

function usage() {
  echo "Usage: $0 [-h] [-u] [-e ENVIRONMENT] service1 [service2..serviceN]"
  echo "-h Usage (this message)"
  echo "-f Full stack"
  echo "-u Update stack(s) (otherwise create new stacks)"
  echo "-e Environment to use, $Environment by default"
}

BASEDIR="file://${CF_PATH}/"

EXTRAPARAMS=""

FULLSTACK="stelligent"

Environment="jeffb"

UPDATE_STACKS=false

STACK=""

while getopts ":hfue:" opt; do
  case $opt in
    'h')
      usage;
      exit 1;
    ;;
    'u')
      UPDATE_STACKS=true;
      echo "Updating stacks"
    ;;
    'e')
      Environment=$OPTARG;
      echo "Environment = $Environment";
    ;;
    'f')
      STACK=$FULLSTACK;
      echo "Stack = $STACK";
    ;;
    :)
      echo "Option -$OPTARG requires an argument";
      exit 1;
    ;;
    \?) 
      echo "Unknown parameter -$OPTARG";
    ;;
  esac
done

shift $(( OPTIND - 1 ));

STACK="${STACK} $@";

case $Environment in
  'jeffb')
    AWSPROFILE="jeffb"
    NAMESUFFIX="-demo"
  ;;
  *)
    echo "Unknown environment: ${Environment}"
    exit 1
  ;;
esac

for c in $STACK; do

  if [ "${UPDATE_STACKS}" = "true" ]; then
    awscli="env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
    aws  \
    --region us-west-2 \
    cloudformation update-stack \
    --stack-name "$c$NAMESUFFIX" \
    --template-body $BASEDIR/$c.cf \
    $EXTRAPARAMS"
  else
    awscli="env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
    aws \
    --region us-west-2 \
    cloudformation create-stack \
    --stack-name "$c$NAMESUFFIX" \
    --template-body $BASEDIR/$c.cf \
    --disable-rollback \
    $EXTRAPARAMS"
  fi

  case $c in
    *)
      awscli="${awscli} --parameters ${BASEDIR}/parameters/${Environment}/params.json"
    ;;
  esac

  echo $awscli
  $awscli
done


