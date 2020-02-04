#include <stdio.h>

int
main()
{
 int x = 0x98FDECBA;
 printf("%.2x\n", x);
 printf("%.2x\n", (~0xFF | x));
 printf("%.2x\n", (0xFF ^ x));
 printf("%.2x\n", (~0xFF & x));
}