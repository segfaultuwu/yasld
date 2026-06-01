PROJECT := yasld

LINUX_DIR := linux
GOBOX_DIR := gobox
LIMINE_DIR := limine
CFG_DIR := cfg
FS_DIR := fs
THIRD_PARTY_DIR := third_party

BUILD_DIR := build
ISO_ROOT := $(BUILD_DIR)/iso_root
INITRAMFS_DIR := $(BUILD_DIR)/initramfs
INITRAMFS := $(BUILD_DIR)/initramfs.cpio
ISO := $(BUILD_DIR)/$(PROJECT).iso

KERNEL_CONFIG := .config
KERNEL_IMAGE := $(LINUX_DIR)/arch/x86/boot/bzImage

GOBOX_BIN := $(GOBOX_DIR)/build/gobox

THIRD_PARTY_ROOT := $(BUILD_DIR)/third_party/root

CURL_BIN := $(THIRD_PARTY_ROOT)/usr/bin/curl
DROPBEAR_BIN := $(THIRD_PARTY_ROOT)/usr/sbin/dropbear
DROPBEARKEY_BIN := $(THIRD_PARTY_ROOT)/usr/bin/dropbearkey
DBCLIENT_BIN := $(THIRD_PARTY_ROOT)/usr/bin/dbclient
SCP_BIN := $(THIRD_PARTY_ROOT)/usr/bin/scp
BASH_BIN := $(THIRD_PARTY_ROOT)/usr/bin/bash
GIT_BIN := $(THIRD_PARTY_ROOT)/usr/bin/git

GIT_CORE_DIR := $(THIRD_PARTY_ROOT)/usr/libexec/git-core
GIT_REMOTE_HTTP := $(GIT_CORE_DIR)/git-remote-http
GIT_REMOTE_HTTPS := $(GIT_CORE_DIR)/git-remote-https

GO ?= go
CPIO ?= cpio
XORRISO ?= xorriso
QEMU ?= qemu-system-x86_64

JOBS ?= $(shell nproc)

QEMU_MEM ?= 2G
QEMU_VGA ?= std

LIMINE_BRANCH ?= v11.x-binary
GOBOX_BRANCH ?= main

SSH_PUBKEY ?= $(HOME)/.ssh/id_ed25519.pub
