#!/bin/sh
set -eu

if [ "$#" -lt 2 ]; then
	echo "usage: $0 <rootfs-dir> <file-or-dir> [file-or-dir...]" >&2
	exit 1
fi

ROOT="$1"
shift

copy_one() {
	src="$1"

	[ -e "$src" ] || return 0

	dst="$ROOT$src"
	mkdir -p "$ROOT$(dirname "$src")"

	# Always remove old destination.
	# This prevents broken symlinks from surviving between builds.
	rm -f "$dst"

	# If src is a symlink, copy the real target contents into dst.
	# Example:
	#   /usr/lib/libldap.so.2 -> libldap.so.2.0.200
	# becomes:
	#   $ROOT/usr/lib/libldap.so.2 as a real ELF file
	real="$(readlink -f "$src" 2>/dev/null || true)"

	if [ -n "$real" ] && [ -e "$real" ]; then
		cp -L "$real" "$dst"
	else
		cp -L "$src" "$dst"
	fi

	echo "  $src"
}

is_elf() {
	file "$1" 2>/dev/null | grep -q 'ELF'
}

copy_interp() {
	bin="$1"

	interp="$(file "$bin" 2>/dev/null | sed -n 's/.*interpreter \([^,]*\).*/\1/p')"

	if [ -n "$interp" ] && [ -e "$interp" ]; then
		copy_one "$interp"
	fi
}

copy_ldd() {
	bin="$1"

	ldd "$bin" 2>/dev/null | while read -r line; do
		case "$line" in
			*" => /"*)
				lib="$(printf '%s\n' "$line" | awk '{print $3}')"
				copy_one "$lib"
				;;
			/*)
				lib="$(printf '%s\n' "$line" | awk '{print $1}')"
				copy_one "$lib"
				;;
		esac
	done
}

copy_elf_deps() {
	bin="$1"

	[ -f "$bin" ] || return 0
	is_elf "$bin" || return 0

	echo "copy deps: $bin"

	copy_interp "$bin"
	copy_ldd "$bin"
}

scan_path() {
	path="$1"

	if [ -d "$path" ]; then
		find "$path" -type f | while read -r file; do
			copy_elf_deps "$file"
		done
	else
		copy_elf_deps "$path"
	fi
}

for path in "$@"; do
	scan_path "$path"
done

# Runtime libs loaded by glibc/dlopen or needed by git/curl/dropbear/bash.
for lib in \
	/usr/lib/libnss_files.so.2 \
	/usr/lib/libnss_dns.so.2 \
	/usr/lib/libresolv.so.2 \
	/usr/lib/libcrypt.so.2 \
	/usr/lib/libldap.so.2 \
	/usr/lib/liblber.so.2 \
	/usr/lib/libsasl2.so.3 \
	/usr/lib/libkrb5.so.3 \
	/usr/lib/libgssapi_krb5.so.2 \
	/usr/lib/libk5crypto.so.3 \
	/usr/lib/libkrb5support.so.0 \
	/usr/lib/libcom_err.so.2 \
	/usr/lib/libkeyutils.so.1
do
	if [ -e "$lib" ]; then
		copy_one "$lib"
	fi
done

# Extra dependency passes.
# Some copied shared libraries have their own deps, so scan copied files again.
for pass in 1 2 3; do
	echo "dependency pass $pass"

	find "$ROOT" -type f 2>/dev/null | while read -r copied; do
		rel="/${copied#$ROOT/}"

		if [ -e "$rel" ]; then
			copy_elf_deps "$rel"
		fi
	done
done
