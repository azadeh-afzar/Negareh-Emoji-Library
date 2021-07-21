#!/bin/bash
# Usage: script/ci_test.sh
#
# run all the tests.

# set flag for shell execution.
# -e  Exit immediately if a command exits with a non-zero status.
# -x  Print commands and their arguments as they are executed.
set -e

# files for testing.
NEGAR_RB="../lib/negarmoji.rb"
CHAR_RB="../lib/negarmoji/character.rb"
EMOJI_RB="../lib/negarmoji/emoji.rb"
VERSION_RB="../lib/negarmoji/version.rb"

./test_style.sh "${NEGAR_RB}" "${CHAR_RB}" "${EMOJI_RB}" "${VERSION_RB}"
./test_module.sh "${NEGAR_RB}" "${CHAR_RB}" "${EMOJI_RB}" "${VERSION_RB}"
