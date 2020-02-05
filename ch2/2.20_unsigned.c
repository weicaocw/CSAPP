#include <stdio.h>

int
main()
{
    printf("%d\n", ((int)-2147483648) == 2147483648U);
    printf("%d\n", (-2147483647 - 1) == 2147483648U);
    printf("%d\n", (-2147483647 - 1)); 
    printf("%d\n", -2147483648); // literal  -2147483648 是long
}