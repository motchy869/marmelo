#!/bin/bash
files=`find .`
for file in $files; do
	echo $file
	touch $file
done