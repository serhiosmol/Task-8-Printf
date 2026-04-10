extern int printf(char*, ...);

int main()
{
    printf("%s, %c, %d, %b, %o, %x\n", "Sergey", 'x', 255, 255,
		  255, 255);
    return 0;
}
