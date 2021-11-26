#!/bin/bash
set -e
rm -rf out || true
mkdir -p out || true
for f in ./src/*.s; do
	nasm -g -f elf64 -o out/$(basename $f .s).o $f
done
ld -o out/AVS4 ./out/*o
echo "OK"
