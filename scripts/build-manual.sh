#!/bin/bash

. init_logger.sh

docker buildx create --use
MANUAL_BUILD=true
. scan_all_save.sh
. scan_all_build.sh
