#!/bin/bash
# $Id$

## run gmetrics from directory $1
for I in $(ls $1/* 2>/dev/null); do
	[[ -x $I ]] &&	exec $I 2>/dev/null
done
