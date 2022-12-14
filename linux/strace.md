


![](../images/Benchmarking/02.png)


```
-tt 在每行输出的前面，显示毫秒级别的时间
-T 显示每次系统调用所花费的时间
-v 对于某些相关调用，把完整的环境变量，文件 stat 结构等打印出来
-f 跟踪目标进程，以及目标进程创建的所有子进程
-e 控制要跟踪的事件和跟踪行为，比如指定要跟踪的系统调用名称
-o 把 strace 输出写入指定的文件中
-s 但系统调用的某个参数是字符串时，最多输出指定长度的内容，默认是 32 个字节
-p 指定要跟踪的进程 pid，要同时跟踪多个进程，重复指定多个 -p 选项即可
-c 最后生成统计信息

strace -tt -T -v -f -e trace=file -o ./strace.log -s 1024 -p 88

strace -e poll,select,connect,sendto ping www.baidu.com

strace ls

strace -tt -T -v -f -s 1024 -c ls

[root@arm-master ~]# curl cheat.sh/strace
 cheat:strace
# To strace a command:
strace <command>

# To save the trace to a file:
strace -o <outfile> <command>

# To follow only the open() system call:
strace -e trace=open <command>

# To follow all the system calls which open a file:
strace -e trace=file <command>

# To follow all the system calls associated with process management:
strace -e trace=process <command>

# To follow child processes as they are created:
strace -f <command>

# To count time, calls and errors for each system call:
strace -c <command>

# To trace a running process (multiple PIDs can be specified):
strace -p <pid>

 tldr:strace
# strace
# Troubleshooting tool for tracing system calls.

# Start tracing a specific process by its PID:
strace -p pid

# Trace a process and filter output by system call:
strace -p pid -e system_call_name

# Count time, calls, and errors for each system call and report a summary on program exit:
strace -p pid -c

# Show the time spent in every system call:
strace -p pid -T

# Start tracing a program by executing it:
strace program

# Start tracing file operations of a program:
strace -e trace=file program
[root@arm-master ~]#


[root@arm-master ~]#
[root@arm-master ~]# curl cheat.sh/ltrace
# ltrace
# Display dynamic library calls of a process.
# More information: <https://linux.die.net/man/1/ltrace>.

# Print (trace) library calls of a program binary:
ltrace ./program

# Count library calls. Print a handy summary at the bottom:
ltrace -c path/to/program

# Trace calls to malloc and free, omit those done by libc:
ltrace -e malloc+free-@libc.so* path/to/program

# Write to file instead of terminal:
ltrace -o file path/to/program



[root@arm-master ~]# curl cheat.sh/extrace
# extrace
# Trace exec() calls.
# More information: <https://github.com/chneukirchen/extrace>.

# Trace all program executions occurring on the system:
sudo extrace

# Run a command and only trace descendants of this command:
sudo extrace command

# Print the current working directory of each process:
sudo extrace -d

# Resolve the full path of each executable:
sudo extrace -l

# Display the user running each process:
sudo extrace -u
[root@arm-master ~]#






```

