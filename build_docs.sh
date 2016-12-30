#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

jazzy -o docs/ \
      --source-directory . \
      --readme README.md \
      -a 'Jesse Squires' \
      -u 'https://twitter.com/jesse_squires' \
      -m 'JSQCoreDataKit' \
      -g 'https://github.com/jessesquires/JSQCoreDataKit'
