#
# xbs-compatible wrapper Makefile for SpamAssassin
#

PROJECT=amavisd

SHELL := /bin/sh

# Sane defaults, which are typically overridden on the command line.
SRCROOT=
OBJROOT=$(SRCROOT)
SYMROOT=$(OBJROOT)
DSTROOT=/usr/local
RC_ARCHS=
CFLAGS=-Os $(RC_CFLAGS)

# Configuration values we customize
#

PROJECT_NAME=amavisd
PROJECT_VERS=2.8.0
PROJECT_PATH=amavisd-new-

ETC_DIR=$(SERVER_INSTALL_PATH_PREFIX)/private/etc
LANGUAGES_DIR=$(ETC_DIR)/mail/amavisd/languages/en.lproj
AMAVIS_DIR=$(SERVER_INSTALL_PATH_PREFIX)/usr/libexec/amavisd
SETUP_EXTRAS_SRC_DIR=amavisd.SetupExtras
COMMON_EXTRAS_DST_DIR=$(SERVER_INSTALL_PATH_PREFIX)/System/Library/ServerSetup/CommonExtras
PROMO_EXTRAS_DST_DIR=$(SERVER_INSTALL_PATH_PREFIX)/System/Library/ServerSetup/PromotionExtras
PATCH_DIR=amavisd.Patches
USR_BIN=$(SERVER_INSTALL_PATH_PREFIX)/usr/bin
BIN_DIR=/amavisd.Bin
LAUNCHD_SRC_DIR=/amavisd.LaunchDaemons
LAUNCHD_DIR=$(SERVER_INSTALL_PATH_PREFIX)/System/Library/LaunchDaemons
OS_SRC_DIR=amavisd.OpenSourceInfo
AMAVIS_CONF_DIR=/amavisd.Conf
INSTALL_EXTRAS_DIR=/amavisd.InstallExtras
USR_LOCAL=/usr/local
USR_OS_VERSION=$(USR_LOCAL)/OpenSourceVersions
USR_OS_LICENSE=$(USR_LOCAL)/OpenSourceLicenses
MAN8_SRC_DIR=/amavisd.Man
MAN8_DST_DIR=$(SERVER_INSTALL_PATH_PREFIX)/usr/share/man/man8

SETUP_AMAVISD=$(COMMON_EXTRAS_DST_DIR)/61-setup_amavisd.sh
PROMO_AMAVISD=$(PROMO_EXTRAS_DST_DIR)/61-setup_amavisd.sh

STRIP=/usr/bin/strip
GNUTAR=/usr/bin/gnutar
CHOWN=/usr/sbin/chown

# These includes provide the proper paths to system utilities
#

include $(MAKEFILEPATH)/pb_makefiles/platform.make
include $(MAKEFILEPATH)/pb_makefiles/commands-$(OS).make
-include /AppleInternal/ServerTools/ServerBuildVariables.xcconfig

default:: make_amavisd

install :: make_amavisd_install

installhdrs :
	$(SILENT) $(ECHO) "No headers to install"

installsrc :
	[ ! -d $(SRCROOT)/$(PROJECT) ] && mkdir -p $(SRCROOT)/$(PROJECT)
	tar cf - . | (cd $(SRCROOT) ; tar xfp -)
	find $(SRCROOT) -type d -name CVS -print0 | xargs -0 rm -rf

make_amavisd_install : $(DSTROOT)$(ETC_DIR) $(DSTROOT)$(USR_BIN)
	$(SILENT) $(ECHO) "-------------- Amavisd-new --------------"

	# install launchd plist
	install -d -m 0755 "$(DSTROOT)$(LAUNCHD_DIR)"
	install -m 0644 "$(SRCROOT)$(LAUNCHD_SRC_DIR)/org.amavis.amavisd.plist" "$(DSTROOT)/$(LAUNCHD_DIR)/org.amavis.amavisd.plist"
	/usr/libexec/PlistBuddy -c 'Set :Program $(SERVER_INSTALL_PATH_PREFIX)/usr/bin/amavisd' "$(DSTROOT)/$(LAUNCHD_DIR)/org.amavis.amavisd.plist"
	/usr/libexec/PlistBuddy -c 'Set :ProgramArguments:0 $(SERVER_INSTALL_PATH_PREFIX)/usr/bin/amavisd' "$(DSTROOT)/$(LAUNCHD_DIR)/org.amavis.amavisd.plist"
	install -m 0644 "$(SRCROOT)$(LAUNCHD_SRC_DIR)/org.amavis.amavisd_cleanup.plist" "$(DSTROOT)/$(LAUNCHD_DIR)/org.amavis.amavisd_cleanup.plist"
	/usr/libexec/PlistBuddy -c 'Set :Program $(SERVER_INSTALL_PATH_PREFIX)/usr/libexec/amavisd/amavisd_cleanup' "$(DSTROOT)/$(LAUNCHD_DIR)/org.amavis.amavisd_cleanup.plist"
	/usr/libexec/PlistBuddy -c 'Set :ProgramArguments:0 $(SERVER_INSTALL_PATH_PREFIX)/usr/libexec/amavisd/amavisd_cleanup' "$(DSTROOT)/$(LAUNCHD_DIR)/org.amavis.amavisd_cleanup.plist"

	# apply patch
	$(SILENT) ($(CD) "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)" && /usr/bin/patch -p1 < "$(SRCROOT)/$(PATCH_DIR)/apple-mods.diff")

	# install amavis config and scripts
	install -m 0644 "$(SRCROOT)/$(AMAVIS_CONF_DIR)/amavisd.conf" "$(DSTROOT)/$(ETC_DIR)/amavisd.conf.default"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd" "$(DSTROOT)/$(USR_BIN)/amavisd"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd-agent" "$(DSTROOT)/$(USR_BIN)/amavisd-agent"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd-nanny" "$(DSTROOT)/$(USR_BIN)/amavisd-nanny"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd-release" "$(DSTROOT)/$(USR_BIN)/amavisd-release"

	# install amavis  directories
	install -d -m 0750 "$(DSTROOT)$(AMAVIS_DIR)"
	install -d -m 0755 "$(DSTROOT)$(LANGUAGES_DIR)"

	# install default language files
	install -m 0644 "$(SRCROOT)/$(INSTALL_EXTRAS_DIR)/languages/en.lproj/"* "$(DSTROOT)/$(LANGUAGES_DIR)/"

	# Setup & migration extras
	install -d -m 0755 "$(DSTROOT)$(COMMON_EXTRAS_DST_DIR)"
	install -d -m 0755 "$(DSTROOT)$(PROMO_EXTRAS_DST_DIR)"
	$(SILENT) (/bin/echo "#!/bin/sh" > "$(DSTROOT)/$(SETUP_AMAVISD)") 
	$(SILENT) (/bin/echo "#" >> "$(DSTROOT)/$(SETUP_AMAVISD)")
	$(SILENT) (/bin/echo "" >> "$(DSTROOT)/$(SETUP_AMAVISD)")
	$(SILENT) (/bin/echo "_server_root=$(SERVER_INSTALL_PATH_PREFIX)" >> "$(DSTROOT)/$(SETUP_AMAVISD)")
	$(SILENT) (/bin/cat "$(SRCROOT)/$(SETUP_EXTRAS_SRC_DIR)/amavisd_common" >> "$(DSTROOT)/$(SETUP_AMAVISD)")
	$(SILENT) (/bin/chmod 755 "$(DSTROOT)/$(SETUP_AMAVISD)")
	install -m 0755	"$(DSTROOT)/$(SETUP_AMAVISD)"  "$(DSTROOT)/$(PROMO_AMAVISD)"
	install -o _amavisd -m 0755 "$(SRCROOT)$)/$(SETUP_EXTRAS_SRC_DIR)/amavisd_cleanup" "$(DSTROOT)/$(AMAVIS_DIR)/amavisd_cleanup"
	$(SILENT) ($(CHOWN) -R root:wheel "$(DSTROOT)$(AMAVIS_DIR)")

	install -d -m 0755 "$(DSTROOT)$(USR_OS_VERSION)"
	install -d -m 0755 "$(DSTROOT)$(USR_OS_LICENSE)"
	install -m 0755 "$(SRCROOT)/$(OS_SRC_DIR)/amavisd.plist" "$(DSTROOT)/$(USR_OS_VERSION)/amavisd.plist"
	install -m 0755 "$(SRCROOT)/$(OS_SRC_DIR)/amavisd.txt" "$(DSTROOT)/$(USR_OS_LICENSE)/amavisd.txt"

	install -d -m 0755 "$(DSTROOT)$(MAN8_DST_DIR)"
	install -m 0444 "$(SRCROOT)/$(MAN8_SRC_DIR)/amavisd.8" "$(DSTROOT)$(MAN8_DST_DIR)/amavisd.8"
	install -m 0444 "$(SRCROOT)/$(MAN8_SRC_DIR)/amavisd-agent.8" "$(DSTROOT)$(MAN8_DST_DIR)/amavisd-agent.8"
	install -m 0444 "$(SRCROOT)/$(MAN8_SRC_DIR)/amavisd-nanny.8" "$(DSTROOT)$(MAN8_DST_DIR)/amavisd-nanny.8"
	install -m 0444 "$(SRCROOT)/$(MAN8_SRC_DIR)/amavisd-release.8" "$(DSTROOT)$(MAN8_DST_DIR)/amavisd-release.8"

	$(SILENT) $(ECHO) "---- Building Amavisd-new complete."

.PHONY: clean installhdrs installsrc build install 


$(DSTROOT) :
	$(SILENT) $(MKDIRS) $@

$(DSTROOT)$(ETC_DIR) :
	$(SILENT) $(MKDIRS) $@

$(DSTROOT)$(USR_BIN) :
	$(SILENT) $(MKDIRS) $@
