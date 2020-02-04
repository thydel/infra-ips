dir.root := $(abspath $(or $(LOC_ROOT), $(loc_root), /usr/local))
dir.set := $(or $(LOC_SET), $(loc_set), epi)

$(foreach _, etc bin lib, $(eval dir.$_ := $(dir.root)/$_))
dir.base := $(dir.etc)/$(dir.set)
$(foreach _, src data doc repo, $(eval dir.$_ := $(dir.base)/$_))

$(if $(filter $(dir.base), $(wildcard $(dir.base))),, $(error dubious basedir $(dir.base)))

repo.url != git config --get remote.origin.url
repo.branch != git branch --show-current
repo.name := $(basename $(notdir $(repo.url)))

define README
# Installed via

export GIT_SSH_COMMAND='$(shell git config core.sshCommand)';
git clone $(repo.name) -b $(repo.branch);
make -C $(repo.name) install;
endef
export README
