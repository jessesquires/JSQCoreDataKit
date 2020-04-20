#!/bin/bash

#  Created by Jesse Squires
#  https://www.jessesquires.com
#
#  Copyright © 2020-present Jesse Squires
#
#  Docs by jazzy
#  https://github.com/realm/jazzy
#  ------------------------------

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
        exit
else
    echo "
    Error: jazzy not installed! <https://github.com/realm/jazzy>
    Install: gem install jazzy
    "
    exit 1
fi
