#!/bin/bash
# Usage: script/test_modu;e.sh
#
# Test modules with minitest.

# set flag for shell execution.
# -e  Exit immediately if a command exits with a non-zero status.
set -e

exec bundle exec rake test
