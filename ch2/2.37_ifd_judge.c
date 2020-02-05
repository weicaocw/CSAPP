#include <stdio.h>
#include <math.h>

int
main()
{
 int x = 2100010001;
 printf("A. %d\n", x == (int)(float) x); 
//  printf("A. %d\n", (int)(float) x); 
 printf("F. %d\n", 2/3 == 2/3.0); 
 float f = INFINITY;
 double d = HUGE_VAL;
 printf("H. %d\n", (d+f) -d == f); 
 printf("H. %f\n", (d+f) -d); 
 printf("H. %f\n", (d+f)); 
}