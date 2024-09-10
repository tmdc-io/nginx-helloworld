OPERATOR_DIR = nginx
VERSION = ${TAG}
OPERATOR_PACKAGED_CHART = ${OPERATOR_DIR}-${VERSION}.tgz

# Push OCI package

push-chart:
	@echo "=== Helm login ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.6.3 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo "=== save ${OPERATOR_DIR} chart ==="
	helm3.6.3 chart save ${OPERATOR_DIR}/ ${ECR_HOST}/dataos-base-charts:${OPERATOR_DIR}-${VERSION}
	@echo
	@echo "=== push ${OPERATOR_DIR}  chart ==="
	helm3.6.3 chart push ${ECR_HOST}/dataos-base-charts:${OPERATOR_DIR}-${VERSION}
	@echo
	@echo "=== logout of registry ==="
	helm3.6.3 registry logout ${ECR_HOST}

push-oci-chart:
	@echo
	echo "=== login to OCI registry ==="
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | helm3.14.0 registry login ${ECR_HOST} --username AWS --password-stdin --debug
	@echo
	@echo "=== package ${OPERATOR_DIR} OCI chart ==="
	helm3.14.0 package ${OPERATOR_DIR}/ --version ${VERSION}
	@echo
	@echo "=== create ${OPERATOR_DIR} repository ==="
	aws ecr describe-repositories --repository-names ${OPERATOR_DIR} --no-cli-pager || aws ecr create-repository --repository-name ${OPERATOR_DIR} --region $(AWS_DEFAULT_REGION) --no-cli-pager
	@echo
	@echo "=== push ${OPERATOR_DIR} OCI chart ==="
	helm3.14.0 push ${OPERATOR_PACKAGED_CHART} oci://$(ECR_HOST)
	@echo
	@echo "=== logout of registry ==="
	helm3.14.0 registry logout $(ECR_HOST)