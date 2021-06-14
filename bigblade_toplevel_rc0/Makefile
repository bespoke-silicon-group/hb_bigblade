THIS_DIR :=$(realpath $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

GIT_CLONE_STYLE :=ssh
#GIT_CLONE_STYLE :=https

ifeq ($(GIT_CLONE_STYLE),ssh)
  GITHUB    :=git@github.com:
  BITBUCKET :=git@bitbucket.com:

else ifeq ($(GIT_CLONE_STYLE),https)
  GITHUB    :=https://github.com/
  BITBUCKET :=https://bitbucket.com/

endif

hb_bigblade_netlists_dir    := $(THIS_DIR)/hb_bigblade_netlists
hb_bigblade_netlists_url    := $(GITHUB)bespoke-silicon-group/hb_bigblade_netlists
hb_bigblade_netlists_commit := refactor

basejump_stl_dir     :=$(THIS_DIR)/basejump_stl
basejump_stl_url     :=$(GITHUB)bespoke-silicon-group/basejump_stl
basejump_stl_commit  :=master

bsg_manycore_dir     :=$(THIS_DIR)/bsg_manycore
bsg_manycore_url     :=$(GITHUB)bespoke-silicon-group/bsg_manycore
bsg_manycore_commit  :=ci_bigblade

black-parrot_dir     :=$(THIS_DIR)/black-parrot
black-parrot_url     :=$(GITHUB)black-parrot/black-parrot
black-parrot_commit  :=tapeout_bigblade_rc1

cgra_dir             :=$(THIS_DIR)/cgra
cgra_url             :=$(GITHUB)cornell-brg/hb_bigblade_cgra
cgra_commit          :=rc0

bsg_replicant_dir    :=$(THIS_DIR)/bsg_replicant
bsg_replicant_url    :=$(GITHUB)bespoke-silicon-group/bsg_replicant
bsg_replicant_commit :=bigblade-tapeout

bsg_14_dir           :=$(THIS_DIR)/bsg_14
bsg_14_url           :=$(GITHUB)bespoke-silicon-group/bsg_14
bsg_14_commit        :=master

bsg_cadenv_dir       :=$(THIS_DIR)/bsg_cadenv
bsg_cadenv_url       :=$(GITHUB)bespoke-silicon-group/bsg_cadenv
bsg_cadenv_commit    :=master

board_dir            :=$(THIS_DIR)/board
board_url            :=$(BITBUCKET)taylor-bsg/board
board_commit         :=e2fec32

bsg_packaging_dir    :=$(THIS_DIR)/bsg_packaging
bsg_packaging_url    :=$(GITHUB)bespoke-silicon-group/bsg_packaging
bsg_packaging_commit :=basejump_fcbga_785

prep_dir := .pdk_prep

all_repos = $(subst _url,.repo,$(filter %_url,$(.VARIABLES)))

init_repos  = bsg_manycore.init
init_repos += basejump_stl.init
init_repos += hb_bigblade_netlists.init

$(prep_dir): $(bsg_14.repo)
	ln -nsf $(bsg_14_dir)/.pdk_prep $@

all: $(all_repos) $(prep_dir) $(init_repos)

%.repo:
	-git clone $($*_url) $($*_dir)
	-cd $($*_dir) ; git checkout $($*_commit)


bsg_manycore.init: bsg_manycore.repo
	$(MAKE) -C $(bsg_manycore_dir) checkout_submodules

black-parrot.init: black-parrot.repo
	$(MAKE) -C $(black-parrot_dir) libs


basejump_stl.init: basejump_stl.init
	cd $(basejump_stl_dir) && git submodule update --init --recursive

hb_bigblade_netlists.init: hb_bigblade_netlists.repo
	$(MAKE) -C $(hb_bigblade_netlists_dir)

summaries=$(subst .repo,.summary,$(all_repos))
.PHONY: $(summaries)

$(summaries): .SHELLFLAGS = -o pipefail -c
$(summaries): %.summary: 
	@./summarize.sh $* $($*_commit) $($*_url) | tee $@

summaries: $(summaries)

clean: are_you_sure
	rm -rf $(subst .repo,,$(all_repos))
	rm -rf .pdk_prep

DISABLE_SAFETY_PROMPT ?= false
are_you_sure:
	@$(DISABLE_SAFETY_PROMPT) || (echo -n "Are you sure [Y/n]? " && read ans && ([ "$$ans" == "Y" ] || [ "$$ans" == "y" ]))

include ../common/exporter/Makefile.include

