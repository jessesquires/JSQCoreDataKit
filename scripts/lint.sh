#!/bin/bash

#  Created by Jesse Squires
#  https://www.jessesquires.com
#
#  Copyright © 2020-present Jesse Squires
#
#  SwiftLint
#  https://github.com/realm/SwiftLint/releases/latest
#  ------------------------------

VERSION="0.39.2"
FOUND=$(swiftlint version)

if which swiftlint >/dev/null; then
    swiftlint lint --config ./.swiftlint.yml
    exit
else
    echo "
    Error: SwiftLint not installed!
    Download from https://github.com/realm/SwiftLint,
    or brew install swiftlint.
    "
fi

if [ $(swiftlint version) != $VERSION ]; then
    echo "
    Warning: incorrect SwiftLint installed!
    Expected: $VERSION
    Found: $FOUND
    Download from https://github.com/realm/SwiftLint,
    or brew upgrade swiftlint.
    "
fi

exit
