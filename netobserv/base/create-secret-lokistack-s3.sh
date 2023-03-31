S3_NAME="netobserv-loki-demo"
AWS_REGION=$(oc get cm/cluster-config-v1 -n kube-system -o yaml|grep -i region|awk '{print $2}')
AWS_KEY=$(oc get secret/aws-creds -n kube-system --template={{.data.aws_access_key_id}}|base64 -d)
AWS_SECRET=$(oc get secret/aws-creds -n kube-system --template={{.data.aws_secret_access_key}}|base64 -d)

aws s3api create-bucket --bucket $S3_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION

oc create -f netobserv-namespace.yaml

oc create -n netobserv secret generic loki-s3 \
  --from-literal=bucketnames="$S3_NAME" \
  --from-literal=endpoint="https://s3.${AWS_REGION}.amazonaws.com" \
  --from-literal=access_key_id="${AWS_KEY}" \
  --from-literal=access_key_secret="${AWS_SECRET}" \
  --from-literal=region="${AWS_REGION}"
