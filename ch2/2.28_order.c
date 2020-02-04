#include <stdio.h>

int
main()
{
    printf("%d\n", 1 << 2 + 1); //8
    printf("%d\n", (1 << 2) + 1); //5
    printf("%d\n", 1 << (2 + 1)); //8
}