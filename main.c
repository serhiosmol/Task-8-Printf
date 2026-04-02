#include <stdio.h>

extern int my_printf(char*, ...);

int main()
{
    my_printf("%s%c", "Hello, World", '!');
    return 0;
}
