default: all

THIS_DIR              ?= invalid
COMMON_SDR_DIR        ?= invalid
COMMON_SDR_DESIGN_DIR ?= invalid

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
basejump_stl_commit  :=dev-bsg_link_sdr

bsg_manycore_dir     :=$(THIS_DIR)/bsg_manycore
bsg_manycore_url     :=$(GITHUB)bespoke-silicon-group/bsg_manycore
bsg_manycore_commit  :=ci_bigblade

bsg_14_dir           :=$(THIS_DIR)/bsg_14
bsg_14_url           :=$(GITHUB)bespoke-silicon-group/bsg_14
bsg_14_commit        :=master

bsg_cadenv_dir       :=$(THIS_DIR)/bsg_cadenv
bsg_cadenv_url       :=$(GITHUB)bespoke-silicon-group/bsg_cadenv
bsg_cadenv_commit    :=master

board_dir            :=$(THIS_DIR)/board
board_url            :=$(BITBUCKET)taylor-bsg/board
board_commit         :=master

bsg_packaging_dir    :=$(THIS_DIR)/bsg_packaging
bsg_packaging_url    :=$(GITHUB)bespoke-silicon-group/bsg_packaging
bsg_packaging_commit :=master

prep_dir := .pdk_prep

all_repos = $(subst _url,.repo,$(filter %_url,$(.VARIABLES)))

$(prep_dir): $(bsg_14.repo)
	ln -nsf $(bsg_14_dir)/.pdk_prep $@

all: prep $(all_repos) $(prep_dir)

%.repo:
	-git clone $($*_url) $($*_dir)
	-cd $($*_dir) ; git checkout $($*_commit)

clean: are_you_sure
	make clean.prep
	rm -rf $(subst .repo,,$(all_repos))
	rm -f .pdk_prep

DISABLE_SAFETY_PROMPT ?= false
are_you_sure:
	@$(DISABLE_SAFETY_PROMPT) || (echo -n "Are you sure [Y/n]? " && read ans && ([ "$$ans" == "Y" ] || [ "$$ans" == "y" ]))

prep:
	ln -s $(COMMON_SDR_DIR)/json/               $(THIS_DIR)
	ln -s $(COMMON_SDR_DESIGN_DIR)/tcl/         $(THIS_DIR)
	ln -s $(COMMON_SDR_DESIGN_DIR)/v/           $(THIS_DIR)
	ln -s $(COMMON_SDR_DESIGN_DIR)/testing/     $(THIS_DIR)
	ln -s $(COMMON_SDR_DIR)/mk/bsg_14.config.mk $(THIS_DIR)/mk/

clean.prep:
	rm -f json tcl v testing mk/bsg_14.config.mk
