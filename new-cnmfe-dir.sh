#!/bin/bash

pattern="recording*downsample4x.mat"
files=( $pattern )
if ! [ -d cnmfe-new ]; then
	mkdir cnmfe-new
fi

ln -s "$(pwd)/${files[0]}" "$(pwd)/cnmfe-new/"

echo "linking recording into new folder complete"
echo "$(pwd)/cnmfe-new/${files[0]}"
