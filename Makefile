PROJECT := yasld

LINUX_DIR := linux
GOBOX_DIR := gobox
LIMINE_DIR := limine
CFG_DIR := cfg
FS_DIR := fs

BUILD_DIR := build
ISO_ROOT := $(BUILD_DIR)/iso_root
INITRAMFS_DIR := $(BUILD_DIR)/initramfs
INITRAMFS := $(BUILD_DIR)/initramfs.cpio
ISO := $(BUILD_DIR)/$(PROJECT).iso

KERNEL_CONFIG := .config
KERNEL_IMAGE := $(LINUX_DIR)/arch/x86/boot/bzImage

GO ?= go
CPIO ?= cpio
XORRISO ?= xorriso
QEMU ?= qemu-system-x86_64

JOBS ?= $(shell nproc)

QEMU_MEM ?= 2G
QEMU_VGA ?= std

LIMINE_BRANCH ?= v11.x-binary
GOBOX_BRANCH ?= main

GOBOX_BIN := $(GOBOX_DIR)/build/gobox

.PHONY: all \
	check-tools \
	fs-default \
	update-submodules update-limine update-gobox \
	limine limine-check \
	kernel kernel-config kernel-menuconfig kernel-clean \
	gobox gobox-check gobox-clean \
	initramfs iso \
	run run-serial run-kvm \
	print-tree inspect-iso \
	clean distclean

all: iso

check-tools:
	@command -v $(GO) >/dev/null || (echo "missing go"; exit 1)
	@command -v $(CPIO) >/dev/null || (echo "missing cpio"; exit 1)
	@command -v $(XORRISO) >/dev/null || (echo "missing xorriso"; exit 1)
	@command -v $(QEMU) >/dev/null || echo "warning: qemu-system-x86_64 not found"

fs-default:
	mkdir -p $(FS_DIR)/etc
	mkdir -p $(FS_DIR)/root
	printf '%s\n' \
		'NAME="yasld"' \
		'PRETTY_NAME="yasld Linux"' \
		'ID=yasld' \
		'VERSION_ID="0.1.0"' \
		'VERSION="0.1.0"' \
		'HOME_URL="https://vapma.wtf"' \
		> $(FS_DIR)/etc/os-release
	printf '%s\n' \
		'root:x:0:0:root:/root:/bin/sh' \
		> $(FS_DIR)/etc/passwd
	printf '%s\n' \
		'root:x:0:' \
		> $(FS_DIR)/etc/group
	printf '%s\n' \
		'PATH=/bin:/sbin:/usr/bin:/usr/sbin' \
		'HOME=/root' \
		'SHELL=/bin/sh' \
		'TERM=linux' \
		'USER=root' \
		'LOGNAME=root' \
		> $(FS_DIR)/etc/environment

update-submodules:
	git submodule update --init --recursive --remote

update-limine:
	@test -d "$(LIMINE_DIR)" || (echo "missing $(LIMINE_DIR)"; exit 1)
	cd $(LIMINE_DIR) && git fetch origin && git switch "$(LIMINE_BRANCH)" && git pull --ff-only

update-gobox:
	@test -d "$(GOBOX_DIR)" || (echo "missing $(GOBOX_DIR)"; exit 1)
	cd $(GOBOX_DIR) && git fetch origin && git switch "$(GOBOX_BRANCH)" && git pull --ff-only

limine:
	@test -d "$(LIMINE_DIR)" || (echo "missing $(LIMINE_DIR). clone limine first"; exit 1)
	$(MAKE) -C $(LIMINE_DIR)

limine-check:
	@test -d "$(LIMINE_DIR)" || (echo "missing $(LIMINE_DIR). clone limine first"; exit 1)
	@test -f "$(LIMINE_DIR)/limine-bios.sys" || $(MAKE) -C $(LIMINE_DIR)
	@test -f "$(LIMINE_DIR)/limine-bios-cd.bin" || $(MAKE) -C $(LIMINE_DIR)
	@test -f "$(LIMINE_DIR)/limine-uefi-cd.bin" || $(MAKE) -C $(LIMINE_DIR)
	@test -f "$(LIMINE_DIR)/BOOTX64.EFI" || (echo "missing $(LIMINE_DIR)/BOOTX64.EFI"; exit 1)
	@test -f "$(LIMINE_DIR)/BOOTIA32.EFI" || (echo "missing $(LIMINE_DIR)/BOOTIA32.EFI"; exit 1)
	@test -x "$(LIMINE_DIR)/limine" || (echo "missing executable $(LIMINE_DIR)/limine"; exit 1)

kernel-config:
	@test -d "$(LINUX_DIR)" || (echo "missing $(LINUX_DIR)"; exit 1)
	@if [ -f "$(KERNEL_CONFIG)" ]; then \
		cp "$(KERNEL_CONFIG)" "$(LINUX_DIR)/.config"; \
		$(MAKE) -C "$(LINUX_DIR)" olddefconfig; \
	else \
		echo "warning: missing $(KERNEL_CONFIG), using linux/.config or defconfig"; \
		if [ ! -f "$(LINUX_DIR)/.config" ]; then \
			$(MAKE) -C "$(LINUX_DIR)" defconfig; \
		fi; \
	fi

kernel: kernel-config
	$(MAKE) -C $(LINUX_DIR) -j$(JOBS)
	@test -f "$(KERNEL_IMAGE)" || (echo "missing $(KERNEL_IMAGE)"; exit 1)

kernel-menuconfig:
	@test -d "$(LINUX_DIR)" || (echo "missing $(LINUX_DIR)"; exit 1)
	$(MAKE) -C $(LINUX_DIR) menuconfig
	cp "$(LINUX_DIR)/.config" "$(KERNEL_CONFIG)"

kernel-clean:
	$(MAKE) -C $(LINUX_DIR) clean

gobox:
	@test -d "$(GOBOX_DIR)" || (echo "missing $(GOBOX_DIR)"; exit 1)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
		$(MAKE) -C $(GOBOX_DIR) release GO="$(GO)"
	@test -f "$(GOBOX_BIN)" || (echo "missing $(GOBOX_BIN)"; exit 1)
	@file $(GOBOX_BIN)
	@ldd $(GOBOX_BIN) 2>/dev/null || true

gobox-check:
	$(MAKE) -C $(GOBOX_DIR) check

gobox-clean:
	$(MAKE) -C $(GOBOX_DIR) clean

initramfs: gobox
	rm -rf $(INITRAMFS_DIR)
	mkdir -p $(INITRAMFS_DIR)
	mkdir -p $(INITRAMFS_DIR)/bin
	mkdir -p $(INITRAMFS_DIR)/sbin
	mkdir -p $(INITRAMFS_DIR)/proc
	mkdir -p $(INITRAMFS_DIR)/sys
	mkdir -p $(INITRAMFS_DIR)/dev
	mkdir -p $(INITRAMFS_DIR)/tmp
	mkdir -p $(INITRAMFS_DIR)/run
	mkdir -p $(INITRAMFS_DIR)/etc
	mkdir -p $(INITRAMFS_DIR)/root
	mkdir -p $(INITRAMFS_DIR)/usr/bin
	mkdir -p $(INITRAMFS_DIR)/usr/sbin

	@if [ -d "$(FS_DIR)" ]; then \
		cp -a $(FS_DIR)/. $(INITRAMFS_DIR)/; \
	else \
		echo "warning: missing $(FS_DIR), run: make fs-default"; \
	fi

	cp $(GOBOX_BIN) $(INITRAMFS_DIR)/bin/gobox
	chmod +x $(INITRAMFS_DIR)/bin/gobox

	ln -sfn bin/gobox $(INITRAMFS_DIR)/init

	@APPLETS="$$( $(MAKE) -s -C $(GOBOX_DIR) list-applets )"; \
	for applet in $$APPLETS; do \
		if [ "$$applet" != "init" ]; then \
			ln -sfn gobox "$(INITRAMFS_DIR)/bin/$$applet"; \
			echo "initramfs link: /bin/$$applet -> gobox"; \
		fi; \
	done

	rm -f $(INITRAMFS)
	cd $(INITRAMFS_DIR) && find . -print0 | $(CPIO) --null -ov --format=newc > ../initramfs.cpio

iso: check-tools limine-check kernel initramfs
	rm -rf $(ISO_ROOT)
	mkdir -p $(ISO_ROOT)/boot/limine
	mkdir -p $(ISO_ROOT)/EFI/BOOT

	cp $(KERNEL_IMAGE) $(ISO_ROOT)/boot/bzImage
	cp $(INITRAMFS) $(ISO_ROOT)/boot/initramfs.cpio
	cp $(CFG_DIR)/limine.conf $(ISO_ROOT)/boot/limine/limine.conf

	cp $(LIMINE_DIR)/limine-bios.sys $(ISO_ROOT)/boot/limine/
	cp $(LIMINE_DIR)/limine-bios-cd.bin $(ISO_ROOT)/boot/limine/
	cp $(LIMINE_DIR)/limine-uefi-cd.bin $(ISO_ROOT)/boot/limine/

	cp $(LIMINE_DIR)/BOOTX64.EFI $(ISO_ROOT)/EFI/BOOT/BOOTX64.EFI
	cp $(LIMINE_DIR)/BOOTIA32.EFI $(ISO_ROOT)/EFI/BOOT/BOOTIA32.EFI

	$(XORRISO) -as mkisofs \
		-b boot/limine/limine-bios-cd.bin \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part \
		--efi-boot-image \
		--protective-msdos-label \
		-o $(ISO) \
		$(ISO_ROOT)

	$(LIMINE_DIR)/limine bios-install $(ISO)

	@echo
	@echo "ISO ready: $(ISO)"
	@echo
	@$(MAKE) print-tree

run: iso
	$(QEMU) \
		-m $(QEMU_MEM) \
		-cdrom $(ISO) \
		-boot d \
		-vga $(QEMU_VGA)

run-serial: iso
	$(QEMU) \
		-m $(QEMU_MEM) \
		-cdrom $(ISO) \
		-boot d \
		-vga $(QEMU_VGA) \
		-serial stdio

run-kvm: iso
	$(QEMU) \
		-enable-kvm \
		-cpu host \
		-m $(QEMU_MEM) \
		-cdrom $(ISO) \
		-boot d \
		-vga $(QEMU_VGA)

inspect-iso:
	xorriso -indev $(ISO) -find / -type f

print-tree:
	@echo "ISO contents:"
	@xorriso -indev $(ISO) -find / -type f 2>/dev/null | grep -E 'bzImage|initramfs|limine|BOOT' || true
	@echo
	@echo "Initramfs important files:"
	@find $(INITRAMFS_DIR) -maxdepth 3 \( -type f -o -type l \) | sort | grep -E '/init|/bin/gobox|/bin/sh|/bin/fetch|/etc/' || true

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	$(MAKE) -C $(LINUX_DIR) clean
	$(MAKE) -C $(GOBOX_DIR) clean
