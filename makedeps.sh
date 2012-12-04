#!/bin/bash

depsdir() {
	echo "ifneq (\$(rebuild),)"
	echo "  ifeq (\$(rebuild),$1)"
	echo "    DEPS_$1=/proc/self/cmdline"
	echo "  else"
	echo "    DEPS_$1="
	echo "  endif"
	echo "else"
	echo -n "  DEPS_$1="; shift
	for d; do
		( cd "$d"; git ls-files | sed "s,^,$d/,"; )
	done | sort | sed 'x; s/ /\\ /g; /./ { s,$, ,; }; s,$,\\,; $ { p; x; }'
	echo "endif"
	echo
}

echo
depsdir $1 $2
