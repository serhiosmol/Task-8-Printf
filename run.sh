#!/bin/bash

FILENAME=${1%.*}

nasm -f elf64 -l "$FILENAME.lst" "$FILENAME.s"
ld -s -o "$FILENAME" "$FILENAME.o"
./"$FILENAME"
