HOST_GCC ?= $(shell command -v gcc)
HOST_CC ?= $(shell command -v cc)
HOST_AS ?= $(shell command -v as)
HOST_LD ?= $(shell command -v ld)
HOST_AR ?= $(shell command -v ar)
HOST_RANLIB ?= $(shell command -v ranlib)
HOST_STRIP ?= $(shell command -v strip)
HOST_GCC_MACHINE ?= $(shell gcc -dumpmachine)
HOST_GCC_VERSION ?= $(shell gcc -dumpversion)

GCC_LIBDIR := /usr/lib/gcc/$(HOST_GCC_MACHINE)/$(HOST_GCC_VERSION)

GCC_INCLUDE_DIRS := \
	/usr/include/bits \
	/usr/include/gnu \
	/usr/include/sys \
	/usr/include/linux \
	/usr/include/asm \
	/usr/include/asm-generic \
	/usr/include/x86_64-linux-gnu \
	/usr/include/x86_64-pc-linux-gnu

GCC_INCLUDE_FILES := \
	/usr/include/assert.h \
	/usr/include/ctype.h \
	/usr/include/errno.h \
	/usr/include/features.h \
	/usr/include/float.h \
	/usr/include/inttypes.h \
	/usr/include/iso646.h \
	/usr/include/limits.h \
	/usr/include/locale.h \
	/usr/include/math.h \
	/usr/include/setjmp.h \
	/usr/include/signal.h \
	/usr/include/stdarg.h \
	/usr/include/stdbool.h \
	/usr/include/stddef.h \
	/usr/include/stdint.h \
	/usr/include/stdio.h \
	/usr/include/stdlib.h \
	/usr/include/string.h \
	/usr/include/strings.h \
	/usr/include/time.h \
	/usr/include/unistd.h \
	/usr/include/wchar.h \
	/usr/include/wctype.h

.PHONY: gcc-bundle gcc-copy-headers

gcc-bundle:
	@test -x "$(HOST_GCC)" || (echo "missing gcc"; exit 1)
	@test -x "$(HOST_AS)" || (echo "missing as from binutils"; exit 1)
	@test -x "$(HOST_LD)" || (echo "missing ld from binutils"; exit 1)
	@test -d "$(GCC_LIBDIR)" || (echo "missing GCC libdir: $(GCC_LIBDIR)"; exit 1)

	mkdir -p $(INITRAMFS_DIR)/usr/bin
	mkdir -p $(INITRAMFS_DIR)/usr/lib
	mkdir -p $(INITRAMFS_DIR)/usr/include
	mkdir -p $(INITRAMFS_DIR)/usr/lib/gcc/$(HOST_GCC_MACHINE)

	cp -L "$(HOST_GCC)" $(INITRAMFS_DIR)/usr/bin/gcc
	cp -L "$(HOST_CC)" $(INITRAMFS_DIR)/usr/bin/cc
	cp -L "$(HOST_AS)" $(INITRAMFS_DIR)/usr/bin/as
	cp -L "$(HOST_LD)" $(INITRAMFS_DIR)/usr/bin/ld
	cp -L "$(HOST_AR)" $(INITRAMFS_DIR)/usr/bin/ar
	cp -L "$(HOST_RANLIB)" $(INITRAMFS_DIR)/usr/bin/ranlib
	cp -L "$(HOST_STRIP)" $(INITRAMFS_DIR)/usr/bin/strip

	cp -a "$(GCC_LIBDIR)" $(INITRAMFS_DIR)/usr/lib/gcc/$(HOST_GCC_MACHINE)/

	$(MAKE) gcc-copy-headers

	@if [ -d /usr/lib/bfd-plugins ]; then \
		mkdir -p $(INITRAMFS_DIR)/usr/lib/bfd-plugins; \
		cp -a /usr/lib/bfd-plugins/. $(INITRAMFS_DIR)/usr/lib/bfd-plugins/; \
	fi

	@for f in \
		/usr/lib/crt1.o \
		/usr/lib/crti.o \
		/usr/lib/crtn.o \
		/usr/lib/Scrt1.o \
		/usr/lib/rcrt1.o \
		/usr/lib/libc.so \
		/usr/lib/libc_nonshared.a \
		/usr/lib/libm.so \
		/usr/lib/libpthread.so \
		/usr/lib/libdl.so \
		/usr/lib/librt.so; do \
		if [ -e "$$f" ]; then \
			mkdir -p "$(INITRAMFS_DIR)$$(dirname $$f)"; \
			cp -L "$$f" "$(INITRAMFS_DIR)$$f"; \
			echo "copied $$f"; \
		fi; \
	done

	./scripts/copy-deps.sh $(INITRAMFS_DIR) \
		$(INITRAMFS_DIR)/usr/bin/gcc \
		$(INITRAMFS_DIR)/usr/bin/cc \
		$(INITRAMFS_DIR)/usr/bin/as \
		$(INITRAMFS_DIR)/usr/bin/ld \
		$(INITRAMFS_DIR)/usr/bin/ar \
		$(INITRAMFS_DIR)/usr/bin/ranlib \
		$(INITRAMFS_DIR)/usr/bin/strip \
		$(GCC_LIBDIR)

	@echo "bundled gcc:"
	@echo "  machine: $(HOST_GCC_MACHINE)"
	@echo "  version: $(HOST_GCC_VERSION)"
	@echo "  libdir:  $(GCC_LIBDIR)"

gcc-copy-headers:
	mkdir -p $(INITRAMFS_DIR)/usr/include

	@for dir in $(GCC_INCLUDE_DIRS); do \
		if [ -d "$$dir" ]; then \
			mkdir -p "$(INITRAMFS_DIR)$$dir"; \
			cp -a "$$dir"/. "$(INITRAMFS_DIR)$$dir"/; \
			echo "copied include dir $$dir"; \
		fi; \
	done

	@for file in $(GCC_INCLUDE_FILES); do \
		if [ -f "$$file" ]; then \
			mkdir -p "$(INITRAMFS_DIR)$$(dirname $$file)"; \
			cp -L "$$file" "$(INITRAMFS_DIR)$$file"; \
			echo "copied include file $$file"; \
		fi; \
	done
