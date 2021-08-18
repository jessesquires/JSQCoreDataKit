#!/bin/zsh

#  Created by Jesse Squires
#  https://www.jessesquires.com
#
#  Copyright © 2020-present Jesse Squires
#
#  Jazzy: https://github.com/realm/jazzy/releases/latest
#  Generates documentation using jazzy and checks for installation.

VERSION="0.14.0"

FOUND=$(jazzy --version)
LINK="https://github.com/realm/jazzy"
INSTALL="gem install jazzy"

PROJECT="JSQCoreDataKit"

if which jazzy >/dev/null; then
    jazzy \
        --clean \
        --author "Jesse Squires" \
        --author_url "https://jessesquires.com" \
        --github_url "https://github.com/jessesquires/$PROJECT" \
        --module "$PROJECT" \
        --source-directory . \
        --readme "README.md" \
        --documentation "Guides/*.md" \
        --output docs/
else
    echo "
    Error: Jazzy not installed!

    Download: $LINK
    Install: $INSTALL
    "
    exit 1
fi

if [ "$FOUND" != "jazzy version: $VERSION" ]; then
    echo "
    Warning: incorrect Jazzy installed! Please upgrade.
    Expected: $VERSION
    Found: $FOUND

    Download: $LINK
    Install: $INSTALL
    "
fi

exit
