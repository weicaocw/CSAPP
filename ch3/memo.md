终于开始第三章的内容了，是在是太慢了。
阅读竞赛继续，目标是一个T 5 = pages。 练习题花费时间的可以两说。

## 2 程序编码
1. %ebp %esp 是什么？
pushl %ebp //save frame pointer
movl %esp %ebp //create new frame pointer

?reset stack pointer
?reset frame pointer 怎么理解

pushl %ebp
相当于两条命令： %esp - 4（生长一格）  并把ebp移到esp的（地址）中
popl正相反




练习题3.1:
0x100
0xAB
0x108 Imm
0xFF
0xAB
0x11
0x13
0xFF
0x11
...好像猜谜～～～

练习题3.2:
x di ax
y bx dx
z si cx

x ==> y
y ==> z
z ==> x

```c
void decode1(int *xp, int *yp, int *zp)
{
    int x = *xp;
    int y = *yp;
    int z = *zp;
    *yp = x;
    *zp = y;
    *xp = z;
}
```


# 5. 算数和逻辑操作
四类操作： 
加载有效地址
一元
二元
移位

## 5.1 加载有效地址
leal 其实没有用到memory～

练习题3.3:
x + 6
x + y
x + 4y
x + 8y + 7
4x + 10
x + 2y + 9

练习3.4：
更新内存的值 0x100
同上 0xA8
同上，乘了个立即数 0x110
？？0x9的地址加一？ 地址有效吗？
让寄存器重的数减一 0
改变eax的中的值 0xfd

练习3.5:
sall $2 %eax
sarl %ecx %eax

## 5.4 讨论
> leal 见5.1: 伸缩变化的变址寻址模式的操作数执行计算，我理解的是使用伸缩变化的变址寻址模式来执行计算

练习3.6:
自我异或就是清0，
为什么清0？i！！！

# 6. 控制

练习3.7
<
< unsigned
short >= short
char != char 
>
> 这个其实不太明白 %eax & %eax

## 6.2 操作码

## 6.3 跳转指令 
指令padding：cpu高速缓存 ？ 为啥？
lea 0x0(%esi), %esi Added nops为什么

跳转地址：PC相关的编码，我的理解是作为一种相对的地址（偏移量）， 当指令被既存在不同的地址，机器码也不变

练习3.8:
A.
8048d1e + da = ？二进制补码？
-35= 8048d00 - 5 = 8048cfb
8048d20 + 24 = 8048d44??怎么少了1？ ！！ 每个指令两个字节，太笨了。。。

B.
(mov) + 54 = 8048d44
8048d00 - 0x10  = 8048cf0

C.8048907 + cb = 80489e2

D. ff25? 表示简介跳转？

## 6.4 条件跳转
？问题：
寄存器：%esp %ebp 到底代表什么 x64中呢？
 
练习3.9
```c
void cond_diff(int a, int *p){
    if (p == 0){
        goto done;
    }
    if ( a <= 0){
        goto done;
    }
    *p += a;
    done:
        return;
}
```
因为c中的条件控制语句可以使用逻辑运算符表示多种判断的组合，而汇编必须一个一个判断。

## 6.5 循环

练习3.10
A:
esi x
ebx y
ecx n
al: n > 0
dl: y < n
eax" n > 0 && y < n 

> ?addl 与？位与？ 看样子可能是位与.   andl？ andb？没有andb?

B:
test-expr: ((n < 0) & (y < n)); 9-14
b-s: x += n; y *= n; n--; 6-8

C:
略！


> extraction： 编译器做的优化：之第三条：
为什么判断 != 0 比 >= 0 少了一条汇编指令？
jnz: ~ZF
jge: ~(SF ^ OF) 
是这个意思吗？

练习题3.11:
A:
a eax 
b ebx
i ecx
result edx

？？？和255比较： jle 为哈？
为什么不是和256比较： jl？

B: 
test-expr: i < 256  line 10
b-s: line 7-9
result += a;
a -= b;
i += b;
初始优化：
转变为do while， result 先加a，然后直接加a
因为编译器知道0 < 256

C:略

D: 略

练习3.12:



阅读竞赛：
0205:
T1: p120-123 表现一般，不够专注
T2: P123-127 大体过关 加油
0206 竞赛
T1: p127-130 表现一般，分心
T2:  130-132/133 表现一般
0207 
T1: 132/133- 136 中等
T2: 136-138 中等 不过做了练习题
加油
0212:
T1: P138-139 适应适应 加油
0217： 复习
2T 结束复习
3-4T： 138-144 一般般

0219
1T:page 144-145 艰难起步。。。

0220
1T: p145-150 过关！
2T: 咋又下来了 150-152/153
3T: 152-154 情有可原，复习钻研来着

0223




