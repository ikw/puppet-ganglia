#!/bin/bash
# $Id$
# 2009, (c) by udo.waechter@uni-osnabrueck.de
#
# This script is part of the ganglia-puppet module.
# It runs all scripts in a given directory.
#
## run gmetrics from directory $1
for I in $(ls $1/* 2>/dev/null); do
	[[ -x $I ]] && $I
done
