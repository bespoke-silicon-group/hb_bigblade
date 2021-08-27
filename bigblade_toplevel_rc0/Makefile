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
# Commit from main on 7/16/2021
hb_bigblade_netlists_commit := 99a45ad

basejump_stl_dir     :=$(THIS_DIR)/basejump_stl
basejump_stl_url     :=$(GITHUB)bespoke-silicon-group/basejump_stl
# Commit from master on 7/16/2021
basejump_stl_commit  :=57553c5

bsg_manycore_dir     :=$(THIS_DIR)/bsg_manycore
bsg_manycore_url     :=$(GITHUB)bespoke-silicon-group/bsg_manycore
# Commit from master on 7/16/2021 post-merge of ci_bigblade -> master
bsg_manycore_commit  :=3a05e000

black-parrot_dir     :=$(THIS_DIR)/black-parrot
black-parrot_url     :=$(GITHUB)black-parrot/black-parrot
# Commit from HEAD of branch tapeout_bigblade_rc1 on 7/16/2021
black-parrot_commit  :=dc23cc70

cgra_dir             :=$(THIS_DIR)/cgra
cgra_url             :=$(GITHUB)cornell-brg/hb_bigblade_cgra
# Commit from HEAD of branch rc0 on 7/16/2021, post-merge of bigblade-tapeout -> bigblade -> main
cgra_commit          :=2d6b92b

bsg_replicant_dir    :=$(THIS_DIR)/bsg_replicant
bsg_replicant_url    :=$(GITHUB)bespoke-silicon-group/bsg_replicant
# Commit from HEAD of main 7/16/2021, post-merge of bigblade-tapeout -> bigblade -> main
bsg_replicant_commit :=f29dccb

bsg_14_dir           :=$(THIS_DIR)/bsg_14
bsg_14_url           :=$(GITHUB)bespoke-silicon-group/bsg_14
# Commit from HEAD of master 8/18/2021, post-merge of Paul & Scott's flow updates
bsg_14_commit        :=3a8afdc

bsg_cadenv_dir       :=$(THIS_DIR)/bsg_cadenv
bsg_cadenv_url       :=$(GITHUB)bespoke-silicon-group/bsg_cadenv
# Commit from HEAD of master 7/16/2021
bsg_cadenv_commit    :=7860120

board_dir            :=$(THIS_DIR)/board
board_url            :=$(BITBUCKET)taylor-bsg/board
board_commit         :=e2fec32

bsg_packaging_dir    :=$(THIS_DIR)/bsg_packaging
bsg_packaging_url    :=$(GITHUB)bespoke-silicon-group/bsg_packaging
# Commit from HEAD of branch basejump_fcbga_785 on 7/16/2021
bsg_packaging_commit :=d06b110

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

# The following rules help with tagging all repositories
# The typical (and rare) flow will be:
# 1. Update the tagfile message
# 2. make tags
# 3. Verify everything looks good
# 4. make push
# 
# This sequence will push a tag called TAG_STRING to all the sub-repositories
TAG_STRING=bigblade-rc1-tapeout-final-closeout-final
tagfile:
	echo "Bigblade RC 1 Tapeout-Final, Closeout Final, June 2021 Tapeout, August 2021 closeout" >> $@
	echo "Tapeout Final: Final RC1 tapeout RTL" >> $@
	echo "Closeout Final: Includes flow changes from Paul/Scott" >> $@
	echo "hb_bigblade_netlists_commit :=$(hb_bigblade_netlists_commit)" >> $@
	echo "basejump_stl_commit         :=$(basejump_stl_commit)" >> $@
	echo "bsg_manycore_commit         :=$(bsg_manycore_commit)" >> $@
	echo "black-parrot_commit         :=$(black-parrot_commit)" >> $@
	echo "cgra_commit                 :=$(cgra_commit)" >> $@
	echo "bsg_replicant_commit        :=$(bsg_replicant_commit)" >> $@
	echo "bsg_14_commit               :=$(bsg_14_commit)" >> $@
	echo "bsg_cadenv_commit           :=$(bsg_cadenv_commit)" >> $@
	echo "board_commit                :=$(board_commit)" >> $@
	echo "bsg_packaging_commit        :=$(bsg_packaging_commit)" >> $@
	echo "In addition, All repositories have been tagged with $(TAG_STRING)" >>$@

tags=$(subst .repo,.tag,$(all_repos))
black-parrot.tag: TAG_STRING := archive/$(TAG_STRING)
$(tags): %.tag: tagfile
	cd $*; git tag -a $(TAG_STRING) -F ../tagfile
tags: $(tags)

push=$(subst .repo,.push,$(all_repos))
black-parrot.push: TAG_STRING := archive/$(TAG_STRING)
$(push): %.push:
	cd $*; git push -n origin $(TAG_STRING)
push: $(push)

clean: are_you_sure
	rm -rf $(subst .repo,,$(all_repos))
	rm -rf .pdk_prep

DISABLE_SAFETY_PROMPT ?= false
are_you_sure:
	@$(DISABLE_SAFETY_PROMPT) || (echo -n "Are you sure [Y/n]? " && read ans && ([ "$$ans" == "Y" ] || [ "$$ans" == "y" ]))

include ../common/exporter/Makefile.include

