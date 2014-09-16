 .section .data
 .section .text
 .globl _recursive
 .globl _start

_start:

	pushl $4
	call _recursive
	addl $4, %esp
	movl %eax, %ebx
	movl $1,%eax
	int $0x80
  .type _recursive,@function
_recursive:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	cmpl $1, %eax
	je end_recur
	#recur core
	decl %eax
	pushl %eax
	call _recursive
	movl 8(%ebp), %ebx
	imull %ebx, %eax
	
end_recur:
	movl %esp, %ebp
	popl %ebp
	ret
