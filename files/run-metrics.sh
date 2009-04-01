#!/bin/bash
# $Id$

## run gmetrics from directory $1
for I in $(ls $1/*); do
	[[ -x $I ]] &&	exec $I
done