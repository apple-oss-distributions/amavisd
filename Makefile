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
PROJECT_VERS=2.5.1
PROJECT_PATH=amavisd-new-

ETC_DIR=/private/etc
AMAVIS_DIR=/private/var/amavis
AMAVIS_TMP_DIR=/private/var/amavis/tmp
AMAVIS_DB_DIR=/private/var/amavis/db
SETUP_EXTRAS_SRC_DIR=amavisd.SetupExtras
SETUP_EXTRAS_DST_DIR=/System/Library/ServerSetup/SetupExtras
UPGRADE_EXTRAS_DST_DIR=/System/Library/ServerSetup/MigrationExtras
VIRUS_MAILS_DIR=/private/var/virusmails
USR_BIN=/usr/bin
LAUNCHD_SRC_DIR=/amavisd.LaunchDaemons
LAUNCHD_DIR=/System/Library/LaunchDaemons
OS_SRC_DIR=amavisd.OpenSourceInfo
AMAVIS_CONF_DIR=/amavisd.Conf
USR_LOCAL=/usr/local
USR_OS_VERSION=$(USR_LOCAL)/OpenSourceVersions
USR_OS_LICENSE=$(USR_LOCAL)/OpenSourceLicenses
MAN8_SRC_DIR=/amavisd.Man
MAN8_DST_DIR=/usr/share/man/man8

STRIP=/usr/bin/strip
GNUTAR=/usr/bin/gnutar
CHOWN=/usr/sbin/chown

# These includes provide the proper paths to system utilities
#

include $(MAKEFILEPATH)/pb_makefiles/platform.make
include $(MAKEFILEPATH)/pb_makefiles/commands-$(OS).make

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
	install -m 0644 "$(SRCROOT)$(LAUNCHD_SRC_DIR)/org.amavis.amavisd_cleanup.plist" "$(DSTROOT)/$(LAUNCHD_DIR)/org.amavis.amavisd_cleanup.plist"

	# install amavis config and scripts
	install -m 0644 "$(SRCROOT)/$(AMAVIS_CONF_DIR)/amavisd.conf" "$(DSTROOT)/$(ETC_DIR)/amavisd.conf"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd" "$(DSTROOT)/$(USR_BIN)/amavisd"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd-agent" "$(DSTROOT)/$(USR_BIN)/amavisd-agent"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd-nanny" "$(DSTROOT)/$(USR_BIN)/amavisd-nanny"
	install -m 0755 "$(SRCROOT)/$(PROJECT_NAME)/$(PROJECT_PATH)$(PROJECT_VERS)/amavisd-release" "$(DSTROOT)/$(USR_BIN)/amavisd-release"

	# install amavis  directories
	install -d -m 0755 "$(DSTROOT)$(AMAVIS_DIR)"
	install -d -m 0755 "$(DSTROOT)$(AMAVIS_DB_DIR)"
	install -d -m 0755 "$(DSTROOT)$(AMAVIS_TMP_DIR)"
	$(SILENT) ($(CHOWN) -R _amavisd:_amavisd "$(DSTROOT)$(AMAVIS_DIR)")

	install -d -m 0755 "$(DSTROOT)$(VIRUS_MAILS_DIR)"
	$(SILENT) ($(CHOWN) -R _amavisd:_amavisd "$(DSTROOT)$(VIRUS_MAILS_DIR)")

	$(SILENT) (/bin/echo "\n" > "$(DSTROOT)$(AMAVIS_DIR)/whitelist_sender")
	$(SILENT) ($(CHOWN) -R _amavisd:_amavisd "$(DSTROOT)$(AMAVIS_DIR)/whitelist_sender")
	$(SILENT) (/bin/chmod 644 "$(DSTROOT)$(AMAVIS_DIR)/whitelist_sender")

	# Setup & migration extras
	install -d -m 0755 "$(DSTROOT)$(SETUP_EXTRAS_DST_DIR)"
	install -d -m 0755 "$(DSTROOT)$(UPGRADE_EXTRAS_DST_DIR)"
	install -m 0755 "$(SRCROOT)$)/$(SETUP_EXTRAS_SRC_DIR)/amavisd_new_setup" "$(DSTROOT)/$(SETUP_EXTRAS_DST_DIR)/amavisd_new_setup"
	install -m 0755 "$(SRCROOT)$)/$(SETUP_EXTRAS_SRC_DIR)/amavisd_new_upgrade" "$(DSTROOT)/$(UPGRADE_EXTRAS_DST_DIR)/amavisd_new_upgrade"
	install -o _amavisd -m 0755 "$(SRCROOT)$)/$(SETUP_EXTRAS_SRC_DIR)/amavisd_cleanup" "$(DSTROOT)/$(AMAVIS_DIR)/amavisd_cleanup"

	install -d -m 0755 "$(DSTROOT)$(USR_OS_VERSION)"
	install -d -m 0755 "$(DSTROOT)$(USR_OS_LICENSE)"
	install -m 0755 "$(SRCROOT)/$(OS_SRC_DIR)/amavisd-new.plist" "$(DSTROOT)/$(USR_OS_VERSION)/amavisd-new.plist"
	install -m 0755 "$(SRCROOT)/$(OS_SRC_DIR)/amavisd-new.txt" "$(DSTROOT)/$(USR_OS_LICENSE)/amavisd-new.txt"

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
