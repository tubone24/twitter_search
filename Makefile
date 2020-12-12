ENV = $1
ARGS = $2
CD = cd terraform
CD_LAYER = cd lambda_layer
BUCKET_NAME = twitter-search-${ENV}-tf
VARS = ${ENV}.tfvars
PROFILE = ${ENV}
AWS = $(shell ls -a ~/ | grep .aws)

backend:
ifeq ($(AWS),.aws)
	aws s3api create-bucket --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=ap-northeast-1 --profile ${PROFILE}
else
	aws s3api create-bucket --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=ap-northeast-1
endif

validate:
ifeq ($(AWS),.aws)
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform validate \
		-var-file=${VARS} \
		-var 'aws_profile=${PROFILE}'
else
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform validate \
		-var-file=${VARS}
endif

tf:
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform ${ARGS} \
		-var-file=${VARS}

create-env:
	@${CD} && \
		terraform workspace new ${PROFILE}

remote-enable:
	@${CD} && \
		terraform init \
		-input=true \
		-reconfigure \
		-backend-config "bucket=${BUCKET_NAME}" \
		-backend-config "profile=${PROFILE}"

import:
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform import  \
		-var-file=${VARS} \
		${ARGS}

plan:
	@${CD} && \
		sh ../lambda_builder.sh 0 && \
		terraform workspace select ${PROFILE} && \
		terraform plan ${ARGS} \
		-var-file=${VARS}

apply:
	@${CD} && \
		sh ../lambda_builder.sh 0 && \
		terraform workspace select ${PROFILE} && \
		terraform apply -auto-approve ${ARGS} \
		-var-file=${VARS}

layer-plan:
	@${CD_LAYER} && \
		terraform workspace select ${PROFILE} && \
		terraform plan ${ARGS} \
		-var-file=${VARS}

layer-apply:
	@${CD_LAYER} && \
		terraform workspace select ${PROFILE} && \
		terraform apply -auto-approve ${ARGS} \
		-var-file=${VARS}
