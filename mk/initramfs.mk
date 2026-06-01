.PHONY: initramfs

initramfs: gobox third-party
	chmod +x scripts/copy-deps.sh
	rm -rf $(INITRAMFS_DIR)

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
	mkdir -p $(INITRAMFS_DIR)/usr/lib
	mkdir -p $(INITRAMFS_DIR)/usr/libexec
	mkdir -p $(INITRAMFS_DIR)/lib
	mkdir -p $(INITRAMFS_DIR)/lib64

	@if [ -d "$(FS_DIR)" ]; then \
		cp -a $(FS_DIR)/. $(INITRAMFS_DIR)/; \
	else \
		echo "warning: missing $(FS_DIR), run: make fs-default"; \
	fi

	cp $(GOBOX_BIN) $(INITRAMFS_DIR)/bin/gobox
	chmod +x $(INITRAMFS_DIR)/bin/gobox

	ln -sfn gobox $(INITRAMFS_DIR)/bin/sh
	ln -sfn bin/gobox $(INITRAMFS_DIR)/init

	@APPLETS="$$( $(MAKE) -s -C $(GOBOX_DIR) list-applets )"; \
	for applet in $$APPLETS; do \
		if [ "$$applet" != "init" ]; then \
			ln -sfn gobox "$(INITRAMFS_DIR)/bin/$$applet"; \
			echo "initramfs link: /bin/$$applet -> gobox"; \
		fi; \
	done

	@if [ -d "$(THIRD_PARTY_ROOT)" ]; then \
		cp -a $(THIRD_PARTY_ROOT)/. $(INITRAMFS_DIR)/; \
	else \
		echo "warning: missing $(THIRD_PARTY_ROOT)"; \
	fi

	@if [ -f "$(INITRAMFS_DIR)/usr/bin/dbclient" ]; then \
		ln -sfn dbclient $(INITRAMFS_DIR)/usr/bin/ssh; \
	fi

	./scripts/copy-deps.sh $(INITRAMFS_DIR) $(THIRD_PARTY_ROOT)

	@if [ -f "$(THIRD_PARTY_ROOT)/usr/lib/libcurl.so" ]; then \
		rm -f $(INITRAMFS_DIR)/usr/lib/libcurl.so; \
		cp -L $(THIRD_PARTY_ROOT)/usr/lib/libcurl.so $(INITRAMFS_DIR)/usr/lib/libcurl.so; \
	fi

	@if [ -f "$(THIRD_PARTY_ROOT)/usr/lib/libcurl.so.4" ]; then \
		rm -f $(INITRAMFS_DIR)/usr/lib/libcurl.so.4; \
		cp -L $(THIRD_PARTY_ROOT)/usr/lib/libcurl.so.4 $(INITRAMFS_DIR)/usr/lib/libcurl.so.4; \
	fi

	@if [ "$(WITH_GCC)" = "1" ]; then \
		$(MAKE) gcc-bundle; \
	fi

	rm -f $(INITRAMFS)
	cd $(INITRAMFS_DIR) && find . -print0 | $(CPIO) --null -ov --format=newc --owner=0:0 > ../initramfs.cpio
