.PHONY: gobox gobox-check gobox-clean update-gobox

update-gobox:
	@test -d "$(GOBOX_DIR)" || (echo "missing $(GOBOX_DIR)"; exit 1)
	cd $(GOBOX_DIR) && git fetch origin && git switch "$(GOBOX_BRANCH)" && git pull --ff-only

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
