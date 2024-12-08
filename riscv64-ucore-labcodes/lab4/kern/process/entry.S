.text
.globl kernel_thread_entry    # 声明 kernel_thread_entry 为全局符号，供外部访问
kernel_thread_entry:          # kernel_thread_entry 函数的入口，表示内核线程的启动函数
    move a0, s1               # 将寄存器 s1 的值移动到 a0 寄存器中
 # 这里可能是将父进程传递的参数 (如：线程的栈指针或其他参数) 传递给内核线程
    jalr s0                    # 跳转到寄存器 s0 所指向的地址，并且将返回地址保存到 ra 中
 # 这里的 s0 寄存器应该保存内核线程的入口地址（可能是线程的执行函数）

    jal do_exit                # 跳转到 do_exit 函数，表示当前线程的退出操作
 # do_exit 函数通常负责清理线程资源并结束线程的生命周期
