# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test podman https://github.com/tvon/asdf-podman.git "podman --help"
```

Tests are automatically run in GitHub Actions on push and PR.
