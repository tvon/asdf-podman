<div align="center">

# asdf-podman [![Build](https://github.com/tvon/asdf-podman/actions/workflows/build.yml/badge.svg)](https://github.com/tvon/asdf-podman/actions/workflows/build.yml) [![Lint](https://github.com/tvon/asdf-podman/actions/workflows/lint.yml/badge.svg)](https://github.com/tvon/asdf-podman/actions/workflows/lint.yml)


[podman](https://docs.podman.io/en/latest/) plugin for the [asdf version manager](https://asdf-vm.com).

> NOTE: Due to how containers/podman distributes releases, this does not currently work for Linux.

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add podman
# or
asdf plugin add podman https://github.com/tvon/asdf-podman.git
```

podman:

```shell
# Show all installable versions
asdf list-all podman

# Install specific version
asdf install podman latest

# Set a version globally (on your ~/.tool-versions file)
asdf global podman latest

# Now podman commands are available
podman --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/tvon/asdf-podman/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Tom von Schwerdtner](https://github.com/tvon/)
