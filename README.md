# printf function on 64-bit Linux NASM

Download NASM (Ubuntu/Debian):
```shell
sudo apt update -y
sudo apt install nasm
```

To compile, link and run program by one command:
```shell
./run.sh printf.s
```

And dividely:
```shell
nasm -f elf64 -l printf.lst printf.s
ld -s -o printf printf.o
```
