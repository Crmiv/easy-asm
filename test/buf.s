
#
.equ SYS_OPEN 5
.equ SYS_WRITE 4
.equ SYS_READ 3
.equ SYS_CLOSE 6
.equ SYS_EXIT 1

#read from /usr/include/asm-generic/fcntl.h

#define O_ACCMODE	00000003
#define O_RDONLY	00000000
#define O_WRONLY	00000001
#define O_RDWR		00000002
#ifndef O_CREAT
#define O_CREAT		00000100	/* not fcntl */
#endif
#ifndef O_EXCL
#define O_EXCL		00000200	/* not fcntl */
#endif
#ifndef O_NOCTTY
#define O_NOCTTY	00000400	/* not fcntl */
#endif
#ifndef O_TRUNC
#define O_TRUNC		00001000	/* not fcntl */
#endif
#ifndef O_APPEND
#define O_APPEND	00002000
#endif
#ifndef O_NONBLOCK
#define O_NONBLOCK	00004000
#endif
#ifndef O_DSYNC
#define O_DSYNC		00010000	/* used to be O_SYNC, see below */
#endif
#ifndef FASYNC
#define FASYNC		00020000	/* fcntl, for BSD compatibility */
#endif
#ifndef O_DIRECT
#define O_DIRECT	00040000	/* direct disk access hint */
#endif
#ifndef O_LARGEFILE
#define O_LARGEFILE	00100000
#endif
#ifndef O_DIRECTORY
#define O_DIRECTORY	00200000	/* must be a directory */
#endif
#ifndef O_NOFOLLOW
#define O_NOFOLLOW	00400000	/* don't follow links */
#endif
#ifndef O_NOATIME
#define O_NOATIME	01000000
#endif
#ifndef O_CLOEXEC
#define O_CLOEXEC	02000000	/* set close_on_exec */
#endif

.equ RDONLY, 0
.equ TRUNC, 00001000
#file desc
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ SYS_CALL, 0x80
.equ END_FILE 0
.equ PARAMETER 2

.section .bss
.lcomm buf, 512
#read from descriptor to buffer
movl 3, %eax 
movl 512, %edx
movl $buf, %ecx
int $0x80

.section .bss
.lcomm buf, 512

.section .text

#stack position des
.equ S_SIZE_RESVERSE, 8

#FD: file-descriptor
.equ S_FD_IN, -4
.equ S_FD_OUT, -8

#func parameter
.equ S_ARGC, 0
.equ S_NAME, 4
.equ S_INFILE, 8 
.equ S_OUTFILE, 12

.globl _start:

_start:
	movl %esp, %ebp
	subl $S_SIZE_RESVERSE, %esp

open_f:

open_fd_in:

	movl $SYS_OPEN, %eax
	movl S_INFILE(%ebp), %ebx
	movl $RDONLY, %ecx
	movl $0666, %edx
	int $SYS_CALL 

store_f_in:
	movl %eax, S_FD_IN(%ebp)

open_fd_out:
	movl $SYS_OPEN, %eax
	movl S_OUTFILE(%ebp), %ebx
	movl $TRUNC, %ecx
	movl $0666, %edx
	int $SYS_CALL 

store_f_out:
	movl %eax, S_FD_OUT(%ebx)

read_loop:
	#main loop read to buffer
	movl $SYS_READ, %eax
	movl $S_FD_IN(%ebp), %ebx
	movl $buf, %ecx
	movl $512, %edx
	int $SYS_CALL
	cmpl %eax, $END_FILE
	jle    end_loop

continue_loop:
	pushl $buf 
	pushl %eax
	call convert_to_upper
	popl %eax
	addl $4, %esp
	
	movl %eax, %edx
	movl $SYS_WRITE, %eax
	movl %S_FD_OUT(%ebp), %ebx
	movl $buf, %ecx
	int $SYS_CALL 

	jmp read_loop 

end_loop:
	movl $SYS_CLOSE ,%eax
	movl S_FD_IN(%ebp), %ebx
	int $SYS_CALL

	movl $SYS_CLOSE, %eax
	movl S_FD_OUT(%ebp), %epx
	int $SYS_CALL

	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $SYS_CALL

.equ LOWER_A, 'a'
.equ LOWER_Z, 'z'
.equ UP_CONVER 'A' - 'a'

.equ ST_BUFFER_LEN, 8
.equ ST_BUFFER, 12

convert_to_upper:
	pushl %ebp
	movl %esp, %ebp

	movl ST_BUFFER(%ebp), %eax
	movl ST_BUFFER_LEN(%ebp), %ebx
	movl $0, %edi

	cmpl $0, %ebx
	je end_convert_loop

convert_loop:
	movb (%eax,%edi,1), %cl
	cmpb $LOWER_A, %cl
	jl	next_byte
	cmpb $LOWER_Z, %cl
	jg next_byte

	addb $UP_CONVER, %cl
	movb %cl, (%eax, %edi, 1)
next_byte:
	incl %edi
	cmpl %edi, %ebx

	jne convert_loop

end_convert_loop:
	movl %ebp, %esp
	popl %ebp
	ret


