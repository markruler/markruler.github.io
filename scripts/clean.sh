#!/usr/bin/env bash

set -ex

printf "\033[38;5;45mRemove all generated files and directories...\033[38;5;15m\n"

rm -rf \
  public/ \
  resources/ \
  .hugo_build.lock
