#!/usr/bin/env bash

cat $1 | awk '{ if($1 ~ /^define$/) for(i=1; i < NR; i++) if($i ~ /^@/) { print $i; break; } }' | cut -d@ -f2 | cut -d\( -f1 | sort | uniq

