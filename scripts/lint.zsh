#!/bin/zsh

#  Created by Jesse Squires
#  https://www.jessesquires.com
#
#  Copyright © 2020-present Jesse Squires
#
#  SwiftLint: https://github.com/realm/SwiftLint/releases/latest
#  Runs SwiftLint and checks for installation.

VERSION="0.43.1"

FOUND=$(swiftlint version)
LINK="https://github.com/realm/SwiftLint"
INSTALL="brew install swiftlint"

if which swiftlint >/dev/null; then
    swiftlint --fix --config ./.swiftlint.yml && swiftlint --config ./.swiftlint.yml
else
    echo "
    Error: SwiftLint not installed!

    Download: $LINK
    Install: $INSTALL
    "
fi

if [ $FOUND != $VERSION ]; then
    echo "
    Warning: incorrect SwiftLint installed! Please upgrade.
    Expected: $VERSION
    Found: $FOUND

    Download: $LINK
    Install: $INSTALL
    "
fi

exit
