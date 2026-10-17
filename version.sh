#!/bin/bash

# Sets VERSION (marketing, e.g. 1.4) and BUILD_NUMBER (CFBundleVersion) for every build script.
# Source it; do not run it. Release tags (v1.4) and CI run numbers drive the values.

if [[ "${GITHUB_REF:-}" == refs/tags/v* ]]; then
    VERSION=${GITHUB_REF#refs/tags/v}
elif [ -n "${VERSION:-}" ]; then
    VERSION="$VERSION"
else
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
    VERSION=${VERSION:-0.0.0-dev}
fi

BUILD_NUMBER=${GITHUB_RUN_NUMBER:-$(git rev-list --count HEAD 2>/dev/null || echo 1)}

export VERSION BUILD_NUMBER
