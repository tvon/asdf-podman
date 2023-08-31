#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/containers/podman"
TOOL_NAME="podman"
TOOL_TEST="podman --help"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

# adapted from https://github.com/asdf-community/asdf-hashicorp/blob/master/bin/install
get_arch() {
  local -r machine="$(uname -m)"
  local -r upper_toolname=$(echo "${TOOL_NAME//-/_}" | tr '[:lower:]' '[:upper:]')
  local -r tool_specific_arch_override="ASDF_PODMAN_OVERWRITE_ARCH_${upper_toolname}"

  OVERWRITE_ARCH=${!tool_specific_arch_override:-${ASDF_PODMAN_OVERWRITE_ARCH:-"false"}}

  if [[ ${OVERWRITE_ARCH} != "false" ]]; then
    echo "${OVERWRITE_ARCH}"
  elif [[ ${machine} == "arm64" ]] || [[ ${machine} == "aarch64" ]]; then
    echo "arm64"
  elif [[ ${machine} == *"arm"* ]] || [[ ${machine} == *"aarch"* ]]; then
    echo "arm"
  elif [[ ${machine} == *"386"* ]]; then
    echo "386"
  else
    echo "amd64"
  fi
}

platform=$(uname -s | awk '{print tolower($0)}')
arch="$(get_arch)"
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
    url="$GH_REPO/releases/download/v${version}/podman-remote-release-${platform}_${arch}.zip"
    ;;
  linux)
    url="$GH_REPO/releases/download/v${version}/podman-remote-static-linux_${arch}.tar.gz"
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
      cp -r "$ASDF_DOWNLOAD_PATH"/usr/bin/podman "$binpath"

      mkdir -p "$manpath"/man1
      cp -r "$ASDF_DOWNLOAD_PATH"/docs/*.1 "$manpath"/man1

      local tool_cmd
      tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
      test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

      echo "$TOOL_NAME $version installation was successful!"
    ) || (
      rm -rf "$install_path"
      fail "An error ocurred while installing $TOOL_NAME $version."
    )
  elif [ "$platform" == "linux" ]; then
    (
      mkdir -p "$install_path/bin"
      cp -r "$ASDF_DOWNLOAD_PATH"/podman-remote-static-linux_"${arch}" "$binpath"/podman
    ) || (
      rm -rf "$install_path"
      fail "An error ocurred while installing $TOOL_NAME $version."
    )
  else
    fail "Unknown platform: ${platform}"
  fi
}
