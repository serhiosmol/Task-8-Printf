main: main.c printf.o
	gcc -Wall -g $^ -o $@

printf.o: printf.s
	nasm -g -f elf64 $<

.PHONY: clean

clean:
	rm -f main *.o
