	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 10, 15	sdk_version 10, 15
	.globl	_simple                 ## -- Begin function simple
	.p2align	4, 0x90
_simple:                                ## @simple
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movq	-8(%rbp), %rdi
	movl	(%rdi), %esi
	addl	-12(%rbp), %esi
	movl	%esi, -16(%rbp)
	movl	-16(%rbp), %esi
	movq	-8(%rbp), %rdi
	movl	%esi, (%rdi)
	movl	-16(%rbp), %eax
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function

.subsections_via_symbols
