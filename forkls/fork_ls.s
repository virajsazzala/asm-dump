# fork_ls.s
# as -o build/fork_ls.o fork_ls.s && ld -o build/fork_ls build/fork_ls.o

	.section .rodata
stmsg:	.string "Before ls\n"
		stmsg_len = . - stmsg - 1

enmsg: .string "After ls\n"
		enmsg_len = . - enmsg - 1

lspath:	.string "/bin/ls"
errmsg:	.string "Error occurred, exiting\n"
		errmsg_len = . - errmsg - 1

	.section .bss
status:	.long 0

	.section .data
argv: 	.quad lspath
		.quad 0
envp: 	.quad 0

	.section .text
	.globl _start

# print: write(1, rsi=buf, rdx=len)
# clobbers: rax, rdi
print:
	mov		$1, %rax
	mov		$1, %rdi
	syscall
	ret

# exit_with: exit(rdi=code)
exit_with:
	mov $60, %rax
	syscall

_start:
	lea		stmsg(%rip), %rsi
	mov		$stmsg_len, %rdx
	call	print

	# fork()
	mov		$57, %rax
	syscall

	test	%rax, %rax
	jz		child
	js		error_fork			# rax < 0: fork failed
	# fall through to parent (rax = child pid)

parent:
	mov		%rax, %rdi			# child pid
	lea		status(%rip), %rsi	# *wstatus
	xor 	%rdx, %rdx			# options = 0
	xor 	%r10, %r10			# rusage = NULL
	mov 	$61, %rax			# wait4
	syscall

	lea		enmsg(%rip), %rsi
	mov 	$enmsg_len, %rdx
	call	print

	xor		%rdi, %rdi
	call	exit_with

child:
	mov 	$59, %rax			# execve
	lea		lspath(%rip), %rdi	# path
	lea		argv(%rip), %rsi	# argv
	lea		envp(%rip), %rdx	# envp
	syscall
	# execve only returns on failure; rax = -errno
	neg		%rax
	mov 	%rax, %rdi
	call	exit_with

error_fork:
	neg		%rax
	mov 	%rax, %rdi
	push	%rdi
	lea		errmsg(%rip), %rsi
	mov		$errmsg_len, %rdx
	call	print
	pop		%rdi
	call	exit_with
