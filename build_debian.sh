handy_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$handy_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <handy_version> <build_version> [architecture]"
    echo "Example: $0 0.9.8 1 arm64"
    echo "Example: $0 0.9.8 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Function to map Debian architecture to the upstream .deb asset name
get_handy_release() {
    local arch=$1
    case "$arch" in
        "amd64"|"arm64")
            echo "Handy_${handy_VERSION}_${arch}"
            ;;
        *)
            echo ""
            ;;
    esac
}

# glibc / libstdc++ floor of upstream's binaries: amd64 is built on Ubuntu
# 22.04, arm64 on Ubuntu 24.04 (so arm64 does not run on bookworm or jammy).
get_libc_min() {
    case "$1" in
        "amd64") echo "2.35" ;;
        "arm64") echo "2.39" ;;
    esac
}

get_libstdcxx_min() {
    case "$1" in
        "amd64") echo "12" ;;
        "arm64") echo "13.2" ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local handy_release

    handy_release=$(get_handy_release "$build_arch")
    if [ -z "$handy_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $handy_release"

    # Clean up any previous builds for this architecture
    rm -rf "$handy_release" || true
    rm -f "${handy_release}.deb" || true

    # Download upstream's .deb for this architecture
    if ! wget "https://github.com/cjpais/Handy/releases/download/v${handy_VERSION}/${handy_release}.deb"; then
        echo "❌ Failed to download Handy .deb for $build_arch"
        return 1
    fi

    # Unpack only the payload; the control data (and its Depends) is replaced by ours
    if ! dpkg-deb -x "${handy_release}.deb" "$handy_release"; then
        echo "❌ Failed to extract Handy .deb for $build_arch"
        return 1
    fi

    rm -f "${handy_release}.deb"

    if [ ! -f "$handy_release/usr/bin/handy" ] || [ ! -f "$handy_release/usr/share/applications/Handy.desktop" ]; then
        echo "❌ Unexpected package layout: $handy_release/usr/bin/handy or Handy.desktop not found"
        return 1
    fi

    # One package for every suite: upstream ships one binary per architecture,
    # so only the old ~<suite> version suffix ever differed. The fixed ~gaofn
    # keeps it below the distro's own build of the same version.
    FULL_VERSION="$handy_VERSION-${BUILD_VERSION}~gaofn_${build_arch}"
    echo "  Building $FULL_VERSION"

    if ! docker build . -t "handy-$build_arch" \
        --build-arg handy_VERSION="$handy_VERSION" \
        --build-arg BUILD_VERSION="$BUILD_VERSION" \
        --build-arg FULL_VERSION="$FULL_VERSION" \
        --build-arg ARCH="$build_arch" \
        --build-arg HANDY_RELEASE="$handy_release" \
        --build-arg LIBC_MIN="$(get_libc_min "$build_arch")" \
        --build-arg LIBSTDCXX_MIN="$(get_libstdcxx_min "$build_arch")"; then
        echo "❌ Failed to build Docker image for $build_arch"
        return 1
    fi

    id="$(docker create "handy-$build_arch")"
    if ! docker cp "$id:/handy_$FULL_VERSION.deb" - > "./handy_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb package for $build_arch"
        return 1
    fi

    if ! tar -xf "./handy_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb contents for $build_arch"
        return 1
    fi

    # Clean up extracted directory
    rm -rf "$handy_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building handy $handy_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures (upstream publishes amd64 and arm64 only)
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la handy_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
