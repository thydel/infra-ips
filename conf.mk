root := $(or $(LOC_ROOT), $(loc_root), /usr/local)
set := $(or $(LOC_SET), $(loc_set), epi)

etc := $(root)/etc
bin := $(root)/bin
base := $(etc)/$(set)
src := $(base)/src
data := $(base)/data
doc := $(base)/doc

repo != git config remote.origin.url
branch != git branch --show-current
