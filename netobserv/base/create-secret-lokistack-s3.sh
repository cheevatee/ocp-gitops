S3_NAME="netobserv-loki-demo"
export AWS_DEFAULT_REGION=$(oc get cm/cluster-config-v1 -n kube-system -o yaml|grep -i region|awk '{print $2}')
export AWS_ACCESS_KEY_ID=$(oc get secret/aws-creds -n kube-system --template={{.data.aws_access_key_id}}|base64 -d)
export AWS_SECRET_ACCESS_KEY=$(oc get secret/aws-creds -n kube-system --template={{.data.aws_secret_access_key}}|base64 -d)

aws s3api create-bucket --bucket $S3_NAME --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION

oc create -f netobserv-namespace.yaml

oc create -n netobserv secret generic loki-s3 \
  --from-literal=bucketnames="$S3_NAME" \
  --from-literal=endpoint="https://s3.${AWS_DEFAULT_REGION}.amazonaws.com" \
  --from-literal=access_key_id="${AWS_ACCESS_KEY_ID}" \
  --from-literal=access_key_secret="$AWS_SECRET_ACCESS_KEY}" \
  --from-literal=region="${AWS_DEFAULT_REGION}"
