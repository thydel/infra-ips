# Use infra-data-ips

Install data src for others repos

```
export GIT_SSH_COMMAND='ssh -i ~/.ssh/t.delamare@epiconcept.fr -F /dev/null';
git clone git@github.com:Epiconcept-Paris/infra-data-ips.git -b master;
make -C infra-data-ips install;
```

# Use infra-ips

Generate and indexed data from `infra-data-ips`

```
export GIT_SSH_COMMAND='ssh -i ~/.ssh/t.delamare@laposte.net -F /dev/null';
git clone git@github.com:thydel/infra-ips.git -b master;
make -C infra-ips install
```
