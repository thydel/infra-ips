# Define private variables

The `paths.yml` file define relative paths for

- `private_repos_file` a `requirement.yml` like file for private data
  repos (See [private-repos.yml][] skeleton)
- `keys_file` to define `default_key`, the default ssh key for private repos
- `workdir` where to clone private data repos

[private-repos.yml]: https://github.com/thydel/ansible-get-priv-repos/blob/master/private-repos.skl.yml "github.com file"

# Get private repos

[ansible-get-priv-repos]: https://github.com/thydel/ansible-get-priv-repos "github.com repo"

## Install if needed

Use [ansible-get-priv-repos][]

```
git -C ext clone git@github.com:thydel/ansible-get-priv-repos.git
make -C ext/ansible-get-priv-repos install
```

## When installed

Get repos

```
get-priv-repos.yml -e dir=$(pwd)
```

`get-priv-repos.yml` use `paths.yml` to access `private_repos_file`,
`keys_file` and `workdir`.

# Use data-ips

```
ln -s ext/ips/oxa
```

# Or use setup.mk

```
setup.mk
```
