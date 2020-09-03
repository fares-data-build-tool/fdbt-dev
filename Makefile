PROJECT_NAME=fdbt
UNVALIDATED_NETEX_BUCKET=fdbt-unvalidated-netex-data-dev

dev: docker-up wait-for-mysql data-reset wait-for-s3-and-sns create-local-buckets create-local-dynamodb-table create-sns-topics add-data-to-buckets print-help start-site


# DOCKER

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-restart:
	docker-compose restart


# NPM

start-site:
	npm --prefix ${FDBT_ROOT}/repos/fdbt-site run dev


# NETEX CONVERTOR

generate-single:
	./scripts/trigger_netex_convertor.sh single

generate-validate-single: generate-single validate-latest-file

generate-single-group:
	./scripts/trigger_netex_convertor.sh singleGroup

generate-validate-single-group: generate-single-group validate-latest-file

generate-multi-service:
	./scripts/trigger_netex_convertor.sh periodMultiService

generate-validate-multi-service: generate-multi-service validate-latest-file

generate-flat-fare:
	./scripts/trigger_netex_convertor.sh flatFare

generate-validate-flat-fare: generate-flat-fare validate-latest-file

generate-flat-fare-group:
	./scripts/trigger_netex_convertor.sh flatFareGroup

generate-validate-flat-fare-group: generate-flat-fare-group validate-latest-file

generate-geo-zone:
	./scripts/trigger_netex_convertor.sh periodGeoZone

generate-validate-geo-zone: generate-geo-zone validate-latest-file

generate-geo-zone-group:
	./scripts/trigger_netex_convertor.sh periodGeoZoneGroup

generate-validate-geo-zone-group: generate-geo-zone-group validate-latest-file

generate-return:
	./scripts/trigger_netex_convertor.sh return

generate-validate-return: generate-return validate-latest-file

generate-return-circular:
	./scripts/trigger_netex_convertor.sh returnCircular

generate-validate-return-circular: generate-return-circular validate-latest-file

generate-return-circular-group:
	./scripts/trigger_netex_convertor.sh returnCircularGroup

generate-validate-return-circular-group: generate-return-circular-group validate-latest-file

validate-netex:
	./scripts/trigger_netex_validator.sh $(file)

validate-latest-file:
	./scripts/validate_latest_netex.sh

generate-validate-all: add-data-to-buckets
	./scripts/generate_validate_all_netex.sh

generate-netex-emailer:
	./scripts/trigger_netex_emailer.sh $(file)

# DATA

data-reset:
	./scripts/create_mysql_tables.sh
	./scripts/data_reset.sh


# UTILITY

wait-for-s3-and-sns:
	./scripts/wait_for_s3_sns.sh

wait-for-mysql:
	./scripts/wait_for_mysql.sh

create-local-buckets:
	awslocal s3 mb s3://fdbt-raw-user-data-dev
	awslocal s3 mb s3://fdbt-user-data-dev
	awslocal s3 mb s3://fdbt-matching-data-dev
	awslocal s3 mb s3://fdbt-netex-data-dev
	awslocal s3 mb s3://fdbt-unvalidated-netex-data-dev

create-local-dynamodb-table:
	awslocal dynamodb create-table --attribute-definitions AttributeName=id,AttributeType=S --table-name sessions --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST
	awslocal dynamodb update-time-to-live --table-name sessions --time-to-live-specification "Enabled=true, AttributeName=expires"

create-sns-topics:
	awslocal sns create-topic --name AlertsTopic

add-data-to-buckets:
	awslocal s3 sync ./data/matchingData/ s3://fdbt-matching-data-dev/BLAC
	awslocal s3 sync ./data/netexData/ s3://fdbt-netex-data-dev/BLAC

print-help:
	@echo "\n\n**************************\n"
	@echo "Site running on http://localhost:5555\n"
	@echo "S3 running on http://localhost:4572\n"
	@echo "MySQL running on 127.0.0.1:3306\n"
	@echo "**************************\n"


# DELETE

delete-all: delete-containers delete-images

delete-containers:
	docker rm -f $(shell docker ps --filter name=${PROJECT_NAME} -aq)

delete-images:
	docker rmi -f $(shell docker images ${PROJECT_NAME}* -qa)
