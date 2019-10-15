# Use infra-data-ips as src

```
export GIT_SSH_COMMAND='ssh -i ~/.ssh/t.delamare@epiconcept.fr -F /dev/null';
git clone git@github.com:Epiconcept-Paris/infra-data-ips.git -b master;
make -C infra-data-ips install;
```

# Install generated data

```
export GIT_SSH_COMMAND='ssh -i ~/.ssh/t.delamare@epiconcept.fr -F /dev/null';
git clone git@github.com:thydel/infra-ips.git -b master;
make -C infra-ips install
```
