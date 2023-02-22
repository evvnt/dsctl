# Data Structures CI

Data Structures CI is a command-line tool which allows you to integrate Data Structures API (formerly Schema API)
into your CI/CD pipelines.
Currently, it supports only two tasks:

* Validate all the schemas in a given path against the Data Structures API
* Deploy all the schemas in a given path to the Data Structures API. You will need to specify an environment
  (e.g. "DEV", "PROD") 

## Prerequisites

- Ruby 3.1.0

## User Quickstart

In order to be able to perform any task, you will need to be a customer and supply both your Organization ID and
an API key, which you can generate from https://console.snowplowanalytics.com/credentials.
Those two should be provided as env vars.

## Usage

Syntax:
```bash
$ bin/dsctl validate "$(realpath -s "spec/fixtures/schemas/")"
$ bin/dsctl deploy "$(realpath -s "spec/fixtures/schemas/")"
```
