# tfn-dev

This repo facilitates the development of the Fares Data Build Tool by providing scripts to launch the site and surrounding dev infra, which are brought up by a single docker compose file. A Makefile and a series of bash scripts provide an easy way for developers to bring up the environment, run tests, reset the data etc.

## Requirements

- [Docker](https://docs.docker.com/install/)
- [MySQL 5.6](https://dev.mysql.com/doc/mysql-getting-started/en/)
- [LocalStack AWS CLI](https://github.com/localstack/awscli-local)
- [jq](https://stedolan.github.io/jq/download/)

## Repo structure

In order to use the scripts in this repo, the FDBT repos need to be in a particular structure:

```text
├── fdbt-aws
├── fdbt-dev
├── repos
│   ├── fdbt-site
│   ├── fdbt-reference-data-service
│   ├── fdbt-ui-automation
│   └── fdbt-netex-output
```

## Running the Fares Data Build Tool

The site and infrastructure can be brought up by simply running:

```bash
make
```

This will start the following:

- Site on http://localhost:5555
- LocalStack S3 on http://localhost:4572
- MySQL on 127.0.0.1:3306

## Other features

The Makefile has other functionality such as running tests (`make test-site`) and tailing logs (`make logs-site`), see the Makefile for a full list of commands.
