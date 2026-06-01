.PHONY: fs-default ssh-key

fs-default:
	mkdir -p $(FS_DIR)/etc
	mkdir -p $(FS_DIR)/root
	mkdir -p $(FS_DIR)/etc/ssl/certs

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

	printf '%s\n' \
		'nameserver 10.0.2.3' \
		'nameserver 1.1.1.1' \
		> $(FS_DIR)/etc/resolv.conf

	printf '%s\n' \
		'hosts: files dns' \
		'passwd: files' \
		'group: files' \
		> $(FS_DIR)/etc/nsswitch.conf

	printf '%s\n' \
		'127.0.0.1 localhost' \
		'::1 localhost' \
		> $(FS_DIR)/etc/hosts

	@if [ -f /etc/ssl/certs/ca-certificates.crt ]; then \
		cp /etc/ssl/certs/ca-certificates.crt $(FS_DIR)/etc/ssl/certs/ca-certificates.crt; \
	fi

ssh-key:
	@test -f "$(SSH_PUBKEY)" || (echo "missing SSH public key: $(SSH_PUBKEY)"; exit 1)
	mkdir -p $(FS_DIR)/root/.ssh
	cp "$(SSH_PUBKEY)" $(FS_DIR)/root/.ssh/authorized_keys
	chmod 700 $(FS_DIR)/root/.ssh
	chmod 600 $(FS_DIR)/root/.ssh/authorized_keys
	@echo "installed SSH key: $(SSH_PUBKEY) -> $(FS_DIR)/root/.ssh/authorized_keys"
