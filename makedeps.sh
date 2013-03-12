#!/bin/bash

depsdir() {
	echo -n "$1.stamp: "; shift
	for d; do
		( cd "$d"; git ls-files | sed "s,^,$d/,"; )
	done | sort | sed 'x; s/ /\\ /g; /./ { s,$, ,; }; s,$,\\,; $ { p; x; }' | sed 's/#/\\#/' 
	echo
}

echo
depsdir $@
