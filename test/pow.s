 .section .data

 .section .text

 .globl _start

#use command-as command-ld
#as --32 xxx.s -o xxx.o
#ld -m elf_i386

_start:
#num in stack
 pushl $3
 pushl $2

 call power
#push back the stack
 addl $8, %esp
 pushl %eax


 pushl $2
 pushl $5
 call power
 addl $8, %esp
 popl %ebx

 addl %eax, %ebx

 movl $1, %eax

#interrupt

 int $0x80
 .type power, @function

power:

 pushl %ebp
 movl %esp, %ebp
 subl $4 ,%esp
 movl 8(%ebp), %ebx
 movl 12(%esp), %ecx

power_loop_s:
 cmpl $1, %ecx
 je end_loop
 movl -4(%ebp), %eax
 imull %ebx, %eax
 movl %eax, -4(%ebp)

 decl %ecx
 jmp power_loop_s

end_loop:
 movl -4(%ebp), %eax
 movl %ebp, %esp
 popl %ebp	
 ret

