.PHONY: third-party third-party-clean \
	curl curl-clean update-curl \
	dropbear dropbear-clean \
	bash bash-clean \
	git git-clean

third-party: curl dropbear bash git

third-party-clean: curl-clean dropbear-clean bash-clean git-clean

update-curl:
	@test -d "$(THIRD_PARTY_DIR)/curl" || (echo "missing $(THIRD_PARTY_DIR)/curl"; exit 1)
	cd $(THIRD_PARTY_DIR)/curl && git fetch origin && git pull --ff-only

curl:
	@test -d "$(THIRD_PARTY_DIR)" || (echo "missing $(THIRD_PARTY_DIR)"; exit 1)
	$(MAKE) -C $(THIRD_PARTY_DIR) curl JOBS="$(JOBS)"
	@test -f "$(CURL_BIN)" || (echo "missing $(CURL_BIN)"; exit 1)

curl-clean:
	@if [ -d "$(THIRD_PARTY_DIR)" ]; then \
		$(MAKE) -C $(THIRD_PARTY_DIR) curl-clean; \
	fi

dropbear:
	@test -d "$(THIRD_PARTY_DIR)" || (echo "missing $(THIRD_PARTY_DIR)"; exit 1)
	$(MAKE) -C $(THIRD_PARTY_DIR) dropbear JOBS="$(JOBS)"
	@test -f "$(DROPBEAR_BIN)" || (echo "missing $(DROPBEAR_BIN)"; exit 1)

dropbear-clean:
	@if [ -d "$(THIRD_PARTY_DIR)" ]; then \
		$(MAKE) -C $(THIRD_PARTY_DIR) dropbear-clean; \
	fi

bash:
	@test -d "$(THIRD_PARTY_DIR)" || (echo "missing $(THIRD_PARTY_DIR)"; exit 1)
	$(MAKE) -C $(THIRD_PARTY_DIR) bash JOBS="$(JOBS)"
	@test -f "$(BASH_BIN)" || (echo "missing $(BASH_BIN)"; exit 1)

bash-clean:
	@if [ -d "$(THIRD_PARTY_DIR)" ]; then \
		$(MAKE) -C $(THIRD_PARTY_DIR) bash-clean; \
	fi

git:
	@test -d "$(THIRD_PARTY_DIR)" || (echo "missing $(THIRD_PARTY_DIR)"; exit 1)
	$(MAKE) -C $(THIRD_PARTY_DIR) git JOBS="$(JOBS)"
	@test -f "$(GIT_BIN)" || (echo "missing $(GIT_BIN)"; exit 1)

git-clean:
	@if [ -d "$(THIRD_PARTY_DIR)" ]; then \
		$(MAKE) -C $(THIRD_PARTY_DIR) git-clean; \
	fi
