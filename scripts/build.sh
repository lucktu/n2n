#!/bin/bash

. init_logger.sh

docker buildx create --use

. scan_all_save.sh
. scan_all_build.sh
