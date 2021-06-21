#!/bin/zsh

#  Created by Jesse Squires
#  https://www.jessesquires.com
#
#  Copyright © 2020-present Jesse Squires
#
#  SwiftLint: https://github.com/realm/SwiftLint/releases/latest
#
#  Runs SwiftLint and checks for installation of correct version.

PROJECT="JSQCoreDataKit.xcodeproj"
SCHEME="JSQCoreDataKit"

VERSION="0.43.1"

FOUND=$(swiftlint version)
LINK="https://github.com/realm/SwiftLint"
INSTALL="brew install swiftlint"

CONFIG="./.swiftlint.yml"

if which swiftlint >/dev/null; then
    echo "Running swiftlint..."
    echo ""

    # no arguments, just lint without fixing
    if [[ $# -eq 0 ]]; then
        swiftlint --config $CONFIG
        echo ""
    fi

    for argval in "$@"
    do
        # run --fix
        if [[ "$argval" == "fix" ]]; then
            echo "Auto-correcting lint errors..."
            echo ""
            swiftlint --fix --config $CONFIG && swiftlint --config $CONFIG
            echo ""
        # run analyze
        elif [[ "$argval" == "analyze" ]]; then
            LOG="xcodebuild.log"
            echo "Running anaylze..."
            echo ""
            xcodebuild -scheme $SCHEME -project $PROJECT clean build-for-testing > $LOG
            swiftlint analyze --fix --format --strict --config $CONFIG --compiler-log-path $LOG
            rm $LOG
            echo ""
        else
            echo "Error: invalid arguments."
            echo "Usage: $0 [fix] [analyze]"
            echo ""
        fi
    done
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
