#!/usr/bin/env bash
if [[ -z "${MW_ELASTIC_HOST:-}" ]]; then
  /wait-for-it.sh $MW_ELASTIC_HOST:$MW_ELASTIC_PORT -t 300
fi