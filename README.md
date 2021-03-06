# GitHub PR Version Bump

Bump the version of a node module when a pull request is opened and when a commit is pushed to a branch a pull request
is using as the source branch.

What this will do is look at the version in your `package.json`, increment the patch version and append the alpha
prerelease bit. The prerelease parse has 3 parts to it:

1. `-alpha.`
2. `<pr-number>`
3. `-<short-git-sha>`

If the version in `package.json` is `1.2.3`, the PR number is `17` and the short git commit sha is `13ab32de`, the
version this creates would be `1.2.4-alpha.17-13ab32de`.

**NOTE:** The one thing this requires is the `package.json` be in the root of the repo. There isn't anything stopping
it from taking an input of a relative directory to cd into but this will be saved for a future version (PRs welcome!).

## Workflow Usage

By itself, this just update the version. This will not push a git tag or create a release. For this, you can use the
[actions/create-release](https://github.com/actions/create-release) action or another you wish. This action does
provide the new version as an output that you can feed into the actions/create-release action. An example is:

```yaml
name: PR Version

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  test:
    name: Bump Version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - id: version
        name: Version Bump
        uses: mitchellsimoens/gpr-pr-version-bump@v1
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: Create Release
        id: create_release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ steps.version.outputs.new_version }}
          release_name: Release ${{ steps.version.outputs.new_version }}
          prerelease: true
```

## Cleanup

When a pull request is closed, this action will not cleanup the versions. For this, see the
[mitchellsimoens/gpr-pr-version-cleanup](https://github.com/mitchellsimoens/gpr-pr-version-cleanup) action.

## Inputs

The follow are the inputs this action accepts:

| Name           | Required | Description                                                    |
|----------------|----------|----------------------------------------------------------------|
| `cwd`          | No       | Set to the relative path where the package.json is located in. |
| `skip_git_tag` | No       | Set to skip creating git tags                                  |

### `cwd`

Defaults to `./`, if the `package.json` is in a nested directory, set this input to the relative path where it's
located in. This will `cd` into that directory so that the `package.json` is read from and where the `npm version`
command will be executed in.

```yaml
name: PR Version

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  test:
    name: Bump Version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - id: version
        name: Version Bump
        uses: mitchellsimoens/gpr-pr-version-bump@v1
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          cwd: ./nested/dir
      - name: Create Release
        id: create_release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ steps.version.outputs.new_version }}
          release_name: Release ${{ steps.version.outputs.new_version }}
          prerelease: true
```

### `skip_git_tag`

Set to `true` to not create a git tag when `npm version` command is executed. This action does not do any git pushing.

```yaml
name: PR Version

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  test:
    name: Bump Version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - id: version
        name: Version Bump
        uses: mitchellsimoens/gpr-pr-version-bump@v1
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          skip_git_tag: true
      - name: Create Release
        id: create_release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ steps.version.outputs.new_version }}
          release_name: Release ${{ steps.version.outputs.new_version }}
          prerelease: true
```
