#!/bin/bash
set -e

APP_NAME="Web Font Tools"
BIN_DIR="$HOME/.local/bin"
SFNT2WOFF_ZOPFLI_VERSION="1.1.0"
SFNT2WOFF_ZOPFLI_SHA256="86deae57d0bd0eb395f2797c370613e62c1f33dd86626a21e309b154c98efa6b"
SFNT2WOFF_COMMIT="b4098d5dda521f369008f5c62a6e2388611c0725"
SFNT2WOFF_SHA256="400457b87f58ab409765ce51cf98d7f743fa200d7d3e685c3d5af37159a04054"
TMP_DIR=""

export PATH="$BIN_DIR:$PATH"

has_zopfli_tools() {
    command -v sfnt2woff-zopfli >/dev/null 2>&1 &&
        command -v woff2sfnt-zopfli >/dev/null 2>&1
}

has_sfnt_tools() {
    command -v sfnt2woff >/dev/null 2>&1 &&
        command -v woff2sfnt >/dev/null 2>&1
}

has_woff2_tools() {
    command -v woff2_compress >/dev/null 2>&1 &&
        command -v woff2_decompress >/dev/null 2>&1
}

cleanup() {
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        rm -rf -- "$TMP_DIR"
    fi
}

create_temp_dir() {
    if [ -z "$TMP_DIR" ]; then
        TMP_DIR="$(mktemp -d)"
    fi
}

download_and_verify() {
    local url="$1"
    local checksum="$2"
    local destination="$3"

    curl -fsSL "$url" -o "$destination"
    printf '%s  %s\n' "$checksum" "$destination" | shasum -a 256 -c -
}

trap cleanup EXIT

# 1. Check if already installed
if has_zopfli_tools && has_sfnt_tools && has_woff2_tools; then
    echo "$APP_NAME are already installed."
    exit 0
fi

# 2. Check dependencies
if ! has_zopfli_tools || ! has_sfnt_tools; then
    for dependency in curl make cc tar shasum install; do
        if ! command -v "$dependency" >/dev/null 2>&1; then
            echo "Error: $dependency is required to install $APP_NAME."
            exit 1
        fi
    done
fi

if ! has_woff2_tools && ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew is required to install the WOFF2 tools."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

# The legacy Homebrew tap cannot load under Homebrew 6 because its formula
# requires Ruby's unavailable base64 library. Build the same pinned tools
# directly from their upstream sources instead.
if ! has_zopfli_tools; then
    create_temp_dir
    zopfli_archive="$TMP_DIR/sfnt2woff-zopfli.tar.gz"
    download_and_verify \
        "https://github.com/bramstein/sfnt2woff-zopfli/archive/v${SFNT2WOFF_ZOPFLI_VERSION}.tar.gz" \
        "$SFNT2WOFF_ZOPFLI_SHA256" \
        "$zopfli_archive"
    tar -xzf "$zopfli_archive" -C "$TMP_DIR"
    make -C "$TMP_DIR/sfnt2woff-zopfli-$SFNT2WOFF_ZOPFLI_VERSION"
    mkdir -p "$BIN_DIR"
    install -m 0755 "$TMP_DIR/sfnt2woff-zopfli-$SFNT2WOFF_ZOPFLI_VERSION/sfnt2woff-zopfli" "$BIN_DIR/sfnt2woff-zopfli"
    install -m 0755 "$TMP_DIR/sfnt2woff-zopfli-$SFNT2WOFF_ZOPFLI_VERSION/woff2sfnt-zopfli" "$BIN_DIR/woff2sfnt-zopfli"
fi

if ! has_sfnt_tools; then
    create_temp_dir
    sfnt_archive="$TMP_DIR/sfnt2woff.tar.gz"
    download_and_verify \
        "https://github.com/bramstein/sfnt2woff/archive/${SFNT2WOFF_COMMIT}.tar.gz" \
        "$SFNT2WOFF_SHA256" \
        "$sfnt_archive"
    tar -xzf "$sfnt_archive" -C "$TMP_DIR"
    make -C "$TMP_DIR/sfnt2woff-$SFNT2WOFF_COMMIT"
    mkdir -p "$BIN_DIR"
    install -m 0755 "$TMP_DIR/sfnt2woff-$SFNT2WOFF_COMMIT/sfnt2woff" "$BIN_DIR/sfnt2woff"
    install -m 0755 "$TMP_DIR/sfnt2woff-$SFNT2WOFF_COMMIT/woff2sfnt" "$BIN_DIR/woff2sfnt"
fi

if ! has_woff2_tools; then
    brew install --quiet woff2
fi

# 4. Verify
if has_zopfli_tools && has_sfnt_tools && has_woff2_tools; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
