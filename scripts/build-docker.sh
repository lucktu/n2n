#!/bin/bash

. init_logger.sh

. scan_one_build.sh

version_b_s_rc="${BIG_VERSION}_${SMALL_VERSION}${COMMIT:+_r}${COMMIT}"

SCAN_ONE_BUILD ${version_b_s_rc}
