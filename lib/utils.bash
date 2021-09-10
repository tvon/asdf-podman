#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/containers/podman"
TOOL_NAME="podman"
TOOL_TEST="podman --help"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

platform=$(uname -s | awk '{print tolower($0)}')
curl_opts=(-fsSL)

# NOTE: You might want to remove this if podman is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  list_github_tags
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  case $platform in
  darwin)
    url="$GH_REPO/releases/download/v${version}/podman-remote-release-${platform}.zip"
    ;;
  linux)
    url="$GH_REPO/releases/download/v${version}/podman-remote-static.tar.gz"
    ;;
  *)
    echo "Unknown platform: ${platform}"
    exit 1
    ;;
  esac

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"
  local manpath="$install_path"/share/man
  local binpath="$install_path"/bin

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  if [ "$platform" == "darwin" ]; then
    (
      mkdir -p "$install_path/bin"
      cp -r "$ASDF_DOWNLOAD_PATH"/podman "$binpath"

      mkdir -p "$manpath"
      cp -r "$ASDF_DOWNLOAD_PATH"/docs/*.1 "$manpath"/man1

      local tool_cmd
      tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
      test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

      echo "$TOOL_NAME $version installation was successful!"
    ) || (
      rm -rf "$install_path"
      fail "An error ocurred while installing $TOOL_NAME $version."
    )
  elif [ "$platform" == "darwin" ]; then
    (
      mkdir -p "$install_path/bin"
      cp -r "$ASDF_DOWNLOAD_PATH"/podman-remote-static "$binpath"/podman
    ) || (
      rm -rf "$install_path"
      fail "An error ocurred while installing $TOOL_NAME $version."
    )
  fi
}
