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

basejump_stl_dir     :=$(THIS_DIR)/basejump_stl
basejump_stl_url     :=$(GITHUB)bespoke-silicon-group/basejump_stl
basejump_stl_commit  :=e9a502b30da83457fcee0af7b2ce147b7899012f
#dev-bsg_link_sdr

bsg_14_dir           :=$(THIS_DIR)/bsg_14
bsg_14_url           :=$(GITHUB)bespoke-silicon-group/bsg_14
bsg_14_commit        :=dec9770529ca82e0e79857eb73201cd0bdcce161

bsg_cadenv_dir       :=$(THIS_DIR)/bsg_cadenv
bsg_cadenv_url       :=$(BITBUCKET)taylor-bsg/bsg_cadenv
bsg_cadenv_commit    :=8f87a0589fcde7390d8e701d36757d33dfeefb71

board_dir            :=$(THIS_DIR)/board
board_url            :=$(BITBUCKET)taylor-bsg/board
board_commit         :=b04897e98da3a993edb85d6f5b5c6fb8291ea8ab

bsg_packaging_dir    :=$(THIS_DIR)/bsg_packaging
bsg_packaging_url    :=$(BITBUCKET)taylor-bsg/bsg_packaging
bsg_packaging_commit :=e2128cf2b172d28cc27c7c7ca9a92b74fbbef480

blackparrot_dir      :=$(THIS_DIR)/black-parrot
blackparrot_url      :=$(GITHUB)black-parrot/black-parrot
blackparrot_commit   :=tapeout_bigblade_rc1

bsg_manycore_dir     :=$(THIS_DIR)/bsg_manycore
bsg_manycore_url     :=$(GITHUB)bespoke-silicon-group/bsg_manycore
bsg_manycore_commit  :=9c38e87d01eee8af23a997bd06475e61bc3b07e6
#CI bigblade

prep_dir := .pdk_prep

all_repos = $(subst _url,.repo,$(filter %_url,$(.VARIABLES)))

$(prep_dir): $(bsg_14.repo)
	ln -nsf $(bsg_14_dir)/.pdk_prep $@

all: $(all_repos) $(prep_dir)

%.repo:
	-git clone $($*_url) $($*_dir)
	-cd $($*_dir) ; git checkout $($*_commit)

clean: are_you_sure
	rm -rf $(subst .repo,,$(all_repos))

DISABLE_SAFETY_PROMPT ?= false
are_you_sure:
	@$(DISABLE_SAFETY_PROMPT) || (echo -n "Are you sure [Y/n]? " && read ans && ([ "$$ans" == "Y" ] || [ "$$ans" == "y" ]))

