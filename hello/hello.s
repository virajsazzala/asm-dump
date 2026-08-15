.section .rodata
msg:
	.string "Hello, World!\n"

.section .text
.globl _start

_start:
	mov $1, %rax		 # syscall write
	mov $1, %rdi		 # fd: stdout
	lea msg(%rip), %rsi  # addr of string
	mov $14, %rdx		 # len of string
	syscall

	mov $60, %rax		 # syscall exit
	xor %rdi, %rdi		 # exit code: 0
	syscall
