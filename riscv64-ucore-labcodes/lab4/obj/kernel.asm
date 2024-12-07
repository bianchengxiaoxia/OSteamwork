
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c020a137          	lui	sp,0xc020a

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000b517          	auipc	a0,0xb
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020b060 <buf>
ffffffffc020003a:	00016617          	auipc	a2,0x16
ffffffffc020003e:	59260613          	addi	a2,a2,1426 # ffffffffc02165cc <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	657040ef          	jal	ra,ffffffffc0204ea0 <memset>

    cons_init();                // init the console
ffffffffc020004e:	4a6000ef          	jal	ra,ffffffffc02004f4 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	e9e58593          	addi	a1,a1,-354 # ffffffffc0204ef0 <etext+0x2>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	eb650513          	addi	a0,a0,-330 # ffffffffc0204f10 <etext+0x22>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	162000ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	687010ef          	jal	ra,ffffffffc0201ef0 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	55a000ef          	jal	ra,ffffffffc02005c8 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	195030ef          	jal	ra,ffffffffc0203a0a <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	60c040ef          	jal	ra,ffffffffc0204686 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4e8000ef          	jal	ra,ffffffffc0200566 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	2e3020ef          	jal	ra,ffffffffc0202b64 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	41c000ef          	jal	ra,ffffffffc02004a2 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	532000ef          	jal	ra,ffffffffc02005bc <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	047040ef          	jal	ra,ffffffffc02048d4 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00005517          	auipc	a0,0x5
ffffffffc02000ac:	e7050513          	addi	a0,a0,-400 # ffffffffc0204f18 <etext+0x2a>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	0000bb97          	auipc	s7,0xb
ffffffffc02000c2:	fa2b8b93          	addi	s7,s7,-94 # ffffffffc020b060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	0ee000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	0de000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	0cc000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	0000b517          	auipc	a0,0xb
ffffffffc020011e:	f4650513          	addi	a0,a0,-186 # ffffffffc020b060 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	3a8000ef          	jal	ra,ffffffffc02004f6 <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	12f040ef          	jal	ra,ffffffffc0204aa2 <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	0f9040ef          	jal	ra,ffffffffc0204aa2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a681                	j	ffffffffc02004f6 <cons_putc>

ffffffffc02001b8 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001b8:	1141                	addi	sp,sp,-16
ffffffffc02001ba:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001bc:	36e000ef          	jal	ra,ffffffffc020052a <cons_getc>
ffffffffc02001c0:	dd75                	beqz	a0,ffffffffc02001bc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001c2:	60a2                	ld	ra,8(sp)
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001ca:	00005517          	auipc	a0,0x5
ffffffffc02001ce:	d5650513          	addi	a0,a0,-682 # ffffffffc0204f20 <etext+0x32>
void print_kerninfo(void) {
ffffffffc02001d2:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001d4:	fadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001d8:	00000597          	auipc	a1,0x0
ffffffffc02001dc:	e5a58593          	addi	a1,a1,-422 # ffffffffc0200032 <kern_init>
ffffffffc02001e0:	00005517          	auipc	a0,0x5
ffffffffc02001e4:	d6050513          	addi	a0,a0,-672 # ffffffffc0204f40 <etext+0x52>
ffffffffc02001e8:	f99ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001ec:	00005597          	auipc	a1,0x5
ffffffffc02001f0:	d0258593          	addi	a1,a1,-766 # ffffffffc0204eee <etext>
ffffffffc02001f4:	00005517          	auipc	a0,0x5
ffffffffc02001f8:	d6c50513          	addi	a0,a0,-660 # ffffffffc0204f60 <etext+0x72>
ffffffffc02001fc:	f85ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200200:	0000b597          	auipc	a1,0xb
ffffffffc0200204:	e6058593          	addi	a1,a1,-416 # ffffffffc020b060 <buf>
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	d7850513          	addi	a0,a0,-648 # ffffffffc0204f80 <etext+0x92>
ffffffffc0200210:	f71ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200214:	00016597          	auipc	a1,0x16
ffffffffc0200218:	3b858593          	addi	a1,a1,952 # ffffffffc02165cc <end>
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	d8450513          	addi	a0,a0,-636 # ffffffffc0204fa0 <etext+0xb2>
ffffffffc0200224:	f5dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200228:	00016597          	auipc	a1,0x16
ffffffffc020022c:	7a358593          	addi	a1,a1,1955 # ffffffffc02169cb <end+0x3ff>
ffffffffc0200230:	00000797          	auipc	a5,0x0
ffffffffc0200234:	e0278793          	addi	a5,a5,-510 # ffffffffc0200032 <kern_init>
ffffffffc0200238:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200240:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200242:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200246:	95be                	add	a1,a1,a5
ffffffffc0200248:	85a9                	srai	a1,a1,0xa
ffffffffc020024a:	00005517          	auipc	a0,0x5
ffffffffc020024e:	d7650513          	addi	a0,a0,-650 # ffffffffc0204fc0 <etext+0xd2>
}
ffffffffc0200252:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200254:	b735                	j	ffffffffc0200180 <cprintf>

ffffffffc0200256 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200258:	00005617          	auipc	a2,0x5
ffffffffc020025c:	d9860613          	addi	a2,a2,-616 # ffffffffc0204ff0 <etext+0x102>
ffffffffc0200260:	04d00593          	li	a1,77
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	da450513          	addi	a0,a0,-604 # ffffffffc0205008 <etext+0x11a>
void print_stackframe(void) {
ffffffffc020026c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020026e:	1d8000ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200272 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200274:	00005617          	auipc	a2,0x5
ffffffffc0200278:	dac60613          	addi	a2,a2,-596 # ffffffffc0205020 <etext+0x132>
ffffffffc020027c:	00005597          	auipc	a1,0x5
ffffffffc0200280:	dc458593          	addi	a1,a1,-572 # ffffffffc0205040 <etext+0x152>
ffffffffc0200284:	00005517          	auipc	a0,0x5
ffffffffc0200288:	dc450513          	addi	a0,a0,-572 # ffffffffc0205048 <etext+0x15a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020028c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020028e:	ef3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200292:	00005617          	auipc	a2,0x5
ffffffffc0200296:	dc660613          	addi	a2,a2,-570 # ffffffffc0205058 <etext+0x16a>
ffffffffc020029a:	00005597          	auipc	a1,0x5
ffffffffc020029e:	de658593          	addi	a1,a1,-538 # ffffffffc0205080 <etext+0x192>
ffffffffc02002a2:	00005517          	auipc	a0,0x5
ffffffffc02002a6:	da650513          	addi	a0,a0,-602 # ffffffffc0205048 <etext+0x15a>
ffffffffc02002aa:	ed7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ae:	00005617          	auipc	a2,0x5
ffffffffc02002b2:	de260613          	addi	a2,a2,-542 # ffffffffc0205090 <etext+0x1a2>
ffffffffc02002b6:	00005597          	auipc	a1,0x5
ffffffffc02002ba:	dfa58593          	addi	a1,a1,-518 # ffffffffc02050b0 <etext+0x1c2>
ffffffffc02002be:	00005517          	auipc	a0,0x5
ffffffffc02002c2:	d8a50513          	addi	a0,a0,-630 # ffffffffc0205048 <etext+0x15a>
ffffffffc02002c6:	ebbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc02002ca:	60a2                	ld	ra,8(sp)
ffffffffc02002cc:	4501                	li	a0,0
ffffffffc02002ce:	0141                	addi	sp,sp,16
ffffffffc02002d0:	8082                	ret

ffffffffc02002d2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d2:	1141                	addi	sp,sp,-16
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002d6:	ef3ff0ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002e6:	f71ff0ef          	jal	ra,ffffffffc0200256 <print_stackframe>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002f2:	7115                	addi	sp,sp,-224
ffffffffc02002f4:	ed5e                	sd	s7,152(sp)
ffffffffc02002f6:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f8:	00005517          	auipc	a0,0x5
ffffffffc02002fc:	dc850513          	addi	a0,a0,-568 # ffffffffc02050c0 <etext+0x1d2>
kmonitor(struct trapframe *tf) {
ffffffffc0200300:	ed86                	sd	ra,216(sp)
ffffffffc0200302:	e9a2                	sd	s0,208(sp)
ffffffffc0200304:	e5a6                	sd	s1,200(sp)
ffffffffc0200306:	e1ca                	sd	s2,192(sp)
ffffffffc0200308:	fd4e                	sd	s3,184(sp)
ffffffffc020030a:	f952                	sd	s4,176(sp)
ffffffffc020030c:	f556                	sd	s5,168(sp)
ffffffffc020030e:	f15a                	sd	s6,160(sp)
ffffffffc0200310:	e962                	sd	s8,144(sp)
ffffffffc0200312:	e566                	sd	s9,136(sp)
ffffffffc0200314:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200316:	e6bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	dce50513          	addi	a0,a0,-562 # ffffffffc02050e8 <etext+0x1fa>
ffffffffc0200322:	e5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200326:	000b8563          	beqz	s7,ffffffffc0200330 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020032a:	855e                	mv	a0,s7
ffffffffc020032c:	4f4000ef          	jal	ra,ffffffffc0200820 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	4581                	li	a1,0
ffffffffc0200334:	4601                	li	a2,0
ffffffffc0200336:	48a1                	li	a7,8
ffffffffc0200338:	00000073          	ecall
ffffffffc020033c:	00005c17          	auipc	s8,0x5
ffffffffc0200340:	e1cc0c13          	addi	s8,s8,-484 # ffffffffc0205158 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200344:	00005917          	auipc	s2,0x5
ffffffffc0200348:	dcc90913          	addi	s2,s2,-564 # ffffffffc0205110 <etext+0x222>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	00005497          	auipc	s1,0x5
ffffffffc0200350:	dcc48493          	addi	s1,s1,-564 # ffffffffc0205118 <etext+0x22a>
        if (argc == MAXARGS - 1) {
ffffffffc0200354:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200356:	00005b17          	auipc	s6,0x5
ffffffffc020035a:	dcab0b13          	addi	s6,s6,-566 # ffffffffc0205120 <etext+0x232>
        argv[argc ++] = buf;
ffffffffc020035e:	00005a17          	auipc	s4,0x5
ffffffffc0200362:	ce2a0a13          	addi	s4,s4,-798 # ffffffffc0205040 <etext+0x152>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200366:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200368:	854a                	mv	a0,s2
ffffffffc020036a:	d29ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc020036e:	842a                	mv	s0,a0
ffffffffc0200370:	dd65                	beqz	a0,ffffffffc0200368 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200372:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200376:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200378:	e1bd                	bnez	a1,ffffffffc02003de <kmonitor+0xec>
    if (argc == 0) {
ffffffffc020037a:	fe0c87e3          	beqz	s9,ffffffffc0200368 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037e:	6582                	ld	a1,0(sp)
ffffffffc0200380:	00005d17          	auipc	s10,0x5
ffffffffc0200384:	dd8d0d13          	addi	s10,s10,-552 # ffffffffc0205158 <commands>
        argv[argc ++] = buf;
ffffffffc0200388:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038a:	4401                	li	s0,0
ffffffffc020038c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038e:	2df040ef          	jal	ra,ffffffffc0204e6c <strcmp>
ffffffffc0200392:	c919                	beqz	a0,ffffffffc02003a8 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200394:	2405                	addiw	s0,s0,1
ffffffffc0200396:	0b540063          	beq	s0,s5,ffffffffc0200436 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039a:	000d3503          	ld	a0,0(s10)
ffffffffc020039e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a2:	2cb040ef          	jal	ra,ffffffffc0204e6c <strcmp>
ffffffffc02003a6:	f57d                	bnez	a0,ffffffffc0200394 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003a8:	00141793          	slli	a5,s0,0x1
ffffffffc02003ac:	97a2                	add	a5,a5,s0
ffffffffc02003ae:	078e                	slli	a5,a5,0x3
ffffffffc02003b0:	97e2                	add	a5,a5,s8
ffffffffc02003b2:	6b9c                	ld	a5,16(a5)
ffffffffc02003b4:	865e                	mv	a2,s7
ffffffffc02003b6:	002c                	addi	a1,sp,8
ffffffffc02003b8:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003bc:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003be:	fa0555e3          	bgez	a0,ffffffffc0200368 <kmonitor+0x76>
}
ffffffffc02003c2:	60ee                	ld	ra,216(sp)
ffffffffc02003c4:	644e                	ld	s0,208(sp)
ffffffffc02003c6:	64ae                	ld	s1,200(sp)
ffffffffc02003c8:	690e                	ld	s2,192(sp)
ffffffffc02003ca:	79ea                	ld	s3,184(sp)
ffffffffc02003cc:	7a4a                	ld	s4,176(sp)
ffffffffc02003ce:	7aaa                	ld	s5,168(sp)
ffffffffc02003d0:	7b0a                	ld	s6,160(sp)
ffffffffc02003d2:	6bea                	ld	s7,152(sp)
ffffffffc02003d4:	6c4a                	ld	s8,144(sp)
ffffffffc02003d6:	6caa                	ld	s9,136(sp)
ffffffffc02003d8:	6d0a                	ld	s10,128(sp)
ffffffffc02003da:	612d                	addi	sp,sp,224
ffffffffc02003dc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	2ab040ef          	jal	ra,ffffffffc0204e8a <strchr>
ffffffffc02003e4:	c901                	beqz	a0,ffffffffc02003f4 <kmonitor+0x102>
ffffffffc02003e6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ea:	00040023          	sb	zero,0(s0)
ffffffffc02003ee:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f0:	d5c9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc02003f2:	b7f5                	j	ffffffffc02003de <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc02003f4:	00044783          	lbu	a5,0(s0)
ffffffffc02003f8:	d3c9                	beqz	a5,ffffffffc020037a <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc02003fa:	033c8963          	beq	s9,s3,ffffffffc020042c <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc02003fe:	003c9793          	slli	a5,s9,0x3
ffffffffc0200402:	0118                	addi	a4,sp,128
ffffffffc0200404:	97ba                	add	a5,a5,a4
ffffffffc0200406:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020040a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020040e:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200410:	e591                	bnez	a1,ffffffffc020041c <kmonitor+0x12a>
ffffffffc0200412:	b7b5                	j	ffffffffc020037e <kmonitor+0x8c>
ffffffffc0200414:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200418:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041a:	d1a5                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020041c:	8526                	mv	a0,s1
ffffffffc020041e:	26d040ef          	jal	ra,ffffffffc0204e8a <strchr>
ffffffffc0200422:	d96d                	beqz	a0,ffffffffc0200414 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	00044583          	lbu	a1,0(s0)
ffffffffc0200428:	d9a9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020042a:	bf55                	j	ffffffffc02003de <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020042c:	45c1                	li	a1,16
ffffffffc020042e:	855a                	mv	a0,s6
ffffffffc0200430:	d51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200434:	b7e9                	j	ffffffffc02003fe <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200436:	6582                	ld	a1,0(sp)
ffffffffc0200438:	00005517          	auipc	a0,0x5
ffffffffc020043c:	d0850513          	addi	a0,a0,-760 # ffffffffc0205140 <etext+0x252>
ffffffffc0200440:	d41ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200444:	b715                	j	ffffffffc0200368 <kmonitor+0x76>

ffffffffc0200446 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200446:	00016317          	auipc	t1,0x16
ffffffffc020044a:	0f230313          	addi	t1,t1,242 # ffffffffc0216538 <is_panic>
ffffffffc020044e:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	e822                	sd	s0,16(sp)
ffffffffc0200458:	f436                	sd	a3,40(sp)
ffffffffc020045a:	f83a                	sd	a4,48(sp)
ffffffffc020045c:	fc3e                	sd	a5,56(sp)
ffffffffc020045e:	e0c2                	sd	a6,64(sp)
ffffffffc0200460:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200462:	020e1a63          	bnez	t3,ffffffffc0200496 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200466:	4785                	li	a5,1
ffffffffc0200468:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020046c:	8432                	mv	s0,a2
ffffffffc020046e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200470:	862e                	mv	a2,a1
ffffffffc0200472:	85aa                	mv	a1,a0
ffffffffc0200474:	00005517          	auipc	a0,0x5
ffffffffc0200478:	d2c50513          	addi	a0,a0,-724 # ffffffffc02051a0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc020047c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047e:	d03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cdbff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc020048a:	00006517          	auipc	a0,0x6
ffffffffc020048e:	c8650513          	addi	a0,a0,-890 # ffffffffc0206110 <default_pmm_manager+0x4d0>
ffffffffc0200492:	cefff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200496:	12c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020049a:	4501                	li	a0,0
ffffffffc020049c:	e57ff0ef          	jal	ra,ffffffffc02002f2 <kmonitor>
    while (1) {
ffffffffc02004a0:	bfed                	j	ffffffffc020049a <__panic+0x54>

ffffffffc02004a2 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004a2:	67e1                	lui	a5,0x18
ffffffffc02004a4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a8:	00016717          	auipc	a4,0x16
ffffffffc02004ac:	0af73023          	sd	a5,160(a4) # ffffffffc0216548 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004b0:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004b4:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004b6:	953e                	add	a0,a0,a5
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4881                	li	a7,0
ffffffffc02004bc:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004c0:	02000793          	li	a5,32
ffffffffc02004c4:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004c8:	00005517          	auipc	a0,0x5
ffffffffc02004cc:	cf850513          	addi	a0,a0,-776 # ffffffffc02051c0 <commands+0x68>
    ticks = 0;
ffffffffc02004d0:	00016797          	auipc	a5,0x16
ffffffffc02004d4:	0607b823          	sd	zero,112(a5) # ffffffffc0216540 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d8:	b165                	j	ffffffffc0200180 <cprintf>

ffffffffc02004da <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004da:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004de:	00016797          	auipc	a5,0x16
ffffffffc02004e2:	06a7b783          	ld	a5,106(a5) # ffffffffc0216548 <timebase>
ffffffffc02004e6:	953e                	add	a0,a0,a5
ffffffffc02004e8:	4581                	li	a1,0
ffffffffc02004ea:	4601                	li	a2,0
ffffffffc02004ec:	4881                	li	a7,0
ffffffffc02004ee:	00000073          	ecall
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004f4:	8082                	ret

ffffffffc02004f6 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004f6:	100027f3          	csrr	a5,sstatus
ffffffffc02004fa:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02004fc:	0ff57513          	zext.b	a0,a0
ffffffffc0200500:	e799                	bnez	a5,ffffffffc020050e <cons_putc+0x18>
ffffffffc0200502:	4581                	li	a1,0
ffffffffc0200504:	4601                	li	a2,0
ffffffffc0200506:	4885                	li	a7,1
ffffffffc0200508:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020050c:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020050e:	1101                	addi	sp,sp,-32
ffffffffc0200510:	ec06                	sd	ra,24(sp)
ffffffffc0200512:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200514:	0ae000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0200518:	6522                	ld	a0,8(sp)
ffffffffc020051a:	4581                	li	a1,0
ffffffffc020051c:	4601                	li	a2,0
ffffffffc020051e:	4885                	li	a7,1
ffffffffc0200520:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200524:	60e2                	ld	ra,24(sp)
ffffffffc0200526:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200528:	a851                	j	ffffffffc02005bc <intr_enable>

ffffffffc020052a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020052a:	100027f3          	csrr	a5,sstatus
ffffffffc020052e:	8b89                	andi	a5,a5,2
ffffffffc0200530:	eb89                	bnez	a5,ffffffffc0200542 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200532:	4501                	li	a0,0
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4889                	li	a7,2
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200540:	8082                	ret
int cons_getc(void) {
ffffffffc0200542:	1101                	addi	sp,sp,-32
ffffffffc0200544:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200546:	07c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc020054a:	4501                	li	a0,0
ffffffffc020054c:	4581                	li	a1,0
ffffffffc020054e:	4601                	li	a2,0
ffffffffc0200550:	4889                	li	a7,2
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	2501                	sext.w	a0,a0
ffffffffc0200558:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020055a:	062000ef          	jal	ra,ffffffffc02005bc <intr_enable>
}
ffffffffc020055e:	60e2                	ld	ra,24(sp)
ffffffffc0200560:	6522                	ld	a0,8(sp)
ffffffffc0200562:	6105                	addi	sp,sp,32
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200566:	8082                	ret

ffffffffc0200568 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200568:	00253513          	sltiu	a0,a0,2
ffffffffc020056c:	8082                	ret

ffffffffc020056e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020056e:	03800513          	li	a0,56
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200574:	0000b797          	auipc	a5,0xb
ffffffffc0200578:	eec78793          	addi	a5,a5,-276 # ffffffffc020b460 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020057c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200580:	1141                	addi	sp,sp,-16
ffffffffc0200582:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200584:	95be                	add	a1,a1,a5
ffffffffc0200586:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020058a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020058c:	127040ef          	jal	ra,ffffffffc0204eb2 <memcpy>
    return 0;
}
ffffffffc0200590:	60a2                	ld	ra,8(sp)
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	0141                	addi	sp,sp,16
ffffffffc0200596:	8082                	ret

ffffffffc0200598 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200598:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020059c:	0000b517          	auipc	a0,0xb
ffffffffc02005a0:	ec450513          	addi	a0,a0,-316 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02005a4:	1141                	addi	sp,sp,-16
ffffffffc02005a6:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a8:	953e                	add	a0,a0,a5
ffffffffc02005aa:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02005ae:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005b0:	103040ef          	jal	ra,ffffffffc0204eb2 <memcpy>
    return 0;
}
ffffffffc02005b4:	60a2                	ld	ra,8(sp)
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	0141                	addi	sp,sp,16
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005bc:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005c0:	8082                	ret

ffffffffc02005c2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005c2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005c6:	8082                	ret

ffffffffc02005c8 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ca:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ce:	1141                	addi	sp,sp,-16
ffffffffc02005d0:	e022                	sd	s0,0(sp)
ffffffffc02005d2:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d4:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005d8:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005de:	05500613          	li	a2,85
ffffffffc02005e2:	c399                	beqz	a5,ffffffffc02005e8 <pgfault_handler+0x1e>
ffffffffc02005e4:	04b00613          	li	a2,75
ffffffffc02005e8:	11843703          	ld	a4,280(s0)
ffffffffc02005ec:	47bd                	li	a5,15
ffffffffc02005ee:	05700693          	li	a3,87
ffffffffc02005f2:	00f70463          	beq	a4,a5,ffffffffc02005fa <pgfault_handler+0x30>
ffffffffc02005f6:	05200693          	li	a3,82
ffffffffc02005fa:	00005517          	auipc	a0,0x5
ffffffffc02005fe:	be650513          	addi	a0,a0,-1050 # ffffffffc02051e0 <commands+0x88>
ffffffffc0200602:	b7fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00016517          	auipc	a0,0x16
ffffffffc020060a:	f9a53503          	ld	a0,-102(a0) # ffffffffc02165a0 <check_mm_struct>
ffffffffc020060e:	c911                	beqz	a0,ffffffffc0200622 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200610:	11043603          	ld	a2,272(s0)
ffffffffc0200614:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200618:	6402                	ld	s0,0(sp)
ffffffffc020061a:	60a2                	ld	ra,8(sp)
ffffffffc020061c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020061e:	1c10306f          	j	ffffffffc0203fde <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00005617          	auipc	a2,0x5
ffffffffc0200626:	bde60613          	addi	a2,a2,-1058 # ffffffffc0205200 <commands+0xa8>
ffffffffc020062a:	06200593          	li	a1,98
ffffffffc020062e:	00005517          	auipc	a0,0x5
ffffffffc0200632:	bea50513          	addi	a0,a0,-1046 # ffffffffc0205218 <commands+0xc0>
ffffffffc0200636:	e11ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020063a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020063a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020063e:	00000797          	auipc	a5,0x0
ffffffffc0200642:	47a78793          	addi	a5,a5,1146 # ffffffffc0200ab8 <__alltraps>
ffffffffc0200646:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020064a:	000407b7          	lui	a5,0x40
ffffffffc020064e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200654:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200656:	1141                	addi	sp,sp,-16
ffffffffc0200658:	e022                	sd	s0,0(sp)
ffffffffc020065a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065c:	00005517          	auipc	a0,0x5
ffffffffc0200660:	bd450513          	addi	a0,a0,-1068 # ffffffffc0205230 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	b1bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0205248 <commands+0xf0>
ffffffffc0200674:	b0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00005517          	auipc	a0,0x5
ffffffffc020067e:	be650513          	addi	a0,a0,-1050 # ffffffffc0205260 <commands+0x108>
ffffffffc0200682:	affff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00005517          	auipc	a0,0x5
ffffffffc020068c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205278 <commands+0x120>
ffffffffc0200690:	af1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00005517          	auipc	a0,0x5
ffffffffc020069a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0205290 <commands+0x138>
ffffffffc020069e:	ae3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00005517          	auipc	a0,0x5
ffffffffc02006a8:	c0450513          	addi	a0,a0,-1020 # ffffffffc02052a8 <commands+0x150>
ffffffffc02006ac:	ad5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00005517          	auipc	a0,0x5
ffffffffc02006b6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02052c0 <commands+0x168>
ffffffffc02006ba:	ac7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00005517          	auipc	a0,0x5
ffffffffc02006c4:	c1850513          	addi	a0,a0,-1000 # ffffffffc02052d8 <commands+0x180>
ffffffffc02006c8:	ab9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00005517          	auipc	a0,0x5
ffffffffc02006d2:	c2250513          	addi	a0,a0,-990 # ffffffffc02052f0 <commands+0x198>
ffffffffc02006d6:	aabff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00005517          	auipc	a0,0x5
ffffffffc02006e0:	c2c50513          	addi	a0,a0,-980 # ffffffffc0205308 <commands+0x1b0>
ffffffffc02006e4:	a9dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00005517          	auipc	a0,0x5
ffffffffc02006ee:	c3650513          	addi	a0,a0,-970 # ffffffffc0205320 <commands+0x1c8>
ffffffffc02006f2:	a8fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	c4050513          	addi	a0,a0,-960 # ffffffffc0205338 <commands+0x1e0>
ffffffffc0200700:	a81ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00005517          	auipc	a0,0x5
ffffffffc020070a:	c4a50513          	addi	a0,a0,-950 # ffffffffc0205350 <commands+0x1f8>
ffffffffc020070e:	a73ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00005517          	auipc	a0,0x5
ffffffffc0200718:	c5450513          	addi	a0,a0,-940 # ffffffffc0205368 <commands+0x210>
ffffffffc020071c:	a65ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00005517          	auipc	a0,0x5
ffffffffc0200726:	c5e50513          	addi	a0,a0,-930 # ffffffffc0205380 <commands+0x228>
ffffffffc020072a:	a57ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	c6850513          	addi	a0,a0,-920 # ffffffffc0205398 <commands+0x240>
ffffffffc0200738:	a49ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00005517          	auipc	a0,0x5
ffffffffc0200742:	c7250513          	addi	a0,a0,-910 # ffffffffc02053b0 <commands+0x258>
ffffffffc0200746:	a3bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00005517          	auipc	a0,0x5
ffffffffc0200750:	c7c50513          	addi	a0,a0,-900 # ffffffffc02053c8 <commands+0x270>
ffffffffc0200754:	a2dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00005517          	auipc	a0,0x5
ffffffffc020075e:	c8650513          	addi	a0,a0,-890 # ffffffffc02053e0 <commands+0x288>
ffffffffc0200762:	a1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00005517          	auipc	a0,0x5
ffffffffc020076c:	c9050513          	addi	a0,a0,-880 # ffffffffc02053f8 <commands+0x2a0>
ffffffffc0200770:	a11ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00005517          	auipc	a0,0x5
ffffffffc020077a:	c9a50513          	addi	a0,a0,-870 # ffffffffc0205410 <commands+0x2b8>
ffffffffc020077e:	a03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00005517          	auipc	a0,0x5
ffffffffc0200788:	ca450513          	addi	a0,a0,-860 # ffffffffc0205428 <commands+0x2d0>
ffffffffc020078c:	9f5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00005517          	auipc	a0,0x5
ffffffffc0200796:	cae50513          	addi	a0,a0,-850 # ffffffffc0205440 <commands+0x2e8>
ffffffffc020079a:	9e7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00005517          	auipc	a0,0x5
ffffffffc02007a4:	cb850513          	addi	a0,a0,-840 # ffffffffc0205458 <commands+0x300>
ffffffffc02007a8:	9d9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00005517          	auipc	a0,0x5
ffffffffc02007b2:	cc250513          	addi	a0,a0,-830 # ffffffffc0205470 <commands+0x318>
ffffffffc02007b6:	9cbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00005517          	auipc	a0,0x5
ffffffffc02007c0:	ccc50513          	addi	a0,a0,-820 # ffffffffc0205488 <commands+0x330>
ffffffffc02007c4:	9bdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00005517          	auipc	a0,0x5
ffffffffc02007ce:	cd650513          	addi	a0,a0,-810 # ffffffffc02054a0 <commands+0x348>
ffffffffc02007d2:	9afff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00005517          	auipc	a0,0x5
ffffffffc02007dc:	ce050513          	addi	a0,a0,-800 # ffffffffc02054b8 <commands+0x360>
ffffffffc02007e0:	9a1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00005517          	auipc	a0,0x5
ffffffffc02007ea:	cea50513          	addi	a0,a0,-790 # ffffffffc02054d0 <commands+0x378>
ffffffffc02007ee:	993ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00005517          	auipc	a0,0x5
ffffffffc02007f8:	cf450513          	addi	a0,a0,-780 # ffffffffc02054e8 <commands+0x390>
ffffffffc02007fc:	985ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00005517          	auipc	a0,0x5
ffffffffc0200806:	cfe50513          	addi	a0,a0,-770 # ffffffffc0205500 <commands+0x3a8>
ffffffffc020080a:	977ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00005517          	auipc	a0,0x5
ffffffffc0200818:	d0450513          	addi	a0,a0,-764 # ffffffffc0205518 <commands+0x3c0>
}
ffffffffc020081c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	b28d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200820 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200820:	1141                	addi	sp,sp,-16
ffffffffc0200822:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200828:	00005517          	auipc	a0,0x5
ffffffffc020082c:	d0850513          	addi	a0,a0,-760 # ffffffffc0205530 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200832:	94fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200836:	8522                	mv	a0,s0
ffffffffc0200838:	e1dff0ef          	jal	ra,ffffffffc0200654 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083c:	10043583          	ld	a1,256(s0)
ffffffffc0200840:	00005517          	auipc	a0,0x5
ffffffffc0200844:	d0850513          	addi	a0,a0,-760 # ffffffffc0205548 <commands+0x3f0>
ffffffffc0200848:	939ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084c:	10843583          	ld	a1,264(s0)
ffffffffc0200850:	00005517          	auipc	a0,0x5
ffffffffc0200854:	d1050513          	addi	a0,a0,-752 # ffffffffc0205560 <commands+0x408>
ffffffffc0200858:	929ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085c:	11043583          	ld	a1,272(s0)
ffffffffc0200860:	00005517          	auipc	a0,0x5
ffffffffc0200864:	d1850513          	addi	a0,a0,-744 # ffffffffc0205578 <commands+0x420>
ffffffffc0200868:	919ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200870:	6402                	ld	s0,0(sp)
ffffffffc0200872:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200874:	00005517          	auipc	a0,0x5
ffffffffc0200878:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205590 <commands+0x438>
}
ffffffffc020087c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087e:	903ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200882 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200882:	11853783          	ld	a5,280(a0)
ffffffffc0200886:	472d                	li	a4,11
ffffffffc0200888:	0786                	slli	a5,a5,0x1
ffffffffc020088a:	8385                	srli	a5,a5,0x1
ffffffffc020088c:	06f76c63          	bltu	a4,a5,ffffffffc0200904 <interrupt_handler+0x82>
ffffffffc0200890:	00005717          	auipc	a4,0x5
ffffffffc0200894:	dc870713          	addi	a4,a4,-568 # ffffffffc0205658 <commands+0x500>
ffffffffc0200898:	078a                	slli	a5,a5,0x2
ffffffffc020089a:	97ba                	add	a5,a5,a4
ffffffffc020089c:	439c                	lw	a5,0(a5)
ffffffffc020089e:	97ba                	add	a5,a5,a4
ffffffffc02008a0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008a2:	00005517          	auipc	a0,0x5
ffffffffc02008a6:	d6650513          	addi	a0,a0,-666 # ffffffffc0205608 <commands+0x4b0>
ffffffffc02008aa:	8d7ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ae:	00005517          	auipc	a0,0x5
ffffffffc02008b2:	d3a50513          	addi	a0,a0,-710 # ffffffffc02055e8 <commands+0x490>
ffffffffc02008b6:	8cbff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008ba:	00005517          	auipc	a0,0x5
ffffffffc02008be:	cee50513          	addi	a0,a0,-786 # ffffffffc02055a8 <commands+0x450>
ffffffffc02008c2:	8bfff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c6:	00005517          	auipc	a0,0x5
ffffffffc02008ca:	d0250513          	addi	a0,a0,-766 # ffffffffc02055c8 <commands+0x470>
ffffffffc02008ce:	8b3ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d2:	1141                	addi	sp,sp,-16
ffffffffc02008d4:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d6:	c05ff0ef          	jal	ra,ffffffffc02004da <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008da:	00016697          	auipc	a3,0x16
ffffffffc02008de:	c6668693          	addi	a3,a3,-922 # ffffffffc0216540 <ticks>
ffffffffc02008e2:	629c                	ld	a5,0(a3)
ffffffffc02008e4:	06400713          	li	a4,100
ffffffffc02008e8:	0785                	addi	a5,a5,1
ffffffffc02008ea:	02e7f733          	remu	a4,a5,a4
ffffffffc02008ee:	e29c                	sd	a5,0(a3)
ffffffffc02008f0:	cb19                	beqz	a4,ffffffffc0200906 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008f2:	60a2                	ld	ra,8(sp)
ffffffffc02008f4:	0141                	addi	sp,sp,16
ffffffffc02008f6:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008f8:	00005517          	auipc	a0,0x5
ffffffffc02008fc:	d4050513          	addi	a0,a0,-704 # ffffffffc0205638 <commands+0x4e0>
ffffffffc0200900:	881ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200904:	bf31                	j	ffffffffc0200820 <print_trapframe>
}
ffffffffc0200906:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200908:	06400593          	li	a1,100
ffffffffc020090c:	00005517          	auipc	a0,0x5
ffffffffc0200910:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205628 <commands+0x4d0>
}
ffffffffc0200914:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200916:	86bff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020091a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091a:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020091e:	1101                	addi	sp,sp,-32
ffffffffc0200920:	e822                	sd	s0,16(sp)
ffffffffc0200922:	ec06                	sd	ra,24(sp)
ffffffffc0200924:	e426                	sd	s1,8(sp)
ffffffffc0200926:	473d                	li	a4,15
ffffffffc0200928:	842a                	mv	s0,a0
ffffffffc020092a:	14f76a63          	bltu	a4,a5,ffffffffc0200a7e <exception_handler+0x164>
ffffffffc020092e:	00005717          	auipc	a4,0x5
ffffffffc0200932:	f1270713          	addi	a4,a4,-238 # ffffffffc0205840 <commands+0x6e8>
ffffffffc0200936:	078a                	slli	a5,a5,0x2
ffffffffc0200938:	97ba                	add	a5,a5,a4
ffffffffc020093a:	439c                	lw	a5,0(a5)
ffffffffc020093c:	97ba                	add	a5,a5,a4
ffffffffc020093e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200940:	00005517          	auipc	a0,0x5
ffffffffc0200944:	ee850513          	addi	a0,a0,-280 # ffffffffc0205828 <commands+0x6d0>
ffffffffc0200948:	839ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094c:	8522                	mv	a0,s0
ffffffffc020094e:	c7dff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200952:	84aa                	mv	s1,a0
ffffffffc0200954:	12051b63          	bnez	a0,ffffffffc0200a8a <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200958:	60e2                	ld	ra,24(sp)
ffffffffc020095a:	6442                	ld	s0,16(sp)
ffffffffc020095c:	64a2                	ld	s1,8(sp)
ffffffffc020095e:	6105                	addi	sp,sp,32
ffffffffc0200960:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	d2650513          	addi	a0,a0,-730 # ffffffffc0205688 <commands+0x530>
}
ffffffffc020096a:	6442                	ld	s0,16(sp)
ffffffffc020096c:	60e2                	ld	ra,24(sp)
ffffffffc020096e:	64a2                	ld	s1,8(sp)
ffffffffc0200970:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200972:	80fff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc0200976:	00005517          	auipc	a0,0x5
ffffffffc020097a:	d3250513          	addi	a0,a0,-718 # ffffffffc02056a8 <commands+0x550>
ffffffffc020097e:	b7f5                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200980:	00005517          	auipc	a0,0x5
ffffffffc0200984:	d4850513          	addi	a0,a0,-696 # ffffffffc02056c8 <commands+0x570>
ffffffffc0200988:	b7cd                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098a:	00005517          	auipc	a0,0x5
ffffffffc020098e:	d5650513          	addi	a0,a0,-682 # ffffffffc02056e0 <commands+0x588>
ffffffffc0200992:	bfe1                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200994:	00005517          	auipc	a0,0x5
ffffffffc0200998:	d5c50513          	addi	a0,a0,-676 # ffffffffc02056f0 <commands+0x598>
ffffffffc020099c:	b7f9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020099e:	00005517          	auipc	a0,0x5
ffffffffc02009a2:	d7250513          	addi	a0,a0,-654 # ffffffffc0205710 <commands+0x5b8>
ffffffffc02009a6:	fdaff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009aa:	8522                	mv	a0,s0
ffffffffc02009ac:	c1fff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009b0:	84aa                	mv	s1,a0
ffffffffc02009b2:	d15d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	e6bff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00005617          	auipc	a2,0x5
ffffffffc02009c0:	d6c60613          	addi	a2,a2,-660 # ffffffffc0205728 <commands+0x5d0>
ffffffffc02009c4:	0b300593          	li	a1,179
ffffffffc02009c8:	00005517          	auipc	a0,0x5
ffffffffc02009cc:	85050513          	addi	a0,a0,-1968 # ffffffffc0205218 <commands+0xc0>
ffffffffc02009d0:	a77ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d4:	00005517          	auipc	a0,0x5
ffffffffc02009d8:	d7450513          	addi	a0,a0,-652 # ffffffffc0205748 <commands+0x5f0>
ffffffffc02009dc:	b779                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	d8250513          	addi	a0,a0,-638 # ffffffffc0205760 <commands+0x608>
ffffffffc02009e6:	f9aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ea:	8522                	mv	a0,s0
ffffffffc02009ec:	bdfff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009f0:	84aa                	mv	s1,a0
ffffffffc02009f2:	d13d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	e2bff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00005617          	auipc	a2,0x5
ffffffffc0200a00:	d2c60613          	addi	a2,a2,-724 # ffffffffc0205728 <commands+0x5d0>
ffffffffc0200a04:	0bd00593          	li	a1,189
ffffffffc0200a08:	00005517          	auipc	a0,0x5
ffffffffc0200a0c:	81050513          	addi	a0,a0,-2032 # ffffffffc0205218 <commands+0xc0>
ffffffffc0200a10:	a37ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a14:	00005517          	auipc	a0,0x5
ffffffffc0200a18:	d6450513          	addi	a0,a0,-668 # ffffffffc0205778 <commands+0x620>
ffffffffc0200a1c:	b7b9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	d7a50513          	addi	a0,a0,-646 # ffffffffc0205798 <commands+0x640>
ffffffffc0200a26:	b791                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a28:	00005517          	auipc	a0,0x5
ffffffffc0200a2c:	d9050513          	addi	a0,a0,-624 # ffffffffc02057b8 <commands+0x660>
ffffffffc0200a30:	bf2d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a32:	00005517          	auipc	a0,0x5
ffffffffc0200a36:	da650513          	addi	a0,a0,-602 # ffffffffc02057d8 <commands+0x680>
ffffffffc0200a3a:	bf05                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3c:	00005517          	auipc	a0,0x5
ffffffffc0200a40:	dbc50513          	addi	a0,a0,-580 # ffffffffc02057f8 <commands+0x6a0>
ffffffffc0200a44:	b71d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a46:	00005517          	auipc	a0,0x5
ffffffffc0200a4a:	dca50513          	addi	a0,a0,-566 # ffffffffc0205810 <commands+0x6b8>
ffffffffc0200a4e:	f32ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a52:	8522                	mv	a0,s0
ffffffffc0200a54:	b77ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a58:	84aa                	mv	s1,a0
ffffffffc0200a5a:	ee050fe3          	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a5e:	8522                	mv	a0,s0
ffffffffc0200a60:	dc1ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a64:	86a6                	mv	a3,s1
ffffffffc0200a66:	00005617          	auipc	a2,0x5
ffffffffc0200a6a:	cc260613          	addi	a2,a2,-830 # ffffffffc0205728 <commands+0x5d0>
ffffffffc0200a6e:	0d300593          	li	a1,211
ffffffffc0200a72:	00004517          	auipc	a0,0x4
ffffffffc0200a76:	7a650513          	addi	a0,a0,1958 # ffffffffc0205218 <commands+0xc0>
ffffffffc0200a7a:	9cdff0ef          	jal	ra,ffffffffc0200446 <__panic>
            print_trapframe(tf);
ffffffffc0200a7e:	8522                	mv	a0,s0
}
ffffffffc0200a80:	6442                	ld	s0,16(sp)
ffffffffc0200a82:	60e2                	ld	ra,24(sp)
ffffffffc0200a84:	64a2                	ld	s1,8(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a88:	bb61                	j	ffffffffc0200820 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8a:	8522                	mv	a0,s0
ffffffffc0200a8c:	d95ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a90:	86a6                	mv	a3,s1
ffffffffc0200a92:	00005617          	auipc	a2,0x5
ffffffffc0200a96:	c9660613          	addi	a2,a2,-874 # ffffffffc0205728 <commands+0x5d0>
ffffffffc0200a9a:	0da00593          	li	a1,218
ffffffffc0200a9e:	00004517          	auipc	a0,0x4
ffffffffc0200aa2:	77a50513          	addi	a0,a0,1914 # ffffffffc0205218 <commands+0xc0>
ffffffffc0200aa6:	9a1ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200aaa <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aaa:	11853783          	ld	a5,280(a0)
ffffffffc0200aae:	0007c363          	bltz	a5,ffffffffc0200ab4 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab2:	b5a5                	j	ffffffffc020091a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ab4:	b3f9                	j	ffffffffc0200882 <interrupt_handler>
	...

ffffffffc0200ab8 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ab8:	14011073          	csrw	sscratch,sp
ffffffffc0200abc:	712d                	addi	sp,sp,-288
ffffffffc0200abe:	e406                	sd	ra,8(sp)
ffffffffc0200ac0:	ec0e                	sd	gp,24(sp)
ffffffffc0200ac2:	f012                	sd	tp,32(sp)
ffffffffc0200ac4:	f416                	sd	t0,40(sp)
ffffffffc0200ac6:	f81a                	sd	t1,48(sp)
ffffffffc0200ac8:	fc1e                	sd	t2,56(sp)
ffffffffc0200aca:	e0a2                	sd	s0,64(sp)
ffffffffc0200acc:	e4a6                	sd	s1,72(sp)
ffffffffc0200ace:	e8aa                	sd	a0,80(sp)
ffffffffc0200ad0:	ecae                	sd	a1,88(sp)
ffffffffc0200ad2:	f0b2                	sd	a2,96(sp)
ffffffffc0200ad4:	f4b6                	sd	a3,104(sp)
ffffffffc0200ad6:	f8ba                	sd	a4,112(sp)
ffffffffc0200ad8:	fcbe                	sd	a5,120(sp)
ffffffffc0200ada:	e142                	sd	a6,128(sp)
ffffffffc0200adc:	e546                	sd	a7,136(sp)
ffffffffc0200ade:	e94a                	sd	s2,144(sp)
ffffffffc0200ae0:	ed4e                	sd	s3,152(sp)
ffffffffc0200ae2:	f152                	sd	s4,160(sp)
ffffffffc0200ae4:	f556                	sd	s5,168(sp)
ffffffffc0200ae6:	f95a                	sd	s6,176(sp)
ffffffffc0200ae8:	fd5e                	sd	s7,184(sp)
ffffffffc0200aea:	e1e2                	sd	s8,192(sp)
ffffffffc0200aec:	e5e6                	sd	s9,200(sp)
ffffffffc0200aee:	e9ea                	sd	s10,208(sp)
ffffffffc0200af0:	edee                	sd	s11,216(sp)
ffffffffc0200af2:	f1f2                	sd	t3,224(sp)
ffffffffc0200af4:	f5f6                	sd	t4,232(sp)
ffffffffc0200af6:	f9fa                	sd	t5,240(sp)
ffffffffc0200af8:	fdfe                	sd	t6,248(sp)
ffffffffc0200afa:	14002473          	csrr	s0,sscratch
ffffffffc0200afe:	100024f3          	csrr	s1,sstatus
ffffffffc0200b02:	14102973          	csrr	s2,sepc
ffffffffc0200b06:	143029f3          	csrr	s3,stval
ffffffffc0200b0a:	14202a73          	csrr	s4,scause
ffffffffc0200b0e:	e822                	sd	s0,16(sp)
ffffffffc0200b10:	e226                	sd	s1,256(sp)
ffffffffc0200b12:	e64a                	sd	s2,264(sp)
ffffffffc0200b14:	ea4e                	sd	s3,272(sp)
ffffffffc0200b16:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b18:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b1a:	f91ff0ef          	jal	ra,ffffffffc0200aaa <trap>

ffffffffc0200b1e <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b1e:	6492                	ld	s1,256(sp)
ffffffffc0200b20:	6932                	ld	s2,264(sp)
ffffffffc0200b22:	10049073          	csrw	sstatus,s1
ffffffffc0200b26:	14191073          	csrw	sepc,s2
ffffffffc0200b2a:	60a2                	ld	ra,8(sp)
ffffffffc0200b2c:	61e2                	ld	gp,24(sp)
ffffffffc0200b2e:	7202                	ld	tp,32(sp)
ffffffffc0200b30:	72a2                	ld	t0,40(sp)
ffffffffc0200b32:	7342                	ld	t1,48(sp)
ffffffffc0200b34:	73e2                	ld	t2,56(sp)
ffffffffc0200b36:	6406                	ld	s0,64(sp)
ffffffffc0200b38:	64a6                	ld	s1,72(sp)
ffffffffc0200b3a:	6546                	ld	a0,80(sp)
ffffffffc0200b3c:	65e6                	ld	a1,88(sp)
ffffffffc0200b3e:	7606                	ld	a2,96(sp)
ffffffffc0200b40:	76a6                	ld	a3,104(sp)
ffffffffc0200b42:	7746                	ld	a4,112(sp)
ffffffffc0200b44:	77e6                	ld	a5,120(sp)
ffffffffc0200b46:	680a                	ld	a6,128(sp)
ffffffffc0200b48:	68aa                	ld	a7,136(sp)
ffffffffc0200b4a:	694a                	ld	s2,144(sp)
ffffffffc0200b4c:	69ea                	ld	s3,152(sp)
ffffffffc0200b4e:	7a0a                	ld	s4,160(sp)
ffffffffc0200b50:	7aaa                	ld	s5,168(sp)
ffffffffc0200b52:	7b4a                	ld	s6,176(sp)
ffffffffc0200b54:	7bea                	ld	s7,184(sp)
ffffffffc0200b56:	6c0e                	ld	s8,192(sp)
ffffffffc0200b58:	6cae                	ld	s9,200(sp)
ffffffffc0200b5a:	6d4e                	ld	s10,208(sp)
ffffffffc0200b5c:	6dee                	ld	s11,216(sp)
ffffffffc0200b5e:	7e0e                	ld	t3,224(sp)
ffffffffc0200b60:	7eae                	ld	t4,232(sp)
ffffffffc0200b62:	7f4e                	ld	t5,240(sp)
ffffffffc0200b64:	7fee                	ld	t6,248(sp)
ffffffffc0200b66:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b68:	10200073          	sret

ffffffffc0200b6c <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b6c:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b6e:	bf45                	j	ffffffffc0200b1e <__trapret>
	...

ffffffffc0200b72 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b72:	00012797          	auipc	a5,0x12
ffffffffc0200b76:	8ee78793          	addi	a5,a5,-1810 # ffffffffc0212460 <free_area>
ffffffffc0200b7a:	e79c                	sd	a5,8(a5)
ffffffffc0200b7c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b7e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b82:	8082                	ret

ffffffffc0200b84 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b84:	00012517          	auipc	a0,0x12
ffffffffc0200b88:	8ec56503          	lwu	a0,-1812(a0) # ffffffffc0212470 <free_area+0x10>
ffffffffc0200b8c:	8082                	ret

ffffffffc0200b8e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b8e:	715d                	addi	sp,sp,-80
ffffffffc0200b90:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b92:	00012417          	auipc	s0,0x12
ffffffffc0200b96:	8ce40413          	addi	s0,s0,-1842 # ffffffffc0212460 <free_area>
ffffffffc0200b9a:	641c                	ld	a5,8(s0)
ffffffffc0200b9c:	e486                	sd	ra,72(sp)
ffffffffc0200b9e:	fc26                	sd	s1,56(sp)
ffffffffc0200ba0:	f84a                	sd	s2,48(sp)
ffffffffc0200ba2:	f44e                	sd	s3,40(sp)
ffffffffc0200ba4:	f052                	sd	s4,32(sp)
ffffffffc0200ba6:	ec56                	sd	s5,24(sp)
ffffffffc0200ba8:	e85a                	sd	s6,16(sp)
ffffffffc0200baa:	e45e                	sd	s7,8(sp)
ffffffffc0200bac:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bae:	2a878d63          	beq	a5,s0,ffffffffc0200e68 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200bb2:	4481                	li	s1,0
ffffffffc0200bb4:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bb6:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bba:	8b09                	andi	a4,a4,2
ffffffffc0200bbc:	2a070a63          	beqz	a4,ffffffffc0200e70 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200bc0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bc4:	679c                	ld	a5,8(a5)
ffffffffc0200bc6:	2905                	addiw	s2,s2,1
ffffffffc0200bc8:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bca:	fe8796e3          	bne	a5,s0,ffffffffc0200bb6 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200bce:	89a6                	mv	s3,s1
ffffffffc0200bd0:	72f000ef          	jal	ra,ffffffffc0201afe <nr_free_pages>
ffffffffc0200bd4:	6f351e63          	bne	a0,s3,ffffffffc02012d0 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bd8:	4505                	li	a0,1
ffffffffc0200bda:	653000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200bde:	8aaa                	mv	s5,a0
ffffffffc0200be0:	42050863          	beqz	a0,ffffffffc0201010 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200be4:	4505                	li	a0,1
ffffffffc0200be6:	647000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200bea:	89aa                	mv	s3,a0
ffffffffc0200bec:	70050263          	beqz	a0,ffffffffc02012f0 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bf0:	4505                	li	a0,1
ffffffffc0200bf2:	63b000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200bf6:	8a2a                	mv	s4,a0
ffffffffc0200bf8:	48050c63          	beqz	a0,ffffffffc0201090 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bfc:	293a8a63          	beq	s5,s3,ffffffffc0200e90 <default_check+0x302>
ffffffffc0200c00:	28aa8863          	beq	s5,a0,ffffffffc0200e90 <default_check+0x302>
ffffffffc0200c04:	28a98663          	beq	s3,a0,ffffffffc0200e90 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c08:	000aa783          	lw	a5,0(s5)
ffffffffc0200c0c:	2a079263          	bnez	a5,ffffffffc0200eb0 <default_check+0x322>
ffffffffc0200c10:	0009a783          	lw	a5,0(s3)
ffffffffc0200c14:	28079e63          	bnez	a5,ffffffffc0200eb0 <default_check+0x322>
ffffffffc0200c18:	411c                	lw	a5,0(a0)
ffffffffc0200c1a:	28079b63          	bnez	a5,ffffffffc0200eb0 <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c1e:	00016797          	auipc	a5,0x16
ffffffffc0200c22:	9527b783          	ld	a5,-1710(a5) # ffffffffc0216570 <pages>
ffffffffc0200c26:	40fa8733          	sub	a4,s5,a5
ffffffffc0200c2a:	00006617          	auipc	a2,0x6
ffffffffc0200c2e:	3ee63603          	ld	a2,1006(a2) # ffffffffc0207018 <nbase>
ffffffffc0200c32:	8719                	srai	a4,a4,0x6
ffffffffc0200c34:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c36:	00016697          	auipc	a3,0x16
ffffffffc0200c3a:	9326b683          	ld	a3,-1742(a3) # ffffffffc0216568 <npage>
ffffffffc0200c3e:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c40:	0732                	slli	a4,a4,0xc
ffffffffc0200c42:	28d77763          	bgeu	a4,a3,ffffffffc0200ed0 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200c46:	40f98733          	sub	a4,s3,a5
ffffffffc0200c4a:	8719                	srai	a4,a4,0x6
ffffffffc0200c4c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c4e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c50:	4cd77063          	bgeu	a4,a3,ffffffffc0201110 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200c54:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c58:	8799                	srai	a5,a5,0x6
ffffffffc0200c5a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c5c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c5e:	30d7f963          	bgeu	a5,a3,ffffffffc0200f70 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200c62:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c64:	00043c03          	ld	s8,0(s0)
ffffffffc0200c68:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c6c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c70:	e400                	sd	s0,8(s0)
ffffffffc0200c72:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200c74:	00011797          	auipc	a5,0x11
ffffffffc0200c78:	7e07ae23          	sw	zero,2044(a5) # ffffffffc0212470 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c7c:	5b1000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200c80:	2c051863          	bnez	a0,ffffffffc0200f50 <default_check+0x3c2>
    free_page(p0);
ffffffffc0200c84:	4585                	li	a1,1
ffffffffc0200c86:	8556                	mv	a0,s5
ffffffffc0200c88:	637000ef          	jal	ra,ffffffffc0201abe <free_pages>
    free_page(p1);
ffffffffc0200c8c:	4585                	li	a1,1
ffffffffc0200c8e:	854e                	mv	a0,s3
ffffffffc0200c90:	62f000ef          	jal	ra,ffffffffc0201abe <free_pages>
    free_page(p2);
ffffffffc0200c94:	4585                	li	a1,1
ffffffffc0200c96:	8552                	mv	a0,s4
ffffffffc0200c98:	627000ef          	jal	ra,ffffffffc0201abe <free_pages>
    assert(nr_free == 3);
ffffffffc0200c9c:	4818                	lw	a4,16(s0)
ffffffffc0200c9e:	478d                	li	a5,3
ffffffffc0200ca0:	28f71863          	bne	a4,a5,ffffffffc0200f30 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ca4:	4505                	li	a0,1
ffffffffc0200ca6:	587000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200caa:	89aa                	mv	s3,a0
ffffffffc0200cac:	26050263          	beqz	a0,ffffffffc0200f10 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cb0:	4505                	li	a0,1
ffffffffc0200cb2:	57b000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200cb6:	8aaa                	mv	s5,a0
ffffffffc0200cb8:	3a050c63          	beqz	a0,ffffffffc0201070 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cbc:	4505                	li	a0,1
ffffffffc0200cbe:	56f000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200cc2:	8a2a                	mv	s4,a0
ffffffffc0200cc4:	38050663          	beqz	a0,ffffffffc0201050 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200cc8:	4505                	li	a0,1
ffffffffc0200cca:	563000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200cce:	36051163          	bnez	a0,ffffffffc0201030 <default_check+0x4a2>
    free_page(p0);
ffffffffc0200cd2:	4585                	li	a1,1
ffffffffc0200cd4:	854e                	mv	a0,s3
ffffffffc0200cd6:	5e9000ef          	jal	ra,ffffffffc0201abe <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200cda:	641c                	ld	a5,8(s0)
ffffffffc0200cdc:	20878a63          	beq	a5,s0,ffffffffc0200ef0 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200ce0:	4505                	li	a0,1
ffffffffc0200ce2:	54b000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200ce6:	30a99563          	bne	s3,a0,ffffffffc0200ff0 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200cea:	4505                	li	a0,1
ffffffffc0200cec:	541000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200cf0:	2e051063          	bnez	a0,ffffffffc0200fd0 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200cf4:	481c                	lw	a5,16(s0)
ffffffffc0200cf6:	2a079d63          	bnez	a5,ffffffffc0200fb0 <default_check+0x422>
    free_page(p);
ffffffffc0200cfa:	854e                	mv	a0,s3
ffffffffc0200cfc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cfe:	01843023          	sd	s8,0(s0)
ffffffffc0200d02:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200d06:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200d0a:	5b5000ef          	jal	ra,ffffffffc0201abe <free_pages>
    free_page(p1);
ffffffffc0200d0e:	4585                	li	a1,1
ffffffffc0200d10:	8556                	mv	a0,s5
ffffffffc0200d12:	5ad000ef          	jal	ra,ffffffffc0201abe <free_pages>
    free_page(p2);
ffffffffc0200d16:	4585                	li	a1,1
ffffffffc0200d18:	8552                	mv	a0,s4
ffffffffc0200d1a:	5a5000ef          	jal	ra,ffffffffc0201abe <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d1e:	4515                	li	a0,5
ffffffffc0200d20:	50d000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200d24:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d26:	26050563          	beqz	a0,ffffffffc0200f90 <default_check+0x402>
ffffffffc0200d2a:	651c                	ld	a5,8(a0)
ffffffffc0200d2c:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d2e:	8b85                	andi	a5,a5,1
ffffffffc0200d30:	54079063          	bnez	a5,ffffffffc0201270 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d34:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d36:	00043b03          	ld	s6,0(s0)
ffffffffc0200d3a:	00843a83          	ld	s5,8(s0)
ffffffffc0200d3e:	e000                	sd	s0,0(s0)
ffffffffc0200d40:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200d42:	4eb000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200d46:	50051563          	bnez	a0,ffffffffc0201250 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d4a:	08098a13          	addi	s4,s3,128
ffffffffc0200d4e:	8552                	mv	a0,s4
ffffffffc0200d50:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d52:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200d56:	00011797          	auipc	a5,0x11
ffffffffc0200d5a:	7007ad23          	sw	zero,1818(a5) # ffffffffc0212470 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d5e:	561000ef          	jal	ra,ffffffffc0201abe <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d62:	4511                	li	a0,4
ffffffffc0200d64:	4c9000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200d68:	4c051463          	bnez	a0,ffffffffc0201230 <default_check+0x6a2>
ffffffffc0200d6c:	0889b783          	ld	a5,136(s3)
ffffffffc0200d70:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d72:	8b85                	andi	a5,a5,1
ffffffffc0200d74:	48078e63          	beqz	a5,ffffffffc0201210 <default_check+0x682>
ffffffffc0200d78:	0909a703          	lw	a4,144(s3)
ffffffffc0200d7c:	478d                	li	a5,3
ffffffffc0200d7e:	48f71963          	bne	a4,a5,ffffffffc0201210 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d82:	450d                	li	a0,3
ffffffffc0200d84:	4a9000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200d88:	8c2a                	mv	s8,a0
ffffffffc0200d8a:	46050363          	beqz	a0,ffffffffc02011f0 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0200d8e:	4505                	li	a0,1
ffffffffc0200d90:	49d000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200d94:	42051e63          	bnez	a0,ffffffffc02011d0 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0200d98:	418a1c63          	bne	s4,s8,ffffffffc02011b0 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d9c:	4585                	li	a1,1
ffffffffc0200d9e:	854e                	mv	a0,s3
ffffffffc0200da0:	51f000ef          	jal	ra,ffffffffc0201abe <free_pages>
    free_pages(p1, 3);
ffffffffc0200da4:	458d                	li	a1,3
ffffffffc0200da6:	8552                	mv	a0,s4
ffffffffc0200da8:	517000ef          	jal	ra,ffffffffc0201abe <free_pages>
ffffffffc0200dac:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200db0:	04098c13          	addi	s8,s3,64
ffffffffc0200db4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200db6:	8b85                	andi	a5,a5,1
ffffffffc0200db8:	3c078c63          	beqz	a5,ffffffffc0201190 <default_check+0x602>
ffffffffc0200dbc:	0109a703          	lw	a4,16(s3)
ffffffffc0200dc0:	4785                	li	a5,1
ffffffffc0200dc2:	3cf71763          	bne	a4,a5,ffffffffc0201190 <default_check+0x602>
ffffffffc0200dc6:	008a3783          	ld	a5,8(s4)
ffffffffc0200dca:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200dcc:	8b85                	andi	a5,a5,1
ffffffffc0200dce:	3a078163          	beqz	a5,ffffffffc0201170 <default_check+0x5e2>
ffffffffc0200dd2:	010a2703          	lw	a4,16(s4)
ffffffffc0200dd6:	478d                	li	a5,3
ffffffffc0200dd8:	38f71c63          	bne	a4,a5,ffffffffc0201170 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200ddc:	4505                	li	a0,1
ffffffffc0200dde:	44f000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200de2:	36a99763          	bne	s3,a0,ffffffffc0201150 <default_check+0x5c2>
    free_page(p0);
ffffffffc0200de6:	4585                	li	a1,1
ffffffffc0200de8:	4d7000ef          	jal	ra,ffffffffc0201abe <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200dec:	4509                	li	a0,2
ffffffffc0200dee:	43f000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200df2:	32aa1f63          	bne	s4,a0,ffffffffc0201130 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0200df6:	4589                	li	a1,2
ffffffffc0200df8:	4c7000ef          	jal	ra,ffffffffc0201abe <free_pages>
    free_page(p2);
ffffffffc0200dfc:	4585                	li	a1,1
ffffffffc0200dfe:	8562                	mv	a0,s8
ffffffffc0200e00:	4bf000ef          	jal	ra,ffffffffc0201abe <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e04:	4515                	li	a0,5
ffffffffc0200e06:	427000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200e0a:	89aa                	mv	s3,a0
ffffffffc0200e0c:	48050263          	beqz	a0,ffffffffc0201290 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0200e10:	4505                	li	a0,1
ffffffffc0200e12:	41b000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0200e16:	2c051d63          	bnez	a0,ffffffffc02010f0 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0200e1a:	481c                	lw	a5,16(s0)
ffffffffc0200e1c:	2a079a63          	bnez	a5,ffffffffc02010d0 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e20:	4595                	li	a1,5
ffffffffc0200e22:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e24:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200e28:	01643023          	sd	s6,0(s0)
ffffffffc0200e2c:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200e30:	48f000ef          	jal	ra,ffffffffc0201abe <free_pages>
    return listelm->next;
ffffffffc0200e34:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e36:	00878963          	beq	a5,s0,ffffffffc0200e48 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e3a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e3e:	679c                	ld	a5,8(a5)
ffffffffc0200e40:	397d                	addiw	s2,s2,-1
ffffffffc0200e42:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e44:	fe879be3          	bne	a5,s0,ffffffffc0200e3a <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0200e48:	26091463          	bnez	s2,ffffffffc02010b0 <default_check+0x522>
    assert(total == 0);
ffffffffc0200e4c:	46049263          	bnez	s1,ffffffffc02012b0 <default_check+0x722>
}
ffffffffc0200e50:	60a6                	ld	ra,72(sp)
ffffffffc0200e52:	6406                	ld	s0,64(sp)
ffffffffc0200e54:	74e2                	ld	s1,56(sp)
ffffffffc0200e56:	7942                	ld	s2,48(sp)
ffffffffc0200e58:	79a2                	ld	s3,40(sp)
ffffffffc0200e5a:	7a02                	ld	s4,32(sp)
ffffffffc0200e5c:	6ae2                	ld	s5,24(sp)
ffffffffc0200e5e:	6b42                	ld	s6,16(sp)
ffffffffc0200e60:	6ba2                	ld	s7,8(sp)
ffffffffc0200e62:	6c02                	ld	s8,0(sp)
ffffffffc0200e64:	6161                	addi	sp,sp,80
ffffffffc0200e66:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e68:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e6a:	4481                	li	s1,0
ffffffffc0200e6c:	4901                	li	s2,0
ffffffffc0200e6e:	b38d                	j	ffffffffc0200bd0 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e70:	00005697          	auipc	a3,0x5
ffffffffc0200e74:	a1068693          	addi	a3,a3,-1520 # ffffffffc0205880 <commands+0x728>
ffffffffc0200e78:	00005617          	auipc	a2,0x5
ffffffffc0200e7c:	a1860613          	addi	a2,a2,-1512 # ffffffffc0205890 <commands+0x738>
ffffffffc0200e80:	0f000593          	li	a1,240
ffffffffc0200e84:	00005517          	auipc	a0,0x5
ffffffffc0200e88:	a2450513          	addi	a0,a0,-1500 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200e8c:	dbaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e90:	00005697          	auipc	a3,0x5
ffffffffc0200e94:	ab068693          	addi	a3,a3,-1360 # ffffffffc0205940 <commands+0x7e8>
ffffffffc0200e98:	00005617          	auipc	a2,0x5
ffffffffc0200e9c:	9f860613          	addi	a2,a2,-1544 # ffffffffc0205890 <commands+0x738>
ffffffffc0200ea0:	0bd00593          	li	a1,189
ffffffffc0200ea4:	00005517          	auipc	a0,0x5
ffffffffc0200ea8:	a0450513          	addi	a0,a0,-1532 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200eac:	d9aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb0:	00005697          	auipc	a3,0x5
ffffffffc0200eb4:	ab868693          	addi	a3,a3,-1352 # ffffffffc0205968 <commands+0x810>
ffffffffc0200eb8:	00005617          	auipc	a2,0x5
ffffffffc0200ebc:	9d860613          	addi	a2,a2,-1576 # ffffffffc0205890 <commands+0x738>
ffffffffc0200ec0:	0be00593          	li	a1,190
ffffffffc0200ec4:	00005517          	auipc	a0,0x5
ffffffffc0200ec8:	9e450513          	addi	a0,a0,-1564 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200ecc:	d7aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ed0:	00005697          	auipc	a3,0x5
ffffffffc0200ed4:	ad868693          	addi	a3,a3,-1320 # ffffffffc02059a8 <commands+0x850>
ffffffffc0200ed8:	00005617          	auipc	a2,0x5
ffffffffc0200edc:	9b860613          	addi	a2,a2,-1608 # ffffffffc0205890 <commands+0x738>
ffffffffc0200ee0:	0c000593          	li	a1,192
ffffffffc0200ee4:	00005517          	auipc	a0,0x5
ffffffffc0200ee8:	9c450513          	addi	a0,a0,-1596 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200eec:	d5aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ef0:	00005697          	auipc	a3,0x5
ffffffffc0200ef4:	b4068693          	addi	a3,a3,-1216 # ffffffffc0205a30 <commands+0x8d8>
ffffffffc0200ef8:	00005617          	auipc	a2,0x5
ffffffffc0200efc:	99860613          	addi	a2,a2,-1640 # ffffffffc0205890 <commands+0x738>
ffffffffc0200f00:	0d900593          	li	a1,217
ffffffffc0200f04:	00005517          	auipc	a0,0x5
ffffffffc0200f08:	9a450513          	addi	a0,a0,-1628 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200f0c:	d3aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f10:	00005697          	auipc	a3,0x5
ffffffffc0200f14:	9d068693          	addi	a3,a3,-1584 # ffffffffc02058e0 <commands+0x788>
ffffffffc0200f18:	00005617          	auipc	a2,0x5
ffffffffc0200f1c:	97860613          	addi	a2,a2,-1672 # ffffffffc0205890 <commands+0x738>
ffffffffc0200f20:	0d200593          	li	a1,210
ffffffffc0200f24:	00005517          	auipc	a0,0x5
ffffffffc0200f28:	98450513          	addi	a0,a0,-1660 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200f2c:	d1aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 3);
ffffffffc0200f30:	00005697          	auipc	a3,0x5
ffffffffc0200f34:	af068693          	addi	a3,a3,-1296 # ffffffffc0205a20 <commands+0x8c8>
ffffffffc0200f38:	00005617          	auipc	a2,0x5
ffffffffc0200f3c:	95860613          	addi	a2,a2,-1704 # ffffffffc0205890 <commands+0x738>
ffffffffc0200f40:	0d000593          	li	a1,208
ffffffffc0200f44:	00005517          	auipc	a0,0x5
ffffffffc0200f48:	96450513          	addi	a0,a0,-1692 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200f4c:	cfaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f50:	00005697          	auipc	a3,0x5
ffffffffc0200f54:	ab868693          	addi	a3,a3,-1352 # ffffffffc0205a08 <commands+0x8b0>
ffffffffc0200f58:	00005617          	auipc	a2,0x5
ffffffffc0200f5c:	93860613          	addi	a2,a2,-1736 # ffffffffc0205890 <commands+0x738>
ffffffffc0200f60:	0cb00593          	li	a1,203
ffffffffc0200f64:	00005517          	auipc	a0,0x5
ffffffffc0200f68:	94450513          	addi	a0,a0,-1724 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200f6c:	cdaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f70:	00005697          	auipc	a3,0x5
ffffffffc0200f74:	a7868693          	addi	a3,a3,-1416 # ffffffffc02059e8 <commands+0x890>
ffffffffc0200f78:	00005617          	auipc	a2,0x5
ffffffffc0200f7c:	91860613          	addi	a2,a2,-1768 # ffffffffc0205890 <commands+0x738>
ffffffffc0200f80:	0c200593          	li	a1,194
ffffffffc0200f84:	00005517          	auipc	a0,0x5
ffffffffc0200f88:	92450513          	addi	a0,a0,-1756 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200f8c:	cbaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc0200f90:	00005697          	auipc	a3,0x5
ffffffffc0200f94:	ae868693          	addi	a3,a3,-1304 # ffffffffc0205a78 <commands+0x920>
ffffffffc0200f98:	00005617          	auipc	a2,0x5
ffffffffc0200f9c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0205890 <commands+0x738>
ffffffffc0200fa0:	0f800593          	li	a1,248
ffffffffc0200fa4:	00005517          	auipc	a0,0x5
ffffffffc0200fa8:	90450513          	addi	a0,a0,-1788 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200fac:	c9aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc0200fb0:	00005697          	auipc	a3,0x5
ffffffffc0200fb4:	ab868693          	addi	a3,a3,-1352 # ffffffffc0205a68 <commands+0x910>
ffffffffc0200fb8:	00005617          	auipc	a2,0x5
ffffffffc0200fbc:	8d860613          	addi	a2,a2,-1832 # ffffffffc0205890 <commands+0x738>
ffffffffc0200fc0:	0df00593          	li	a1,223
ffffffffc0200fc4:	00005517          	auipc	a0,0x5
ffffffffc0200fc8:	8e450513          	addi	a0,a0,-1820 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200fcc:	c7aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fd0:	00005697          	auipc	a3,0x5
ffffffffc0200fd4:	a3868693          	addi	a3,a3,-1480 # ffffffffc0205a08 <commands+0x8b0>
ffffffffc0200fd8:	00005617          	auipc	a2,0x5
ffffffffc0200fdc:	8b860613          	addi	a2,a2,-1864 # ffffffffc0205890 <commands+0x738>
ffffffffc0200fe0:	0dd00593          	li	a1,221
ffffffffc0200fe4:	00005517          	auipc	a0,0x5
ffffffffc0200fe8:	8c450513          	addi	a0,a0,-1852 # ffffffffc02058a8 <commands+0x750>
ffffffffc0200fec:	c5aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ff0:	00005697          	auipc	a3,0x5
ffffffffc0200ff4:	a5868693          	addi	a3,a3,-1448 # ffffffffc0205a48 <commands+0x8f0>
ffffffffc0200ff8:	00005617          	auipc	a2,0x5
ffffffffc0200ffc:	89860613          	addi	a2,a2,-1896 # ffffffffc0205890 <commands+0x738>
ffffffffc0201000:	0dc00593          	li	a1,220
ffffffffc0201004:	00005517          	auipc	a0,0x5
ffffffffc0201008:	8a450513          	addi	a0,a0,-1884 # ffffffffc02058a8 <commands+0x750>
ffffffffc020100c:	c3aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201010:	00005697          	auipc	a3,0x5
ffffffffc0201014:	8d068693          	addi	a3,a3,-1840 # ffffffffc02058e0 <commands+0x788>
ffffffffc0201018:	00005617          	auipc	a2,0x5
ffffffffc020101c:	87860613          	addi	a2,a2,-1928 # ffffffffc0205890 <commands+0x738>
ffffffffc0201020:	0b900593          	li	a1,185
ffffffffc0201024:	00005517          	auipc	a0,0x5
ffffffffc0201028:	88450513          	addi	a0,a0,-1916 # ffffffffc02058a8 <commands+0x750>
ffffffffc020102c:	c1aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201030:	00005697          	auipc	a3,0x5
ffffffffc0201034:	9d868693          	addi	a3,a3,-1576 # ffffffffc0205a08 <commands+0x8b0>
ffffffffc0201038:	00005617          	auipc	a2,0x5
ffffffffc020103c:	85860613          	addi	a2,a2,-1960 # ffffffffc0205890 <commands+0x738>
ffffffffc0201040:	0d600593          	li	a1,214
ffffffffc0201044:	00005517          	auipc	a0,0x5
ffffffffc0201048:	86450513          	addi	a0,a0,-1948 # ffffffffc02058a8 <commands+0x750>
ffffffffc020104c:	bfaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201050:	00005697          	auipc	a3,0x5
ffffffffc0201054:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205920 <commands+0x7c8>
ffffffffc0201058:	00005617          	auipc	a2,0x5
ffffffffc020105c:	83860613          	addi	a2,a2,-1992 # ffffffffc0205890 <commands+0x738>
ffffffffc0201060:	0d400593          	li	a1,212
ffffffffc0201064:	00005517          	auipc	a0,0x5
ffffffffc0201068:	84450513          	addi	a0,a0,-1980 # ffffffffc02058a8 <commands+0x750>
ffffffffc020106c:	bdaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201070:	00005697          	auipc	a3,0x5
ffffffffc0201074:	89068693          	addi	a3,a3,-1904 # ffffffffc0205900 <commands+0x7a8>
ffffffffc0201078:	00005617          	auipc	a2,0x5
ffffffffc020107c:	81860613          	addi	a2,a2,-2024 # ffffffffc0205890 <commands+0x738>
ffffffffc0201080:	0d300593          	li	a1,211
ffffffffc0201084:	00005517          	auipc	a0,0x5
ffffffffc0201088:	82450513          	addi	a0,a0,-2012 # ffffffffc02058a8 <commands+0x750>
ffffffffc020108c:	bbaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201090:	00005697          	auipc	a3,0x5
ffffffffc0201094:	89068693          	addi	a3,a3,-1904 # ffffffffc0205920 <commands+0x7c8>
ffffffffc0201098:	00004617          	auipc	a2,0x4
ffffffffc020109c:	7f860613          	addi	a2,a2,2040 # ffffffffc0205890 <commands+0x738>
ffffffffc02010a0:	0bb00593          	li	a1,187
ffffffffc02010a4:	00005517          	auipc	a0,0x5
ffffffffc02010a8:	80450513          	addi	a0,a0,-2044 # ffffffffc02058a8 <commands+0x750>
ffffffffc02010ac:	b9aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(count == 0);
ffffffffc02010b0:	00005697          	auipc	a3,0x5
ffffffffc02010b4:	b1868693          	addi	a3,a3,-1256 # ffffffffc0205bc8 <commands+0xa70>
ffffffffc02010b8:	00004617          	auipc	a2,0x4
ffffffffc02010bc:	7d860613          	addi	a2,a2,2008 # ffffffffc0205890 <commands+0x738>
ffffffffc02010c0:	12500593          	li	a1,293
ffffffffc02010c4:	00004517          	auipc	a0,0x4
ffffffffc02010c8:	7e450513          	addi	a0,a0,2020 # ffffffffc02058a8 <commands+0x750>
ffffffffc02010cc:	b7aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc02010d0:	00005697          	auipc	a3,0x5
ffffffffc02010d4:	99868693          	addi	a3,a3,-1640 # ffffffffc0205a68 <commands+0x910>
ffffffffc02010d8:	00004617          	auipc	a2,0x4
ffffffffc02010dc:	7b860613          	addi	a2,a2,1976 # ffffffffc0205890 <commands+0x738>
ffffffffc02010e0:	11a00593          	li	a1,282
ffffffffc02010e4:	00004517          	auipc	a0,0x4
ffffffffc02010e8:	7c450513          	addi	a0,a0,1988 # ffffffffc02058a8 <commands+0x750>
ffffffffc02010ec:	b5aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010f0:	00005697          	auipc	a3,0x5
ffffffffc02010f4:	91868693          	addi	a3,a3,-1768 # ffffffffc0205a08 <commands+0x8b0>
ffffffffc02010f8:	00004617          	auipc	a2,0x4
ffffffffc02010fc:	79860613          	addi	a2,a2,1944 # ffffffffc0205890 <commands+0x738>
ffffffffc0201100:	11800593          	li	a1,280
ffffffffc0201104:	00004517          	auipc	a0,0x4
ffffffffc0201108:	7a450513          	addi	a0,a0,1956 # ffffffffc02058a8 <commands+0x750>
ffffffffc020110c:	b3aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201110:	00005697          	auipc	a3,0x5
ffffffffc0201114:	8b868693          	addi	a3,a3,-1864 # ffffffffc02059c8 <commands+0x870>
ffffffffc0201118:	00004617          	auipc	a2,0x4
ffffffffc020111c:	77860613          	addi	a2,a2,1912 # ffffffffc0205890 <commands+0x738>
ffffffffc0201120:	0c100593          	li	a1,193
ffffffffc0201124:	00004517          	auipc	a0,0x4
ffffffffc0201128:	78450513          	addi	a0,a0,1924 # ffffffffc02058a8 <commands+0x750>
ffffffffc020112c:	b1aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201130:	00005697          	auipc	a3,0x5
ffffffffc0201134:	a5868693          	addi	a3,a3,-1448 # ffffffffc0205b88 <commands+0xa30>
ffffffffc0201138:	00004617          	auipc	a2,0x4
ffffffffc020113c:	75860613          	addi	a2,a2,1880 # ffffffffc0205890 <commands+0x738>
ffffffffc0201140:	11200593          	li	a1,274
ffffffffc0201144:	00004517          	auipc	a0,0x4
ffffffffc0201148:	76450513          	addi	a0,a0,1892 # ffffffffc02058a8 <commands+0x750>
ffffffffc020114c:	afaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201150:	00005697          	auipc	a3,0x5
ffffffffc0201154:	a1868693          	addi	a3,a3,-1512 # ffffffffc0205b68 <commands+0xa10>
ffffffffc0201158:	00004617          	auipc	a2,0x4
ffffffffc020115c:	73860613          	addi	a2,a2,1848 # ffffffffc0205890 <commands+0x738>
ffffffffc0201160:	11000593          	li	a1,272
ffffffffc0201164:	00004517          	auipc	a0,0x4
ffffffffc0201168:	74450513          	addi	a0,a0,1860 # ffffffffc02058a8 <commands+0x750>
ffffffffc020116c:	adaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201170:	00005697          	auipc	a3,0x5
ffffffffc0201174:	9d068693          	addi	a3,a3,-1584 # ffffffffc0205b40 <commands+0x9e8>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	71860613          	addi	a2,a2,1816 # ffffffffc0205890 <commands+0x738>
ffffffffc0201180:	10e00593          	li	a1,270
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	72450513          	addi	a0,a0,1828 # ffffffffc02058a8 <commands+0x750>
ffffffffc020118c:	abaff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201190:	00005697          	auipc	a3,0x5
ffffffffc0201194:	98868693          	addi	a3,a3,-1656 # ffffffffc0205b18 <commands+0x9c0>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	6f860613          	addi	a2,a2,1784 # ffffffffc0205890 <commands+0x738>
ffffffffc02011a0:	10d00593          	li	a1,269
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	70450513          	addi	a0,a0,1796 # ffffffffc02058a8 <commands+0x750>
ffffffffc02011ac:	a9aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011b0:	00005697          	auipc	a3,0x5
ffffffffc02011b4:	95868693          	addi	a3,a3,-1704 # ffffffffc0205b08 <commands+0x9b0>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	6d860613          	addi	a2,a2,1752 # ffffffffc0205890 <commands+0x738>
ffffffffc02011c0:	10800593          	li	a1,264
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	6e450513          	addi	a0,a0,1764 # ffffffffc02058a8 <commands+0x750>
ffffffffc02011cc:	a7aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d0:	00005697          	auipc	a3,0x5
ffffffffc02011d4:	83868693          	addi	a3,a3,-1992 # ffffffffc0205a08 <commands+0x8b0>
ffffffffc02011d8:	00004617          	auipc	a2,0x4
ffffffffc02011dc:	6b860613          	addi	a2,a2,1720 # ffffffffc0205890 <commands+0x738>
ffffffffc02011e0:	10700593          	li	a1,263
ffffffffc02011e4:	00004517          	auipc	a0,0x4
ffffffffc02011e8:	6c450513          	addi	a0,a0,1732 # ffffffffc02058a8 <commands+0x750>
ffffffffc02011ec:	a5aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011f0:	00005697          	auipc	a3,0x5
ffffffffc02011f4:	8f868693          	addi	a3,a3,-1800 # ffffffffc0205ae8 <commands+0x990>
ffffffffc02011f8:	00004617          	auipc	a2,0x4
ffffffffc02011fc:	69860613          	addi	a2,a2,1688 # ffffffffc0205890 <commands+0x738>
ffffffffc0201200:	10600593          	li	a1,262
ffffffffc0201204:	00004517          	auipc	a0,0x4
ffffffffc0201208:	6a450513          	addi	a0,a0,1700 # ffffffffc02058a8 <commands+0x750>
ffffffffc020120c:	a3aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201210:	00005697          	auipc	a3,0x5
ffffffffc0201214:	8a868693          	addi	a3,a3,-1880 # ffffffffc0205ab8 <commands+0x960>
ffffffffc0201218:	00004617          	auipc	a2,0x4
ffffffffc020121c:	67860613          	addi	a2,a2,1656 # ffffffffc0205890 <commands+0x738>
ffffffffc0201220:	10500593          	li	a1,261
ffffffffc0201224:	00004517          	auipc	a0,0x4
ffffffffc0201228:	68450513          	addi	a0,a0,1668 # ffffffffc02058a8 <commands+0x750>
ffffffffc020122c:	a1aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201230:	00005697          	auipc	a3,0x5
ffffffffc0201234:	87068693          	addi	a3,a3,-1936 # ffffffffc0205aa0 <commands+0x948>
ffffffffc0201238:	00004617          	auipc	a2,0x4
ffffffffc020123c:	65860613          	addi	a2,a2,1624 # ffffffffc0205890 <commands+0x738>
ffffffffc0201240:	10400593          	li	a1,260
ffffffffc0201244:	00004517          	auipc	a0,0x4
ffffffffc0201248:	66450513          	addi	a0,a0,1636 # ffffffffc02058a8 <commands+0x750>
ffffffffc020124c:	9faff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201250:	00004697          	auipc	a3,0x4
ffffffffc0201254:	7b868693          	addi	a3,a3,1976 # ffffffffc0205a08 <commands+0x8b0>
ffffffffc0201258:	00004617          	auipc	a2,0x4
ffffffffc020125c:	63860613          	addi	a2,a2,1592 # ffffffffc0205890 <commands+0x738>
ffffffffc0201260:	0fe00593          	li	a1,254
ffffffffc0201264:	00004517          	auipc	a0,0x4
ffffffffc0201268:	64450513          	addi	a0,a0,1604 # ffffffffc02058a8 <commands+0x750>
ffffffffc020126c:	9daff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201270:	00005697          	auipc	a3,0x5
ffffffffc0201274:	81868693          	addi	a3,a3,-2024 # ffffffffc0205a88 <commands+0x930>
ffffffffc0201278:	00004617          	auipc	a2,0x4
ffffffffc020127c:	61860613          	addi	a2,a2,1560 # ffffffffc0205890 <commands+0x738>
ffffffffc0201280:	0f900593          	li	a1,249
ffffffffc0201284:	00004517          	auipc	a0,0x4
ffffffffc0201288:	62450513          	addi	a0,a0,1572 # ffffffffc02058a8 <commands+0x750>
ffffffffc020128c:	9baff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201290:	00005697          	auipc	a3,0x5
ffffffffc0201294:	91868693          	addi	a3,a3,-1768 # ffffffffc0205ba8 <commands+0xa50>
ffffffffc0201298:	00004617          	auipc	a2,0x4
ffffffffc020129c:	5f860613          	addi	a2,a2,1528 # ffffffffc0205890 <commands+0x738>
ffffffffc02012a0:	11700593          	li	a1,279
ffffffffc02012a4:	00004517          	auipc	a0,0x4
ffffffffc02012a8:	60450513          	addi	a0,a0,1540 # ffffffffc02058a8 <commands+0x750>
ffffffffc02012ac:	99aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == 0);
ffffffffc02012b0:	00005697          	auipc	a3,0x5
ffffffffc02012b4:	92868693          	addi	a3,a3,-1752 # ffffffffc0205bd8 <commands+0xa80>
ffffffffc02012b8:	00004617          	auipc	a2,0x4
ffffffffc02012bc:	5d860613          	addi	a2,a2,1496 # ffffffffc0205890 <commands+0x738>
ffffffffc02012c0:	12600593          	li	a1,294
ffffffffc02012c4:	00004517          	auipc	a0,0x4
ffffffffc02012c8:	5e450513          	addi	a0,a0,1508 # ffffffffc02058a8 <commands+0x750>
ffffffffc02012cc:	97aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012d0:	00004697          	auipc	a3,0x4
ffffffffc02012d4:	5f068693          	addi	a3,a3,1520 # ffffffffc02058c0 <commands+0x768>
ffffffffc02012d8:	00004617          	auipc	a2,0x4
ffffffffc02012dc:	5b860613          	addi	a2,a2,1464 # ffffffffc0205890 <commands+0x738>
ffffffffc02012e0:	0f300593          	li	a1,243
ffffffffc02012e4:	00004517          	auipc	a0,0x4
ffffffffc02012e8:	5c450513          	addi	a0,a0,1476 # ffffffffc02058a8 <commands+0x750>
ffffffffc02012ec:	95aff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012f0:	00004697          	auipc	a3,0x4
ffffffffc02012f4:	61068693          	addi	a3,a3,1552 # ffffffffc0205900 <commands+0x7a8>
ffffffffc02012f8:	00004617          	auipc	a2,0x4
ffffffffc02012fc:	59860613          	addi	a2,a2,1432 # ffffffffc0205890 <commands+0x738>
ffffffffc0201300:	0ba00593          	li	a1,186
ffffffffc0201304:	00004517          	auipc	a0,0x4
ffffffffc0201308:	5a450513          	addi	a0,a0,1444 # ffffffffc02058a8 <commands+0x750>
ffffffffc020130c:	93aff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201310 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201310:	1141                	addi	sp,sp,-16
ffffffffc0201312:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201314:	14058463          	beqz	a1,ffffffffc020145c <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0201318:	00659693          	slli	a3,a1,0x6
ffffffffc020131c:	96aa                	add	a3,a3,a0
ffffffffc020131e:	87aa                	mv	a5,a0
ffffffffc0201320:	02d50263          	beq	a0,a3,ffffffffc0201344 <default_free_pages+0x34>
ffffffffc0201324:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201326:	8b05                	andi	a4,a4,1
ffffffffc0201328:	10071a63          	bnez	a4,ffffffffc020143c <default_free_pages+0x12c>
ffffffffc020132c:	6798                	ld	a4,8(a5)
ffffffffc020132e:	8b09                	andi	a4,a4,2
ffffffffc0201330:	10071663          	bnez	a4,ffffffffc020143c <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201334:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201338:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020133c:	04078793          	addi	a5,a5,64
ffffffffc0201340:	fed792e3          	bne	a5,a3,ffffffffc0201324 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201344:	2581                	sext.w	a1,a1
ffffffffc0201346:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201348:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020134c:	4789                	li	a5,2
ffffffffc020134e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201352:	00011697          	auipc	a3,0x11
ffffffffc0201356:	10e68693          	addi	a3,a3,270 # ffffffffc0212460 <free_area>
ffffffffc020135a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020135c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020135e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201362:	9db9                	addw	a1,a1,a4
ffffffffc0201364:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201366:	0ad78463          	beq	a5,a3,ffffffffc020140e <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc020136a:	fe878713          	addi	a4,a5,-24
ffffffffc020136e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201372:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201374:	00e56a63          	bltu	a0,a4,ffffffffc0201388 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201378:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020137a:	04d70c63          	beq	a4,a3,ffffffffc02013d2 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020137e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201380:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201384:	fee57ae3          	bgeu	a0,a4,ffffffffc0201378 <default_free_pages+0x68>
ffffffffc0201388:	c199                	beqz	a1,ffffffffc020138e <default_free_pages+0x7e>
ffffffffc020138a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020138e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201390:	e390                	sd	a2,0(a5)
ffffffffc0201392:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201394:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201396:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201398:	00d70d63          	beq	a4,a3,ffffffffc02013b2 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020139c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc02013a0:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc02013a4:	02059813          	slli	a6,a1,0x20
ffffffffc02013a8:	01a85793          	srli	a5,a6,0x1a
ffffffffc02013ac:	97b2                	add	a5,a5,a2
ffffffffc02013ae:	02f50c63          	beq	a0,a5,ffffffffc02013e6 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02013b2:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02013b4:	00d78c63          	beq	a5,a3,ffffffffc02013cc <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02013b8:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02013ba:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02013be:	02061593          	slli	a1,a2,0x20
ffffffffc02013c2:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02013c6:	972a                	add	a4,a4,a0
ffffffffc02013c8:	04e68a63          	beq	a3,a4,ffffffffc020141c <default_free_pages+0x10c>
}
ffffffffc02013cc:	60a2                	ld	ra,8(sp)
ffffffffc02013ce:	0141                	addi	sp,sp,16
ffffffffc02013d0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02013d2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013d4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02013d6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013d8:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013da:	02d70763          	beq	a4,a3,ffffffffc0201408 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02013de:	8832                	mv	a6,a2
ffffffffc02013e0:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02013e2:	87ba                	mv	a5,a4
ffffffffc02013e4:	bf71                	j	ffffffffc0201380 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02013e6:	491c                	lw	a5,16(a0)
ffffffffc02013e8:	9dbd                	addw	a1,a1,a5
ffffffffc02013ea:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013ee:	57f5                	li	a5,-3
ffffffffc02013f0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013f4:	01853803          	ld	a6,24(a0)
ffffffffc02013f8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02013fa:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013fc:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201400:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201402:	0105b023          	sd	a6,0(a1)
ffffffffc0201406:	b77d                	j	ffffffffc02013b4 <default_free_pages+0xa4>
ffffffffc0201408:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020140a:	873e                	mv	a4,a5
ffffffffc020140c:	bf41                	j	ffffffffc020139c <default_free_pages+0x8c>
}
ffffffffc020140e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201410:	e390                	sd	a2,0(a5)
ffffffffc0201412:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201414:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201416:	ed1c                	sd	a5,24(a0)
ffffffffc0201418:	0141                	addi	sp,sp,16
ffffffffc020141a:	8082                	ret
            base->property += p->property;
ffffffffc020141c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201420:	ff078693          	addi	a3,a5,-16
ffffffffc0201424:	9e39                	addw	a2,a2,a4
ffffffffc0201426:	c910                	sw	a2,16(a0)
ffffffffc0201428:	5775                	li	a4,-3
ffffffffc020142a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020142e:	6398                	ld	a4,0(a5)
ffffffffc0201430:	679c                	ld	a5,8(a5)
}
ffffffffc0201432:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201434:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201436:	e398                	sd	a4,0(a5)
ffffffffc0201438:	0141                	addi	sp,sp,16
ffffffffc020143a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020143c:	00004697          	auipc	a3,0x4
ffffffffc0201440:	7b468693          	addi	a3,a3,1972 # ffffffffc0205bf0 <commands+0xa98>
ffffffffc0201444:	00004617          	auipc	a2,0x4
ffffffffc0201448:	44c60613          	addi	a2,a2,1100 # ffffffffc0205890 <commands+0x738>
ffffffffc020144c:	08300593          	li	a1,131
ffffffffc0201450:	00004517          	auipc	a0,0x4
ffffffffc0201454:	45850513          	addi	a0,a0,1112 # ffffffffc02058a8 <commands+0x750>
ffffffffc0201458:	feffe0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc020145c:	00004697          	auipc	a3,0x4
ffffffffc0201460:	78c68693          	addi	a3,a3,1932 # ffffffffc0205be8 <commands+0xa90>
ffffffffc0201464:	00004617          	auipc	a2,0x4
ffffffffc0201468:	42c60613          	addi	a2,a2,1068 # ffffffffc0205890 <commands+0x738>
ffffffffc020146c:	08000593          	li	a1,128
ffffffffc0201470:	00004517          	auipc	a0,0x4
ffffffffc0201474:	43850513          	addi	a0,a0,1080 # ffffffffc02058a8 <commands+0x750>
ffffffffc0201478:	fcffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020147c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020147c:	c941                	beqz	a0,ffffffffc020150c <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020147e:	00011597          	auipc	a1,0x11
ffffffffc0201482:	fe258593          	addi	a1,a1,-30 # ffffffffc0212460 <free_area>
ffffffffc0201486:	0105a803          	lw	a6,16(a1)
ffffffffc020148a:	872a                	mv	a4,a0
ffffffffc020148c:	02081793          	slli	a5,a6,0x20
ffffffffc0201490:	9381                	srli	a5,a5,0x20
ffffffffc0201492:	00a7ee63          	bltu	a5,a0,ffffffffc02014ae <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201496:	87ae                	mv	a5,a1
ffffffffc0201498:	a801                	j	ffffffffc02014a8 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020149a:	ff87a683          	lw	a3,-8(a5)
ffffffffc020149e:	02069613          	slli	a2,a3,0x20
ffffffffc02014a2:	9201                	srli	a2,a2,0x20
ffffffffc02014a4:	00e67763          	bgeu	a2,a4,ffffffffc02014b2 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014a8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014aa:	feb798e3          	bne	a5,a1,ffffffffc020149a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014ae:	4501                	li	a0,0
}
ffffffffc02014b0:	8082                	ret
    return listelm->prev;
ffffffffc02014b2:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014b6:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02014ba:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02014be:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc02014c2:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014c6:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014ca:	02c77863          	bgeu	a4,a2,ffffffffc02014fa <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02014ce:	071a                	slli	a4,a4,0x6
ffffffffc02014d0:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02014d2:	41c686bb          	subw	a3,a3,t3
ffffffffc02014d6:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014d8:	00870613          	addi	a2,a4,8
ffffffffc02014dc:	4689                	li	a3,2
ffffffffc02014de:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014e2:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014e6:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02014ea:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02014ee:	e290                	sd	a2,0(a3)
ffffffffc02014f0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02014f4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02014f6:	01173c23          	sd	a7,24(a4)
ffffffffc02014fa:	41c8083b          	subw	a6,a6,t3
ffffffffc02014fe:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201502:	5775                	li	a4,-3
ffffffffc0201504:	17c1                	addi	a5,a5,-16
ffffffffc0201506:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020150a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020150c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020150e:	00004697          	auipc	a3,0x4
ffffffffc0201512:	6da68693          	addi	a3,a3,1754 # ffffffffc0205be8 <commands+0xa90>
ffffffffc0201516:	00004617          	auipc	a2,0x4
ffffffffc020151a:	37a60613          	addi	a2,a2,890 # ffffffffc0205890 <commands+0x738>
ffffffffc020151e:	06200593          	li	a1,98
ffffffffc0201522:	00004517          	auipc	a0,0x4
ffffffffc0201526:	38650513          	addi	a0,a0,902 # ffffffffc02058a8 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc020152a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020152c:	f1bfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201530 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201530:	1141                	addi	sp,sp,-16
ffffffffc0201532:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201534:	c5f1                	beqz	a1,ffffffffc0201600 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0201536:	00659693          	slli	a3,a1,0x6
ffffffffc020153a:	96aa                	add	a3,a3,a0
ffffffffc020153c:	87aa                	mv	a5,a0
ffffffffc020153e:	00d50f63          	beq	a0,a3,ffffffffc020155c <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201542:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201544:	8b05                	andi	a4,a4,1
ffffffffc0201546:	cf49                	beqz	a4,ffffffffc02015e0 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201548:	0007a823          	sw	zero,16(a5)
ffffffffc020154c:	0007b423          	sd	zero,8(a5)
ffffffffc0201550:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201554:	04078793          	addi	a5,a5,64
ffffffffc0201558:	fed795e3          	bne	a5,a3,ffffffffc0201542 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020155c:	2581                	sext.w	a1,a1
ffffffffc020155e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201560:	4789                	li	a5,2
ffffffffc0201562:	00850713          	addi	a4,a0,8
ffffffffc0201566:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020156a:	00011697          	auipc	a3,0x11
ffffffffc020156e:	ef668693          	addi	a3,a3,-266 # ffffffffc0212460 <free_area>
ffffffffc0201572:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201574:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201576:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020157a:	9db9                	addw	a1,a1,a4
ffffffffc020157c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020157e:	04d78a63          	beq	a5,a3,ffffffffc02015d2 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0201582:	fe878713          	addi	a4,a5,-24
ffffffffc0201586:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020158a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020158c:	00e56a63          	bltu	a0,a4,ffffffffc02015a0 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201590:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201592:	02d70263          	beq	a4,a3,ffffffffc02015b6 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201596:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201598:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020159c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201590 <default_init_memmap+0x60>
ffffffffc02015a0:	c199                	beqz	a1,ffffffffc02015a6 <default_init_memmap+0x76>
ffffffffc02015a2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015a6:	6398                	ld	a4,0(a5)
}
ffffffffc02015a8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015aa:	e390                	sd	a2,0(a5)
ffffffffc02015ac:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015ae:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015b0:	ed18                	sd	a4,24(a0)
ffffffffc02015b2:	0141                	addi	sp,sp,16
ffffffffc02015b4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015b6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015b8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02015ba:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015bc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015be:	00d70663          	beq	a4,a3,ffffffffc02015ca <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02015c2:	8832                	mv	a6,a2
ffffffffc02015c4:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02015c6:	87ba                	mv	a5,a4
ffffffffc02015c8:	bfc1                	j	ffffffffc0201598 <default_init_memmap+0x68>
}
ffffffffc02015ca:	60a2                	ld	ra,8(sp)
ffffffffc02015cc:	e290                	sd	a2,0(a3)
ffffffffc02015ce:	0141                	addi	sp,sp,16
ffffffffc02015d0:	8082                	ret
ffffffffc02015d2:	60a2                	ld	ra,8(sp)
ffffffffc02015d4:	e390                	sd	a2,0(a5)
ffffffffc02015d6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015d8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015da:	ed1c                	sd	a5,24(a0)
ffffffffc02015dc:	0141                	addi	sp,sp,16
ffffffffc02015de:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015e0:	00004697          	auipc	a3,0x4
ffffffffc02015e4:	63868693          	addi	a3,a3,1592 # ffffffffc0205c18 <commands+0xac0>
ffffffffc02015e8:	00004617          	auipc	a2,0x4
ffffffffc02015ec:	2a860613          	addi	a2,a2,680 # ffffffffc0205890 <commands+0x738>
ffffffffc02015f0:	04900593          	li	a1,73
ffffffffc02015f4:	00004517          	auipc	a0,0x4
ffffffffc02015f8:	2b450513          	addi	a0,a0,692 # ffffffffc02058a8 <commands+0x750>
ffffffffc02015fc:	e4bfe0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0201600:	00004697          	auipc	a3,0x4
ffffffffc0201604:	5e868693          	addi	a3,a3,1512 # ffffffffc0205be8 <commands+0xa90>
ffffffffc0201608:	00004617          	auipc	a2,0x4
ffffffffc020160c:	28860613          	addi	a2,a2,648 # ffffffffc0205890 <commands+0x738>
ffffffffc0201610:	04600593          	li	a1,70
ffffffffc0201614:	00004517          	auipc	a0,0x4
ffffffffc0201618:	29450513          	addi	a0,a0,660 # ffffffffc02058a8 <commands+0x750>
ffffffffc020161c:	e2bfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201620 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201620:	c94d                	beqz	a0,ffffffffc02016d2 <slob_free+0xb2>
{
ffffffffc0201622:	1141                	addi	sp,sp,-16
ffffffffc0201624:	e022                	sd	s0,0(sp)
ffffffffc0201626:	e406                	sd	ra,8(sp)
ffffffffc0201628:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc020162a:	e9c1                	bnez	a1,ffffffffc02016ba <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020162c:	100027f3          	csrr	a5,sstatus
ffffffffc0201630:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201632:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201634:	ebd9                	bnez	a5,ffffffffc02016ca <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201636:	0000a617          	auipc	a2,0xa
ffffffffc020163a:	a1a60613          	addi	a2,a2,-1510 # ffffffffc020b050 <slobfree>
ffffffffc020163e:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201640:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201642:	679c                	ld	a5,8(a5)
ffffffffc0201644:	02877a63          	bgeu	a4,s0,ffffffffc0201678 <slob_free+0x58>
ffffffffc0201648:	00f46463          	bltu	s0,a5,ffffffffc0201650 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020164c:	fef76ae3          	bltu	a4,a5,ffffffffc0201640 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201650:	400c                	lw	a1,0(s0)
ffffffffc0201652:	00459693          	slli	a3,a1,0x4
ffffffffc0201656:	96a2                	add	a3,a3,s0
ffffffffc0201658:	02d78a63          	beq	a5,a3,ffffffffc020168c <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020165c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020165e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201660:	00469793          	slli	a5,a3,0x4
ffffffffc0201664:	97ba                	add	a5,a5,a4
ffffffffc0201666:	02f40e63          	beq	s0,a5,ffffffffc02016a2 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020166a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020166c:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020166e:	e129                	bnez	a0,ffffffffc02016b0 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201670:	60a2                	ld	ra,8(sp)
ffffffffc0201672:	6402                	ld	s0,0(sp)
ffffffffc0201674:	0141                	addi	sp,sp,16
ffffffffc0201676:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201678:	fcf764e3          	bltu	a4,a5,ffffffffc0201640 <slob_free+0x20>
ffffffffc020167c:	fcf472e3          	bgeu	s0,a5,ffffffffc0201640 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201680:	400c                	lw	a1,0(s0)
ffffffffc0201682:	00459693          	slli	a3,a1,0x4
ffffffffc0201686:	96a2                	add	a3,a3,s0
ffffffffc0201688:	fcd79ae3          	bne	a5,a3,ffffffffc020165c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020168c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020168e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201690:	9db5                	addw	a1,a1,a3
ffffffffc0201692:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201694:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201696:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201698:	00469793          	slli	a5,a3,0x4
ffffffffc020169c:	97ba                	add	a5,a5,a4
ffffffffc020169e:	fcf416e3          	bne	s0,a5,ffffffffc020166a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02016a2:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02016a4:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc02016a6:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02016a8:	9ebd                	addw	a3,a3,a5
ffffffffc02016aa:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02016ac:	e70c                	sd	a1,8(a4)
ffffffffc02016ae:	d169                	beqz	a0,ffffffffc0201670 <slob_free+0x50>
}
ffffffffc02016b0:	6402                	ld	s0,0(sp)
ffffffffc02016b2:	60a2                	ld	ra,8(sp)
ffffffffc02016b4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02016b6:	f07fe06f          	j	ffffffffc02005bc <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02016ba:	25bd                	addiw	a1,a1,15
ffffffffc02016bc:	8191                	srli	a1,a1,0x4
ffffffffc02016be:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c0:	100027f3          	csrr	a5,sstatus
ffffffffc02016c4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02016c6:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c8:	d7bd                	beqz	a5,ffffffffc0201636 <slob_free+0x16>
        intr_disable();
ffffffffc02016ca:	ef9fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc02016ce:	4505                	li	a0,1
ffffffffc02016d0:	b79d                	j	ffffffffc0201636 <slob_free+0x16>
ffffffffc02016d2:	8082                	ret

ffffffffc02016d4 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02016d4:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02016d6:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02016d8:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02016dc:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02016de:	34e000ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
  if(!page)
ffffffffc02016e2:	c91d                	beqz	a0,ffffffffc0201718 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02016e4:	00015697          	auipc	a3,0x15
ffffffffc02016e8:	e8c6b683          	ld	a3,-372(a3) # ffffffffc0216570 <pages>
ffffffffc02016ec:	8d15                	sub	a0,a0,a3
ffffffffc02016ee:	8519                	srai	a0,a0,0x6
ffffffffc02016f0:	00006697          	auipc	a3,0x6
ffffffffc02016f4:	9286b683          	ld	a3,-1752(a3) # ffffffffc0207018 <nbase>
ffffffffc02016f8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02016fa:	00c51793          	slli	a5,a0,0xc
ffffffffc02016fe:	83b1                	srli	a5,a5,0xc
ffffffffc0201700:	00015717          	auipc	a4,0x15
ffffffffc0201704:	e6873703          	ld	a4,-408(a4) # ffffffffc0216568 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201708:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc020170a:	00e7fa63          	bgeu	a5,a4,ffffffffc020171e <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020170e:	00015697          	auipc	a3,0x15
ffffffffc0201712:	e726b683          	ld	a3,-398(a3) # ffffffffc0216580 <va_pa_offset>
ffffffffc0201716:	9536                	add	a0,a0,a3
}
ffffffffc0201718:	60a2                	ld	ra,8(sp)
ffffffffc020171a:	0141                	addi	sp,sp,16
ffffffffc020171c:	8082                	ret
ffffffffc020171e:	86aa                	mv	a3,a0
ffffffffc0201720:	00004617          	auipc	a2,0x4
ffffffffc0201724:	55860613          	addi	a2,a2,1368 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc0201728:	06900593          	li	a1,105
ffffffffc020172c:	00004517          	auipc	a0,0x4
ffffffffc0201730:	57450513          	addi	a0,a0,1396 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc0201734:	d13fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201738 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201738:	1101                	addi	sp,sp,-32
ffffffffc020173a:	ec06                	sd	ra,24(sp)
ffffffffc020173c:	e822                	sd	s0,16(sp)
ffffffffc020173e:	e426                	sd	s1,8(sp)
ffffffffc0201740:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201742:	01050713          	addi	a4,a0,16
ffffffffc0201746:	6785                	lui	a5,0x1
ffffffffc0201748:	0cf77363          	bgeu	a4,a5,ffffffffc020180e <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc020174c:	00f50493          	addi	s1,a0,15
ffffffffc0201750:	8091                	srli	s1,s1,0x4
ffffffffc0201752:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201754:	10002673          	csrr	a2,sstatus
ffffffffc0201758:	8a09                	andi	a2,a2,2
ffffffffc020175a:	e25d                	bnez	a2,ffffffffc0201800 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc020175c:	0000a917          	auipc	s2,0xa
ffffffffc0201760:	8f490913          	addi	s2,s2,-1804 # ffffffffc020b050 <slobfree>
ffffffffc0201764:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201768:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020176a:	4398                	lw	a4,0(a5)
ffffffffc020176c:	08975e63          	bge	a4,s1,ffffffffc0201808 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201770:	00d78b63          	beq	a5,a3,ffffffffc0201786 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201774:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201776:	4018                	lw	a4,0(s0)
ffffffffc0201778:	02975a63          	bge	a4,s1,ffffffffc02017ac <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc020177c:	00093683          	ld	a3,0(s2)
ffffffffc0201780:	87a2                	mv	a5,s0
ffffffffc0201782:	fed799e3          	bne	a5,a3,ffffffffc0201774 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201786:	ee31                	bnez	a2,ffffffffc02017e2 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201788:	4501                	li	a0,0
ffffffffc020178a:	f4bff0ef          	jal	ra,ffffffffc02016d4 <__slob_get_free_pages.constprop.0>
ffffffffc020178e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201790:	cd05                	beqz	a0,ffffffffc02017c8 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201792:	6585                	lui	a1,0x1
ffffffffc0201794:	e8dff0ef          	jal	ra,ffffffffc0201620 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201798:	10002673          	csrr	a2,sstatus
ffffffffc020179c:	8a09                	andi	a2,a2,2
ffffffffc020179e:	ee05                	bnez	a2,ffffffffc02017d6 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc02017a0:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02017a4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02017a6:	4018                	lw	a4,0(s0)
ffffffffc02017a8:	fc974ae3          	blt	a4,s1,ffffffffc020177c <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc02017ac:	04e48763          	beq	s1,a4,ffffffffc02017fa <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc02017b0:	00449693          	slli	a3,s1,0x4
ffffffffc02017b4:	96a2                	add	a3,a3,s0
ffffffffc02017b6:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02017b8:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02017ba:	9f05                	subw	a4,a4,s1
ffffffffc02017bc:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02017be:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02017c0:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02017c2:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc02017c6:	e20d                	bnez	a2,ffffffffc02017e8 <slob_alloc.constprop.0+0xb0>
}
ffffffffc02017c8:	60e2                	ld	ra,24(sp)
ffffffffc02017ca:	8522                	mv	a0,s0
ffffffffc02017cc:	6442                	ld	s0,16(sp)
ffffffffc02017ce:	64a2                	ld	s1,8(sp)
ffffffffc02017d0:	6902                	ld	s2,0(sp)
ffffffffc02017d2:	6105                	addi	sp,sp,32
ffffffffc02017d4:	8082                	ret
        intr_disable();
ffffffffc02017d6:	dedfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
			cur = slobfree;
ffffffffc02017da:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02017de:	4605                	li	a2,1
ffffffffc02017e0:	b7d1                	j	ffffffffc02017a4 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02017e2:	ddbfe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02017e6:	b74d                	j	ffffffffc0201788 <slob_alloc.constprop.0+0x50>
ffffffffc02017e8:	dd5fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
}
ffffffffc02017ec:	60e2                	ld	ra,24(sp)
ffffffffc02017ee:	8522                	mv	a0,s0
ffffffffc02017f0:	6442                	ld	s0,16(sp)
ffffffffc02017f2:	64a2                	ld	s1,8(sp)
ffffffffc02017f4:	6902                	ld	s2,0(sp)
ffffffffc02017f6:	6105                	addi	sp,sp,32
ffffffffc02017f8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02017fa:	6418                	ld	a4,8(s0)
ffffffffc02017fc:	e798                	sd	a4,8(a5)
ffffffffc02017fe:	b7d1                	j	ffffffffc02017c2 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201800:	dc3fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0201804:	4605                	li	a2,1
ffffffffc0201806:	bf99                	j	ffffffffc020175c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201808:	843e                	mv	s0,a5
ffffffffc020180a:	87b6                	mv	a5,a3
ffffffffc020180c:	b745                	j	ffffffffc02017ac <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020180e:	00004697          	auipc	a3,0x4
ffffffffc0201812:	4a268693          	addi	a3,a3,1186 # ffffffffc0205cb0 <default_pmm_manager+0x70>
ffffffffc0201816:	00004617          	auipc	a2,0x4
ffffffffc020181a:	07a60613          	addi	a2,a2,122 # ffffffffc0205890 <commands+0x738>
ffffffffc020181e:	06300593          	li	a1,99
ffffffffc0201822:	00004517          	auipc	a0,0x4
ffffffffc0201826:	4ae50513          	addi	a0,a0,1198 # ffffffffc0205cd0 <default_pmm_manager+0x90>
ffffffffc020182a:	c1dfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020182e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc020182e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201830:	00004517          	auipc	a0,0x4
ffffffffc0201834:	4b850513          	addi	a0,a0,1208 # ffffffffc0205ce8 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201838:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc020183a:	947fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc020183e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201840:	00004517          	auipc	a0,0x4
ffffffffc0201844:	4c050513          	addi	a0,a0,1216 # ffffffffc0205d00 <default_pmm_manager+0xc0>
}
ffffffffc0201848:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020184a:	937fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020184e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc020184e:	1101                	addi	sp,sp,-32
ffffffffc0201850:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201852:	6905                	lui	s2,0x1
{
ffffffffc0201854:	e822                	sd	s0,16(sp)
ffffffffc0201856:	ec06                	sd	ra,24(sp)
ffffffffc0201858:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020185a:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc020185e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201860:	04a7f963          	bgeu	a5,a0,ffffffffc02018b2 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201864:	4561                	li	a0,24
ffffffffc0201866:	ed3ff0ef          	jal	ra,ffffffffc0201738 <slob_alloc.constprop.0>
ffffffffc020186a:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc020186c:	c929                	beqz	a0,ffffffffc02018be <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc020186e:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201872:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201874:	00f95763          	bge	s2,a5,ffffffffc0201882 <kmalloc+0x34>
ffffffffc0201878:	6705                	lui	a4,0x1
ffffffffc020187a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc020187c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc020187e:	fef74ee3          	blt	a4,a5,ffffffffc020187a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201882:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201884:	e51ff0ef          	jal	ra,ffffffffc02016d4 <__slob_get_free_pages.constprop.0>
ffffffffc0201888:	e488                	sd	a0,8(s1)
ffffffffc020188a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc020188c:	c525                	beqz	a0,ffffffffc02018f4 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020188e:	100027f3          	csrr	a5,sstatus
ffffffffc0201892:	8b89                	andi	a5,a5,2
ffffffffc0201894:	ef8d                	bnez	a5,ffffffffc02018ce <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201896:	00015797          	auipc	a5,0x15
ffffffffc020189a:	cba78793          	addi	a5,a5,-838 # ffffffffc0216550 <bigblocks>
ffffffffc020189e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02018a0:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02018a2:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02018a4:	60e2                	ld	ra,24(sp)
ffffffffc02018a6:	8522                	mv	a0,s0
ffffffffc02018a8:	6442                	ld	s0,16(sp)
ffffffffc02018aa:	64a2                	ld	s1,8(sp)
ffffffffc02018ac:	6902                	ld	s2,0(sp)
ffffffffc02018ae:	6105                	addi	sp,sp,32
ffffffffc02018b0:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02018b2:	0541                	addi	a0,a0,16
ffffffffc02018b4:	e85ff0ef          	jal	ra,ffffffffc0201738 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc02018b8:	01050413          	addi	s0,a0,16
ffffffffc02018bc:	f565                	bnez	a0,ffffffffc02018a4 <kmalloc+0x56>
ffffffffc02018be:	4401                	li	s0,0
}
ffffffffc02018c0:	60e2                	ld	ra,24(sp)
ffffffffc02018c2:	8522                	mv	a0,s0
ffffffffc02018c4:	6442                	ld	s0,16(sp)
ffffffffc02018c6:	64a2                	ld	s1,8(sp)
ffffffffc02018c8:	6902                	ld	s2,0(sp)
ffffffffc02018ca:	6105                	addi	sp,sp,32
ffffffffc02018cc:	8082                	ret
        intr_disable();
ffffffffc02018ce:	cf5fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		bb->next = bigblocks;
ffffffffc02018d2:	00015797          	auipc	a5,0x15
ffffffffc02018d6:	c7e78793          	addi	a5,a5,-898 # ffffffffc0216550 <bigblocks>
ffffffffc02018da:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02018dc:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02018de:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc02018e0:	cddfe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
		return bb->pages;
ffffffffc02018e4:	6480                	ld	s0,8(s1)
}
ffffffffc02018e6:	60e2                	ld	ra,24(sp)
ffffffffc02018e8:	64a2                	ld	s1,8(sp)
ffffffffc02018ea:	8522                	mv	a0,s0
ffffffffc02018ec:	6442                	ld	s0,16(sp)
ffffffffc02018ee:	6902                	ld	s2,0(sp)
ffffffffc02018f0:	6105                	addi	sp,sp,32
ffffffffc02018f2:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02018f4:	45e1                	li	a1,24
ffffffffc02018f6:	8526                	mv	a0,s1
ffffffffc02018f8:	d29ff0ef          	jal	ra,ffffffffc0201620 <slob_free>
  return __kmalloc(size, 0);
ffffffffc02018fc:	b765                	j	ffffffffc02018a4 <kmalloc+0x56>

ffffffffc02018fe <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02018fe:	c169                	beqz	a0,ffffffffc02019c0 <kfree+0xc2>
{
ffffffffc0201900:	1101                	addi	sp,sp,-32
ffffffffc0201902:	e822                	sd	s0,16(sp)
ffffffffc0201904:	ec06                	sd	ra,24(sp)
ffffffffc0201906:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201908:	03451793          	slli	a5,a0,0x34
ffffffffc020190c:	842a                	mv	s0,a0
ffffffffc020190e:	e3d9                	bnez	a5,ffffffffc0201994 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201910:	100027f3          	csrr	a5,sstatus
ffffffffc0201914:	8b89                	andi	a5,a5,2
ffffffffc0201916:	e7d9                	bnez	a5,ffffffffc02019a4 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201918:	00015797          	auipc	a5,0x15
ffffffffc020191c:	c387b783          	ld	a5,-968(a5) # ffffffffc0216550 <bigblocks>
    return 0;
ffffffffc0201920:	4601                	li	a2,0
ffffffffc0201922:	cbad                	beqz	a5,ffffffffc0201994 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201924:	00015697          	auipc	a3,0x15
ffffffffc0201928:	c2c68693          	addi	a3,a3,-980 # ffffffffc0216550 <bigblocks>
ffffffffc020192c:	a021                	j	ffffffffc0201934 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020192e:	01048693          	addi	a3,s1,16
ffffffffc0201932:	c3a5                	beqz	a5,ffffffffc0201992 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201934:	6798                	ld	a4,8(a5)
ffffffffc0201936:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201938:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc020193a:	fe871ae3          	bne	a4,s0,ffffffffc020192e <kfree+0x30>
				*last = bb->next;
ffffffffc020193e:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201940:	ee2d                	bnez	a2,ffffffffc02019ba <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201942:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201946:	4098                	lw	a4,0(s1)
ffffffffc0201948:	08f46963          	bltu	s0,a5,ffffffffc02019da <kfree+0xdc>
ffffffffc020194c:	00015697          	auipc	a3,0x15
ffffffffc0201950:	c346b683          	ld	a3,-972(a3) # ffffffffc0216580 <va_pa_offset>
ffffffffc0201954:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201956:	8031                	srli	s0,s0,0xc
ffffffffc0201958:	00015797          	auipc	a5,0x15
ffffffffc020195c:	c107b783          	ld	a5,-1008(a5) # ffffffffc0216568 <npage>
ffffffffc0201960:	06f47163          	bgeu	s0,a5,ffffffffc02019c2 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201964:	00005517          	auipc	a0,0x5
ffffffffc0201968:	6b453503          	ld	a0,1716(a0) # ffffffffc0207018 <nbase>
ffffffffc020196c:	8c09                	sub	s0,s0,a0
ffffffffc020196e:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201970:	00015517          	auipc	a0,0x15
ffffffffc0201974:	c0053503          	ld	a0,-1024(a0) # ffffffffc0216570 <pages>
ffffffffc0201978:	4585                	li	a1,1
ffffffffc020197a:	9522                	add	a0,a0,s0
ffffffffc020197c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201980:	13e000ef          	jal	ra,ffffffffc0201abe <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201984:	6442                	ld	s0,16(sp)
ffffffffc0201986:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201988:	8526                	mv	a0,s1
}
ffffffffc020198a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020198c:	45e1                	li	a1,24
}
ffffffffc020198e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201990:	b941                	j	ffffffffc0201620 <slob_free>
ffffffffc0201992:	e20d                	bnez	a2,ffffffffc02019b4 <kfree+0xb6>
ffffffffc0201994:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201998:	6442                	ld	s0,16(sp)
ffffffffc020199a:	60e2                	ld	ra,24(sp)
ffffffffc020199c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020199e:	4581                	li	a1,0
}
ffffffffc02019a0:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02019a2:	b9bd                	j	ffffffffc0201620 <slob_free>
        intr_disable();
ffffffffc02019a4:	c1ffe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02019a8:	00015797          	auipc	a5,0x15
ffffffffc02019ac:	ba87b783          	ld	a5,-1112(a5) # ffffffffc0216550 <bigblocks>
        return 1;
ffffffffc02019b0:	4605                	li	a2,1
ffffffffc02019b2:	fbad                	bnez	a5,ffffffffc0201924 <kfree+0x26>
        intr_enable();
ffffffffc02019b4:	c09fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02019b8:	bff1                	j	ffffffffc0201994 <kfree+0x96>
ffffffffc02019ba:	c03fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02019be:	b751                	j	ffffffffc0201942 <kfree+0x44>
ffffffffc02019c0:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02019c2:	00004617          	auipc	a2,0x4
ffffffffc02019c6:	38660613          	addi	a2,a2,902 # ffffffffc0205d48 <default_pmm_manager+0x108>
ffffffffc02019ca:	06200593          	li	a1,98
ffffffffc02019ce:	00004517          	auipc	a0,0x4
ffffffffc02019d2:	2d250513          	addi	a0,a0,722 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc02019d6:	a71fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02019da:	86a2                	mv	a3,s0
ffffffffc02019dc:	00004617          	auipc	a2,0x4
ffffffffc02019e0:	34460613          	addi	a2,a2,836 # ffffffffc0205d20 <default_pmm_manager+0xe0>
ffffffffc02019e4:	06e00593          	li	a1,110
ffffffffc02019e8:	00004517          	auipc	a0,0x4
ffffffffc02019ec:	2b850513          	addi	a0,a0,696 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc02019f0:	a57fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02019f4 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02019f4:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02019f6:	00004617          	auipc	a2,0x4
ffffffffc02019fa:	35260613          	addi	a2,a2,850 # ffffffffc0205d48 <default_pmm_manager+0x108>
ffffffffc02019fe:	06200593          	li	a1,98
ffffffffc0201a02:	00004517          	auipc	a0,0x4
ffffffffc0201a06:	29e50513          	addi	a0,a0,670 # ffffffffc0205ca0 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201a0a:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201a0c:	a3bfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a10 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201a10:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201a12:	00004617          	auipc	a2,0x4
ffffffffc0201a16:	35660613          	addi	a2,a2,854 # ffffffffc0205d68 <default_pmm_manager+0x128>
ffffffffc0201a1a:	07400593          	li	a1,116
ffffffffc0201a1e:	00004517          	auipc	a0,0x4
ffffffffc0201a22:	28250513          	addi	a0,a0,642 # ffffffffc0205ca0 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201a26:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201a28:	a1ffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a2c <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201a2c:	7139                	addi	sp,sp,-64
ffffffffc0201a2e:	f426                	sd	s1,40(sp)
ffffffffc0201a30:	f04a                	sd	s2,32(sp)
ffffffffc0201a32:	ec4e                	sd	s3,24(sp)
ffffffffc0201a34:	e852                	sd	s4,16(sp)
ffffffffc0201a36:	e456                	sd	s5,8(sp)
ffffffffc0201a38:	e05a                	sd	s6,0(sp)
ffffffffc0201a3a:	fc06                	sd	ra,56(sp)
ffffffffc0201a3c:	f822                	sd	s0,48(sp)
ffffffffc0201a3e:	84aa                	mv	s1,a0
ffffffffc0201a40:	00015917          	auipc	s2,0x15
ffffffffc0201a44:	b3890913          	addi	s2,s2,-1224 # ffffffffc0216578 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201a48:	4a05                	li	s4,1
ffffffffc0201a4a:	00015a97          	auipc	s5,0x15
ffffffffc0201a4e:	b4ea8a93          	addi	s5,s5,-1202 # ffffffffc0216598 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a52:	0005099b          	sext.w	s3,a0
ffffffffc0201a56:	00015b17          	auipc	s6,0x15
ffffffffc0201a5a:	b4ab0b13          	addi	s6,s6,-1206 # ffffffffc02165a0 <check_mm_struct>
ffffffffc0201a5e:	a01d                	j	ffffffffc0201a84 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201a60:	00093783          	ld	a5,0(s2)
ffffffffc0201a64:	6f9c                	ld	a5,24(a5)
ffffffffc0201a66:	9782                	jalr	a5
ffffffffc0201a68:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a6a:	4601                	li	a2,0
ffffffffc0201a6c:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201a6e:	ec0d                	bnez	s0,ffffffffc0201aa8 <alloc_pages+0x7c>
ffffffffc0201a70:	029a6c63          	bltu	s4,s1,ffffffffc0201aa8 <alloc_pages+0x7c>
ffffffffc0201a74:	000aa783          	lw	a5,0(s5)
ffffffffc0201a78:	2781                	sext.w	a5,a5
ffffffffc0201a7a:	c79d                	beqz	a5,ffffffffc0201aa8 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a7c:	000b3503          	ld	a0,0(s6)
ffffffffc0201a80:	037010ef          	jal	ra,ffffffffc02032b6 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a84:	100027f3          	csrr	a5,sstatus
ffffffffc0201a88:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201a8a:	8526                	mv	a0,s1
ffffffffc0201a8c:	dbf1                	beqz	a5,ffffffffc0201a60 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201a8e:	b35fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201a92:	00093783          	ld	a5,0(s2)
ffffffffc0201a96:	8526                	mv	a0,s1
ffffffffc0201a98:	6f9c                	ld	a5,24(a5)
ffffffffc0201a9a:	9782                	jalr	a5
ffffffffc0201a9c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201a9e:	b1ffe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201aa2:	4601                	li	a2,0
ffffffffc0201aa4:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201aa6:	d469                	beqz	s0,ffffffffc0201a70 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201aa8:	70e2                	ld	ra,56(sp)
ffffffffc0201aaa:	8522                	mv	a0,s0
ffffffffc0201aac:	7442                	ld	s0,48(sp)
ffffffffc0201aae:	74a2                	ld	s1,40(sp)
ffffffffc0201ab0:	7902                	ld	s2,32(sp)
ffffffffc0201ab2:	69e2                	ld	s3,24(sp)
ffffffffc0201ab4:	6a42                	ld	s4,16(sp)
ffffffffc0201ab6:	6aa2                	ld	s5,8(sp)
ffffffffc0201ab8:	6b02                	ld	s6,0(sp)
ffffffffc0201aba:	6121                	addi	sp,sp,64
ffffffffc0201abc:	8082                	ret

ffffffffc0201abe <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201abe:	100027f3          	csrr	a5,sstatus
ffffffffc0201ac2:	8b89                	andi	a5,a5,2
ffffffffc0201ac4:	e799                	bnez	a5,ffffffffc0201ad2 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ac6:	00015797          	auipc	a5,0x15
ffffffffc0201aca:	ab27b783          	ld	a5,-1358(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201ace:	739c                	ld	a5,32(a5)
ffffffffc0201ad0:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ad2:	1101                	addi	sp,sp,-32
ffffffffc0201ad4:	ec06                	sd	ra,24(sp)
ffffffffc0201ad6:	e822                	sd	s0,16(sp)
ffffffffc0201ad8:	e426                	sd	s1,8(sp)
ffffffffc0201ada:	842a                	mv	s0,a0
ffffffffc0201adc:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201ade:	ae5fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ae2:	00015797          	auipc	a5,0x15
ffffffffc0201ae6:	a967b783          	ld	a5,-1386(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201aea:	739c                	ld	a5,32(a5)
ffffffffc0201aec:	85a6                	mv	a1,s1
ffffffffc0201aee:	8522                	mv	a0,s0
ffffffffc0201af0:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201af2:	6442                	ld	s0,16(sp)
ffffffffc0201af4:	60e2                	ld	ra,24(sp)
ffffffffc0201af6:	64a2                	ld	s1,8(sp)
ffffffffc0201af8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201afa:	ac3fe06f          	j	ffffffffc02005bc <intr_enable>

ffffffffc0201afe <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201afe:	100027f3          	csrr	a5,sstatus
ffffffffc0201b02:	8b89                	andi	a5,a5,2
ffffffffc0201b04:	e799                	bnez	a5,ffffffffc0201b12 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201b06:	00015797          	auipc	a5,0x15
ffffffffc0201b0a:	a727b783          	ld	a5,-1422(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201b0e:	779c                	ld	a5,40(a5)
ffffffffc0201b10:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201b12:	1141                	addi	sp,sp,-16
ffffffffc0201b14:	e406                	sd	ra,8(sp)
ffffffffc0201b16:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201b18:	aabfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201b1c:	00015797          	auipc	a5,0x15
ffffffffc0201b20:	a5c7b783          	ld	a5,-1444(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201b24:	779c                	ld	a5,40(a5)
ffffffffc0201b26:	9782                	jalr	a5
ffffffffc0201b28:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201b2a:	a93fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201b2e:	60a2                	ld	ra,8(sp)
ffffffffc0201b30:	8522                	mv	a0,s0
ffffffffc0201b32:	6402                	ld	s0,0(sp)
ffffffffc0201b34:	0141                	addi	sp,sp,16
ffffffffc0201b36:	8082                	ret

ffffffffc0201b38 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b38:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201b3c:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b40:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b42:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b44:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b46:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b4a:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b4c:	f04a                	sd	s2,32(sp)
ffffffffc0201b4e:	ec4e                	sd	s3,24(sp)
ffffffffc0201b50:	e852                	sd	s4,16(sp)
ffffffffc0201b52:	fc06                	sd	ra,56(sp)
ffffffffc0201b54:	f822                	sd	s0,48(sp)
ffffffffc0201b56:	e456                	sd	s5,8(sp)
ffffffffc0201b58:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b5a:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b5e:	892e                	mv	s2,a1
ffffffffc0201b60:	89b2                	mv	s3,a2
ffffffffc0201b62:	00015a17          	auipc	s4,0x15
ffffffffc0201b66:	a06a0a13          	addi	s4,s4,-1530 # ffffffffc0216568 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b6a:	e7b5                	bnez	a5,ffffffffc0201bd6 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201b6c:	12060b63          	beqz	a2,ffffffffc0201ca2 <get_pte+0x16a>
ffffffffc0201b70:	4505                	li	a0,1
ffffffffc0201b72:	ebbff0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0201b76:	842a                	mv	s0,a0
ffffffffc0201b78:	12050563          	beqz	a0,ffffffffc0201ca2 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201b7c:	00015b17          	auipc	s6,0x15
ffffffffc0201b80:	9f4b0b13          	addi	s6,s6,-1548 # ffffffffc0216570 <pages>
ffffffffc0201b84:	000b3503          	ld	a0,0(s6)
ffffffffc0201b88:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201b8c:	00015a17          	auipc	s4,0x15
ffffffffc0201b90:	9dca0a13          	addi	s4,s4,-1572 # ffffffffc0216568 <npage>
ffffffffc0201b94:	40a40533          	sub	a0,s0,a0
ffffffffc0201b98:	8519                	srai	a0,a0,0x6
ffffffffc0201b9a:	9556                	add	a0,a0,s5
ffffffffc0201b9c:	000a3703          	ld	a4,0(s4)
ffffffffc0201ba0:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201ba4:	4685                	li	a3,1
ffffffffc0201ba6:	c014                	sw	a3,0(s0)
ffffffffc0201ba8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201baa:	0532                	slli	a0,a0,0xc
ffffffffc0201bac:	14e7f263          	bgeu	a5,a4,ffffffffc0201cf0 <get_pte+0x1b8>
ffffffffc0201bb0:	00015797          	auipc	a5,0x15
ffffffffc0201bb4:	9d07b783          	ld	a5,-1584(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc0201bb8:	6605                	lui	a2,0x1
ffffffffc0201bba:	4581                	li	a1,0
ffffffffc0201bbc:	953e                	add	a0,a0,a5
ffffffffc0201bbe:	2e2030ef          	jal	ra,ffffffffc0204ea0 <memset>
    return page - pages + nbase;
ffffffffc0201bc2:	000b3683          	ld	a3,0(s6)
ffffffffc0201bc6:	40d406b3          	sub	a3,s0,a3
ffffffffc0201bca:	8699                	srai	a3,a3,0x6
ffffffffc0201bcc:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201bce:	06aa                	slli	a3,a3,0xa
ffffffffc0201bd0:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201bd4:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201bd6:	77fd                	lui	a5,0xfffff
ffffffffc0201bd8:	068a                	slli	a3,a3,0x2
ffffffffc0201bda:	000a3703          	ld	a4,0(s4)
ffffffffc0201bde:	8efd                	and	a3,a3,a5
ffffffffc0201be0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201be4:	0ce7f163          	bgeu	a5,a4,ffffffffc0201ca6 <get_pte+0x16e>
ffffffffc0201be8:	00015a97          	auipc	s5,0x15
ffffffffc0201bec:	998a8a93          	addi	s5,s5,-1640 # ffffffffc0216580 <va_pa_offset>
ffffffffc0201bf0:	000ab403          	ld	s0,0(s5)
ffffffffc0201bf4:	01595793          	srli	a5,s2,0x15
ffffffffc0201bf8:	1ff7f793          	andi	a5,a5,511
ffffffffc0201bfc:	96a2                	add	a3,a3,s0
ffffffffc0201bfe:	00379413          	slli	s0,a5,0x3
ffffffffc0201c02:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201c04:	6014                	ld	a3,0(s0)
ffffffffc0201c06:	0016f793          	andi	a5,a3,1
ffffffffc0201c0a:	e3ad                	bnez	a5,ffffffffc0201c6c <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201c0c:	08098b63          	beqz	s3,ffffffffc0201ca2 <get_pte+0x16a>
ffffffffc0201c10:	4505                	li	a0,1
ffffffffc0201c12:	e1bff0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0201c16:	84aa                	mv	s1,a0
ffffffffc0201c18:	c549                	beqz	a0,ffffffffc0201ca2 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201c1a:	00015b17          	auipc	s6,0x15
ffffffffc0201c1e:	956b0b13          	addi	s6,s6,-1706 # ffffffffc0216570 <pages>
ffffffffc0201c22:	000b3503          	ld	a0,0(s6)
ffffffffc0201c26:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201c2a:	000a3703          	ld	a4,0(s4)
ffffffffc0201c2e:	40a48533          	sub	a0,s1,a0
ffffffffc0201c32:	8519                	srai	a0,a0,0x6
ffffffffc0201c34:	954e                	add	a0,a0,s3
ffffffffc0201c36:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201c3a:	4685                	li	a3,1
ffffffffc0201c3c:	c094                	sw	a3,0(s1)
ffffffffc0201c3e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c40:	0532                	slli	a0,a0,0xc
ffffffffc0201c42:	08e7fa63          	bgeu	a5,a4,ffffffffc0201cd6 <get_pte+0x19e>
ffffffffc0201c46:	000ab783          	ld	a5,0(s5)
ffffffffc0201c4a:	6605                	lui	a2,0x1
ffffffffc0201c4c:	4581                	li	a1,0
ffffffffc0201c4e:	953e                	add	a0,a0,a5
ffffffffc0201c50:	250030ef          	jal	ra,ffffffffc0204ea0 <memset>
    return page - pages + nbase;
ffffffffc0201c54:	000b3683          	ld	a3,0(s6)
ffffffffc0201c58:	40d486b3          	sub	a3,s1,a3
ffffffffc0201c5c:	8699                	srai	a3,a3,0x6
ffffffffc0201c5e:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201c60:	06aa                	slli	a3,a3,0xa
ffffffffc0201c62:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201c66:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201c68:	000a3703          	ld	a4,0(s4)
ffffffffc0201c6c:	068a                	slli	a3,a3,0x2
ffffffffc0201c6e:	757d                	lui	a0,0xfffff
ffffffffc0201c70:	8ee9                	and	a3,a3,a0
ffffffffc0201c72:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201c76:	04e7f463          	bgeu	a5,a4,ffffffffc0201cbe <get_pte+0x186>
ffffffffc0201c7a:	000ab503          	ld	a0,0(s5)
ffffffffc0201c7e:	00c95913          	srli	s2,s2,0xc
ffffffffc0201c82:	1ff97913          	andi	s2,s2,511
ffffffffc0201c86:	96aa                	add	a3,a3,a0
ffffffffc0201c88:	00391513          	slli	a0,s2,0x3
ffffffffc0201c8c:	9536                	add	a0,a0,a3
}
ffffffffc0201c8e:	70e2                	ld	ra,56(sp)
ffffffffc0201c90:	7442                	ld	s0,48(sp)
ffffffffc0201c92:	74a2                	ld	s1,40(sp)
ffffffffc0201c94:	7902                	ld	s2,32(sp)
ffffffffc0201c96:	69e2                	ld	s3,24(sp)
ffffffffc0201c98:	6a42                	ld	s4,16(sp)
ffffffffc0201c9a:	6aa2                	ld	s5,8(sp)
ffffffffc0201c9c:	6b02                	ld	s6,0(sp)
ffffffffc0201c9e:	6121                	addi	sp,sp,64
ffffffffc0201ca0:	8082                	ret
            return NULL;
ffffffffc0201ca2:	4501                	li	a0,0
ffffffffc0201ca4:	b7ed                	j	ffffffffc0201c8e <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201ca6:	00004617          	auipc	a2,0x4
ffffffffc0201caa:	fd260613          	addi	a2,a2,-46 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc0201cae:	0e400593          	li	a1,228
ffffffffc0201cb2:	00004517          	auipc	a0,0x4
ffffffffc0201cb6:	0de50513          	addi	a0,a0,222 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0201cba:	f8cfe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201cbe:	00004617          	auipc	a2,0x4
ffffffffc0201cc2:	fba60613          	addi	a2,a2,-70 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc0201cc6:	0ef00593          	li	a1,239
ffffffffc0201cca:	00004517          	auipc	a0,0x4
ffffffffc0201cce:	0c650513          	addi	a0,a0,198 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0201cd2:	f74fe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201cd6:	86aa                	mv	a3,a0
ffffffffc0201cd8:	00004617          	auipc	a2,0x4
ffffffffc0201cdc:	fa060613          	addi	a2,a2,-96 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc0201ce0:	0ec00593          	li	a1,236
ffffffffc0201ce4:	00004517          	auipc	a0,0x4
ffffffffc0201ce8:	0ac50513          	addi	a0,a0,172 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0201cec:	f5afe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201cf0:	86aa                	mv	a3,a0
ffffffffc0201cf2:	00004617          	auipc	a2,0x4
ffffffffc0201cf6:	f8660613          	addi	a2,a2,-122 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc0201cfa:	0e100593          	li	a1,225
ffffffffc0201cfe:	00004517          	auipc	a0,0x4
ffffffffc0201d02:	09250513          	addi	a0,a0,146 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0201d06:	f40fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201d0a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201d0a:	1141                	addi	sp,sp,-16
ffffffffc0201d0c:	e022                	sd	s0,0(sp)
ffffffffc0201d0e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d10:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201d12:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d14:	e25ff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201d18:	c011                	beqz	s0,ffffffffc0201d1c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201d1a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201d1c:	c511                	beqz	a0,ffffffffc0201d28 <get_page+0x1e>
ffffffffc0201d1e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201d20:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201d22:	0017f713          	andi	a4,a5,1
ffffffffc0201d26:	e709                	bnez	a4,ffffffffc0201d30 <get_page+0x26>
}
ffffffffc0201d28:	60a2                	ld	ra,8(sp)
ffffffffc0201d2a:	6402                	ld	s0,0(sp)
ffffffffc0201d2c:	0141                	addi	sp,sp,16
ffffffffc0201d2e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d30:	078a                	slli	a5,a5,0x2
ffffffffc0201d32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d34:	00015717          	auipc	a4,0x15
ffffffffc0201d38:	83473703          	ld	a4,-1996(a4) # ffffffffc0216568 <npage>
ffffffffc0201d3c:	00e7ff63          	bgeu	a5,a4,ffffffffc0201d5a <get_page+0x50>
ffffffffc0201d40:	60a2                	ld	ra,8(sp)
ffffffffc0201d42:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201d44:	fff80537          	lui	a0,0xfff80
ffffffffc0201d48:	97aa                	add	a5,a5,a0
ffffffffc0201d4a:	079a                	slli	a5,a5,0x6
ffffffffc0201d4c:	00015517          	auipc	a0,0x15
ffffffffc0201d50:	82453503          	ld	a0,-2012(a0) # ffffffffc0216570 <pages>
ffffffffc0201d54:	953e                	add	a0,a0,a5
ffffffffc0201d56:	0141                	addi	sp,sp,16
ffffffffc0201d58:	8082                	ret
ffffffffc0201d5a:	c9bff0ef          	jal	ra,ffffffffc02019f4 <pa2page.part.0>

ffffffffc0201d5e <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201d5e:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d60:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201d62:	ec26                	sd	s1,24(sp)
ffffffffc0201d64:	f406                	sd	ra,40(sp)
ffffffffc0201d66:	f022                	sd	s0,32(sp)
ffffffffc0201d68:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d6a:	dcfff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
    if (ptep != NULL) {
ffffffffc0201d6e:	c511                	beqz	a0,ffffffffc0201d7a <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201d70:	611c                	ld	a5,0(a0)
ffffffffc0201d72:	842a                	mv	s0,a0
ffffffffc0201d74:	0017f713          	andi	a4,a5,1
ffffffffc0201d78:	e711                	bnez	a4,ffffffffc0201d84 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201d7a:	70a2                	ld	ra,40(sp)
ffffffffc0201d7c:	7402                	ld	s0,32(sp)
ffffffffc0201d7e:	64e2                	ld	s1,24(sp)
ffffffffc0201d80:	6145                	addi	sp,sp,48
ffffffffc0201d82:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d84:	078a                	slli	a5,a5,0x2
ffffffffc0201d86:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d88:	00014717          	auipc	a4,0x14
ffffffffc0201d8c:	7e073703          	ld	a4,2016(a4) # ffffffffc0216568 <npage>
ffffffffc0201d90:	06e7f363          	bgeu	a5,a4,ffffffffc0201df6 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d94:	fff80537          	lui	a0,0xfff80
ffffffffc0201d98:	97aa                	add	a5,a5,a0
ffffffffc0201d9a:	079a                	slli	a5,a5,0x6
ffffffffc0201d9c:	00014517          	auipc	a0,0x14
ffffffffc0201da0:	7d453503          	ld	a0,2004(a0) # ffffffffc0216570 <pages>
ffffffffc0201da4:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201da6:	411c                	lw	a5,0(a0)
ffffffffc0201da8:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201dac:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201dae:	cb11                	beqz	a4,ffffffffc0201dc2 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201db0:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201db4:	12048073          	sfence.vma	s1
}
ffffffffc0201db8:	70a2                	ld	ra,40(sp)
ffffffffc0201dba:	7402                	ld	s0,32(sp)
ffffffffc0201dbc:	64e2                	ld	s1,24(sp)
ffffffffc0201dbe:	6145                	addi	sp,sp,48
ffffffffc0201dc0:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201dc2:	100027f3          	csrr	a5,sstatus
ffffffffc0201dc6:	8b89                	andi	a5,a5,2
ffffffffc0201dc8:	eb89                	bnez	a5,ffffffffc0201dda <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0201dca:	00014797          	auipc	a5,0x14
ffffffffc0201dce:	7ae7b783          	ld	a5,1966(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201dd2:	739c                	ld	a5,32(a5)
ffffffffc0201dd4:	4585                	li	a1,1
ffffffffc0201dd6:	9782                	jalr	a5
    if (flag) {
ffffffffc0201dd8:	bfe1                	j	ffffffffc0201db0 <page_remove+0x52>
        intr_disable();
ffffffffc0201dda:	e42a                	sd	a0,8(sp)
ffffffffc0201ddc:	fe6fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201de0:	00014797          	auipc	a5,0x14
ffffffffc0201de4:	7987b783          	ld	a5,1944(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201de8:	739c                	ld	a5,32(a5)
ffffffffc0201dea:	6522                	ld	a0,8(sp)
ffffffffc0201dec:	4585                	li	a1,1
ffffffffc0201dee:	9782                	jalr	a5
        intr_enable();
ffffffffc0201df0:	fccfe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201df4:	bf75                	j	ffffffffc0201db0 <page_remove+0x52>
ffffffffc0201df6:	bffff0ef          	jal	ra,ffffffffc02019f4 <pa2page.part.0>

ffffffffc0201dfa <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201dfa:	7139                	addi	sp,sp,-64
ffffffffc0201dfc:	e852                	sd	s4,16(sp)
ffffffffc0201dfe:	8a32                	mv	s4,a2
ffffffffc0201e00:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e02:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e04:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e06:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201e08:	f426                	sd	s1,40(sp)
ffffffffc0201e0a:	fc06                	sd	ra,56(sp)
ffffffffc0201e0c:	f04a                	sd	s2,32(sp)
ffffffffc0201e0e:	ec4e                	sd	s3,24(sp)
ffffffffc0201e10:	e456                	sd	s5,8(sp)
ffffffffc0201e12:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201e14:	d25ff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
    if (ptep == NULL) {
ffffffffc0201e18:	c961                	beqz	a0,ffffffffc0201ee8 <page_insert+0xee>
    page->ref += 1;
ffffffffc0201e1a:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201e1c:	611c                	ld	a5,0(a0)
ffffffffc0201e1e:	89aa                	mv	s3,a0
ffffffffc0201e20:	0016871b          	addiw	a4,a3,1
ffffffffc0201e24:	c018                	sw	a4,0(s0)
ffffffffc0201e26:	0017f713          	andi	a4,a5,1
ffffffffc0201e2a:	ef05                	bnez	a4,ffffffffc0201e62 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201e2c:	00014717          	auipc	a4,0x14
ffffffffc0201e30:	74473703          	ld	a4,1860(a4) # ffffffffc0216570 <pages>
ffffffffc0201e34:	8c19                	sub	s0,s0,a4
ffffffffc0201e36:	000807b7          	lui	a5,0x80
ffffffffc0201e3a:	8419                	srai	s0,s0,0x6
ffffffffc0201e3c:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e3e:	042a                	slli	s0,s0,0xa
ffffffffc0201e40:	8cc1                	or	s1,s1,s0
ffffffffc0201e42:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201e46:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201e4a:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201e4e:	4501                	li	a0,0
}
ffffffffc0201e50:	70e2                	ld	ra,56(sp)
ffffffffc0201e52:	7442                	ld	s0,48(sp)
ffffffffc0201e54:	74a2                	ld	s1,40(sp)
ffffffffc0201e56:	7902                	ld	s2,32(sp)
ffffffffc0201e58:	69e2                	ld	s3,24(sp)
ffffffffc0201e5a:	6a42                	ld	s4,16(sp)
ffffffffc0201e5c:	6aa2                	ld	s5,8(sp)
ffffffffc0201e5e:	6121                	addi	sp,sp,64
ffffffffc0201e60:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e62:	078a                	slli	a5,a5,0x2
ffffffffc0201e64:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e66:	00014717          	auipc	a4,0x14
ffffffffc0201e6a:	70273703          	ld	a4,1794(a4) # ffffffffc0216568 <npage>
ffffffffc0201e6e:	06e7ff63          	bgeu	a5,a4,ffffffffc0201eec <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e72:	00014a97          	auipc	s5,0x14
ffffffffc0201e76:	6fea8a93          	addi	s5,s5,1790 # ffffffffc0216570 <pages>
ffffffffc0201e7a:	000ab703          	ld	a4,0(s5)
ffffffffc0201e7e:	fff80937          	lui	s2,0xfff80
ffffffffc0201e82:	993e                	add	s2,s2,a5
ffffffffc0201e84:	091a                	slli	s2,s2,0x6
ffffffffc0201e86:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0201e88:	01240c63          	beq	s0,s2,ffffffffc0201ea0 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0201e8c:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd69a34>
ffffffffc0201e90:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201e94:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0201e98:	c691                	beqz	a3,ffffffffc0201ea4 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201e9a:	120a0073          	sfence.vma	s4
}
ffffffffc0201e9e:	bf59                	j	ffffffffc0201e34 <page_insert+0x3a>
ffffffffc0201ea0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ea2:	bf49                	j	ffffffffc0201e34 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ea4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ea8:	8b89                	andi	a5,a5,2
ffffffffc0201eaa:	ef91                	bnez	a5,ffffffffc0201ec6 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0201eac:	00014797          	auipc	a5,0x14
ffffffffc0201eb0:	6cc7b783          	ld	a5,1740(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201eb4:	739c                	ld	a5,32(a5)
ffffffffc0201eb6:	4585                	li	a1,1
ffffffffc0201eb8:	854a                	mv	a0,s2
ffffffffc0201eba:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0201ebc:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201ec0:	120a0073          	sfence.vma	s4
ffffffffc0201ec4:	bf85                	j	ffffffffc0201e34 <page_insert+0x3a>
        intr_disable();
ffffffffc0201ec6:	efcfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201eca:	00014797          	auipc	a5,0x14
ffffffffc0201ece:	6ae7b783          	ld	a5,1710(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0201ed2:	739c                	ld	a5,32(a5)
ffffffffc0201ed4:	4585                	li	a1,1
ffffffffc0201ed6:	854a                	mv	a0,s2
ffffffffc0201ed8:	9782                	jalr	a5
        intr_enable();
ffffffffc0201eda:	ee2fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201ede:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201ee2:	120a0073          	sfence.vma	s4
ffffffffc0201ee6:	b7b9                	j	ffffffffc0201e34 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201ee8:	5571                	li	a0,-4
ffffffffc0201eea:	b79d                	j	ffffffffc0201e50 <page_insert+0x56>
ffffffffc0201eec:	b09ff0ef          	jal	ra,ffffffffc02019f4 <pa2page.part.0>

ffffffffc0201ef0 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201ef0:	00004797          	auipc	a5,0x4
ffffffffc0201ef4:	d5078793          	addi	a5,a5,-688 # ffffffffc0205c40 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ef8:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201efa:	711d                	addi	sp,sp,-96
ffffffffc0201efc:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201efe:	00004517          	auipc	a0,0x4
ffffffffc0201f02:	ea250513          	addi	a0,a0,-350 # ffffffffc0205da0 <default_pmm_manager+0x160>
    pmm_manager = &default_pmm_manager;
ffffffffc0201f06:	00014b97          	auipc	s7,0x14
ffffffffc0201f0a:	672b8b93          	addi	s7,s7,1650 # ffffffffc0216578 <pmm_manager>
void pmm_init(void) {
ffffffffc0201f0e:	ec86                	sd	ra,88(sp)
ffffffffc0201f10:	e4a6                	sd	s1,72(sp)
ffffffffc0201f12:	fc4e                	sd	s3,56(sp)
ffffffffc0201f14:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201f16:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201f1a:	e8a2                	sd	s0,80(sp)
ffffffffc0201f1c:	e0ca                	sd	s2,64(sp)
ffffffffc0201f1e:	f852                	sd	s4,48(sp)
ffffffffc0201f20:	f456                	sd	s5,40(sp)
ffffffffc0201f22:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201f24:	a5cfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc0201f28:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201f2c:	00014997          	auipc	s3,0x14
ffffffffc0201f30:	65498993          	addi	s3,s3,1620 # ffffffffc0216580 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201f34:	00014497          	auipc	s1,0x14
ffffffffc0201f38:	63448493          	addi	s1,s1,1588 # ffffffffc0216568 <npage>
    pmm_manager->init();
ffffffffc0201f3c:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201f3e:	00014b17          	auipc	s6,0x14
ffffffffc0201f42:	632b0b13          	addi	s6,s6,1586 # ffffffffc0216570 <pages>
    pmm_manager->init();
ffffffffc0201f46:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201f48:	57f5                	li	a5,-3
ffffffffc0201f4a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201f4c:	00004517          	auipc	a0,0x4
ffffffffc0201f50:	e6c50513          	addi	a0,a0,-404 # ffffffffc0205db8 <default_pmm_manager+0x178>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201f54:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0201f58:	a28fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201f5c:	46c5                	li	a3,17
ffffffffc0201f5e:	06ee                	slli	a3,a3,0x1b
ffffffffc0201f60:	40100613          	li	a2,1025
ffffffffc0201f64:	07e005b7          	lui	a1,0x7e00
ffffffffc0201f68:	16fd                	addi	a3,a3,-1
ffffffffc0201f6a:	0656                	slli	a2,a2,0x15
ffffffffc0201f6c:	00004517          	auipc	a0,0x4
ffffffffc0201f70:	e6450513          	addi	a0,a0,-412 # ffffffffc0205dd0 <default_pmm_manager+0x190>
ffffffffc0201f74:	a0cfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201f78:	777d                	lui	a4,0xfffff
ffffffffc0201f7a:	00015797          	auipc	a5,0x15
ffffffffc0201f7e:	65178793          	addi	a5,a5,1617 # ffffffffc02175cb <end+0xfff>
ffffffffc0201f82:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201f84:	00088737          	lui	a4,0x88
ffffffffc0201f88:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201f8a:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201f8e:	4701                	li	a4,0
ffffffffc0201f90:	4585                	li	a1,1
ffffffffc0201f92:	fff80837          	lui	a6,0xfff80
ffffffffc0201f96:	a019                	j	ffffffffc0201f9c <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0201f98:	000b3783          	ld	a5,0(s6)
ffffffffc0201f9c:	00671693          	slli	a3,a4,0x6
ffffffffc0201fa0:	97b6                	add	a5,a5,a3
ffffffffc0201fa2:	07a1                	addi	a5,a5,8
ffffffffc0201fa4:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201fa8:	6090                	ld	a2,0(s1)
ffffffffc0201faa:	0705                	addi	a4,a4,1
ffffffffc0201fac:	010607b3          	add	a5,a2,a6
ffffffffc0201fb0:	fef764e3          	bltu	a4,a5,ffffffffc0201f98 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201fb4:	000b3503          	ld	a0,0(s6)
ffffffffc0201fb8:	079a                	slli	a5,a5,0x6
ffffffffc0201fba:	c0200737          	lui	a4,0xc0200
ffffffffc0201fbe:	00f506b3          	add	a3,a0,a5
ffffffffc0201fc2:	60e6e563          	bltu	a3,a4,ffffffffc02025cc <pmm_init+0x6dc>
ffffffffc0201fc6:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201fca:	4745                	li	a4,17
ffffffffc0201fcc:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201fce:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201fd0:	4ae6e563          	bltu	a3,a4,ffffffffc020247a <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201fd4:	00004517          	auipc	a0,0x4
ffffffffc0201fd8:	e2450513          	addi	a0,a0,-476 # ffffffffc0205df8 <default_pmm_manager+0x1b8>
ffffffffc0201fdc:	9a4fe0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201fe0:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201fe4:	00014917          	auipc	s2,0x14
ffffffffc0201fe8:	57c90913          	addi	s2,s2,1404 # ffffffffc0216560 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201fec:	7b9c                	ld	a5,48(a5)
ffffffffc0201fee:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201ff0:	00004517          	auipc	a0,0x4
ffffffffc0201ff4:	e2050513          	addi	a0,a0,-480 # ffffffffc0205e10 <default_pmm_manager+0x1d0>
ffffffffc0201ff8:	988fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201ffc:	00008697          	auipc	a3,0x8
ffffffffc0202000:	00468693          	addi	a3,a3,4 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202004:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202008:	c02007b7          	lui	a5,0xc0200
ffffffffc020200c:	5cf6ec63          	bltu	a3,a5,ffffffffc02025e4 <pmm_init+0x6f4>
ffffffffc0202010:	0009b783          	ld	a5,0(s3)
ffffffffc0202014:	8e9d                	sub	a3,a3,a5
ffffffffc0202016:	00014797          	auipc	a5,0x14
ffffffffc020201a:	54d7b123          	sd	a3,1346(a5) # ffffffffc0216558 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020201e:	100027f3          	csrr	a5,sstatus
ffffffffc0202022:	8b89                	andi	a5,a5,2
ffffffffc0202024:	48079263          	bnez	a5,ffffffffc02024a8 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202028:	000bb783          	ld	a5,0(s7)
ffffffffc020202c:	779c                	ld	a5,40(a5)
ffffffffc020202e:	9782                	jalr	a5
ffffffffc0202030:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202032:	6098                	ld	a4,0(s1)
ffffffffc0202034:	c80007b7          	lui	a5,0xc8000
ffffffffc0202038:	83b1                	srli	a5,a5,0xc
ffffffffc020203a:	5ee7e163          	bltu	a5,a4,ffffffffc020261c <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020203e:	00093503          	ld	a0,0(s2)
ffffffffc0202042:	5a050d63          	beqz	a0,ffffffffc02025fc <pmm_init+0x70c>
ffffffffc0202046:	03451793          	slli	a5,a0,0x34
ffffffffc020204a:	5a079963          	bnez	a5,ffffffffc02025fc <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020204e:	4601                	li	a2,0
ffffffffc0202050:	4581                	li	a1,0
ffffffffc0202052:	cb9ff0ef          	jal	ra,ffffffffc0201d0a <get_page>
ffffffffc0202056:	62051563          	bnez	a0,ffffffffc0202680 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020205a:	4505                	li	a0,1
ffffffffc020205c:	9d1ff0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0202060:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202062:	00093503          	ld	a0,0(s2)
ffffffffc0202066:	4681                	li	a3,0
ffffffffc0202068:	4601                	li	a2,0
ffffffffc020206a:	85d2                	mv	a1,s4
ffffffffc020206c:	d8fff0ef          	jal	ra,ffffffffc0201dfa <page_insert>
ffffffffc0202070:	5e051863          	bnez	a0,ffffffffc0202660 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202074:	00093503          	ld	a0,0(s2)
ffffffffc0202078:	4601                	li	a2,0
ffffffffc020207a:	4581                	li	a1,0
ffffffffc020207c:	abdff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
ffffffffc0202080:	5c050063          	beqz	a0,ffffffffc0202640 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202084:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202086:	0017f713          	andi	a4,a5,1
ffffffffc020208a:	5a070963          	beqz	a4,ffffffffc020263c <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020208e:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202090:	078a                	slli	a5,a5,0x2
ffffffffc0202092:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202094:	52e7fa63          	bgeu	a5,a4,ffffffffc02025c8 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202098:	000b3683          	ld	a3,0(s6)
ffffffffc020209c:	fff80637          	lui	a2,0xfff80
ffffffffc02020a0:	97b2                	add	a5,a5,a2
ffffffffc02020a2:	079a                	slli	a5,a5,0x6
ffffffffc02020a4:	97b6                	add	a5,a5,a3
ffffffffc02020a6:	10fa16e3          	bne	s4,a5,ffffffffc02029b2 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc02020aa:	000a2683          	lw	a3,0(s4)
ffffffffc02020ae:	4785                	li	a5,1
ffffffffc02020b0:	12f69de3          	bne	a3,a5,ffffffffc02029ea <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02020b4:	00093503          	ld	a0,0(s2)
ffffffffc02020b8:	77fd                	lui	a5,0xfffff
ffffffffc02020ba:	6114                	ld	a3,0(a0)
ffffffffc02020bc:	068a                	slli	a3,a3,0x2
ffffffffc02020be:	8efd                	and	a3,a3,a5
ffffffffc02020c0:	00c6d613          	srli	a2,a3,0xc
ffffffffc02020c4:	10e677e3          	bgeu	a2,a4,ffffffffc02029d2 <pmm_init+0xae2>
ffffffffc02020c8:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02020cc:	96e2                	add	a3,a3,s8
ffffffffc02020ce:	0006ba83          	ld	s5,0(a3)
ffffffffc02020d2:	0a8a                	slli	s5,s5,0x2
ffffffffc02020d4:	00fafab3          	and	s5,s5,a5
ffffffffc02020d8:	00cad793          	srli	a5,s5,0xc
ffffffffc02020dc:	62e7f263          	bgeu	a5,a4,ffffffffc0202700 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02020e0:	4601                	li	a2,0
ffffffffc02020e2:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02020e4:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02020e6:	a53ff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02020ea:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02020ec:	5f551a63          	bne	a0,s5,ffffffffc02026e0 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc02020f0:	4505                	li	a0,1
ffffffffc02020f2:	93bff0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc02020f6:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02020f8:	00093503          	ld	a0,0(s2)
ffffffffc02020fc:	46d1                	li	a3,20
ffffffffc02020fe:	6605                	lui	a2,0x1
ffffffffc0202100:	85d6                	mv	a1,s5
ffffffffc0202102:	cf9ff0ef          	jal	ra,ffffffffc0201dfa <page_insert>
ffffffffc0202106:	58051d63          	bnez	a0,ffffffffc02026a0 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020210a:	00093503          	ld	a0,0(s2)
ffffffffc020210e:	4601                	li	a2,0
ffffffffc0202110:	6585                	lui	a1,0x1
ffffffffc0202112:	a27ff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
ffffffffc0202116:	0e050ae3          	beqz	a0,ffffffffc0202a0a <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020211a:	611c                	ld	a5,0(a0)
ffffffffc020211c:	0107f713          	andi	a4,a5,16
ffffffffc0202120:	6e070d63          	beqz	a4,ffffffffc020281a <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0202124:	8b91                	andi	a5,a5,4
ffffffffc0202126:	6a078a63          	beqz	a5,ffffffffc02027da <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020212a:	00093503          	ld	a0,0(s2)
ffffffffc020212e:	611c                	ld	a5,0(a0)
ffffffffc0202130:	8bc1                	andi	a5,a5,16
ffffffffc0202132:	68078463          	beqz	a5,ffffffffc02027ba <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0202136:	000aa703          	lw	a4,0(s5)
ffffffffc020213a:	4785                	li	a5,1
ffffffffc020213c:	58f71263          	bne	a4,a5,ffffffffc02026c0 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202140:	4681                	li	a3,0
ffffffffc0202142:	6605                	lui	a2,0x1
ffffffffc0202144:	85d2                	mv	a1,s4
ffffffffc0202146:	cb5ff0ef          	jal	ra,ffffffffc0201dfa <page_insert>
ffffffffc020214a:	62051863          	bnez	a0,ffffffffc020277a <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc020214e:	000a2703          	lw	a4,0(s4)
ffffffffc0202152:	4789                	li	a5,2
ffffffffc0202154:	60f71363          	bne	a4,a5,ffffffffc020275a <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc0202158:	000aa783          	lw	a5,0(s5)
ffffffffc020215c:	5c079f63          	bnez	a5,ffffffffc020273a <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202160:	00093503          	ld	a0,0(s2)
ffffffffc0202164:	4601                	li	a2,0
ffffffffc0202166:	6585                	lui	a1,0x1
ffffffffc0202168:	9d1ff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
ffffffffc020216c:	5a050763          	beqz	a0,ffffffffc020271a <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0202170:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202172:	00177793          	andi	a5,a4,1
ffffffffc0202176:	4c078363          	beqz	a5,ffffffffc020263c <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020217a:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020217c:	00271793          	slli	a5,a4,0x2
ffffffffc0202180:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202182:	44d7f363          	bgeu	a5,a3,ffffffffc02025c8 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202186:	000b3683          	ld	a3,0(s6)
ffffffffc020218a:	fff80637          	lui	a2,0xfff80
ffffffffc020218e:	97b2                	add	a5,a5,a2
ffffffffc0202190:	079a                	slli	a5,a5,0x6
ffffffffc0202192:	97b6                	add	a5,a5,a3
ffffffffc0202194:	6efa1363          	bne	s4,a5,ffffffffc020287a <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202198:	8b41                	andi	a4,a4,16
ffffffffc020219a:	6c071063          	bnez	a4,ffffffffc020285a <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020219e:	00093503          	ld	a0,0(s2)
ffffffffc02021a2:	4581                	li	a1,0
ffffffffc02021a4:	bbbff0ef          	jal	ra,ffffffffc0201d5e <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02021a8:	000a2703          	lw	a4,0(s4)
ffffffffc02021ac:	4785                	li	a5,1
ffffffffc02021ae:	68f71663          	bne	a4,a5,ffffffffc020283a <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc02021b2:	000aa783          	lw	a5,0(s5)
ffffffffc02021b6:	74079e63          	bnez	a5,ffffffffc0202912 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02021ba:	00093503          	ld	a0,0(s2)
ffffffffc02021be:	6585                	lui	a1,0x1
ffffffffc02021c0:	b9fff0ef          	jal	ra,ffffffffc0201d5e <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02021c4:	000a2783          	lw	a5,0(s4)
ffffffffc02021c8:	72079563          	bnez	a5,ffffffffc02028f2 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc02021cc:	000aa783          	lw	a5,0(s5)
ffffffffc02021d0:	70079163          	bnez	a5,ffffffffc02028d2 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02021d4:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02021d8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021da:	000a3683          	ld	a3,0(s4)
ffffffffc02021de:	068a                	slli	a3,a3,0x2
ffffffffc02021e0:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021e2:	3ee6f363          	bgeu	a3,a4,ffffffffc02025c8 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02021e6:	fff807b7          	lui	a5,0xfff80
ffffffffc02021ea:	000b3503          	ld	a0,0(s6)
ffffffffc02021ee:	96be                	add	a3,a3,a5
ffffffffc02021f0:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02021f2:	00d507b3          	add	a5,a0,a3
ffffffffc02021f6:	4390                	lw	a2,0(a5)
ffffffffc02021f8:	4785                	li	a5,1
ffffffffc02021fa:	6af61c63          	bne	a2,a5,ffffffffc02028b2 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc02021fe:	8699                	srai	a3,a3,0x6
ffffffffc0202200:	000805b7          	lui	a1,0x80
ffffffffc0202204:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0202206:	00c69613          	slli	a2,a3,0xc
ffffffffc020220a:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020220c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020220e:	68e67663          	bgeu	a2,a4,ffffffffc020289a <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202212:	0009b603          	ld	a2,0(s3)
ffffffffc0202216:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0202218:	629c                	ld	a5,0(a3)
ffffffffc020221a:	078a                	slli	a5,a5,0x2
ffffffffc020221c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020221e:	3ae7f563          	bgeu	a5,a4,ffffffffc02025c8 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202222:	8f8d                	sub	a5,a5,a1
ffffffffc0202224:	079a                	slli	a5,a5,0x6
ffffffffc0202226:	953e                	add	a0,a0,a5
ffffffffc0202228:	100027f3          	csrr	a5,sstatus
ffffffffc020222c:	8b89                	andi	a5,a5,2
ffffffffc020222e:	2c079763          	bnez	a5,ffffffffc02024fc <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0202232:	000bb783          	ld	a5,0(s7)
ffffffffc0202236:	4585                	li	a1,1
ffffffffc0202238:	739c                	ld	a5,32(a5)
ffffffffc020223a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020223c:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202240:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202242:	078a                	slli	a5,a5,0x2
ffffffffc0202244:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202246:	38e7f163          	bgeu	a5,a4,ffffffffc02025c8 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020224a:	000b3503          	ld	a0,0(s6)
ffffffffc020224e:	fff80737          	lui	a4,0xfff80
ffffffffc0202252:	97ba                	add	a5,a5,a4
ffffffffc0202254:	079a                	slli	a5,a5,0x6
ffffffffc0202256:	953e                	add	a0,a0,a5
ffffffffc0202258:	100027f3          	csrr	a5,sstatus
ffffffffc020225c:	8b89                	andi	a5,a5,2
ffffffffc020225e:	28079363          	bnez	a5,ffffffffc02024e4 <pmm_init+0x5f4>
ffffffffc0202262:	000bb783          	ld	a5,0(s7)
ffffffffc0202266:	4585                	li	a1,1
ffffffffc0202268:	739c                	ld	a5,32(a5)
ffffffffc020226a:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020226c:	00093783          	ld	a5,0(s2)
ffffffffc0202270:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd69a34>
  asm volatile("sfence.vma");
ffffffffc0202274:	12000073          	sfence.vma
ffffffffc0202278:	100027f3          	csrr	a5,sstatus
ffffffffc020227c:	8b89                	andi	a5,a5,2
ffffffffc020227e:	24079963          	bnez	a5,ffffffffc02024d0 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202282:	000bb783          	ld	a5,0(s7)
ffffffffc0202286:	779c                	ld	a5,40(a5)
ffffffffc0202288:	9782                	jalr	a5
ffffffffc020228a:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020228c:	71441363          	bne	s0,s4,ffffffffc0202992 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202290:	00004517          	auipc	a0,0x4
ffffffffc0202294:	e6850513          	addi	a0,a0,-408 # ffffffffc02060f8 <default_pmm_manager+0x4b8>
ffffffffc0202298:	ee9fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020229c:	100027f3          	csrr	a5,sstatus
ffffffffc02022a0:	8b89                	andi	a5,a5,2
ffffffffc02022a2:	20079d63          	bnez	a5,ffffffffc02024bc <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc02022a6:	000bb783          	ld	a5,0(s7)
ffffffffc02022aa:	779c                	ld	a5,40(a5)
ffffffffc02022ac:	9782                	jalr	a5
ffffffffc02022ae:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02022b0:	6098                	ld	a4,0(s1)
ffffffffc02022b2:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02022b6:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02022b8:	00c71793          	slli	a5,a4,0xc
ffffffffc02022bc:	6a05                	lui	s4,0x1
ffffffffc02022be:	02f47c63          	bgeu	s0,a5,ffffffffc02022f6 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02022c2:	00c45793          	srli	a5,s0,0xc
ffffffffc02022c6:	00093503          	ld	a0,0(s2)
ffffffffc02022ca:	2ee7f263          	bgeu	a5,a4,ffffffffc02025ae <pmm_init+0x6be>
ffffffffc02022ce:	0009b583          	ld	a1,0(s3)
ffffffffc02022d2:	4601                	li	a2,0
ffffffffc02022d4:	95a2                	add	a1,a1,s0
ffffffffc02022d6:	863ff0ef          	jal	ra,ffffffffc0201b38 <get_pte>
ffffffffc02022da:	2a050a63          	beqz	a0,ffffffffc020258e <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02022de:	611c                	ld	a5,0(a0)
ffffffffc02022e0:	078a                	slli	a5,a5,0x2
ffffffffc02022e2:	0157f7b3          	and	a5,a5,s5
ffffffffc02022e6:	28879463          	bne	a5,s0,ffffffffc020256e <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02022ea:	6098                	ld	a4,0(s1)
ffffffffc02022ec:	9452                	add	s0,s0,s4
ffffffffc02022ee:	00c71793          	slli	a5,a4,0xc
ffffffffc02022f2:	fcf468e3          	bltu	s0,a5,ffffffffc02022c2 <pmm_init+0x3d2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02022f6:	00093783          	ld	a5,0(s2)
ffffffffc02022fa:	639c                	ld	a5,0(a5)
ffffffffc02022fc:	66079b63          	bnez	a5,ffffffffc0202972 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0202300:	4505                	li	a0,1
ffffffffc0202302:	f2aff0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0202306:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202308:	00093503          	ld	a0,0(s2)
ffffffffc020230c:	4699                	li	a3,6
ffffffffc020230e:	10000613          	li	a2,256
ffffffffc0202312:	85d6                	mv	a1,s5
ffffffffc0202314:	ae7ff0ef          	jal	ra,ffffffffc0201dfa <page_insert>
ffffffffc0202318:	62051d63          	bnez	a0,ffffffffc0202952 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc020231c:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde8a34>
ffffffffc0202320:	4785                	li	a5,1
ffffffffc0202322:	60f71863          	bne	a4,a5,ffffffffc0202932 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202326:	00093503          	ld	a0,0(s2)
ffffffffc020232a:	6405                	lui	s0,0x1
ffffffffc020232c:	4699                	li	a3,6
ffffffffc020232e:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202332:	85d6                	mv	a1,s5
ffffffffc0202334:	ac7ff0ef          	jal	ra,ffffffffc0201dfa <page_insert>
ffffffffc0202338:	46051163          	bnez	a0,ffffffffc020279a <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc020233c:	000aa703          	lw	a4,0(s5)
ffffffffc0202340:	4789                	li	a5,2
ffffffffc0202342:	72f71463          	bne	a4,a5,ffffffffc0202a6a <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202346:	00004597          	auipc	a1,0x4
ffffffffc020234a:	eea58593          	addi	a1,a1,-278 # ffffffffc0206230 <default_pmm_manager+0x5f0>
ffffffffc020234e:	10000513          	li	a0,256
ffffffffc0202352:	309020ef          	jal	ra,ffffffffc0204e5a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202356:	10040593          	addi	a1,s0,256
ffffffffc020235a:	10000513          	li	a0,256
ffffffffc020235e:	30f020ef          	jal	ra,ffffffffc0204e6c <strcmp>
ffffffffc0202362:	6e051463          	bnez	a0,ffffffffc0202a4a <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0202366:	000b3683          	ld	a3,0(s6)
ffffffffc020236a:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc020236e:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202370:	40da86b3          	sub	a3,s5,a3
ffffffffc0202374:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202376:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202378:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020237a:	8031                	srli	s0,s0,0xc
ffffffffc020237c:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202380:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202382:	50f77c63          	bgeu	a4,a5,ffffffffc020289a <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202386:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020238a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020238e:	96be                	add	a3,a3,a5
ffffffffc0202390:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202394:	291020ef          	jal	ra,ffffffffc0204e24 <strlen>
ffffffffc0202398:	68051963          	bnez	a0,ffffffffc0202a2a <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020239c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02023a0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023a2:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02023a6:	068a                	slli	a3,a3,0x2
ffffffffc02023a8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023aa:	20f6ff63          	bgeu	a3,a5,ffffffffc02025c8 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc02023ae:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02023b0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023b2:	4ef47463          	bgeu	s0,a5,ffffffffc020289a <pmm_init+0x9aa>
ffffffffc02023b6:	0009b403          	ld	s0,0(s3)
ffffffffc02023ba:	9436                	add	s0,s0,a3
ffffffffc02023bc:	100027f3          	csrr	a5,sstatus
ffffffffc02023c0:	8b89                	andi	a5,a5,2
ffffffffc02023c2:	18079b63          	bnez	a5,ffffffffc0202558 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc02023c6:	000bb783          	ld	a5,0(s7)
ffffffffc02023ca:	4585                	li	a1,1
ffffffffc02023cc:	8556                	mv	a0,s5
ffffffffc02023ce:	739c                	ld	a5,32(a5)
ffffffffc02023d0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02023d2:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02023d4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023d6:	078a                	slli	a5,a5,0x2
ffffffffc02023d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023da:	1ee7f763          	bgeu	a5,a4,ffffffffc02025c8 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02023de:	000b3503          	ld	a0,0(s6)
ffffffffc02023e2:	fff80737          	lui	a4,0xfff80
ffffffffc02023e6:	97ba                	add	a5,a5,a4
ffffffffc02023e8:	079a                	slli	a5,a5,0x6
ffffffffc02023ea:	953e                	add	a0,a0,a5
ffffffffc02023ec:	100027f3          	csrr	a5,sstatus
ffffffffc02023f0:	8b89                	andi	a5,a5,2
ffffffffc02023f2:	14079763          	bnez	a5,ffffffffc0202540 <pmm_init+0x650>
ffffffffc02023f6:	000bb783          	ld	a5,0(s7)
ffffffffc02023fa:	4585                	li	a1,1
ffffffffc02023fc:	739c                	ld	a5,32(a5)
ffffffffc02023fe:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202400:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202404:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202406:	078a                	slli	a5,a5,0x2
ffffffffc0202408:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020240a:	1ae7ff63          	bgeu	a5,a4,ffffffffc02025c8 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020240e:	000b3503          	ld	a0,0(s6)
ffffffffc0202412:	fff80737          	lui	a4,0xfff80
ffffffffc0202416:	97ba                	add	a5,a5,a4
ffffffffc0202418:	079a                	slli	a5,a5,0x6
ffffffffc020241a:	953e                	add	a0,a0,a5
ffffffffc020241c:	100027f3          	csrr	a5,sstatus
ffffffffc0202420:	8b89                	andi	a5,a5,2
ffffffffc0202422:	10079363          	bnez	a5,ffffffffc0202528 <pmm_init+0x638>
ffffffffc0202426:	000bb783          	ld	a5,0(s7)
ffffffffc020242a:	4585                	li	a1,1
ffffffffc020242c:	739c                	ld	a5,32(a5)
ffffffffc020242e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202430:	00093783          	ld	a5,0(s2)
ffffffffc0202434:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202438:	12000073          	sfence.vma
ffffffffc020243c:	100027f3          	csrr	a5,sstatus
ffffffffc0202440:	8b89                	andi	a5,a5,2
ffffffffc0202442:	0c079963          	bnez	a5,ffffffffc0202514 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202446:	000bb783          	ld	a5,0(s7)
ffffffffc020244a:	779c                	ld	a5,40(a5)
ffffffffc020244c:	9782                	jalr	a5
ffffffffc020244e:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202450:	3a8c1563          	bne	s8,s0,ffffffffc02027fa <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202454:	00004517          	auipc	a0,0x4
ffffffffc0202458:	e5450513          	addi	a0,a0,-428 # ffffffffc02062a8 <default_pmm_manager+0x668>
ffffffffc020245c:	d25fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202460:	6446                	ld	s0,80(sp)
ffffffffc0202462:	60e6                	ld	ra,88(sp)
ffffffffc0202464:	64a6                	ld	s1,72(sp)
ffffffffc0202466:	6906                	ld	s2,64(sp)
ffffffffc0202468:	79e2                	ld	s3,56(sp)
ffffffffc020246a:	7a42                	ld	s4,48(sp)
ffffffffc020246c:	7aa2                	ld	s5,40(sp)
ffffffffc020246e:	7b02                	ld	s6,32(sp)
ffffffffc0202470:	6be2                	ld	s7,24(sp)
ffffffffc0202472:	6c42                	ld	s8,16(sp)
ffffffffc0202474:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202476:	bb8ff06f          	j	ffffffffc020182e <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020247a:	6785                	lui	a5,0x1
ffffffffc020247c:	17fd                	addi	a5,a5,-1
ffffffffc020247e:	96be                	add	a3,a3,a5
ffffffffc0202480:	77fd                	lui	a5,0xfffff
ffffffffc0202482:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202484:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202488:	14c6f063          	bgeu	a3,a2,ffffffffc02025c8 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc020248c:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202490:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202492:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202496:	6a10                	ld	a2,16(a2)
ffffffffc0202498:	069a                	slli	a3,a3,0x6
ffffffffc020249a:	00c7d593          	srli	a1,a5,0xc
ffffffffc020249e:	9536                	add	a0,a0,a3
ffffffffc02024a0:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02024a2:	0009b583          	ld	a1,0(s3)
}
ffffffffc02024a6:	b63d                	j	ffffffffc0201fd4 <pmm_init+0xe4>
        intr_disable();
ffffffffc02024a8:	91afe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02024ac:	000bb783          	ld	a5,0(s7)
ffffffffc02024b0:	779c                	ld	a5,40(a5)
ffffffffc02024b2:	9782                	jalr	a5
ffffffffc02024b4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02024b6:	906fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02024ba:	bea5                	j	ffffffffc0202032 <pmm_init+0x142>
        intr_disable();
ffffffffc02024bc:	906fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02024c0:	000bb783          	ld	a5,0(s7)
ffffffffc02024c4:	779c                	ld	a5,40(a5)
ffffffffc02024c6:	9782                	jalr	a5
ffffffffc02024c8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02024ca:	8f2fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02024ce:	b3cd                	j	ffffffffc02022b0 <pmm_init+0x3c0>
        intr_disable();
ffffffffc02024d0:	8f2fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02024d4:	000bb783          	ld	a5,0(s7)
ffffffffc02024d8:	779c                	ld	a5,40(a5)
ffffffffc02024da:	9782                	jalr	a5
ffffffffc02024dc:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02024de:	8defe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02024e2:	b36d                	j	ffffffffc020228c <pmm_init+0x39c>
ffffffffc02024e4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02024e6:	8dcfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02024ea:	000bb783          	ld	a5,0(s7)
ffffffffc02024ee:	6522                	ld	a0,8(sp)
ffffffffc02024f0:	4585                	li	a1,1
ffffffffc02024f2:	739c                	ld	a5,32(a5)
ffffffffc02024f4:	9782                	jalr	a5
        intr_enable();
ffffffffc02024f6:	8c6fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02024fa:	bb8d                	j	ffffffffc020226c <pmm_init+0x37c>
ffffffffc02024fc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02024fe:	8c4fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202502:	000bb783          	ld	a5,0(s7)
ffffffffc0202506:	6522                	ld	a0,8(sp)
ffffffffc0202508:	4585                	li	a1,1
ffffffffc020250a:	739c                	ld	a5,32(a5)
ffffffffc020250c:	9782                	jalr	a5
        intr_enable();
ffffffffc020250e:	8aefe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202512:	b32d                	j	ffffffffc020223c <pmm_init+0x34c>
        intr_disable();
ffffffffc0202514:	8aefe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202518:	000bb783          	ld	a5,0(s7)
ffffffffc020251c:	779c                	ld	a5,40(a5)
ffffffffc020251e:	9782                	jalr	a5
ffffffffc0202520:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202522:	89afe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202526:	b72d                	j	ffffffffc0202450 <pmm_init+0x560>
ffffffffc0202528:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020252a:	898fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020252e:	000bb783          	ld	a5,0(s7)
ffffffffc0202532:	6522                	ld	a0,8(sp)
ffffffffc0202534:	4585                	li	a1,1
ffffffffc0202536:	739c                	ld	a5,32(a5)
ffffffffc0202538:	9782                	jalr	a5
        intr_enable();
ffffffffc020253a:	882fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020253e:	bdcd                	j	ffffffffc0202430 <pmm_init+0x540>
ffffffffc0202540:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202542:	880fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202546:	000bb783          	ld	a5,0(s7)
ffffffffc020254a:	6522                	ld	a0,8(sp)
ffffffffc020254c:	4585                	li	a1,1
ffffffffc020254e:	739c                	ld	a5,32(a5)
ffffffffc0202550:	9782                	jalr	a5
        intr_enable();
ffffffffc0202552:	86afe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202556:	b56d                	j	ffffffffc0202400 <pmm_init+0x510>
        intr_disable();
ffffffffc0202558:	86afe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc020255c:	000bb783          	ld	a5,0(s7)
ffffffffc0202560:	4585                	li	a1,1
ffffffffc0202562:	8556                	mv	a0,s5
ffffffffc0202564:	739c                	ld	a5,32(a5)
ffffffffc0202566:	9782                	jalr	a5
        intr_enable();
ffffffffc0202568:	854fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020256c:	b59d                	j	ffffffffc02023d2 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020256e:	00004697          	auipc	a3,0x4
ffffffffc0202572:	bea68693          	addi	a3,a3,-1046 # ffffffffc0206158 <default_pmm_manager+0x518>
ffffffffc0202576:	00003617          	auipc	a2,0x3
ffffffffc020257a:	31a60613          	addi	a2,a2,794 # ffffffffc0205890 <commands+0x738>
ffffffffc020257e:	19e00593          	li	a1,414
ffffffffc0202582:	00004517          	auipc	a0,0x4
ffffffffc0202586:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020258a:	ebdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020258e:	00004697          	auipc	a3,0x4
ffffffffc0202592:	b8a68693          	addi	a3,a3,-1142 # ffffffffc0206118 <default_pmm_manager+0x4d8>
ffffffffc0202596:	00003617          	auipc	a2,0x3
ffffffffc020259a:	2fa60613          	addi	a2,a2,762 # ffffffffc0205890 <commands+0x738>
ffffffffc020259e:	19d00593          	li	a1,413
ffffffffc02025a2:	00003517          	auipc	a0,0x3
ffffffffc02025a6:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02025aa:	e9dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02025ae:	86a2                	mv	a3,s0
ffffffffc02025b0:	00003617          	auipc	a2,0x3
ffffffffc02025b4:	6c860613          	addi	a2,a2,1736 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc02025b8:	19d00593          	li	a1,413
ffffffffc02025bc:	00003517          	auipc	a0,0x3
ffffffffc02025c0:	7d450513          	addi	a0,a0,2004 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02025c4:	e83fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02025c8:	c2cff0ef          	jal	ra,ffffffffc02019f4 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02025cc:	00003617          	auipc	a2,0x3
ffffffffc02025d0:	75460613          	addi	a2,a2,1876 # ffffffffc0205d20 <default_pmm_manager+0xe0>
ffffffffc02025d4:	07f00593          	li	a1,127
ffffffffc02025d8:	00003517          	auipc	a0,0x3
ffffffffc02025dc:	7b850513          	addi	a0,a0,1976 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02025e0:	e67fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02025e4:	00003617          	auipc	a2,0x3
ffffffffc02025e8:	73c60613          	addi	a2,a2,1852 # ffffffffc0205d20 <default_pmm_manager+0xe0>
ffffffffc02025ec:	0c300593          	li	a1,195
ffffffffc02025f0:	00003517          	auipc	a0,0x3
ffffffffc02025f4:	7a050513          	addi	a0,a0,1952 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02025f8:	e4ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02025fc:	00004697          	auipc	a3,0x4
ffffffffc0202600:	85468693          	addi	a3,a3,-1964 # ffffffffc0205e50 <default_pmm_manager+0x210>
ffffffffc0202604:	00003617          	auipc	a2,0x3
ffffffffc0202608:	28c60613          	addi	a2,a2,652 # ffffffffc0205890 <commands+0x738>
ffffffffc020260c:	16100593          	li	a1,353
ffffffffc0202610:	00003517          	auipc	a0,0x3
ffffffffc0202614:	78050513          	addi	a0,a0,1920 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202618:	e2ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020261c:	00004697          	auipc	a3,0x4
ffffffffc0202620:	81468693          	addi	a3,a3,-2028 # ffffffffc0205e30 <default_pmm_manager+0x1f0>
ffffffffc0202624:	00003617          	auipc	a2,0x3
ffffffffc0202628:	26c60613          	addi	a2,a2,620 # ffffffffc0205890 <commands+0x738>
ffffffffc020262c:	16000593          	li	a1,352
ffffffffc0202630:	00003517          	auipc	a0,0x3
ffffffffc0202634:	76050513          	addi	a0,a0,1888 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202638:	e0ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020263c:	bd4ff0ef          	jal	ra,ffffffffc0201a10 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202640:	00004697          	auipc	a3,0x4
ffffffffc0202644:	8a068693          	addi	a3,a3,-1888 # ffffffffc0205ee0 <default_pmm_manager+0x2a0>
ffffffffc0202648:	00003617          	auipc	a2,0x3
ffffffffc020264c:	24860613          	addi	a2,a2,584 # ffffffffc0205890 <commands+0x738>
ffffffffc0202650:	16900593          	li	a1,361
ffffffffc0202654:	00003517          	auipc	a0,0x3
ffffffffc0202658:	73c50513          	addi	a0,a0,1852 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020265c:	debfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202660:	00004697          	auipc	a3,0x4
ffffffffc0202664:	85068693          	addi	a3,a3,-1968 # ffffffffc0205eb0 <default_pmm_manager+0x270>
ffffffffc0202668:	00003617          	auipc	a2,0x3
ffffffffc020266c:	22860613          	addi	a2,a2,552 # ffffffffc0205890 <commands+0x738>
ffffffffc0202670:	16600593          	li	a1,358
ffffffffc0202674:	00003517          	auipc	a0,0x3
ffffffffc0202678:	71c50513          	addi	a0,a0,1820 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020267c:	dcbfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202680:	00004697          	auipc	a3,0x4
ffffffffc0202684:	80868693          	addi	a3,a3,-2040 # ffffffffc0205e88 <default_pmm_manager+0x248>
ffffffffc0202688:	00003617          	auipc	a2,0x3
ffffffffc020268c:	20860613          	addi	a2,a2,520 # ffffffffc0205890 <commands+0x738>
ffffffffc0202690:	16200593          	li	a1,354
ffffffffc0202694:	00003517          	auipc	a0,0x3
ffffffffc0202698:	6fc50513          	addi	a0,a0,1788 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020269c:	dabfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02026a0:	00004697          	auipc	a3,0x4
ffffffffc02026a4:	8c868693          	addi	a3,a3,-1848 # ffffffffc0205f68 <default_pmm_manager+0x328>
ffffffffc02026a8:	00003617          	auipc	a2,0x3
ffffffffc02026ac:	1e860613          	addi	a2,a2,488 # ffffffffc0205890 <commands+0x738>
ffffffffc02026b0:	17200593          	li	a1,370
ffffffffc02026b4:	00003517          	auipc	a0,0x3
ffffffffc02026b8:	6dc50513          	addi	a0,a0,1756 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02026bc:	d8bfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02026c0:	00004697          	auipc	a3,0x4
ffffffffc02026c4:	94868693          	addi	a3,a3,-1720 # ffffffffc0206008 <default_pmm_manager+0x3c8>
ffffffffc02026c8:	00003617          	auipc	a2,0x3
ffffffffc02026cc:	1c860613          	addi	a2,a2,456 # ffffffffc0205890 <commands+0x738>
ffffffffc02026d0:	17700593          	li	a1,375
ffffffffc02026d4:	00003517          	auipc	a0,0x3
ffffffffc02026d8:	6bc50513          	addi	a0,a0,1724 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02026dc:	d6bfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02026e0:	00004697          	auipc	a3,0x4
ffffffffc02026e4:	86068693          	addi	a3,a3,-1952 # ffffffffc0205f40 <default_pmm_manager+0x300>
ffffffffc02026e8:	00003617          	auipc	a2,0x3
ffffffffc02026ec:	1a860613          	addi	a2,a2,424 # ffffffffc0205890 <commands+0x738>
ffffffffc02026f0:	16f00593          	li	a1,367
ffffffffc02026f4:	00003517          	auipc	a0,0x3
ffffffffc02026f8:	69c50513          	addi	a0,a0,1692 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02026fc:	d4bfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202700:	86d6                	mv	a3,s5
ffffffffc0202702:	00003617          	auipc	a2,0x3
ffffffffc0202706:	57660613          	addi	a2,a2,1398 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc020270a:	16e00593          	li	a1,366
ffffffffc020270e:	00003517          	auipc	a0,0x3
ffffffffc0202712:	68250513          	addi	a0,a0,1666 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202716:	d31fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020271a:	00004697          	auipc	a3,0x4
ffffffffc020271e:	88668693          	addi	a3,a3,-1914 # ffffffffc0205fa0 <default_pmm_manager+0x360>
ffffffffc0202722:	00003617          	auipc	a2,0x3
ffffffffc0202726:	16e60613          	addi	a2,a2,366 # ffffffffc0205890 <commands+0x738>
ffffffffc020272a:	17c00593          	li	a1,380
ffffffffc020272e:	00003517          	auipc	a0,0x3
ffffffffc0202732:	66250513          	addi	a0,a0,1634 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202736:	d11fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020273a:	00004697          	auipc	a3,0x4
ffffffffc020273e:	92e68693          	addi	a3,a3,-1746 # ffffffffc0206068 <default_pmm_manager+0x428>
ffffffffc0202742:	00003617          	auipc	a2,0x3
ffffffffc0202746:	14e60613          	addi	a2,a2,334 # ffffffffc0205890 <commands+0x738>
ffffffffc020274a:	17b00593          	li	a1,379
ffffffffc020274e:	00003517          	auipc	a0,0x3
ffffffffc0202752:	64250513          	addi	a0,a0,1602 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202756:	cf1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020275a:	00004697          	auipc	a3,0x4
ffffffffc020275e:	8f668693          	addi	a3,a3,-1802 # ffffffffc0206050 <default_pmm_manager+0x410>
ffffffffc0202762:	00003617          	auipc	a2,0x3
ffffffffc0202766:	12e60613          	addi	a2,a2,302 # ffffffffc0205890 <commands+0x738>
ffffffffc020276a:	17a00593          	li	a1,378
ffffffffc020276e:	00003517          	auipc	a0,0x3
ffffffffc0202772:	62250513          	addi	a0,a0,1570 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202776:	cd1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020277a:	00004697          	auipc	a3,0x4
ffffffffc020277e:	8a668693          	addi	a3,a3,-1882 # ffffffffc0206020 <default_pmm_manager+0x3e0>
ffffffffc0202782:	00003617          	auipc	a2,0x3
ffffffffc0202786:	10e60613          	addi	a2,a2,270 # ffffffffc0205890 <commands+0x738>
ffffffffc020278a:	17900593          	li	a1,377
ffffffffc020278e:	00003517          	auipc	a0,0x3
ffffffffc0202792:	60250513          	addi	a0,a0,1538 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202796:	cb1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020279a:	00004697          	auipc	a3,0x4
ffffffffc020279e:	a3e68693          	addi	a3,a3,-1474 # ffffffffc02061d8 <default_pmm_manager+0x598>
ffffffffc02027a2:	00003617          	auipc	a2,0x3
ffffffffc02027a6:	0ee60613          	addi	a2,a2,238 # ffffffffc0205890 <commands+0x738>
ffffffffc02027aa:	1a700593          	li	a1,423
ffffffffc02027ae:	00003517          	auipc	a0,0x3
ffffffffc02027b2:	5e250513          	addi	a0,a0,1506 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02027b6:	c91fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027ba:	00004697          	auipc	a3,0x4
ffffffffc02027be:	83668693          	addi	a3,a3,-1994 # ffffffffc0205ff0 <default_pmm_manager+0x3b0>
ffffffffc02027c2:	00003617          	auipc	a2,0x3
ffffffffc02027c6:	0ce60613          	addi	a2,a2,206 # ffffffffc0205890 <commands+0x738>
ffffffffc02027ca:	17600593          	li	a1,374
ffffffffc02027ce:	00003517          	auipc	a0,0x3
ffffffffc02027d2:	5c250513          	addi	a0,a0,1474 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02027d6:	c71fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02027da:	00004697          	auipc	a3,0x4
ffffffffc02027de:	80668693          	addi	a3,a3,-2042 # ffffffffc0205fe0 <default_pmm_manager+0x3a0>
ffffffffc02027e2:	00003617          	auipc	a2,0x3
ffffffffc02027e6:	0ae60613          	addi	a2,a2,174 # ffffffffc0205890 <commands+0x738>
ffffffffc02027ea:	17500593          	li	a1,373
ffffffffc02027ee:	00003517          	auipc	a0,0x3
ffffffffc02027f2:	5a250513          	addi	a0,a0,1442 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02027f6:	c51fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02027fa:	00004697          	auipc	a3,0x4
ffffffffc02027fe:	8de68693          	addi	a3,a3,-1826 # ffffffffc02060d8 <default_pmm_manager+0x498>
ffffffffc0202802:	00003617          	auipc	a2,0x3
ffffffffc0202806:	08e60613          	addi	a2,a2,142 # ffffffffc0205890 <commands+0x738>
ffffffffc020280a:	1b800593          	li	a1,440
ffffffffc020280e:	00003517          	auipc	a0,0x3
ffffffffc0202812:	58250513          	addi	a0,a0,1410 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202816:	c31fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020281a:	00003697          	auipc	a3,0x3
ffffffffc020281e:	7b668693          	addi	a3,a3,1974 # ffffffffc0205fd0 <default_pmm_manager+0x390>
ffffffffc0202822:	00003617          	auipc	a2,0x3
ffffffffc0202826:	06e60613          	addi	a2,a2,110 # ffffffffc0205890 <commands+0x738>
ffffffffc020282a:	17400593          	li	a1,372
ffffffffc020282e:	00003517          	auipc	a0,0x3
ffffffffc0202832:	56250513          	addi	a0,a0,1378 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202836:	c11fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020283a:	00003697          	auipc	a3,0x3
ffffffffc020283e:	6ee68693          	addi	a3,a3,1774 # ffffffffc0205f28 <default_pmm_manager+0x2e8>
ffffffffc0202842:	00003617          	auipc	a2,0x3
ffffffffc0202846:	04e60613          	addi	a2,a2,78 # ffffffffc0205890 <commands+0x738>
ffffffffc020284a:	18100593          	li	a1,385
ffffffffc020284e:	00003517          	auipc	a0,0x3
ffffffffc0202852:	54250513          	addi	a0,a0,1346 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202856:	bf1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020285a:	00004697          	auipc	a3,0x4
ffffffffc020285e:	82668693          	addi	a3,a3,-2010 # ffffffffc0206080 <default_pmm_manager+0x440>
ffffffffc0202862:	00003617          	auipc	a2,0x3
ffffffffc0202866:	02e60613          	addi	a2,a2,46 # ffffffffc0205890 <commands+0x738>
ffffffffc020286a:	17e00593          	li	a1,382
ffffffffc020286e:	00003517          	auipc	a0,0x3
ffffffffc0202872:	52250513          	addi	a0,a0,1314 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202876:	bd1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020287a:	00003697          	auipc	a3,0x3
ffffffffc020287e:	69668693          	addi	a3,a3,1686 # ffffffffc0205f10 <default_pmm_manager+0x2d0>
ffffffffc0202882:	00003617          	auipc	a2,0x3
ffffffffc0202886:	00e60613          	addi	a2,a2,14 # ffffffffc0205890 <commands+0x738>
ffffffffc020288a:	17d00593          	li	a1,381
ffffffffc020288e:	00003517          	auipc	a0,0x3
ffffffffc0202892:	50250513          	addi	a0,a0,1282 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202896:	bb1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc020289a:	00003617          	auipc	a2,0x3
ffffffffc020289e:	3de60613          	addi	a2,a2,990 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc02028a2:	06900593          	li	a1,105
ffffffffc02028a6:	00003517          	auipc	a0,0x3
ffffffffc02028aa:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc02028ae:	b99fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02028b2:	00003697          	auipc	a3,0x3
ffffffffc02028b6:	7fe68693          	addi	a3,a3,2046 # ffffffffc02060b0 <default_pmm_manager+0x470>
ffffffffc02028ba:	00003617          	auipc	a2,0x3
ffffffffc02028be:	fd660613          	addi	a2,a2,-42 # ffffffffc0205890 <commands+0x738>
ffffffffc02028c2:	18800593          	li	a1,392
ffffffffc02028c6:	00003517          	auipc	a0,0x3
ffffffffc02028ca:	4ca50513          	addi	a0,a0,1226 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02028ce:	b79fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02028d2:	00003697          	auipc	a3,0x3
ffffffffc02028d6:	79668693          	addi	a3,a3,1942 # ffffffffc0206068 <default_pmm_manager+0x428>
ffffffffc02028da:	00003617          	auipc	a2,0x3
ffffffffc02028de:	fb660613          	addi	a2,a2,-74 # ffffffffc0205890 <commands+0x738>
ffffffffc02028e2:	18600593          	li	a1,390
ffffffffc02028e6:	00003517          	auipc	a0,0x3
ffffffffc02028ea:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02028ee:	b59fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02028f2:	00003697          	auipc	a3,0x3
ffffffffc02028f6:	7a668693          	addi	a3,a3,1958 # ffffffffc0206098 <default_pmm_manager+0x458>
ffffffffc02028fa:	00003617          	auipc	a2,0x3
ffffffffc02028fe:	f9660613          	addi	a2,a2,-106 # ffffffffc0205890 <commands+0x738>
ffffffffc0202902:	18500593          	li	a1,389
ffffffffc0202906:	00003517          	auipc	a0,0x3
ffffffffc020290a:	48a50513          	addi	a0,a0,1162 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020290e:	b39fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202912:	00003697          	auipc	a3,0x3
ffffffffc0202916:	75668693          	addi	a3,a3,1878 # ffffffffc0206068 <default_pmm_manager+0x428>
ffffffffc020291a:	00003617          	auipc	a2,0x3
ffffffffc020291e:	f7660613          	addi	a2,a2,-138 # ffffffffc0205890 <commands+0x738>
ffffffffc0202922:	18200593          	li	a1,386
ffffffffc0202926:	00003517          	auipc	a0,0x3
ffffffffc020292a:	46a50513          	addi	a0,a0,1130 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020292e:	b19fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202932:	00004697          	auipc	a3,0x4
ffffffffc0202936:	88e68693          	addi	a3,a3,-1906 # ffffffffc02061c0 <default_pmm_manager+0x580>
ffffffffc020293a:	00003617          	auipc	a2,0x3
ffffffffc020293e:	f5660613          	addi	a2,a2,-170 # ffffffffc0205890 <commands+0x738>
ffffffffc0202942:	1a600593          	li	a1,422
ffffffffc0202946:	00003517          	auipc	a0,0x3
ffffffffc020294a:	44a50513          	addi	a0,a0,1098 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020294e:	af9fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202952:	00004697          	auipc	a3,0x4
ffffffffc0202956:	83668693          	addi	a3,a3,-1994 # ffffffffc0206188 <default_pmm_manager+0x548>
ffffffffc020295a:	00003617          	auipc	a2,0x3
ffffffffc020295e:	f3660613          	addi	a2,a2,-202 # ffffffffc0205890 <commands+0x738>
ffffffffc0202962:	1a500593          	li	a1,421
ffffffffc0202966:	00003517          	auipc	a0,0x3
ffffffffc020296a:	42a50513          	addi	a0,a0,1066 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020296e:	ad9fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202972:	00003697          	auipc	a3,0x3
ffffffffc0202976:	7fe68693          	addi	a3,a3,2046 # ffffffffc0206170 <default_pmm_manager+0x530>
ffffffffc020297a:	00003617          	auipc	a2,0x3
ffffffffc020297e:	f1660613          	addi	a2,a2,-234 # ffffffffc0205890 <commands+0x738>
ffffffffc0202982:	1a100593          	li	a1,417
ffffffffc0202986:	00003517          	auipc	a0,0x3
ffffffffc020298a:	40a50513          	addi	a0,a0,1034 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc020298e:	ab9fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202992:	00003697          	auipc	a3,0x3
ffffffffc0202996:	74668693          	addi	a3,a3,1862 # ffffffffc02060d8 <default_pmm_manager+0x498>
ffffffffc020299a:	00003617          	auipc	a2,0x3
ffffffffc020299e:	ef660613          	addi	a2,a2,-266 # ffffffffc0205890 <commands+0x738>
ffffffffc02029a2:	19000593          	li	a1,400
ffffffffc02029a6:	00003517          	auipc	a0,0x3
ffffffffc02029aa:	3ea50513          	addi	a0,a0,1002 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02029ae:	a99fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02029b2:	00003697          	auipc	a3,0x3
ffffffffc02029b6:	55e68693          	addi	a3,a3,1374 # ffffffffc0205f10 <default_pmm_manager+0x2d0>
ffffffffc02029ba:	00003617          	auipc	a2,0x3
ffffffffc02029be:	ed660613          	addi	a2,a2,-298 # ffffffffc0205890 <commands+0x738>
ffffffffc02029c2:	16a00593          	li	a1,362
ffffffffc02029c6:	00003517          	auipc	a0,0x3
ffffffffc02029ca:	3ca50513          	addi	a0,a0,970 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02029ce:	a79fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02029d2:	00003617          	auipc	a2,0x3
ffffffffc02029d6:	2a660613          	addi	a2,a2,678 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc02029da:	16d00593          	li	a1,365
ffffffffc02029de:	00003517          	auipc	a0,0x3
ffffffffc02029e2:	3b250513          	addi	a0,a0,946 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc02029e6:	a61fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02029ea:	00003697          	auipc	a3,0x3
ffffffffc02029ee:	53e68693          	addi	a3,a3,1342 # ffffffffc0205f28 <default_pmm_manager+0x2e8>
ffffffffc02029f2:	00003617          	auipc	a2,0x3
ffffffffc02029f6:	e9e60613          	addi	a2,a2,-354 # ffffffffc0205890 <commands+0x738>
ffffffffc02029fa:	16b00593          	li	a1,363
ffffffffc02029fe:	00003517          	auipc	a0,0x3
ffffffffc0202a02:	39250513          	addi	a0,a0,914 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202a06:	a41fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202a0a:	00003697          	auipc	a3,0x3
ffffffffc0202a0e:	59668693          	addi	a3,a3,1430 # ffffffffc0205fa0 <default_pmm_manager+0x360>
ffffffffc0202a12:	00003617          	auipc	a2,0x3
ffffffffc0202a16:	e7e60613          	addi	a2,a2,-386 # ffffffffc0205890 <commands+0x738>
ffffffffc0202a1a:	17300593          	li	a1,371
ffffffffc0202a1e:	00003517          	auipc	a0,0x3
ffffffffc0202a22:	37250513          	addi	a0,a0,882 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202a26:	a21fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a2a:	00004697          	auipc	a3,0x4
ffffffffc0202a2e:	85668693          	addi	a3,a3,-1962 # ffffffffc0206280 <default_pmm_manager+0x640>
ffffffffc0202a32:	00003617          	auipc	a2,0x3
ffffffffc0202a36:	e5e60613          	addi	a2,a2,-418 # ffffffffc0205890 <commands+0x738>
ffffffffc0202a3a:	1af00593          	li	a1,431
ffffffffc0202a3e:	00003517          	auipc	a0,0x3
ffffffffc0202a42:	35250513          	addi	a0,a0,850 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202a46:	a01fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a4a:	00003697          	auipc	a3,0x3
ffffffffc0202a4e:	7fe68693          	addi	a3,a3,2046 # ffffffffc0206248 <default_pmm_manager+0x608>
ffffffffc0202a52:	00003617          	auipc	a2,0x3
ffffffffc0202a56:	e3e60613          	addi	a2,a2,-450 # ffffffffc0205890 <commands+0x738>
ffffffffc0202a5a:	1ac00593          	li	a1,428
ffffffffc0202a5e:	00003517          	auipc	a0,0x3
ffffffffc0202a62:	33250513          	addi	a0,a0,818 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202a66:	9e1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202a6a:	00003697          	auipc	a3,0x3
ffffffffc0202a6e:	7ae68693          	addi	a3,a3,1966 # ffffffffc0206218 <default_pmm_manager+0x5d8>
ffffffffc0202a72:	00003617          	auipc	a2,0x3
ffffffffc0202a76:	e1e60613          	addi	a2,a2,-482 # ffffffffc0205890 <commands+0x738>
ffffffffc0202a7a:	1a800593          	li	a1,424
ffffffffc0202a7e:	00003517          	auipc	a0,0x3
ffffffffc0202a82:	31250513          	addi	a0,a0,786 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202a86:	9c1fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202a8a <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a8a:	12058073          	sfence.vma	a1
}
ffffffffc0202a8e:	8082                	ret

ffffffffc0202a90 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a90:	7179                	addi	sp,sp,-48
ffffffffc0202a92:	e84a                	sd	s2,16(sp)
ffffffffc0202a94:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202a96:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a98:	f022                	sd	s0,32(sp)
ffffffffc0202a9a:	ec26                	sd	s1,24(sp)
ffffffffc0202a9c:	e44e                	sd	s3,8(sp)
ffffffffc0202a9e:	f406                	sd	ra,40(sp)
ffffffffc0202aa0:	84ae                	mv	s1,a1
ffffffffc0202aa2:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202aa4:	f89fe0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0202aa8:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202aaa:	cd09                	beqz	a0,ffffffffc0202ac4 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202aac:	85aa                	mv	a1,a0
ffffffffc0202aae:	86ce                	mv	a3,s3
ffffffffc0202ab0:	8626                	mv	a2,s1
ffffffffc0202ab2:	854a                	mv	a0,s2
ffffffffc0202ab4:	b46ff0ef          	jal	ra,ffffffffc0201dfa <page_insert>
ffffffffc0202ab8:	ed21                	bnez	a0,ffffffffc0202b10 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0202aba:	00014797          	auipc	a5,0x14
ffffffffc0202abe:	ade7a783          	lw	a5,-1314(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc0202ac2:	eb89                	bnez	a5,ffffffffc0202ad4 <pgdir_alloc_page+0x44>
}
ffffffffc0202ac4:	70a2                	ld	ra,40(sp)
ffffffffc0202ac6:	8522                	mv	a0,s0
ffffffffc0202ac8:	7402                	ld	s0,32(sp)
ffffffffc0202aca:	64e2                	ld	s1,24(sp)
ffffffffc0202acc:	6942                	ld	s2,16(sp)
ffffffffc0202ace:	69a2                	ld	s3,8(sp)
ffffffffc0202ad0:	6145                	addi	sp,sp,48
ffffffffc0202ad2:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202ad4:	4681                	li	a3,0
ffffffffc0202ad6:	8622                	mv	a2,s0
ffffffffc0202ad8:	85a6                	mv	a1,s1
ffffffffc0202ada:	00014517          	auipc	a0,0x14
ffffffffc0202ade:	ac653503          	ld	a0,-1338(a0) # ffffffffc02165a0 <check_mm_struct>
ffffffffc0202ae2:	7c8000ef          	jal	ra,ffffffffc02032aa <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202ae6:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202ae8:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202aea:	4785                	li	a5,1
ffffffffc0202aec:	fcf70ce3          	beq	a4,a5,ffffffffc0202ac4 <pgdir_alloc_page+0x34>
ffffffffc0202af0:	00003697          	auipc	a3,0x3
ffffffffc0202af4:	7d868693          	addi	a3,a3,2008 # ffffffffc02062c8 <default_pmm_manager+0x688>
ffffffffc0202af8:	00003617          	auipc	a2,0x3
ffffffffc0202afc:	d9860613          	addi	a2,a2,-616 # ffffffffc0205890 <commands+0x738>
ffffffffc0202b00:	14800593          	li	a1,328
ffffffffc0202b04:	00003517          	auipc	a0,0x3
ffffffffc0202b08:	28c50513          	addi	a0,a0,652 # ffffffffc0205d90 <default_pmm_manager+0x150>
ffffffffc0202b0c:	93bfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b10:	100027f3          	csrr	a5,sstatus
ffffffffc0202b14:	8b89                	andi	a5,a5,2
ffffffffc0202b16:	eb99                	bnez	a5,ffffffffc0202b2c <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0202b18:	00014797          	auipc	a5,0x14
ffffffffc0202b1c:	a607b783          	ld	a5,-1440(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0202b20:	739c                	ld	a5,32(a5)
ffffffffc0202b22:	8522                	mv	a0,s0
ffffffffc0202b24:	4585                	li	a1,1
ffffffffc0202b26:	9782                	jalr	a5
            return NULL;
ffffffffc0202b28:	4401                	li	s0,0
ffffffffc0202b2a:	bf69                	j	ffffffffc0202ac4 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0202b2c:	a97fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b30:	00014797          	auipc	a5,0x14
ffffffffc0202b34:	a487b783          	ld	a5,-1464(a5) # ffffffffc0216578 <pmm_manager>
ffffffffc0202b38:	739c                	ld	a5,32(a5)
ffffffffc0202b3a:	8522                	mv	a0,s0
ffffffffc0202b3c:	4585                	li	a1,1
ffffffffc0202b3e:	9782                	jalr	a5
            return NULL;
ffffffffc0202b40:	4401                	li	s0,0
        intr_enable();
ffffffffc0202b42:	a7bfd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202b46:	bfbd                	j	ffffffffc0202ac4 <pgdir_alloc_page+0x34>

ffffffffc0202b48 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202b48:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202b4a:	00003617          	auipc	a2,0x3
ffffffffc0202b4e:	1fe60613          	addi	a2,a2,510 # ffffffffc0205d48 <default_pmm_manager+0x108>
ffffffffc0202b52:	06200593          	li	a1,98
ffffffffc0202b56:	00003517          	auipc	a0,0x3
ffffffffc0202b5a:	14a50513          	addi	a0,a0,330 # ffffffffc0205ca0 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0202b5e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202b60:	8e7fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202b64 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202b64:	7135                	addi	sp,sp,-160
ffffffffc0202b66:	ed06                	sd	ra,152(sp)
ffffffffc0202b68:	e922                	sd	s0,144(sp)
ffffffffc0202b6a:	e526                	sd	s1,136(sp)
ffffffffc0202b6c:	e14a                	sd	s2,128(sp)
ffffffffc0202b6e:	fcce                	sd	s3,120(sp)
ffffffffc0202b70:	f8d2                	sd	s4,112(sp)
ffffffffc0202b72:	f4d6                	sd	s5,104(sp)
ffffffffc0202b74:	f0da                	sd	s6,96(sp)
ffffffffc0202b76:	ecde                	sd	s7,88(sp)
ffffffffc0202b78:	e8e2                	sd	s8,80(sp)
ffffffffc0202b7a:	e4e6                	sd	s9,72(sp)
ffffffffc0202b7c:	e0ea                	sd	s10,64(sp)
ffffffffc0202b7e:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b80:	566010ef          	jal	ra,ffffffffc02040e6 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b84:	00014697          	auipc	a3,0x14
ffffffffc0202b88:	a046b683          	ld	a3,-1532(a3) # ffffffffc0216588 <max_swap_offset>
ffffffffc0202b8c:	010007b7          	lui	a5,0x1000
ffffffffc0202b90:	ff968713          	addi	a4,a3,-7
ffffffffc0202b94:	17e1                	addi	a5,a5,-8
ffffffffc0202b96:	42e7e063          	bltu	a5,a4,ffffffffc0202fb6 <swap_init+0x452>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b9a:	00008797          	auipc	a5,0x8
ffffffffc0202b9e:	47678793          	addi	a5,a5,1142 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202ba2:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202ba4:	00014b97          	auipc	s7,0x14
ffffffffc0202ba8:	9ecb8b93          	addi	s7,s7,-1556 # ffffffffc0216590 <sm>
ffffffffc0202bac:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0202bb0:	9702                	jalr	a4
ffffffffc0202bb2:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0202bb4:	c10d                	beqz	a0,ffffffffc0202bd6 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202bb6:	60ea                	ld	ra,152(sp)
ffffffffc0202bb8:	644a                	ld	s0,144(sp)
ffffffffc0202bba:	64aa                	ld	s1,136(sp)
ffffffffc0202bbc:	79e6                	ld	s3,120(sp)
ffffffffc0202bbe:	7a46                	ld	s4,112(sp)
ffffffffc0202bc0:	7aa6                	ld	s5,104(sp)
ffffffffc0202bc2:	7b06                	ld	s6,96(sp)
ffffffffc0202bc4:	6be6                	ld	s7,88(sp)
ffffffffc0202bc6:	6c46                	ld	s8,80(sp)
ffffffffc0202bc8:	6ca6                	ld	s9,72(sp)
ffffffffc0202bca:	6d06                	ld	s10,64(sp)
ffffffffc0202bcc:	7de2                	ld	s11,56(sp)
ffffffffc0202bce:	854a                	mv	a0,s2
ffffffffc0202bd0:	690a                	ld	s2,128(sp)
ffffffffc0202bd2:	610d                	addi	sp,sp,160
ffffffffc0202bd4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bd6:	000bb783          	ld	a5,0(s7)
ffffffffc0202bda:	00003517          	auipc	a0,0x3
ffffffffc0202bde:	73650513          	addi	a0,a0,1846 # ffffffffc0206310 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc0202be2:	00010417          	auipc	s0,0x10
ffffffffc0202be6:	87e40413          	addi	s0,s0,-1922 # ffffffffc0212460 <free_area>
ffffffffc0202bea:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202bec:	4785                	li	a5,1
ffffffffc0202bee:	00014717          	auipc	a4,0x14
ffffffffc0202bf2:	9af72523          	sw	a5,-1622(a4) # ffffffffc0216598 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bf6:	d8afd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202bfa:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202bfc:	4d01                	li	s10,0
ffffffffc0202bfe:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c00:	32878b63          	beq	a5,s0,ffffffffc0202f36 <swap_init+0x3d2>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202c04:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202c08:	8b09                	andi	a4,a4,2
ffffffffc0202c0a:	32070863          	beqz	a4,ffffffffc0202f3a <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc0202c0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c12:	679c                	ld	a5,8(a5)
ffffffffc0202c14:	2d85                	addiw	s11,s11,1
ffffffffc0202c16:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c1a:	fe8795e3          	bne	a5,s0,ffffffffc0202c04 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202c1e:	84ea                	mv	s1,s10
ffffffffc0202c20:	edffe0ef          	jal	ra,ffffffffc0201afe <nr_free_pages>
ffffffffc0202c24:	42951163          	bne	a0,s1,ffffffffc0203046 <swap_init+0x4e2>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202c28:	866a                	mv	a2,s10
ffffffffc0202c2a:	85ee                	mv	a1,s11
ffffffffc0202c2c:	00003517          	auipc	a0,0x3
ffffffffc0202c30:	6fc50513          	addi	a0,a0,1788 # ffffffffc0206328 <default_pmm_manager+0x6e8>
ffffffffc0202c34:	d4cfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202c38:	41f000ef          	jal	ra,ffffffffc0203856 <mm_create>
ffffffffc0202c3c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202c3e:	46050463          	beqz	a0,ffffffffc02030a6 <swap_init+0x542>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202c42:	00014797          	auipc	a5,0x14
ffffffffc0202c46:	95e78793          	addi	a5,a5,-1698 # ffffffffc02165a0 <check_mm_struct>
ffffffffc0202c4a:	6398                	ld	a4,0(a5)
ffffffffc0202c4c:	3c071d63          	bnez	a4,ffffffffc0203026 <swap_init+0x4c2>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c50:	00014717          	auipc	a4,0x14
ffffffffc0202c54:	91070713          	addi	a4,a4,-1776 # ffffffffc0216560 <boot_pgdir>
ffffffffc0202c58:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0202c5c:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0202c5e:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c62:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c66:	42079063          	bnez	a5,ffffffffc0203086 <swap_init+0x522>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c6a:	6599                	lui	a1,0x6
ffffffffc0202c6c:	460d                	li	a2,3
ffffffffc0202c6e:	6505                	lui	a0,0x1
ffffffffc0202c70:	42f000ef          	jal	ra,ffffffffc020389e <vma_create>
ffffffffc0202c74:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c76:	52050463          	beqz	a0,ffffffffc020319e <swap_init+0x63a>

     insert_vma_struct(mm, vma);
ffffffffc0202c7a:	8556                	mv	a0,s5
ffffffffc0202c7c:	491000ef          	jal	ra,ffffffffc020390c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c80:	00003517          	auipc	a0,0x3
ffffffffc0202c84:	71850513          	addi	a0,a0,1816 # ffffffffc0206398 <default_pmm_manager+0x758>
ffffffffc0202c88:	cf8fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c8c:	018ab503          	ld	a0,24(s5)
ffffffffc0202c90:	4605                	li	a2,1
ffffffffc0202c92:	6585                	lui	a1,0x1
ffffffffc0202c94:	ea5fe0ef          	jal	ra,ffffffffc0201b38 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c98:	4c050363          	beqz	a0,ffffffffc020315e <swap_init+0x5fa>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c9c:	00003517          	auipc	a0,0x3
ffffffffc0202ca0:	74c50513          	addi	a0,a0,1868 # ffffffffc02063e8 <default_pmm_manager+0x7a8>
ffffffffc0202ca4:	0000f497          	auipc	s1,0xf
ffffffffc0202ca8:	7f448493          	addi	s1,s1,2036 # ffffffffc0212498 <check_rp>
ffffffffc0202cac:	cd4fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cb0:	00010997          	auipc	s3,0x10
ffffffffc0202cb4:	80898993          	addi	s3,s3,-2040 # ffffffffc02124b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202cb8:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0202cba:	4505                	li	a0,1
ffffffffc0202cbc:	d71fe0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
ffffffffc0202cc0:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0202cc4:	2c050963          	beqz	a0,ffffffffc0202f96 <swap_init+0x432>
ffffffffc0202cc8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202cca:	8b89                	andi	a5,a5,2
ffffffffc0202ccc:	32079d63          	bnez	a5,ffffffffc0203006 <swap_init+0x4a2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cd0:	0a21                	addi	s4,s4,8
ffffffffc0202cd2:	ff3a14e3          	bne	s4,s3,ffffffffc0202cba <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202cd6:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202cd8:	0000fa17          	auipc	s4,0xf
ffffffffc0202cdc:	7c0a0a13          	addi	s4,s4,1984 # ffffffffc0212498 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0202ce0:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0202ce2:	ec3e                	sd	a5,24(sp)
ffffffffc0202ce4:	641c                	ld	a5,8(s0)
ffffffffc0202ce6:	e400                	sd	s0,8(s0)
ffffffffc0202ce8:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202cea:	481c                	lw	a5,16(s0)
ffffffffc0202cec:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202cee:	0000f797          	auipc	a5,0xf
ffffffffc0202cf2:	7807a123          	sw	zero,1922(a5) # ffffffffc0212470 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202cf6:	000a3503          	ld	a0,0(s4)
ffffffffc0202cfa:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cfc:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0202cfe:	dc1fe0ef          	jal	ra,ffffffffc0201abe <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d02:	ff3a1ae3          	bne	s4,s3,ffffffffc0202cf6 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d06:	01042a03          	lw	s4,16(s0)
ffffffffc0202d0a:	4791                	li	a5,4
ffffffffc0202d0c:	42fa1963          	bne	s4,a5,ffffffffc020313e <swap_init+0x5da>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	76050513          	addi	a0,a0,1888 # ffffffffc0206470 <default_pmm_manager+0x830>
ffffffffc0202d18:	c68fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d1c:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202d1e:	00014797          	auipc	a5,0x14
ffffffffc0202d22:	8807a523          	sw	zero,-1910(a5) # ffffffffc02165a8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d26:	4629                	li	a2,10
ffffffffc0202d28:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202d2c:	00014697          	auipc	a3,0x14
ffffffffc0202d30:	87c6a683          	lw	a3,-1924(a3) # ffffffffc02165a8 <pgfault_num>
ffffffffc0202d34:	4585                	li	a1,1
ffffffffc0202d36:	00014797          	auipc	a5,0x14
ffffffffc0202d3a:	87278793          	addi	a5,a5,-1934 # ffffffffc02165a8 <pgfault_num>
ffffffffc0202d3e:	54b69063          	bne	a3,a1,ffffffffc020327e <swap_init+0x71a>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d42:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202d46:	4398                	lw	a4,0(a5)
ffffffffc0202d48:	2701                	sext.w	a4,a4
ffffffffc0202d4a:	3cd71a63          	bne	a4,a3,ffffffffc020311e <swap_init+0x5ba>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d4e:	6689                	lui	a3,0x2
ffffffffc0202d50:	462d                	li	a2,11
ffffffffc0202d52:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d56:	4398                	lw	a4,0(a5)
ffffffffc0202d58:	4589                	li	a1,2
ffffffffc0202d5a:	2701                	sext.w	a4,a4
ffffffffc0202d5c:	4ab71163          	bne	a4,a1,ffffffffc02031fe <swap_init+0x69a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d60:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d64:	4394                	lw	a3,0(a5)
ffffffffc0202d66:	2681                	sext.w	a3,a3
ffffffffc0202d68:	4ae69b63          	bne	a3,a4,ffffffffc020321e <swap_init+0x6ba>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d6c:	668d                	lui	a3,0x3
ffffffffc0202d6e:	4631                	li	a2,12
ffffffffc0202d70:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d74:	4398                	lw	a4,0(a5)
ffffffffc0202d76:	458d                	li	a1,3
ffffffffc0202d78:	2701                	sext.w	a4,a4
ffffffffc0202d7a:	4cb71263          	bne	a4,a1,ffffffffc020323e <swap_init+0x6da>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d7e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d82:	4394                	lw	a3,0(a5)
ffffffffc0202d84:	2681                	sext.w	a3,a3
ffffffffc0202d86:	4ce69c63          	bne	a3,a4,ffffffffc020325e <swap_init+0x6fa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d8a:	6691                	lui	a3,0x4
ffffffffc0202d8c:	4635                	li	a2,13
ffffffffc0202d8e:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d92:	4398                	lw	a4,0(a5)
ffffffffc0202d94:	2701                	sext.w	a4,a4
ffffffffc0202d96:	43471463          	bne	a4,s4,ffffffffc02031be <swap_init+0x65a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d9a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202d9e:	439c                	lw	a5,0(a5)
ffffffffc0202da0:	2781                	sext.w	a5,a5
ffffffffc0202da2:	42e79e63          	bne	a5,a4,ffffffffc02031de <swap_init+0x67a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202da6:	481c                	lw	a5,16(s0)
ffffffffc0202da8:	2a079f63          	bnez	a5,ffffffffc0203066 <swap_init+0x502>
ffffffffc0202dac:	0000f797          	auipc	a5,0xf
ffffffffc0202db0:	70c78793          	addi	a5,a5,1804 # ffffffffc02124b8 <swap_in_seq_no>
ffffffffc0202db4:	0000f717          	auipc	a4,0xf
ffffffffc0202db8:	72c70713          	addi	a4,a4,1836 # ffffffffc02124e0 <swap_out_seq_no>
ffffffffc0202dbc:	0000f617          	auipc	a2,0xf
ffffffffc0202dc0:	72460613          	addi	a2,a2,1828 # ffffffffc02124e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202dc4:	56fd                	li	a3,-1
ffffffffc0202dc6:	c394                	sw	a3,0(a5)
ffffffffc0202dc8:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202dca:	0791                	addi	a5,a5,4
ffffffffc0202dcc:	0711                	addi	a4,a4,4
ffffffffc0202dce:	fec79ce3          	bne	a5,a2,ffffffffc0202dc6 <swap_init+0x262>
ffffffffc0202dd2:	0000f717          	auipc	a4,0xf
ffffffffc0202dd6:	6a670713          	addi	a4,a4,1702 # ffffffffc0212478 <check_ptep>
ffffffffc0202dda:	0000f697          	auipc	a3,0xf
ffffffffc0202dde:	6be68693          	addi	a3,a3,1726 # ffffffffc0212498 <check_rp>
ffffffffc0202de2:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202de4:	00013c17          	auipc	s8,0x13
ffffffffc0202de8:	784c0c13          	addi	s8,s8,1924 # ffffffffc0216568 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dec:	00013c97          	auipc	s9,0x13
ffffffffc0202df0:	784c8c93          	addi	s9,s9,1924 # ffffffffc0216570 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202df4:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202df8:	4601                	li	a2,0
ffffffffc0202dfa:	855a                	mv	a0,s6
ffffffffc0202dfc:	e836                	sd	a3,16(sp)
ffffffffc0202dfe:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202e00:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e02:	d37fe0ef          	jal	ra,ffffffffc0201b38 <get_pte>
ffffffffc0202e06:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202e08:	65a2                	ld	a1,8(sp)
ffffffffc0202e0a:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e0c:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0202e0e:	1c050063          	beqz	a0,ffffffffc0202fce <swap_init+0x46a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202e12:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e14:	0017f613          	andi	a2,a5,1
ffffffffc0202e18:	1c060b63          	beqz	a2,ffffffffc0202fee <swap_init+0x48a>
    if (PPN(pa) >= npage) {
ffffffffc0202e1c:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e20:	078a                	slli	a5,a5,0x2
ffffffffc0202e22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e24:	12c7fd63          	bgeu	a5,a2,ffffffffc0202f5e <swap_init+0x3fa>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e28:	00004617          	auipc	a2,0x4
ffffffffc0202e2c:	1f060613          	addi	a2,a2,496 # ffffffffc0207018 <nbase>
ffffffffc0202e30:	00063a03          	ld	s4,0(a2)
ffffffffc0202e34:	000cb603          	ld	a2,0(s9)
ffffffffc0202e38:	6288                	ld	a0,0(a3)
ffffffffc0202e3a:	414787b3          	sub	a5,a5,s4
ffffffffc0202e3e:	079a                	slli	a5,a5,0x6
ffffffffc0202e40:	97b2                	add	a5,a5,a2
ffffffffc0202e42:	12f51a63          	bne	a0,a5,ffffffffc0202f76 <swap_init+0x412>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e46:	6785                	lui	a5,0x1
ffffffffc0202e48:	95be                	add	a1,a1,a5
ffffffffc0202e4a:	6795                	lui	a5,0x5
ffffffffc0202e4c:	0721                	addi	a4,a4,8
ffffffffc0202e4e:	06a1                	addi	a3,a3,8
ffffffffc0202e50:	faf592e3          	bne	a1,a5,ffffffffc0202df4 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e54:	00003517          	auipc	a0,0x3
ffffffffc0202e58:	6c450513          	addi	a0,a0,1732 # ffffffffc0206518 <default_pmm_manager+0x8d8>
ffffffffc0202e5c:	b24fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e60:	000bb783          	ld	a5,0(s7)
ffffffffc0202e64:	7f9c                	ld	a5,56(a5)
ffffffffc0202e66:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e68:	30051b63          	bnez	a0,ffffffffc020317e <swap_init+0x61a>

     nr_free = nr_free_store;
ffffffffc0202e6c:	77a2                	ld	a5,40(sp)
ffffffffc0202e6e:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202e70:	67e2                	ld	a5,24(sp)
ffffffffc0202e72:	e01c                	sd	a5,0(s0)
ffffffffc0202e74:	7782                	ld	a5,32(sp)
ffffffffc0202e76:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e78:	6088                	ld	a0,0(s1)
ffffffffc0202e7a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e7c:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0202e7e:	c41fe0ef          	jal	ra,ffffffffc0201abe <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e82:	ff349be3          	bne	s1,s3,ffffffffc0202e78 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202e86:	8556                	mv	a0,s5
ffffffffc0202e88:	355000ef          	jal	ra,ffffffffc02039dc <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202e8c:	00013797          	auipc	a5,0x13
ffffffffc0202e90:	6d478793          	addi	a5,a5,1748 # ffffffffc0216560 <boot_pgdir>
ffffffffc0202e94:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202e96:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e9a:	639c                	ld	a5,0(a5)
ffffffffc0202e9c:	078a                	slli	a5,a5,0x2
ffffffffc0202e9e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ea0:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202f5a <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ea4:	414786b3          	sub	a3,a5,s4
ffffffffc0202ea8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202eaa:	8699                	srai	a3,a3,0x6
ffffffffc0202eac:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202eae:	00c69793          	slli	a5,a3,0xc
ffffffffc0202eb2:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202eb4:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202eb8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202eba:	22e7f663          	bgeu	a5,a4,ffffffffc02030e6 <swap_init+0x582>
     free_page(pde2page(pd0[0]));
ffffffffc0202ebe:	00013797          	auipc	a5,0x13
ffffffffc0202ec2:	6c27b783          	ld	a5,1730(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc0202ec6:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ec8:	629c                	ld	a5,0(a3)
ffffffffc0202eca:	078a                	slli	a5,a5,0x2
ffffffffc0202ecc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ece:	08e7f663          	bgeu	a5,a4,ffffffffc0202f5a <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ed2:	414787b3          	sub	a5,a5,s4
ffffffffc0202ed6:	079a                	slli	a5,a5,0x6
ffffffffc0202ed8:	953e                	add	a0,a0,a5
ffffffffc0202eda:	4585                	li	a1,1
ffffffffc0202edc:	be3fe0ef          	jal	ra,ffffffffc0201abe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ee0:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202ee4:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ee8:	078a                	slli	a5,a5,0x2
ffffffffc0202eea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202eec:	06e7f763          	bgeu	a5,a4,ffffffffc0202f5a <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ef0:	000cb503          	ld	a0,0(s9)
ffffffffc0202ef4:	414787b3          	sub	a5,a5,s4
ffffffffc0202ef8:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202efa:	4585                	li	a1,1
ffffffffc0202efc:	953e                	add	a0,a0,a5
ffffffffc0202efe:	bc1fe0ef          	jal	ra,ffffffffc0201abe <free_pages>
     pgdir[0] = 0;
ffffffffc0202f02:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202f06:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202f0a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f0c:	00878a63          	beq	a5,s0,ffffffffc0202f20 <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202f10:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f14:	679c                	ld	a5,8(a5)
ffffffffc0202f16:	3dfd                	addiw	s11,s11,-1
ffffffffc0202f18:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f1c:	fe879ae3          	bne	a5,s0,ffffffffc0202f10 <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc0202f20:	1c0d9f63          	bnez	s11,ffffffffc02030fe <swap_init+0x59a>
     assert(total==0);
ffffffffc0202f24:	1a0d1163          	bnez	s10,ffffffffc02030c6 <swap_init+0x562>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f28:	00003517          	auipc	a0,0x3
ffffffffc0202f2c:	64050513          	addi	a0,a0,1600 # ffffffffc0206568 <default_pmm_manager+0x928>
ffffffffc0202f30:	a50fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202f34:	b149                	j	ffffffffc0202bb6 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f36:	4481                	li	s1,0
ffffffffc0202f38:	b1e5                	j	ffffffffc0202c20 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0202f3a:	00003697          	auipc	a3,0x3
ffffffffc0202f3e:	94668693          	addi	a3,a3,-1722 # ffffffffc0205880 <commands+0x728>
ffffffffc0202f42:	00003617          	auipc	a2,0x3
ffffffffc0202f46:	94e60613          	addi	a2,a2,-1714 # ffffffffc0205890 <commands+0x738>
ffffffffc0202f4a:	0bd00593          	li	a1,189
ffffffffc0202f4e:	00003517          	auipc	a0,0x3
ffffffffc0202f52:	3b250513          	addi	a0,a0,946 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0202f56:	cf0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202f5a:	befff0ef          	jal	ra,ffffffffc0202b48 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0202f5e:	00003617          	auipc	a2,0x3
ffffffffc0202f62:	dea60613          	addi	a2,a2,-534 # ffffffffc0205d48 <default_pmm_manager+0x108>
ffffffffc0202f66:	06200593          	li	a1,98
ffffffffc0202f6a:	00003517          	auipc	a0,0x3
ffffffffc0202f6e:	d3650513          	addi	a0,a0,-714 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc0202f72:	cd4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f76:	00003697          	auipc	a3,0x3
ffffffffc0202f7a:	57a68693          	addi	a3,a3,1402 # ffffffffc02064f0 <default_pmm_manager+0x8b0>
ffffffffc0202f7e:	00003617          	auipc	a2,0x3
ffffffffc0202f82:	91260613          	addi	a2,a2,-1774 # ffffffffc0205890 <commands+0x738>
ffffffffc0202f86:	0fd00593          	li	a1,253
ffffffffc0202f8a:	00003517          	auipc	a0,0x3
ffffffffc0202f8e:	37650513          	addi	a0,a0,886 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0202f92:	cb4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202f96:	00003697          	auipc	a3,0x3
ffffffffc0202f9a:	47a68693          	addi	a3,a3,1146 # ffffffffc0206410 <default_pmm_manager+0x7d0>
ffffffffc0202f9e:	00003617          	auipc	a2,0x3
ffffffffc0202fa2:	8f260613          	addi	a2,a2,-1806 # ffffffffc0205890 <commands+0x738>
ffffffffc0202fa6:	0dd00593          	li	a1,221
ffffffffc0202faa:	00003517          	auipc	a0,0x3
ffffffffc0202fae:	35650513          	addi	a0,a0,854 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0202fb2:	c94fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202fb6:	00003617          	auipc	a2,0x3
ffffffffc0202fba:	32a60613          	addi	a2,a2,810 # ffffffffc02062e0 <default_pmm_manager+0x6a0>
ffffffffc0202fbe:	02a00593          	li	a1,42
ffffffffc0202fc2:	00003517          	auipc	a0,0x3
ffffffffc0202fc6:	33e50513          	addi	a0,a0,830 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0202fca:	c7cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202fce:	00003697          	auipc	a3,0x3
ffffffffc0202fd2:	50a68693          	addi	a3,a3,1290 # ffffffffc02064d8 <default_pmm_manager+0x898>
ffffffffc0202fd6:	00003617          	auipc	a2,0x3
ffffffffc0202fda:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0205890 <commands+0x738>
ffffffffc0202fde:	0fc00593          	li	a1,252
ffffffffc0202fe2:	00003517          	auipc	a0,0x3
ffffffffc0202fe6:	31e50513          	addi	a0,a0,798 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0202fea:	c5cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202fee:	00003617          	auipc	a2,0x3
ffffffffc0202ff2:	d7a60613          	addi	a2,a2,-646 # ffffffffc0205d68 <default_pmm_manager+0x128>
ffffffffc0202ff6:	07400593          	li	a1,116
ffffffffc0202ffa:	00003517          	auipc	a0,0x3
ffffffffc0202ffe:	ca650513          	addi	a0,a0,-858 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc0203002:	c44fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203006:	00003697          	auipc	a3,0x3
ffffffffc020300a:	42268693          	addi	a3,a3,1058 # ffffffffc0206428 <default_pmm_manager+0x7e8>
ffffffffc020300e:	00003617          	auipc	a2,0x3
ffffffffc0203012:	88260613          	addi	a2,a2,-1918 # ffffffffc0205890 <commands+0x738>
ffffffffc0203016:	0de00593          	li	a1,222
ffffffffc020301a:	00003517          	auipc	a0,0x3
ffffffffc020301e:	2e650513          	addi	a0,a0,742 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0203022:	c24fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203026:	00003697          	auipc	a3,0x3
ffffffffc020302a:	33a68693          	addi	a3,a3,826 # ffffffffc0206360 <default_pmm_manager+0x720>
ffffffffc020302e:	00003617          	auipc	a2,0x3
ffffffffc0203032:	86260613          	addi	a2,a2,-1950 # ffffffffc0205890 <commands+0x738>
ffffffffc0203036:	0c800593          	li	a1,200
ffffffffc020303a:	00003517          	auipc	a0,0x3
ffffffffc020303e:	2c650513          	addi	a0,a0,710 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0203042:	c04fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203046:	00003697          	auipc	a3,0x3
ffffffffc020304a:	87a68693          	addi	a3,a3,-1926 # ffffffffc02058c0 <commands+0x768>
ffffffffc020304e:	00003617          	auipc	a2,0x3
ffffffffc0203052:	84260613          	addi	a2,a2,-1982 # ffffffffc0205890 <commands+0x738>
ffffffffc0203056:	0c000593          	li	a1,192
ffffffffc020305a:	00003517          	auipc	a0,0x3
ffffffffc020305e:	2a650513          	addi	a0,a0,678 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0203062:	be4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert( nr_free == 0);         
ffffffffc0203066:	00003697          	auipc	a3,0x3
ffffffffc020306a:	a0268693          	addi	a3,a3,-1534 # ffffffffc0205a68 <commands+0x910>
ffffffffc020306e:	00003617          	auipc	a2,0x3
ffffffffc0203072:	82260613          	addi	a2,a2,-2014 # ffffffffc0205890 <commands+0x738>
ffffffffc0203076:	0f400593          	li	a1,244
ffffffffc020307a:	00003517          	auipc	a0,0x3
ffffffffc020307e:	28650513          	addi	a0,a0,646 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0203082:	bc4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203086:	00003697          	auipc	a3,0x3
ffffffffc020308a:	2f268693          	addi	a3,a3,754 # ffffffffc0206378 <default_pmm_manager+0x738>
ffffffffc020308e:	00003617          	auipc	a2,0x3
ffffffffc0203092:	80260613          	addi	a2,a2,-2046 # ffffffffc0205890 <commands+0x738>
ffffffffc0203096:	0cd00593          	li	a1,205
ffffffffc020309a:	00003517          	auipc	a0,0x3
ffffffffc020309e:	26650513          	addi	a0,a0,614 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc02030a2:	ba4fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(mm != NULL);
ffffffffc02030a6:	00003697          	auipc	a3,0x3
ffffffffc02030aa:	2aa68693          	addi	a3,a3,682 # ffffffffc0206350 <default_pmm_manager+0x710>
ffffffffc02030ae:	00002617          	auipc	a2,0x2
ffffffffc02030b2:	7e260613          	addi	a2,a2,2018 # ffffffffc0205890 <commands+0x738>
ffffffffc02030b6:	0c500593          	li	a1,197
ffffffffc02030ba:	00003517          	auipc	a0,0x3
ffffffffc02030be:	24650513          	addi	a0,a0,582 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc02030c2:	b84fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total==0);
ffffffffc02030c6:	00003697          	auipc	a3,0x3
ffffffffc02030ca:	49268693          	addi	a3,a3,1170 # ffffffffc0206558 <default_pmm_manager+0x918>
ffffffffc02030ce:	00002617          	auipc	a2,0x2
ffffffffc02030d2:	7c260613          	addi	a2,a2,1986 # ffffffffc0205890 <commands+0x738>
ffffffffc02030d6:	11d00593          	li	a1,285
ffffffffc02030da:	00003517          	auipc	a0,0x3
ffffffffc02030de:	22650513          	addi	a0,a0,550 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc02030e2:	b64fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02030e6:	00003617          	auipc	a2,0x3
ffffffffc02030ea:	b9260613          	addi	a2,a2,-1134 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc02030ee:	06900593          	li	a1,105
ffffffffc02030f2:	00003517          	auipc	a0,0x3
ffffffffc02030f6:	bae50513          	addi	a0,a0,-1106 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc02030fa:	b4cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(count==0);
ffffffffc02030fe:	00003697          	auipc	a3,0x3
ffffffffc0203102:	44a68693          	addi	a3,a3,1098 # ffffffffc0206548 <default_pmm_manager+0x908>
ffffffffc0203106:	00002617          	auipc	a2,0x2
ffffffffc020310a:	78a60613          	addi	a2,a2,1930 # ffffffffc0205890 <commands+0x738>
ffffffffc020310e:	11c00593          	li	a1,284
ffffffffc0203112:	00003517          	auipc	a0,0x3
ffffffffc0203116:	1ee50513          	addi	a0,a0,494 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020311a:	b2cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc020311e:	00003697          	auipc	a3,0x3
ffffffffc0203122:	37a68693          	addi	a3,a3,890 # ffffffffc0206498 <default_pmm_manager+0x858>
ffffffffc0203126:	00002617          	auipc	a2,0x2
ffffffffc020312a:	76a60613          	addi	a2,a2,1898 # ffffffffc0205890 <commands+0x738>
ffffffffc020312e:	09600593          	li	a1,150
ffffffffc0203132:	00003517          	auipc	a0,0x3
ffffffffc0203136:	1ce50513          	addi	a0,a0,462 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020313a:	b0cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020313e:	00003697          	auipc	a3,0x3
ffffffffc0203142:	30a68693          	addi	a3,a3,778 # ffffffffc0206448 <default_pmm_manager+0x808>
ffffffffc0203146:	00002617          	auipc	a2,0x2
ffffffffc020314a:	74a60613          	addi	a2,a2,1866 # ffffffffc0205890 <commands+0x738>
ffffffffc020314e:	0eb00593          	li	a1,235
ffffffffc0203152:	00003517          	auipc	a0,0x3
ffffffffc0203156:	1ae50513          	addi	a0,a0,430 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020315a:	aecfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020315e:	00003697          	auipc	a3,0x3
ffffffffc0203162:	27268693          	addi	a3,a3,626 # ffffffffc02063d0 <default_pmm_manager+0x790>
ffffffffc0203166:	00002617          	auipc	a2,0x2
ffffffffc020316a:	72a60613          	addi	a2,a2,1834 # ffffffffc0205890 <commands+0x738>
ffffffffc020316e:	0d800593          	li	a1,216
ffffffffc0203172:	00003517          	auipc	a0,0x3
ffffffffc0203176:	18e50513          	addi	a0,a0,398 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020317a:	accfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(ret==0);
ffffffffc020317e:	00003697          	auipc	a3,0x3
ffffffffc0203182:	3c268693          	addi	a3,a3,962 # ffffffffc0206540 <default_pmm_manager+0x900>
ffffffffc0203186:	00002617          	auipc	a2,0x2
ffffffffc020318a:	70a60613          	addi	a2,a2,1802 # ffffffffc0205890 <commands+0x738>
ffffffffc020318e:	10300593          	li	a1,259
ffffffffc0203192:	00003517          	auipc	a0,0x3
ffffffffc0203196:	16e50513          	addi	a0,a0,366 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020319a:	aacfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(vma != NULL);
ffffffffc020319e:	00003697          	auipc	a3,0x3
ffffffffc02031a2:	1ea68693          	addi	a3,a3,490 # ffffffffc0206388 <default_pmm_manager+0x748>
ffffffffc02031a6:	00002617          	auipc	a2,0x2
ffffffffc02031aa:	6ea60613          	addi	a2,a2,1770 # ffffffffc0205890 <commands+0x738>
ffffffffc02031ae:	0d000593          	li	a1,208
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	14e50513          	addi	a0,a0,334 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc02031ba:	a8cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc02031be:	00003697          	auipc	a3,0x3
ffffffffc02031c2:	30a68693          	addi	a3,a3,778 # ffffffffc02064c8 <default_pmm_manager+0x888>
ffffffffc02031c6:	00002617          	auipc	a2,0x2
ffffffffc02031ca:	6ca60613          	addi	a2,a2,1738 # ffffffffc0205890 <commands+0x738>
ffffffffc02031ce:	0a000593          	li	a1,160
ffffffffc02031d2:	00003517          	auipc	a0,0x3
ffffffffc02031d6:	12e50513          	addi	a0,a0,302 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc02031da:	a6cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc02031de:	00003697          	auipc	a3,0x3
ffffffffc02031e2:	2ea68693          	addi	a3,a3,746 # ffffffffc02064c8 <default_pmm_manager+0x888>
ffffffffc02031e6:	00002617          	auipc	a2,0x2
ffffffffc02031ea:	6aa60613          	addi	a2,a2,1706 # ffffffffc0205890 <commands+0x738>
ffffffffc02031ee:	0a200593          	li	a1,162
ffffffffc02031f2:	00003517          	auipc	a0,0x3
ffffffffc02031f6:	10e50513          	addi	a0,a0,270 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc02031fa:	a4cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc02031fe:	00003697          	auipc	a3,0x3
ffffffffc0203202:	2aa68693          	addi	a3,a3,682 # ffffffffc02064a8 <default_pmm_manager+0x868>
ffffffffc0203206:	00002617          	auipc	a2,0x2
ffffffffc020320a:	68a60613          	addi	a2,a2,1674 # ffffffffc0205890 <commands+0x738>
ffffffffc020320e:	09800593          	li	a1,152
ffffffffc0203212:	00003517          	auipc	a0,0x3
ffffffffc0203216:	0ee50513          	addi	a0,a0,238 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020321a:	a2cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc020321e:	00003697          	auipc	a3,0x3
ffffffffc0203222:	28a68693          	addi	a3,a3,650 # ffffffffc02064a8 <default_pmm_manager+0x868>
ffffffffc0203226:	00002617          	auipc	a2,0x2
ffffffffc020322a:	66a60613          	addi	a2,a2,1642 # ffffffffc0205890 <commands+0x738>
ffffffffc020322e:	09a00593          	li	a1,154
ffffffffc0203232:	00003517          	auipc	a0,0x3
ffffffffc0203236:	0ce50513          	addi	a0,a0,206 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020323a:	a0cfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc020323e:	00003697          	auipc	a3,0x3
ffffffffc0203242:	27a68693          	addi	a3,a3,634 # ffffffffc02064b8 <default_pmm_manager+0x878>
ffffffffc0203246:	00002617          	auipc	a2,0x2
ffffffffc020324a:	64a60613          	addi	a2,a2,1610 # ffffffffc0205890 <commands+0x738>
ffffffffc020324e:	09c00593          	li	a1,156
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	0ae50513          	addi	a0,a0,174 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020325a:	9ecfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc020325e:	00003697          	auipc	a3,0x3
ffffffffc0203262:	25a68693          	addi	a3,a3,602 # ffffffffc02064b8 <default_pmm_manager+0x878>
ffffffffc0203266:	00002617          	auipc	a2,0x2
ffffffffc020326a:	62a60613          	addi	a2,a2,1578 # ffffffffc0205890 <commands+0x738>
ffffffffc020326e:	09e00593          	li	a1,158
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	08e50513          	addi	a0,a0,142 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020327a:	9ccfd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc020327e:	00003697          	auipc	a3,0x3
ffffffffc0203282:	21a68693          	addi	a3,a3,538 # ffffffffc0206498 <default_pmm_manager+0x858>
ffffffffc0203286:	00002617          	auipc	a2,0x2
ffffffffc020328a:	60a60613          	addi	a2,a2,1546 # ffffffffc0205890 <commands+0x738>
ffffffffc020328e:	09400593          	li	a1,148
ffffffffc0203292:	00003517          	auipc	a0,0x3
ffffffffc0203296:	06e50513          	addi	a0,a0,110 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc020329a:	9acfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020329e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020329e:	00013797          	auipc	a5,0x13
ffffffffc02032a2:	2f27b783          	ld	a5,754(a5) # ffffffffc0216590 <sm>
ffffffffc02032a6:	6b9c                	ld	a5,16(a5)
ffffffffc02032a8:	8782                	jr	a5

ffffffffc02032aa <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02032aa:	00013797          	auipc	a5,0x13
ffffffffc02032ae:	2e67b783          	ld	a5,742(a5) # ffffffffc0216590 <sm>
ffffffffc02032b2:	739c                	ld	a5,32(a5)
ffffffffc02032b4:	8782                	jr	a5

ffffffffc02032b6 <swap_out>:
{
ffffffffc02032b6:	711d                	addi	sp,sp,-96
ffffffffc02032b8:	ec86                	sd	ra,88(sp)
ffffffffc02032ba:	e8a2                	sd	s0,80(sp)
ffffffffc02032bc:	e4a6                	sd	s1,72(sp)
ffffffffc02032be:	e0ca                	sd	s2,64(sp)
ffffffffc02032c0:	fc4e                	sd	s3,56(sp)
ffffffffc02032c2:	f852                	sd	s4,48(sp)
ffffffffc02032c4:	f456                	sd	s5,40(sp)
ffffffffc02032c6:	f05a                	sd	s6,32(sp)
ffffffffc02032c8:	ec5e                	sd	s7,24(sp)
ffffffffc02032ca:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02032cc:	cde9                	beqz	a1,ffffffffc02033a6 <swap_out+0xf0>
ffffffffc02032ce:	8a2e                	mv	s4,a1
ffffffffc02032d0:	892a                	mv	s2,a0
ffffffffc02032d2:	8ab2                	mv	s5,a2
ffffffffc02032d4:	4401                	li	s0,0
ffffffffc02032d6:	00013997          	auipc	s3,0x13
ffffffffc02032da:	2ba98993          	addi	s3,s3,698 # ffffffffc0216590 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032de:	00003b17          	auipc	s6,0x3
ffffffffc02032e2:	30ab0b13          	addi	s6,s6,778 # ffffffffc02065e8 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc02032e6:	00003b97          	auipc	s7,0x3
ffffffffc02032ea:	2eab8b93          	addi	s7,s7,746 # ffffffffc02065d0 <default_pmm_manager+0x990>
ffffffffc02032ee:	a825                	j	ffffffffc0203326 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032f0:	67a2                	ld	a5,8(sp)
ffffffffc02032f2:	8626                	mv	a2,s1
ffffffffc02032f4:	85a2                	mv	a1,s0
ffffffffc02032f6:	7f94                	ld	a3,56(a5)
ffffffffc02032f8:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02032fa:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032fc:	82b1                	srli	a3,a3,0xc
ffffffffc02032fe:	0685                	addi	a3,a3,1
ffffffffc0203300:	e81fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203304:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203306:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203308:	7d1c                	ld	a5,56(a0)
ffffffffc020330a:	83b1                	srli	a5,a5,0xc
ffffffffc020330c:	0785                	addi	a5,a5,1
ffffffffc020330e:	07a2                	slli	a5,a5,0x8
ffffffffc0203310:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203314:	faafe0ef          	jal	ra,ffffffffc0201abe <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203318:	01893503          	ld	a0,24(s2)
ffffffffc020331c:	85a6                	mv	a1,s1
ffffffffc020331e:	f6cff0ef          	jal	ra,ffffffffc0202a8a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203322:	048a0d63          	beq	s4,s0,ffffffffc020337c <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203326:	0009b783          	ld	a5,0(s3)
ffffffffc020332a:	8656                	mv	a2,s5
ffffffffc020332c:	002c                	addi	a1,sp,8
ffffffffc020332e:	7b9c                	ld	a5,48(a5)
ffffffffc0203330:	854a                	mv	a0,s2
ffffffffc0203332:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203334:	e12d                	bnez	a0,ffffffffc0203396 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203336:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203338:	01893503          	ld	a0,24(s2)
ffffffffc020333c:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020333e:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203340:	85a6                	mv	a1,s1
ffffffffc0203342:	ff6fe0ef          	jal	ra,ffffffffc0201b38 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203346:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203348:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc020334a:	8b85                	andi	a5,a5,1
ffffffffc020334c:	cfb9                	beqz	a5,ffffffffc02033aa <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020334e:	65a2                	ld	a1,8(sp)
ffffffffc0203350:	7d9c                	ld	a5,56(a1)
ffffffffc0203352:	83b1                	srli	a5,a5,0xc
ffffffffc0203354:	0785                	addi	a5,a5,1
ffffffffc0203356:	00879513          	slli	a0,a5,0x8
ffffffffc020335a:	653000ef          	jal	ra,ffffffffc02041ac <swapfs_write>
ffffffffc020335e:	d949                	beqz	a0,ffffffffc02032f0 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203360:	855e                	mv	a0,s7
ffffffffc0203362:	e1ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203366:	0009b783          	ld	a5,0(s3)
ffffffffc020336a:	6622                	ld	a2,8(sp)
ffffffffc020336c:	4681                	li	a3,0
ffffffffc020336e:	739c                	ld	a5,32(a5)
ffffffffc0203370:	85a6                	mv	a1,s1
ffffffffc0203372:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203374:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203376:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203378:	fa8a17e3          	bne	s4,s0,ffffffffc0203326 <swap_out+0x70>
}
ffffffffc020337c:	60e6                	ld	ra,88(sp)
ffffffffc020337e:	8522                	mv	a0,s0
ffffffffc0203380:	6446                	ld	s0,80(sp)
ffffffffc0203382:	64a6                	ld	s1,72(sp)
ffffffffc0203384:	6906                	ld	s2,64(sp)
ffffffffc0203386:	79e2                	ld	s3,56(sp)
ffffffffc0203388:	7a42                	ld	s4,48(sp)
ffffffffc020338a:	7aa2                	ld	s5,40(sp)
ffffffffc020338c:	7b02                	ld	s6,32(sp)
ffffffffc020338e:	6be2                	ld	s7,24(sp)
ffffffffc0203390:	6c42                	ld	s8,16(sp)
ffffffffc0203392:	6125                	addi	sp,sp,96
ffffffffc0203394:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203396:	85a2                	mv	a1,s0
ffffffffc0203398:	00003517          	auipc	a0,0x3
ffffffffc020339c:	1f050513          	addi	a0,a0,496 # ffffffffc0206588 <default_pmm_manager+0x948>
ffffffffc02033a0:	de1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc02033a4:	bfe1                	j	ffffffffc020337c <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02033a6:	4401                	li	s0,0
ffffffffc02033a8:	bfd1                	j	ffffffffc020337c <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02033aa:	00003697          	auipc	a3,0x3
ffffffffc02033ae:	20e68693          	addi	a3,a3,526 # ffffffffc02065b8 <default_pmm_manager+0x978>
ffffffffc02033b2:	00002617          	auipc	a2,0x2
ffffffffc02033b6:	4de60613          	addi	a2,a2,1246 # ffffffffc0205890 <commands+0x738>
ffffffffc02033ba:	06900593          	li	a1,105
ffffffffc02033be:	00003517          	auipc	a0,0x3
ffffffffc02033c2:	f4250513          	addi	a0,a0,-190 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc02033c6:	880fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02033ca <swap_in>:
{
ffffffffc02033ca:	7179                	addi	sp,sp,-48
ffffffffc02033cc:	e84a                	sd	s2,16(sp)
ffffffffc02033ce:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02033d0:	4505                	li	a0,1
{
ffffffffc02033d2:	ec26                	sd	s1,24(sp)
ffffffffc02033d4:	e44e                	sd	s3,8(sp)
ffffffffc02033d6:	f406                	sd	ra,40(sp)
ffffffffc02033d8:	f022                	sd	s0,32(sp)
ffffffffc02033da:	84ae                	mv	s1,a1
ffffffffc02033dc:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02033de:	e4efe0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
     assert(result!=NULL);
ffffffffc02033e2:	c129                	beqz	a0,ffffffffc0203424 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02033e4:	842a                	mv	s0,a0
ffffffffc02033e6:	01893503          	ld	a0,24(s2)
ffffffffc02033ea:	4601                	li	a2,0
ffffffffc02033ec:	85a6                	mv	a1,s1
ffffffffc02033ee:	f4afe0ef          	jal	ra,ffffffffc0201b38 <get_pte>
ffffffffc02033f2:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02033f4:	6108                	ld	a0,0(a0)
ffffffffc02033f6:	85a2                	mv	a1,s0
ffffffffc02033f8:	527000ef          	jal	ra,ffffffffc020411e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02033fc:	00093583          	ld	a1,0(s2)
ffffffffc0203400:	8626                	mv	a2,s1
ffffffffc0203402:	00003517          	auipc	a0,0x3
ffffffffc0203406:	23650513          	addi	a0,a0,566 # ffffffffc0206638 <default_pmm_manager+0x9f8>
ffffffffc020340a:	81a1                	srli	a1,a1,0x8
ffffffffc020340c:	d75fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203410:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203412:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203416:	7402                	ld	s0,32(sp)
ffffffffc0203418:	64e2                	ld	s1,24(sp)
ffffffffc020341a:	6942                	ld	s2,16(sp)
ffffffffc020341c:	69a2                	ld	s3,8(sp)
ffffffffc020341e:	4501                	li	a0,0
ffffffffc0203420:	6145                	addi	sp,sp,48
ffffffffc0203422:	8082                	ret
     assert(result!=NULL);
ffffffffc0203424:	00003697          	auipc	a3,0x3
ffffffffc0203428:	20468693          	addi	a3,a3,516 # ffffffffc0206628 <default_pmm_manager+0x9e8>
ffffffffc020342c:	00002617          	auipc	a2,0x2
ffffffffc0203430:	46460613          	addi	a2,a2,1124 # ffffffffc0205890 <commands+0x738>
ffffffffc0203434:	07f00593          	li	a1,127
ffffffffc0203438:	00003517          	auipc	a0,0x3
ffffffffc020343c:	ec850513          	addi	a0,a0,-312 # ffffffffc0206300 <default_pmm_manager+0x6c0>
ffffffffc0203440:	806fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203444 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203444:	0000f797          	auipc	a5,0xf
ffffffffc0203448:	0c478793          	addi	a5,a5,196 # ffffffffc0212508 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020344c:	f51c                	sd	a5,40(a0)
ffffffffc020344e:	e79c                	sd	a5,8(a5)
ffffffffc0203450:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203452:	4501                	li	a0,0
ffffffffc0203454:	8082                	ret

ffffffffc0203456 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203456:	4501                	li	a0,0
ffffffffc0203458:	8082                	ret

ffffffffc020345a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020345a:	4501                	li	a0,0
ffffffffc020345c:	8082                	ret

ffffffffc020345e <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020345e:	4501                	li	a0,0
ffffffffc0203460:	8082                	ret

ffffffffc0203462 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203462:	711d                	addi	sp,sp,-96
ffffffffc0203464:	fc4e                	sd	s3,56(sp)
ffffffffc0203466:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203468:	00003517          	auipc	a0,0x3
ffffffffc020346c:	21050513          	addi	a0,a0,528 # ffffffffc0206678 <default_pmm_manager+0xa38>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203470:	698d                	lui	s3,0x3
ffffffffc0203472:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203474:	e0ca                	sd	s2,64(sp)
ffffffffc0203476:	ec86                	sd	ra,88(sp)
ffffffffc0203478:	e8a2                	sd	s0,80(sp)
ffffffffc020347a:	e4a6                	sd	s1,72(sp)
ffffffffc020347c:	f456                	sd	s5,40(sp)
ffffffffc020347e:	f05a                	sd	s6,32(sp)
ffffffffc0203480:	ec5e                	sd	s7,24(sp)
ffffffffc0203482:	e862                	sd	s8,16(sp)
ffffffffc0203484:	e466                	sd	s9,8(sp)
ffffffffc0203486:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203488:	cf9fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020348c:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203490:	00013917          	auipc	s2,0x13
ffffffffc0203494:	11892903          	lw	s2,280(s2) # ffffffffc02165a8 <pgfault_num>
ffffffffc0203498:	4791                	li	a5,4
ffffffffc020349a:	14f91e63          	bne	s2,a5,ffffffffc02035f6 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020349e:	00003517          	auipc	a0,0x3
ffffffffc02034a2:	21a50513          	addi	a0,a0,538 # ffffffffc02066b8 <default_pmm_manager+0xa78>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034a6:	6a85                	lui	s5,0x1
ffffffffc02034a8:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034aa:	cd7fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02034ae:	00013417          	auipc	s0,0x13
ffffffffc02034b2:	0fa40413          	addi	s0,s0,250 # ffffffffc02165a8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034b6:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02034ba:	4004                	lw	s1,0(s0)
ffffffffc02034bc:	2481                	sext.w	s1,s1
ffffffffc02034be:	2b249c63          	bne	s1,s2,ffffffffc0203776 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034c2:	00003517          	auipc	a0,0x3
ffffffffc02034c6:	21e50513          	addi	a0,a0,542 # ffffffffc02066e0 <default_pmm_manager+0xaa0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034ca:	6b91                	lui	s7,0x4
ffffffffc02034cc:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034ce:	cb3fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034d2:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02034d6:	00042903          	lw	s2,0(s0)
ffffffffc02034da:	2901                	sext.w	s2,s2
ffffffffc02034dc:	26991d63          	bne	s2,s1,ffffffffc0203756 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034e0:	00003517          	auipc	a0,0x3
ffffffffc02034e4:	22850513          	addi	a0,a0,552 # ffffffffc0206708 <default_pmm_manager+0xac8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034e8:	6c89                	lui	s9,0x2
ffffffffc02034ea:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034ec:	c95fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034f0:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02034f4:	401c                	lw	a5,0(s0)
ffffffffc02034f6:	2781                	sext.w	a5,a5
ffffffffc02034f8:	23279f63          	bne	a5,s2,ffffffffc0203736 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02034fc:	00003517          	auipc	a0,0x3
ffffffffc0203500:	23450513          	addi	a0,a0,564 # ffffffffc0206730 <default_pmm_manager+0xaf0>
ffffffffc0203504:	c7dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203508:	6795                	lui	a5,0x5
ffffffffc020350a:	4739                	li	a4,14
ffffffffc020350c:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203510:	4004                	lw	s1,0(s0)
ffffffffc0203512:	4795                	li	a5,5
ffffffffc0203514:	2481                	sext.w	s1,s1
ffffffffc0203516:	20f49063          	bne	s1,a5,ffffffffc0203716 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020351a:	00003517          	auipc	a0,0x3
ffffffffc020351e:	1ee50513          	addi	a0,a0,494 # ffffffffc0206708 <default_pmm_manager+0xac8>
ffffffffc0203522:	c5ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203526:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020352a:	401c                	lw	a5,0(s0)
ffffffffc020352c:	2781                	sext.w	a5,a5
ffffffffc020352e:	1c979463          	bne	a5,s1,ffffffffc02036f6 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203532:	00003517          	auipc	a0,0x3
ffffffffc0203536:	18650513          	addi	a0,a0,390 # ffffffffc02066b8 <default_pmm_manager+0xa78>
ffffffffc020353a:	c47fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020353e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203542:	401c                	lw	a5,0(s0)
ffffffffc0203544:	4719                	li	a4,6
ffffffffc0203546:	2781                	sext.w	a5,a5
ffffffffc0203548:	18e79763          	bne	a5,a4,ffffffffc02036d6 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020354c:	00003517          	auipc	a0,0x3
ffffffffc0203550:	1bc50513          	addi	a0,a0,444 # ffffffffc0206708 <default_pmm_manager+0xac8>
ffffffffc0203554:	c2dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203558:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc020355c:	401c                	lw	a5,0(s0)
ffffffffc020355e:	471d                	li	a4,7
ffffffffc0203560:	2781                	sext.w	a5,a5
ffffffffc0203562:	14e79a63          	bne	a5,a4,ffffffffc02036b6 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203566:	00003517          	auipc	a0,0x3
ffffffffc020356a:	11250513          	addi	a0,a0,274 # ffffffffc0206678 <default_pmm_manager+0xa38>
ffffffffc020356e:	c13fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203572:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203576:	401c                	lw	a5,0(s0)
ffffffffc0203578:	4721                	li	a4,8
ffffffffc020357a:	2781                	sext.w	a5,a5
ffffffffc020357c:	10e79d63          	bne	a5,a4,ffffffffc0203696 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203580:	00003517          	auipc	a0,0x3
ffffffffc0203584:	16050513          	addi	a0,a0,352 # ffffffffc02066e0 <default_pmm_manager+0xaa0>
ffffffffc0203588:	bf9fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020358c:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203590:	401c                	lw	a5,0(s0)
ffffffffc0203592:	4725                	li	a4,9
ffffffffc0203594:	2781                	sext.w	a5,a5
ffffffffc0203596:	0ee79063          	bne	a5,a4,ffffffffc0203676 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020359a:	00003517          	auipc	a0,0x3
ffffffffc020359e:	19650513          	addi	a0,a0,406 # ffffffffc0206730 <default_pmm_manager+0xaf0>
ffffffffc02035a2:	bdffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02035a6:	6795                	lui	a5,0x5
ffffffffc02035a8:	4739                	li	a4,14
ffffffffc02035aa:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02035ae:	4004                	lw	s1,0(s0)
ffffffffc02035b0:	47a9                	li	a5,10
ffffffffc02035b2:	2481                	sext.w	s1,s1
ffffffffc02035b4:	0af49163          	bne	s1,a5,ffffffffc0203656 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035b8:	00003517          	auipc	a0,0x3
ffffffffc02035bc:	10050513          	addi	a0,a0,256 # ffffffffc02066b8 <default_pmm_manager+0xa78>
ffffffffc02035c0:	bc1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02035c4:	6785                	lui	a5,0x1
ffffffffc02035c6:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02035ca:	06979663          	bne	a5,s1,ffffffffc0203636 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc02035ce:	401c                	lw	a5,0(s0)
ffffffffc02035d0:	472d                	li	a4,11
ffffffffc02035d2:	2781                	sext.w	a5,a5
ffffffffc02035d4:	04e79163          	bne	a5,a4,ffffffffc0203616 <_fifo_check_swap+0x1b4>
}
ffffffffc02035d8:	60e6                	ld	ra,88(sp)
ffffffffc02035da:	6446                	ld	s0,80(sp)
ffffffffc02035dc:	64a6                	ld	s1,72(sp)
ffffffffc02035de:	6906                	ld	s2,64(sp)
ffffffffc02035e0:	79e2                	ld	s3,56(sp)
ffffffffc02035e2:	7a42                	ld	s4,48(sp)
ffffffffc02035e4:	7aa2                	ld	s5,40(sp)
ffffffffc02035e6:	7b02                	ld	s6,32(sp)
ffffffffc02035e8:	6be2                	ld	s7,24(sp)
ffffffffc02035ea:	6c42                	ld	s8,16(sp)
ffffffffc02035ec:	6ca2                	ld	s9,8(sp)
ffffffffc02035ee:	6d02                	ld	s10,0(sp)
ffffffffc02035f0:	4501                	li	a0,0
ffffffffc02035f2:	6125                	addi	sp,sp,96
ffffffffc02035f4:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02035f6:	00003697          	auipc	a3,0x3
ffffffffc02035fa:	ed268693          	addi	a3,a3,-302 # ffffffffc02064c8 <default_pmm_manager+0x888>
ffffffffc02035fe:	00002617          	auipc	a2,0x2
ffffffffc0203602:	29260613          	addi	a2,a2,658 # ffffffffc0205890 <commands+0x738>
ffffffffc0203606:	05100593          	li	a1,81
ffffffffc020360a:	00003517          	auipc	a0,0x3
ffffffffc020360e:	09650513          	addi	a0,a0,150 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203612:	e35fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==11);
ffffffffc0203616:	00003697          	auipc	a3,0x3
ffffffffc020361a:	1ca68693          	addi	a3,a3,458 # ffffffffc02067e0 <default_pmm_manager+0xba0>
ffffffffc020361e:	00002617          	auipc	a2,0x2
ffffffffc0203622:	27260613          	addi	a2,a2,626 # ffffffffc0205890 <commands+0x738>
ffffffffc0203626:	07300593          	li	a1,115
ffffffffc020362a:	00003517          	auipc	a0,0x3
ffffffffc020362e:	07650513          	addi	a0,a0,118 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203632:	e15fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203636:	00003697          	auipc	a3,0x3
ffffffffc020363a:	18268693          	addi	a3,a3,386 # ffffffffc02067b8 <default_pmm_manager+0xb78>
ffffffffc020363e:	00002617          	auipc	a2,0x2
ffffffffc0203642:	25260613          	addi	a2,a2,594 # ffffffffc0205890 <commands+0x738>
ffffffffc0203646:	07100593          	li	a1,113
ffffffffc020364a:	00003517          	auipc	a0,0x3
ffffffffc020364e:	05650513          	addi	a0,a0,86 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203652:	df5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==10);
ffffffffc0203656:	00003697          	auipc	a3,0x3
ffffffffc020365a:	15268693          	addi	a3,a3,338 # ffffffffc02067a8 <default_pmm_manager+0xb68>
ffffffffc020365e:	00002617          	auipc	a2,0x2
ffffffffc0203662:	23260613          	addi	a2,a2,562 # ffffffffc0205890 <commands+0x738>
ffffffffc0203666:	06f00593          	li	a1,111
ffffffffc020366a:	00003517          	auipc	a0,0x3
ffffffffc020366e:	03650513          	addi	a0,a0,54 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203672:	dd5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==9);
ffffffffc0203676:	00003697          	auipc	a3,0x3
ffffffffc020367a:	12268693          	addi	a3,a3,290 # ffffffffc0206798 <default_pmm_manager+0xb58>
ffffffffc020367e:	00002617          	auipc	a2,0x2
ffffffffc0203682:	21260613          	addi	a2,a2,530 # ffffffffc0205890 <commands+0x738>
ffffffffc0203686:	06c00593          	li	a1,108
ffffffffc020368a:	00003517          	auipc	a0,0x3
ffffffffc020368e:	01650513          	addi	a0,a0,22 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203692:	db5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==8);
ffffffffc0203696:	00003697          	auipc	a3,0x3
ffffffffc020369a:	0f268693          	addi	a3,a3,242 # ffffffffc0206788 <default_pmm_manager+0xb48>
ffffffffc020369e:	00002617          	auipc	a2,0x2
ffffffffc02036a2:	1f260613          	addi	a2,a2,498 # ffffffffc0205890 <commands+0x738>
ffffffffc02036a6:	06900593          	li	a1,105
ffffffffc02036aa:	00003517          	auipc	a0,0x3
ffffffffc02036ae:	ff650513          	addi	a0,a0,-10 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc02036b2:	d95fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==7);
ffffffffc02036b6:	00003697          	auipc	a3,0x3
ffffffffc02036ba:	0c268693          	addi	a3,a3,194 # ffffffffc0206778 <default_pmm_manager+0xb38>
ffffffffc02036be:	00002617          	auipc	a2,0x2
ffffffffc02036c2:	1d260613          	addi	a2,a2,466 # ffffffffc0205890 <commands+0x738>
ffffffffc02036c6:	06600593          	li	a1,102
ffffffffc02036ca:	00003517          	auipc	a0,0x3
ffffffffc02036ce:	fd650513          	addi	a0,a0,-42 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc02036d2:	d75fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==6);
ffffffffc02036d6:	00003697          	auipc	a3,0x3
ffffffffc02036da:	09268693          	addi	a3,a3,146 # ffffffffc0206768 <default_pmm_manager+0xb28>
ffffffffc02036de:	00002617          	auipc	a2,0x2
ffffffffc02036e2:	1b260613          	addi	a2,a2,434 # ffffffffc0205890 <commands+0x738>
ffffffffc02036e6:	06300593          	li	a1,99
ffffffffc02036ea:	00003517          	auipc	a0,0x3
ffffffffc02036ee:	fb650513          	addi	a0,a0,-74 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc02036f2:	d55fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc02036f6:	00003697          	auipc	a3,0x3
ffffffffc02036fa:	06268693          	addi	a3,a3,98 # ffffffffc0206758 <default_pmm_manager+0xb18>
ffffffffc02036fe:	00002617          	auipc	a2,0x2
ffffffffc0203702:	19260613          	addi	a2,a2,402 # ffffffffc0205890 <commands+0x738>
ffffffffc0203706:	06000593          	li	a1,96
ffffffffc020370a:	00003517          	auipc	a0,0x3
ffffffffc020370e:	f9650513          	addi	a0,a0,-106 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203712:	d35fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc0203716:	00003697          	auipc	a3,0x3
ffffffffc020371a:	04268693          	addi	a3,a3,66 # ffffffffc0206758 <default_pmm_manager+0xb18>
ffffffffc020371e:	00002617          	auipc	a2,0x2
ffffffffc0203722:	17260613          	addi	a2,a2,370 # ffffffffc0205890 <commands+0x738>
ffffffffc0203726:	05d00593          	li	a1,93
ffffffffc020372a:	00003517          	auipc	a0,0x3
ffffffffc020372e:	f7650513          	addi	a0,a0,-138 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203732:	d15fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203736:	00003697          	auipc	a3,0x3
ffffffffc020373a:	d9268693          	addi	a3,a3,-622 # ffffffffc02064c8 <default_pmm_manager+0x888>
ffffffffc020373e:	00002617          	auipc	a2,0x2
ffffffffc0203742:	15260613          	addi	a2,a2,338 # ffffffffc0205890 <commands+0x738>
ffffffffc0203746:	05a00593          	li	a1,90
ffffffffc020374a:	00003517          	auipc	a0,0x3
ffffffffc020374e:	f5650513          	addi	a0,a0,-170 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203752:	cf5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203756:	00003697          	auipc	a3,0x3
ffffffffc020375a:	d7268693          	addi	a3,a3,-654 # ffffffffc02064c8 <default_pmm_manager+0x888>
ffffffffc020375e:	00002617          	auipc	a2,0x2
ffffffffc0203762:	13260613          	addi	a2,a2,306 # ffffffffc0205890 <commands+0x738>
ffffffffc0203766:	05700593          	li	a1,87
ffffffffc020376a:	00003517          	auipc	a0,0x3
ffffffffc020376e:	f3650513          	addi	a0,a0,-202 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203772:	cd5fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203776:	00003697          	auipc	a3,0x3
ffffffffc020377a:	d5268693          	addi	a3,a3,-686 # ffffffffc02064c8 <default_pmm_manager+0x888>
ffffffffc020377e:	00002617          	auipc	a2,0x2
ffffffffc0203782:	11260613          	addi	a2,a2,274 # ffffffffc0205890 <commands+0x738>
ffffffffc0203786:	05400593          	li	a1,84
ffffffffc020378a:	00003517          	auipc	a0,0x3
ffffffffc020378e:	f1650513          	addi	a0,a0,-234 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc0203792:	cb5fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203796 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203796:	751c                	ld	a5,40(a0)
{
ffffffffc0203798:	1141                	addi	sp,sp,-16
ffffffffc020379a:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020379c:	cf91                	beqz	a5,ffffffffc02037b8 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc020379e:	ee0d                	bnez	a2,ffffffffc02037d8 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02037a0:	679c                	ld	a5,8(a5)
}
ffffffffc02037a2:	60a2                	ld	ra,8(sp)
ffffffffc02037a4:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02037a6:	6394                	ld	a3,0(a5)
ffffffffc02037a8:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02037aa:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02037ae:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02037b0:	e314                	sd	a3,0(a4)
ffffffffc02037b2:	e19c                	sd	a5,0(a1)
}
ffffffffc02037b4:	0141                	addi	sp,sp,16
ffffffffc02037b6:	8082                	ret
         assert(head != NULL);
ffffffffc02037b8:	00003697          	auipc	a3,0x3
ffffffffc02037bc:	03868693          	addi	a3,a3,56 # ffffffffc02067f0 <default_pmm_manager+0xbb0>
ffffffffc02037c0:	00002617          	auipc	a2,0x2
ffffffffc02037c4:	0d060613          	addi	a2,a2,208 # ffffffffc0205890 <commands+0x738>
ffffffffc02037c8:	04100593          	li	a1,65
ffffffffc02037cc:	00003517          	auipc	a0,0x3
ffffffffc02037d0:	ed450513          	addi	a0,a0,-300 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc02037d4:	c73fc0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(in_tick==0);
ffffffffc02037d8:	00003697          	auipc	a3,0x3
ffffffffc02037dc:	02868693          	addi	a3,a3,40 # ffffffffc0206800 <default_pmm_manager+0xbc0>
ffffffffc02037e0:	00002617          	auipc	a2,0x2
ffffffffc02037e4:	0b060613          	addi	a2,a2,176 # ffffffffc0205890 <commands+0x738>
ffffffffc02037e8:	04200593          	li	a1,66
ffffffffc02037ec:	00003517          	auipc	a0,0x3
ffffffffc02037f0:	eb450513          	addi	a0,a0,-332 # ffffffffc02066a0 <default_pmm_manager+0xa60>
ffffffffc02037f4:	c53fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02037f8 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02037f8:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02037fa:	cb91                	beqz	a5,ffffffffc020380e <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02037fc:	6394                	ld	a3,0(a5)
ffffffffc02037fe:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0203802:	e398                	sd	a4,0(a5)
ffffffffc0203804:	e698                	sd	a4,8(a3)
}
ffffffffc0203806:	4501                	li	a0,0
    elm->next = next;
ffffffffc0203808:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020380a:	f614                	sd	a3,40(a2)
ffffffffc020380c:	8082                	ret
{
ffffffffc020380e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203810:	00003697          	auipc	a3,0x3
ffffffffc0203814:	00068693          	mv	a3,a3
ffffffffc0203818:	00002617          	auipc	a2,0x2
ffffffffc020381c:	07860613          	addi	a2,a2,120 # ffffffffc0205890 <commands+0x738>
ffffffffc0203820:	03200593          	li	a1,50
ffffffffc0203824:	00003517          	auipc	a0,0x3
ffffffffc0203828:	e7c50513          	addi	a0,a0,-388 # ffffffffc02066a0 <default_pmm_manager+0xa60>
{
ffffffffc020382c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020382e:	c19fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203832 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203832:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203834:	00003697          	auipc	a3,0x3
ffffffffc0203838:	01468693          	addi	a3,a3,20 # ffffffffc0206848 <default_pmm_manager+0xc08>
ffffffffc020383c:	00002617          	auipc	a2,0x2
ffffffffc0203840:	05460613          	addi	a2,a2,84 # ffffffffc0205890 <commands+0x738>
ffffffffc0203844:	07e00593          	li	a1,126
ffffffffc0203848:	00003517          	auipc	a0,0x3
ffffffffc020384c:	02050513          	addi	a0,a0,32 # ffffffffc0206868 <default_pmm_manager+0xc28>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203850:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203852:	bf5fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203856 <mm_create>:
mm_create(void) {
ffffffffc0203856:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203858:	03000513          	li	a0,48
mm_create(void) {
ffffffffc020385c:	e022                	sd	s0,0(sp)
ffffffffc020385e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203860:	feffd0ef          	jal	ra,ffffffffc020184e <kmalloc>
ffffffffc0203864:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203866:	c105                	beqz	a0,ffffffffc0203886 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0203868:	e408                	sd	a0,8(s0)
ffffffffc020386a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020386c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203870:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203874:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203878:	00013797          	auipc	a5,0x13
ffffffffc020387c:	d207a783          	lw	a5,-736(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc0203880:	eb81                	bnez	a5,ffffffffc0203890 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0203882:	02053423          	sd	zero,40(a0)
}
ffffffffc0203886:	60a2                	ld	ra,8(sp)
ffffffffc0203888:	8522                	mv	a0,s0
ffffffffc020388a:	6402                	ld	s0,0(sp)
ffffffffc020388c:	0141                	addi	sp,sp,16
ffffffffc020388e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203890:	a0fff0ef          	jal	ra,ffffffffc020329e <swap_init_mm>
}
ffffffffc0203894:	60a2                	ld	ra,8(sp)
ffffffffc0203896:	8522                	mv	a0,s0
ffffffffc0203898:	6402                	ld	s0,0(sp)
ffffffffc020389a:	0141                	addi	sp,sp,16
ffffffffc020389c:	8082                	ret

ffffffffc020389e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020389e:	1101                	addi	sp,sp,-32
ffffffffc02038a0:	e04a                	sd	s2,0(sp)
ffffffffc02038a2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038a4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02038a8:	e822                	sd	s0,16(sp)
ffffffffc02038aa:	e426                	sd	s1,8(sp)
ffffffffc02038ac:	ec06                	sd	ra,24(sp)
ffffffffc02038ae:	84ae                	mv	s1,a1
ffffffffc02038b0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038b2:	f9dfd0ef          	jal	ra,ffffffffc020184e <kmalloc>
    if (vma != NULL) {
ffffffffc02038b6:	c509                	beqz	a0,ffffffffc02038c0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02038b8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02038bc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02038be:	cd00                	sw	s0,24(a0)
}
ffffffffc02038c0:	60e2                	ld	ra,24(sp)
ffffffffc02038c2:	6442                	ld	s0,16(sp)
ffffffffc02038c4:	64a2                	ld	s1,8(sp)
ffffffffc02038c6:	6902                	ld	s2,0(sp)
ffffffffc02038c8:	6105                	addi	sp,sp,32
ffffffffc02038ca:	8082                	ret

ffffffffc02038cc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02038cc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02038ce:	c505                	beqz	a0,ffffffffc02038f6 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02038d0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02038d2:	c501                	beqz	a0,ffffffffc02038da <find_vma+0xe>
ffffffffc02038d4:	651c                	ld	a5,8(a0)
ffffffffc02038d6:	02f5f263          	bgeu	a1,a5,ffffffffc02038fa <find_vma+0x2e>
    return listelm->next;
ffffffffc02038da:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02038dc:	00f68d63          	beq	a3,a5,ffffffffc02038f6 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02038e0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038e4:	00e5e663          	bltu	a1,a4,ffffffffc02038f0 <find_vma+0x24>
ffffffffc02038e8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02038ec:	00e5ec63          	bltu	a1,a4,ffffffffc0203904 <find_vma+0x38>
ffffffffc02038f0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02038f2:	fef697e3          	bne	a3,a5,ffffffffc02038e0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02038f6:	4501                	li	a0,0
}
ffffffffc02038f8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02038fa:	691c                	ld	a5,16(a0)
ffffffffc02038fc:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02038da <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203900:	ea88                	sd	a0,16(a3)
ffffffffc0203902:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203904:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203908:	ea88                	sd	a0,16(a3)
ffffffffc020390a:	8082                	ret

ffffffffc020390c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020390c:	6590                	ld	a2,8(a1)
ffffffffc020390e:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203912:	1141                	addi	sp,sp,-16
ffffffffc0203914:	e406                	sd	ra,8(sp)
ffffffffc0203916:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203918:	01066763          	bltu	a2,a6,ffffffffc0203926 <insert_vma_struct+0x1a>
ffffffffc020391c:	a085                	j	ffffffffc020397c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020391e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203922:	04e66863          	bltu	a2,a4,ffffffffc0203972 <insert_vma_struct+0x66>
ffffffffc0203926:	86be                	mv	a3,a5
ffffffffc0203928:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020392a:	fef51ae3          	bne	a0,a5,ffffffffc020391e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020392e:	02a68463          	beq	a3,a0,ffffffffc0203956 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203932:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203936:	fe86b883          	ld	a7,-24(a3)
ffffffffc020393a:	08e8f163          	bgeu	a7,a4,ffffffffc02039bc <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020393e:	04e66f63          	bltu	a2,a4,ffffffffc020399c <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0203942:	00f50a63          	beq	a0,a5,ffffffffc0203956 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203946:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020394a:	05076963          	bltu	a4,a6,ffffffffc020399c <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020394e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203952:	02c77363          	bgeu	a4,a2,ffffffffc0203978 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203956:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203958:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020395a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020395e:	e390                	sd	a2,0(a5)
ffffffffc0203960:	e690                	sd	a2,8(a3)
}
ffffffffc0203962:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203964:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203966:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0203968:	0017079b          	addiw	a5,a4,1
ffffffffc020396c:	d11c                	sw	a5,32(a0)
}
ffffffffc020396e:	0141                	addi	sp,sp,16
ffffffffc0203970:	8082                	ret
    if (le_prev != list) {
ffffffffc0203972:	fca690e3          	bne	a3,a0,ffffffffc0203932 <insert_vma_struct+0x26>
ffffffffc0203976:	bfd1                	j	ffffffffc020394a <insert_vma_struct+0x3e>
ffffffffc0203978:	ebbff0ef          	jal	ra,ffffffffc0203832 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020397c:	00003697          	auipc	a3,0x3
ffffffffc0203980:	efc68693          	addi	a3,a3,-260 # ffffffffc0206878 <default_pmm_manager+0xc38>
ffffffffc0203984:	00002617          	auipc	a2,0x2
ffffffffc0203988:	f0c60613          	addi	a2,a2,-244 # ffffffffc0205890 <commands+0x738>
ffffffffc020398c:	08500593          	li	a1,133
ffffffffc0203990:	00003517          	auipc	a0,0x3
ffffffffc0203994:	ed850513          	addi	a0,a0,-296 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203998:	aaffc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020399c:	00003697          	auipc	a3,0x3
ffffffffc02039a0:	f1c68693          	addi	a3,a3,-228 # ffffffffc02068b8 <default_pmm_manager+0xc78>
ffffffffc02039a4:	00002617          	auipc	a2,0x2
ffffffffc02039a8:	eec60613          	addi	a2,a2,-276 # ffffffffc0205890 <commands+0x738>
ffffffffc02039ac:	07d00593          	li	a1,125
ffffffffc02039b0:	00003517          	auipc	a0,0x3
ffffffffc02039b4:	eb850513          	addi	a0,a0,-328 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc02039b8:	a8ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02039bc:	00003697          	auipc	a3,0x3
ffffffffc02039c0:	edc68693          	addi	a3,a3,-292 # ffffffffc0206898 <default_pmm_manager+0xc58>
ffffffffc02039c4:	00002617          	auipc	a2,0x2
ffffffffc02039c8:	ecc60613          	addi	a2,a2,-308 # ffffffffc0205890 <commands+0x738>
ffffffffc02039cc:	07c00593          	li	a1,124
ffffffffc02039d0:	00003517          	auipc	a0,0x3
ffffffffc02039d4:	e9850513          	addi	a0,a0,-360 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc02039d8:	a6ffc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02039dc <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02039dc:	1141                	addi	sp,sp,-16
ffffffffc02039de:	e022                	sd	s0,0(sp)
ffffffffc02039e0:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02039e2:	6508                	ld	a0,8(a0)
ffffffffc02039e4:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02039e6:	00a40c63          	beq	s0,a0,ffffffffc02039fe <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc02039ea:	6118                	ld	a4,0(a0)
ffffffffc02039ec:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02039ee:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02039f0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02039f2:	e398                	sd	a4,0(a5)
ffffffffc02039f4:	f0bfd0ef          	jal	ra,ffffffffc02018fe <kfree>
    return listelm->next;
ffffffffc02039f8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02039fa:	fea418e3          	bne	s0,a0,ffffffffc02039ea <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc02039fe:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203a00:	6402                	ld	s0,0(sp)
ffffffffc0203a02:	60a2                	ld	ra,8(sp)
ffffffffc0203a04:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203a06:	ef9fd06f          	j	ffffffffc02018fe <kfree>

ffffffffc0203a0a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203a0a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a0c:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0203a10:	fc06                	sd	ra,56(sp)
ffffffffc0203a12:	f822                	sd	s0,48(sp)
ffffffffc0203a14:	f426                	sd	s1,40(sp)
ffffffffc0203a16:	f04a                	sd	s2,32(sp)
ffffffffc0203a18:	ec4e                	sd	s3,24(sp)
ffffffffc0203a1a:	e852                	sd	s4,16(sp)
ffffffffc0203a1c:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a1e:	e31fd0ef          	jal	ra,ffffffffc020184e <kmalloc>
    if (mm != NULL) {
ffffffffc0203a22:	58050e63          	beqz	a0,ffffffffc0203fbe <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc0203a26:	e508                	sd	a0,8(a0)
ffffffffc0203a28:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203a2a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203a2e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203a32:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a36:	00013797          	auipc	a5,0x13
ffffffffc0203a3a:	b627a783          	lw	a5,-1182(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc0203a3e:	84aa                	mv	s1,a0
ffffffffc0203a40:	e7b9                	bnez	a5,ffffffffc0203a8e <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0203a42:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0203a46:	03200413          	li	s0,50
ffffffffc0203a4a:	a811                	j	ffffffffc0203a5e <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc0203a4c:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a4e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a50:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0203a54:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a56:	8526                	mv	a0,s1
ffffffffc0203a58:	eb5ff0ef          	jal	ra,ffffffffc020390c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a5c:	cc05                	beqz	s0,ffffffffc0203a94 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a5e:	03000513          	li	a0,48
ffffffffc0203a62:	dedfd0ef          	jal	ra,ffffffffc020184e <kmalloc>
ffffffffc0203a66:	85aa                	mv	a1,a0
ffffffffc0203a68:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203a6c:	f165                	bnez	a0,ffffffffc0203a4c <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc0203a6e:	00003697          	auipc	a3,0x3
ffffffffc0203a72:	91a68693          	addi	a3,a3,-1766 # ffffffffc0206388 <default_pmm_manager+0x748>
ffffffffc0203a76:	00002617          	auipc	a2,0x2
ffffffffc0203a7a:	e1a60613          	addi	a2,a2,-486 # ffffffffc0205890 <commands+0x738>
ffffffffc0203a7e:	0c900593          	li	a1,201
ffffffffc0203a82:	00003517          	auipc	a0,0x3
ffffffffc0203a86:	de650513          	addi	a0,a0,-538 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203a8a:	9bdfc0ef          	jal	ra,ffffffffc0200446 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203a8e:	811ff0ef          	jal	ra,ffffffffc020329e <swap_init_mm>
ffffffffc0203a92:	bf55                	j	ffffffffc0203a46 <vmm_init+0x3c>
ffffffffc0203a94:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a98:	1f900913          	li	s2,505
ffffffffc0203a9c:	a819                	j	ffffffffc0203ab2 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0203a9e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203aa0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203aa2:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203aa6:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203aa8:	8526                	mv	a0,s1
ffffffffc0203aaa:	e63ff0ef          	jal	ra,ffffffffc020390c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203aae:	03240a63          	beq	s0,s2,ffffffffc0203ae2 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ab2:	03000513          	li	a0,48
ffffffffc0203ab6:	d99fd0ef          	jal	ra,ffffffffc020184e <kmalloc>
ffffffffc0203aba:	85aa                	mv	a1,a0
ffffffffc0203abc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203ac0:	fd79                	bnez	a0,ffffffffc0203a9e <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0203ac2:	00003697          	auipc	a3,0x3
ffffffffc0203ac6:	8c668693          	addi	a3,a3,-1850 # ffffffffc0206388 <default_pmm_manager+0x748>
ffffffffc0203aca:	00002617          	auipc	a2,0x2
ffffffffc0203ace:	dc660613          	addi	a2,a2,-570 # ffffffffc0205890 <commands+0x738>
ffffffffc0203ad2:	0cf00593          	li	a1,207
ffffffffc0203ad6:	00003517          	auipc	a0,0x3
ffffffffc0203ada:	d9250513          	addi	a0,a0,-622 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203ade:	969fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return listelm->next;
ffffffffc0203ae2:	649c                	ld	a5,8(s1)
ffffffffc0203ae4:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203ae6:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203aea:	30f48e63          	beq	s1,a5,ffffffffc0203e06 <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203aee:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203af2:	ffe70613          	addi	a2,a4,-2
ffffffffc0203af6:	2ad61863          	bne	a2,a3,ffffffffc0203da6 <vmm_init+0x39c>
ffffffffc0203afa:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203afe:	2ae69463          	bne	a3,a4,ffffffffc0203da6 <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203b02:	0715                	addi	a4,a4,5
ffffffffc0203b04:	679c                	ld	a5,8(a5)
ffffffffc0203b06:	feb712e3          	bne	a4,a1,ffffffffc0203aea <vmm_init+0xe0>
ffffffffc0203b0a:	4a1d                	li	s4,7
ffffffffc0203b0c:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b0e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b12:	85a2                	mv	a1,s0
ffffffffc0203b14:	8526                	mv	a0,s1
ffffffffc0203b16:	db7ff0ef          	jal	ra,ffffffffc02038cc <find_vma>
ffffffffc0203b1a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203b1c:	34050563          	beqz	a0,ffffffffc0203e66 <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203b20:	00140593          	addi	a1,s0,1
ffffffffc0203b24:	8526                	mv	a0,s1
ffffffffc0203b26:	da7ff0ef          	jal	ra,ffffffffc02038cc <find_vma>
ffffffffc0203b2a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b2c:	34050d63          	beqz	a0,ffffffffc0203e86 <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203b30:	85d2                	mv	a1,s4
ffffffffc0203b32:	8526                	mv	a0,s1
ffffffffc0203b34:	d99ff0ef          	jal	ra,ffffffffc02038cc <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b38:	36051763          	bnez	a0,ffffffffc0203ea6 <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203b3c:	00340593          	addi	a1,s0,3
ffffffffc0203b40:	8526                	mv	a0,s1
ffffffffc0203b42:	d8bff0ef          	jal	ra,ffffffffc02038cc <find_vma>
        assert(vma4 == NULL);
ffffffffc0203b46:	2e051063          	bnez	a0,ffffffffc0203e26 <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203b4a:	00440593          	addi	a1,s0,4
ffffffffc0203b4e:	8526                	mv	a0,s1
ffffffffc0203b50:	d7dff0ef          	jal	ra,ffffffffc02038cc <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b54:	2e051963          	bnez	a0,ffffffffc0203e46 <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b58:	00893783          	ld	a5,8(s2)
ffffffffc0203b5c:	26879563          	bne	a5,s0,ffffffffc0203dc6 <vmm_init+0x3bc>
ffffffffc0203b60:	01093783          	ld	a5,16(s2)
ffffffffc0203b64:	27479163          	bne	a5,s4,ffffffffc0203dc6 <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b68:	0089b783          	ld	a5,8(s3)
ffffffffc0203b6c:	26879d63          	bne	a5,s0,ffffffffc0203de6 <vmm_init+0x3dc>
ffffffffc0203b70:	0109b783          	ld	a5,16(s3)
ffffffffc0203b74:	27479963          	bne	a5,s4,ffffffffc0203de6 <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b78:	0415                	addi	s0,s0,5
ffffffffc0203b7a:	0a15                	addi	s4,s4,5
ffffffffc0203b7c:	f9541be3          	bne	s0,s5,ffffffffc0203b12 <vmm_init+0x108>
ffffffffc0203b80:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203b82:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203b84:	85a2                	mv	a1,s0
ffffffffc0203b86:	8526                	mv	a0,s1
ffffffffc0203b88:	d45ff0ef          	jal	ra,ffffffffc02038cc <find_vma>
ffffffffc0203b8c:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203b90:	c90d                	beqz	a0,ffffffffc0203bc2 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203b92:	6914                	ld	a3,16(a0)
ffffffffc0203b94:	6510                	ld	a2,8(a0)
ffffffffc0203b96:	00003517          	auipc	a0,0x3
ffffffffc0203b9a:	e4250513          	addi	a0,a0,-446 # ffffffffc02069d8 <default_pmm_manager+0xd98>
ffffffffc0203b9e:	de2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203ba2:	00003697          	auipc	a3,0x3
ffffffffc0203ba6:	e5e68693          	addi	a3,a3,-418 # ffffffffc0206a00 <default_pmm_manager+0xdc0>
ffffffffc0203baa:	00002617          	auipc	a2,0x2
ffffffffc0203bae:	ce660613          	addi	a2,a2,-794 # ffffffffc0205890 <commands+0x738>
ffffffffc0203bb2:	0f100593          	li	a1,241
ffffffffc0203bb6:	00003517          	auipc	a0,0x3
ffffffffc0203bba:	cb250513          	addi	a0,a0,-846 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203bbe:	889fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203bc2:	147d                	addi	s0,s0,-1
ffffffffc0203bc4:	fd2410e3          	bne	s0,s2,ffffffffc0203b84 <vmm_init+0x17a>
ffffffffc0203bc8:	a801                	j	ffffffffc0203bd8 <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203bca:	6118                	ld	a4,0(a0)
ffffffffc0203bcc:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203bce:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203bd0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203bd2:	e398                	sd	a4,0(a5)
ffffffffc0203bd4:	d2bfd0ef          	jal	ra,ffffffffc02018fe <kfree>
    return listelm->next;
ffffffffc0203bd8:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203bda:	fea498e3          	bne	s1,a0,ffffffffc0203bca <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0203bde:	8526                	mv	a0,s1
ffffffffc0203be0:	d1ffd0ef          	jal	ra,ffffffffc02018fe <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203be4:	00003517          	auipc	a0,0x3
ffffffffc0203be8:	e3450513          	addi	a0,a0,-460 # ffffffffc0206a18 <default_pmm_manager+0xdd8>
ffffffffc0203bec:	d94fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203bf0:	f0ffd0ef          	jal	ra,ffffffffc0201afe <nr_free_pages>
ffffffffc0203bf4:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203bf6:	03000513          	li	a0,48
ffffffffc0203bfa:	c55fd0ef          	jal	ra,ffffffffc020184e <kmalloc>
ffffffffc0203bfe:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203c00:	2c050363          	beqz	a0,ffffffffc0203ec6 <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203c04:	00013797          	auipc	a5,0x13
ffffffffc0203c08:	9947a783          	lw	a5,-1644(a5) # ffffffffc0216598 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203c0c:	e508                	sd	a0,8(a0)
ffffffffc0203c0e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203c10:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203c14:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203c18:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203c1c:	18079263          	bnez	a5,ffffffffc0203da0 <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc0203c20:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c24:	00013917          	auipc	s2,0x13
ffffffffc0203c28:	93c93903          	ld	s2,-1732(s2) # ffffffffc0216560 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203c2c:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203c30:	00013717          	auipc	a4,0x13
ffffffffc0203c34:	96873823          	sd	s0,-1680(a4) # ffffffffc02165a0 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c38:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203c3c:	36079163          	bnez	a5,ffffffffc0203f9e <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c40:	03000513          	li	a0,48
ffffffffc0203c44:	c0bfd0ef          	jal	ra,ffffffffc020184e <kmalloc>
ffffffffc0203c48:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0203c4a:	2a050263          	beqz	a0,ffffffffc0203eee <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc0203c4e:	002007b7          	lui	a5,0x200
ffffffffc0203c52:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0203c56:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203c58:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203c5a:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203c5e:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203c60:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203c64:	ca9ff0ef          	jal	ra,ffffffffc020390c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c68:	10000593          	li	a1,256
ffffffffc0203c6c:	8522                	mv	a0,s0
ffffffffc0203c6e:	c5fff0ef          	jal	ra,ffffffffc02038cc <find_vma>
ffffffffc0203c72:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203c76:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c7a:	28a99a63          	bne	s3,a0,ffffffffc0203f0e <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc0203c7e:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203c82:	0785                	addi	a5,a5,1
ffffffffc0203c84:	fee79de3          	bne	a5,a4,ffffffffc0203c7e <vmm_init+0x274>
        sum += i;
ffffffffc0203c88:	6705                	lui	a4,0x1
ffffffffc0203c8a:	10000793          	li	a5,256
ffffffffc0203c8e:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203c92:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203c96:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203c9a:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203c9c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203c9e:	fec79ce3          	bne	a5,a2,ffffffffc0203c96 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0203ca2:	28071663          	bnez	a4,ffffffffc0203f2e <vmm_init+0x524>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ca6:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203caa:	00013a97          	auipc	s5,0x13
ffffffffc0203cae:	8bea8a93          	addi	s5,s5,-1858 # ffffffffc0216568 <npage>
ffffffffc0203cb2:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cb6:	078a                	slli	a5,a5,0x2
ffffffffc0203cb8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cba:	28c7fa63          	bgeu	a5,a2,ffffffffc0203f4e <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cbe:	00003a17          	auipc	s4,0x3
ffffffffc0203cc2:	35aa3a03          	ld	s4,858(s4) # ffffffffc0207018 <nbase>
ffffffffc0203cc6:	414787b3          	sub	a5,a5,s4
ffffffffc0203cca:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0203ccc:	8799                	srai	a5,a5,0x6
ffffffffc0203cce:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0203cd0:	00c79713          	slli	a4,a5,0xc
ffffffffc0203cd4:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cd6:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203cda:	28c77663          	bgeu	a4,a2,ffffffffc0203f66 <vmm_init+0x55c>
ffffffffc0203cde:	00013997          	auipc	s3,0x13
ffffffffc0203ce2:	8a29b983          	ld	s3,-1886(s3) # ffffffffc0216580 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203ce6:	4581                	li	a1,0
ffffffffc0203ce8:	854a                	mv	a0,s2
ffffffffc0203cea:	99b6                	add	s3,s3,a3
ffffffffc0203cec:	872fe0ef          	jal	ra,ffffffffc0201d5e <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cf0:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0203cf4:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cf8:	078a                	slli	a5,a5,0x2
ffffffffc0203cfa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cfc:	24e7f963          	bgeu	a5,a4,ffffffffc0203f4e <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d00:	00013997          	auipc	s3,0x13
ffffffffc0203d04:	87098993          	addi	s3,s3,-1936 # ffffffffc0216570 <pages>
ffffffffc0203d08:	0009b503          	ld	a0,0(s3)
ffffffffc0203d0c:	414787b3          	sub	a5,a5,s4
ffffffffc0203d10:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203d12:	953e                	add	a0,a0,a5
ffffffffc0203d14:	4585                	li	a1,1
ffffffffc0203d16:	da9fd0ef          	jal	ra,ffffffffc0201abe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d1a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203d1e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d22:	078a                	slli	a5,a5,0x2
ffffffffc0203d24:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d26:	22e7f463          	bgeu	a5,a4,ffffffffc0203f4e <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d2a:	0009b503          	ld	a0,0(s3)
ffffffffc0203d2e:	414787b3          	sub	a5,a5,s4
ffffffffc0203d32:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203d34:	4585                	li	a1,1
ffffffffc0203d36:	953e                	add	a0,a0,a5
ffffffffc0203d38:	d87fd0ef          	jal	ra,ffffffffc0201abe <free_pages>
    pgdir[0] = 0;
ffffffffc0203d3c:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203d40:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203d44:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203d46:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203d4a:	00a40c63          	beq	s0,a0,ffffffffc0203d62 <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203d4e:	6118                	ld	a4,0(a0)
ffffffffc0203d50:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203d52:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203d54:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203d56:	e398                	sd	a4,0(a5)
ffffffffc0203d58:	ba7fd0ef          	jal	ra,ffffffffc02018fe <kfree>
    return listelm->next;
ffffffffc0203d5c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203d5e:	fea418e3          	bne	s0,a0,ffffffffc0203d4e <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc0203d62:	8522                	mv	a0,s0
ffffffffc0203d64:	b9bfd0ef          	jal	ra,ffffffffc02018fe <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc0203d68:	00013797          	auipc	a5,0x13
ffffffffc0203d6c:	8207bc23          	sd	zero,-1992(a5) # ffffffffc02165a0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d70:	d8ffd0ef          	jal	ra,ffffffffc0201afe <nr_free_pages>
ffffffffc0203d74:	20a49563          	bne	s1,a0,ffffffffc0203f7e <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203d78:	00003517          	auipc	a0,0x3
ffffffffc0203d7c:	d1850513          	addi	a0,a0,-744 # ffffffffc0206a90 <default_pmm_manager+0xe50>
ffffffffc0203d80:	c00fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203d84:	7442                	ld	s0,48(sp)
ffffffffc0203d86:	70e2                	ld	ra,56(sp)
ffffffffc0203d88:	74a2                	ld	s1,40(sp)
ffffffffc0203d8a:	7902                	ld	s2,32(sp)
ffffffffc0203d8c:	69e2                	ld	s3,24(sp)
ffffffffc0203d8e:	6a42                	ld	s4,16(sp)
ffffffffc0203d90:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d92:	00003517          	auipc	a0,0x3
ffffffffc0203d96:	d1e50513          	addi	a0,a0,-738 # ffffffffc0206ab0 <default_pmm_manager+0xe70>
}
ffffffffc0203d9a:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d9c:	be4fc06f          	j	ffffffffc0200180 <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203da0:	cfeff0ef          	jal	ra,ffffffffc020329e <swap_init_mm>
ffffffffc0203da4:	b541                	j	ffffffffc0203c24 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203da6:	00003697          	auipc	a3,0x3
ffffffffc0203daa:	b4a68693          	addi	a3,a3,-1206 # ffffffffc02068f0 <default_pmm_manager+0xcb0>
ffffffffc0203dae:	00002617          	auipc	a2,0x2
ffffffffc0203db2:	ae260613          	addi	a2,a2,-1310 # ffffffffc0205890 <commands+0x738>
ffffffffc0203db6:	0d800593          	li	a1,216
ffffffffc0203dba:	00003517          	auipc	a0,0x3
ffffffffc0203dbe:	aae50513          	addi	a0,a0,-1362 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203dc2:	e84fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203dc6:	00003697          	auipc	a3,0x3
ffffffffc0203dca:	bb268693          	addi	a3,a3,-1102 # ffffffffc0206978 <default_pmm_manager+0xd38>
ffffffffc0203dce:	00002617          	auipc	a2,0x2
ffffffffc0203dd2:	ac260613          	addi	a2,a2,-1342 # ffffffffc0205890 <commands+0x738>
ffffffffc0203dd6:	0e800593          	li	a1,232
ffffffffc0203dda:	00003517          	auipc	a0,0x3
ffffffffc0203dde:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203de2:	e64fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203de6:	00003697          	auipc	a3,0x3
ffffffffc0203dea:	bc268693          	addi	a3,a3,-1086 # ffffffffc02069a8 <default_pmm_manager+0xd68>
ffffffffc0203dee:	00002617          	auipc	a2,0x2
ffffffffc0203df2:	aa260613          	addi	a2,a2,-1374 # ffffffffc0205890 <commands+0x738>
ffffffffc0203df6:	0e900593          	li	a1,233
ffffffffc0203dfa:	00003517          	auipc	a0,0x3
ffffffffc0203dfe:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203e02:	e44fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203e06:	00003697          	auipc	a3,0x3
ffffffffc0203e0a:	ad268693          	addi	a3,a3,-1326 # ffffffffc02068d8 <default_pmm_manager+0xc98>
ffffffffc0203e0e:	00002617          	auipc	a2,0x2
ffffffffc0203e12:	a8260613          	addi	a2,a2,-1406 # ffffffffc0205890 <commands+0x738>
ffffffffc0203e16:	0d600593          	li	a1,214
ffffffffc0203e1a:	00003517          	auipc	a0,0x3
ffffffffc0203e1e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203e22:	e24fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc0203e26:	00003697          	auipc	a3,0x3
ffffffffc0203e2a:	b3268693          	addi	a3,a3,-1230 # ffffffffc0206958 <default_pmm_manager+0xd18>
ffffffffc0203e2e:	00002617          	auipc	a2,0x2
ffffffffc0203e32:	a6260613          	addi	a2,a2,-1438 # ffffffffc0205890 <commands+0x738>
ffffffffc0203e36:	0e400593          	li	a1,228
ffffffffc0203e3a:	00003517          	auipc	a0,0x3
ffffffffc0203e3e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203e42:	e04fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc0203e46:	00003697          	auipc	a3,0x3
ffffffffc0203e4a:	b2268693          	addi	a3,a3,-1246 # ffffffffc0206968 <default_pmm_manager+0xd28>
ffffffffc0203e4e:	00002617          	auipc	a2,0x2
ffffffffc0203e52:	a4260613          	addi	a2,a2,-1470 # ffffffffc0205890 <commands+0x738>
ffffffffc0203e56:	0e600593          	li	a1,230
ffffffffc0203e5a:	00003517          	auipc	a0,0x3
ffffffffc0203e5e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203e62:	de4fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc0203e66:	00003697          	auipc	a3,0x3
ffffffffc0203e6a:	ac268693          	addi	a3,a3,-1342 # ffffffffc0206928 <default_pmm_manager+0xce8>
ffffffffc0203e6e:	00002617          	auipc	a2,0x2
ffffffffc0203e72:	a2260613          	addi	a2,a2,-1502 # ffffffffc0205890 <commands+0x738>
ffffffffc0203e76:	0de00593          	li	a1,222
ffffffffc0203e7a:	00003517          	auipc	a0,0x3
ffffffffc0203e7e:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203e82:	dc4fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc0203e86:	00003697          	auipc	a3,0x3
ffffffffc0203e8a:	ab268693          	addi	a3,a3,-1358 # ffffffffc0206938 <default_pmm_manager+0xcf8>
ffffffffc0203e8e:	00002617          	auipc	a2,0x2
ffffffffc0203e92:	a0260613          	addi	a2,a2,-1534 # ffffffffc0205890 <commands+0x738>
ffffffffc0203e96:	0e000593          	li	a1,224
ffffffffc0203e9a:	00003517          	auipc	a0,0x3
ffffffffc0203e9e:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203ea2:	da4fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc0203ea6:	00003697          	auipc	a3,0x3
ffffffffc0203eaa:	aa268693          	addi	a3,a3,-1374 # ffffffffc0206948 <default_pmm_manager+0xd08>
ffffffffc0203eae:	00002617          	auipc	a2,0x2
ffffffffc0203eb2:	9e260613          	addi	a2,a2,-1566 # ffffffffc0205890 <commands+0x738>
ffffffffc0203eb6:	0e200593          	li	a1,226
ffffffffc0203eba:	00003517          	auipc	a0,0x3
ffffffffc0203ebe:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203ec2:	d84fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203ec6:	00003697          	auipc	a3,0x3
ffffffffc0203eca:	c0268693          	addi	a3,a3,-1022 # ffffffffc0206ac8 <default_pmm_manager+0xe88>
ffffffffc0203ece:	00002617          	auipc	a2,0x2
ffffffffc0203ed2:	9c260613          	addi	a2,a2,-1598 # ffffffffc0205890 <commands+0x738>
ffffffffc0203ed6:	10100593          	li	a1,257
ffffffffc0203eda:	00003517          	auipc	a0,0x3
ffffffffc0203ede:	98e50513          	addi	a0,a0,-1650 # ffffffffc0206868 <default_pmm_manager+0xc28>
    check_mm_struct = mm_create();
ffffffffc0203ee2:	00012797          	auipc	a5,0x12
ffffffffc0203ee6:	6a07bf23          	sd	zero,1726(a5) # ffffffffc02165a0 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203eea:	d5cfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(vma != NULL);
ffffffffc0203eee:	00002697          	auipc	a3,0x2
ffffffffc0203ef2:	49a68693          	addi	a3,a3,1178 # ffffffffc0206388 <default_pmm_manager+0x748>
ffffffffc0203ef6:	00002617          	auipc	a2,0x2
ffffffffc0203efa:	99a60613          	addi	a2,a2,-1638 # ffffffffc0205890 <commands+0x738>
ffffffffc0203efe:	10800593          	li	a1,264
ffffffffc0203f02:	00003517          	auipc	a0,0x3
ffffffffc0203f06:	96650513          	addi	a0,a0,-1690 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203f0a:	d3cfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203f0e:	00003697          	auipc	a3,0x3
ffffffffc0203f12:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0206a38 <default_pmm_manager+0xdf8>
ffffffffc0203f16:	00002617          	auipc	a2,0x2
ffffffffc0203f1a:	97a60613          	addi	a2,a2,-1670 # ffffffffc0205890 <commands+0x738>
ffffffffc0203f1e:	10d00593          	li	a1,269
ffffffffc0203f22:	00003517          	auipc	a0,0x3
ffffffffc0203f26:	94650513          	addi	a0,a0,-1722 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203f2a:	d1cfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(sum == 0);
ffffffffc0203f2e:	00003697          	auipc	a3,0x3
ffffffffc0203f32:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0206a58 <default_pmm_manager+0xe18>
ffffffffc0203f36:	00002617          	auipc	a2,0x2
ffffffffc0203f3a:	95a60613          	addi	a2,a2,-1702 # ffffffffc0205890 <commands+0x738>
ffffffffc0203f3e:	11700593          	li	a1,279
ffffffffc0203f42:	00003517          	auipc	a0,0x3
ffffffffc0203f46:	92650513          	addi	a0,a0,-1754 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203f4a:	cfcfc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203f4e:	00002617          	auipc	a2,0x2
ffffffffc0203f52:	dfa60613          	addi	a2,a2,-518 # ffffffffc0205d48 <default_pmm_manager+0x108>
ffffffffc0203f56:	06200593          	li	a1,98
ffffffffc0203f5a:	00002517          	auipc	a0,0x2
ffffffffc0203f5e:	d4650513          	addi	a0,a0,-698 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc0203f62:	ce4fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203f66:	00002617          	auipc	a2,0x2
ffffffffc0203f6a:	d1260613          	addi	a2,a2,-750 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc0203f6e:	06900593          	li	a1,105
ffffffffc0203f72:	00002517          	auipc	a0,0x2
ffffffffc0203f76:	d2e50513          	addi	a0,a0,-722 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc0203f7a:	cccfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203f7e:	00003697          	auipc	a3,0x3
ffffffffc0203f82:	aea68693          	addi	a3,a3,-1302 # ffffffffc0206a68 <default_pmm_manager+0xe28>
ffffffffc0203f86:	00002617          	auipc	a2,0x2
ffffffffc0203f8a:	90a60613          	addi	a2,a2,-1782 # ffffffffc0205890 <commands+0x738>
ffffffffc0203f8e:	12400593          	li	a1,292
ffffffffc0203f92:	00003517          	auipc	a0,0x3
ffffffffc0203f96:	8d650513          	addi	a0,a0,-1834 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203f9a:	cacfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203f9e:	00002697          	auipc	a3,0x2
ffffffffc0203fa2:	3da68693          	addi	a3,a3,986 # ffffffffc0206378 <default_pmm_manager+0x738>
ffffffffc0203fa6:	00002617          	auipc	a2,0x2
ffffffffc0203faa:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0205890 <commands+0x738>
ffffffffc0203fae:	10500593          	li	a1,261
ffffffffc0203fb2:	00003517          	auipc	a0,0x3
ffffffffc0203fb6:	8b650513          	addi	a0,a0,-1866 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203fba:	c8cfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc0203fbe:	00002697          	auipc	a3,0x2
ffffffffc0203fc2:	39268693          	addi	a3,a3,914 # ffffffffc0206350 <default_pmm_manager+0x710>
ffffffffc0203fc6:	00002617          	auipc	a2,0x2
ffffffffc0203fca:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0205890 <commands+0x738>
ffffffffc0203fce:	0c200593          	li	a1,194
ffffffffc0203fd2:	00003517          	auipc	a0,0x3
ffffffffc0203fd6:	89650513          	addi	a0,a0,-1898 # ffffffffc0206868 <default_pmm_manager+0xc28>
ffffffffc0203fda:	c6cfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203fde <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203fde:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203fe0:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203fe2:	f022                	sd	s0,32(sp)
ffffffffc0203fe4:	ec26                	sd	s1,24(sp)
ffffffffc0203fe6:	f406                	sd	ra,40(sp)
ffffffffc0203fe8:	e84a                	sd	s2,16(sp)
ffffffffc0203fea:	8432                	mv	s0,a2
ffffffffc0203fec:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203fee:	8dfff0ef          	jal	ra,ffffffffc02038cc <find_vma>

    pgfault_num++;
ffffffffc0203ff2:	00012797          	auipc	a5,0x12
ffffffffc0203ff6:	5b67a783          	lw	a5,1462(a5) # ffffffffc02165a8 <pgfault_num>
ffffffffc0203ffa:	2785                	addiw	a5,a5,1
ffffffffc0203ffc:	00012717          	auipc	a4,0x12
ffffffffc0204000:	5af72623          	sw	a5,1452(a4) # ffffffffc02165a8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204004:	c551                	beqz	a0,ffffffffc0204090 <do_pgfault+0xb2>
ffffffffc0204006:	651c                	ld	a5,8(a0)
ffffffffc0204008:	08f46463          	bltu	s0,a5,ffffffffc0204090 <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020400c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020400e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204010:	8b89                	andi	a5,a5,2
ffffffffc0204012:	efb1                	bnez	a5,ffffffffc020406e <do_pgfault+0x90>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204014:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204016:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204018:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020401a:	4605                	li	a2,1
ffffffffc020401c:	85a2                	mv	a1,s0
ffffffffc020401e:	b1bfd0ef          	jal	ra,ffffffffc0201b38 <get_pte>
ffffffffc0204022:	c955                	beqz	a0,ffffffffc02040d6 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204024:	610c                	ld	a1,0(a0)
ffffffffc0204026:	c5b1                	beqz	a1,ffffffffc0204072 <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204028:	00012797          	auipc	a5,0x12
ffffffffc020402c:	5707a783          	lw	a5,1392(a5) # ffffffffc0216598 <swap_init_ok>
ffffffffc0204030:	cbad                	beqz	a5,ffffffffc02040a2 <do_pgfault+0xc4>
            struct Page *page = NULL;
            // (1) 根据 mm 和 addr，尝试将相应磁盘页的内容加载到由 page 管理的内存中
            if (swap_in(mm, addr, &page) == 0) {
ffffffffc0204032:	0030                	addi	a2,sp,8
ffffffffc0204034:	85a2                	mv	a1,s0
ffffffffc0204036:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204038:	e402                	sd	zero,8(sp)
            if (swap_in(mm, addr, &page) == 0) {
ffffffffc020403a:	b90ff0ef          	jal	ra,ffffffffc02033ca <swap_in>
ffffffffc020403e:	e935                	bnez	a0,ffffffffc02040b2 <do_pgfault+0xd4>
                // (2) 根据 mm，addr 和 page 建立物理地址与逻辑地址之间的映射
                if (page_insert(mm->pgdir, page, addr, perm) == 0) {
ffffffffc0204040:	65a2                	ld	a1,8(sp)
ffffffffc0204042:	6c88                	ld	a0,24(s1)
ffffffffc0204044:	86ca                	mv	a3,s2
ffffffffc0204046:	8622                	mv	a2,s0
ffffffffc0204048:	db3fd0ef          	jal	ra,ffffffffc0201dfa <page_insert>
ffffffffc020404c:	892a                	mv	s2,a0
ffffffffc020404e:	e93d                	bnez	a0,ffffffffc02040c4 <do_pgfault+0xe6>
                    // (3) 设置页面为可交换
                    swap_map_swappable(mm, addr, page, 1);
ffffffffc0204050:	6622                	ld	a2,8(sp)
ffffffffc0204052:	4685                	li	a3,1
ffffffffc0204054:	85a2                	mv	a1,s0
ffffffffc0204056:	8526                	mv	a0,s1
ffffffffc0204058:	a52ff0ef          	jal	ra,ffffffffc02032aa <swap_map_swappable>
                    page->pra_vaddr = addr;
ffffffffc020405c:	67a2                	ld	a5,8(sp)
ffffffffc020405e:	ff80                	sd	s0,56(a5)
    }

   ret = 0;
failed:
    return ret;
}
ffffffffc0204060:	70a2                	ld	ra,40(sp)
ffffffffc0204062:	7402                	ld	s0,32(sp)
ffffffffc0204064:	64e2                	ld	s1,24(sp)
ffffffffc0204066:	854a                	mv	a0,s2
ffffffffc0204068:	6942                	ld	s2,16(sp)
ffffffffc020406a:	6145                	addi	sp,sp,48
ffffffffc020406c:	8082                	ret
        perm |= READ_WRITE;
ffffffffc020406e:	495d                	li	s2,23
ffffffffc0204070:	b755                	j	ffffffffc0204014 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204072:	6c88                	ld	a0,24(s1)
ffffffffc0204074:	864a                	mv	a2,s2
ffffffffc0204076:	85a2                	mv	a1,s0
ffffffffc0204078:	a19fe0ef          	jal	ra,ffffffffc0202a90 <pgdir_alloc_page>
   ret = 0;
ffffffffc020407c:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020407e:	f16d                	bnez	a0,ffffffffc0204060 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204080:	00003517          	auipc	a0,0x3
ffffffffc0204084:	ab050513          	addi	a0,a0,-1360 # ffffffffc0206b30 <default_pmm_manager+0xef0>
ffffffffc0204088:	8f8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020408c:	5971                	li	s2,-4
            goto failed;
ffffffffc020408e:	bfc9                	j	ffffffffc0204060 <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204090:	85a2                	mv	a1,s0
ffffffffc0204092:	00003517          	auipc	a0,0x3
ffffffffc0204096:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0206ae0 <default_pmm_manager+0xea0>
ffffffffc020409a:	8e6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc020409e:	5975                	li	s2,-3
        goto failed;
ffffffffc02040a0:	b7c1                	j	ffffffffc0204060 <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02040a2:	00003517          	auipc	a0,0x3
ffffffffc02040a6:	afe50513          	addi	a0,a0,-1282 # ffffffffc0206ba0 <default_pmm_manager+0xf60>
ffffffffc02040aa:	8d6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02040ae:	5971                	li	s2,-4
            goto failed;
ffffffffc02040b0:	bf45                	j	ffffffffc0204060 <do_pgfault+0x82>
                cprintf("swap_in failed for addr 0x%x\n", addr);
ffffffffc02040b2:	85a2                	mv	a1,s0
ffffffffc02040b4:	00003517          	auipc	a0,0x3
ffffffffc02040b8:	acc50513          	addi	a0,a0,-1332 # ffffffffc0206b80 <default_pmm_manager+0xf40>
ffffffffc02040bc:	8c4fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02040c0:	5971                	li	s2,-4
ffffffffc02040c2:	bf79                	j	ffffffffc0204060 <do_pgfault+0x82>
                    cprintf("page_insert failed for addr 0x%x\n", addr);
ffffffffc02040c4:	85a2                	mv	a1,s0
ffffffffc02040c6:	00003517          	auipc	a0,0x3
ffffffffc02040ca:	a9250513          	addi	a0,a0,-1390 # ffffffffc0206b58 <default_pmm_manager+0xf18>
ffffffffc02040ce:	8b2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02040d2:	5971                	li	s2,-4
ffffffffc02040d4:	b771                	j	ffffffffc0204060 <do_pgfault+0x82>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02040d6:	00003517          	auipc	a0,0x3
ffffffffc02040da:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0206b10 <default_pmm_manager+0xed0>
ffffffffc02040de:	8a2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02040e2:	5971                	li	s2,-4
        goto failed;
ffffffffc02040e4:	bfb5                	j	ffffffffc0204060 <do_pgfault+0x82>

ffffffffc02040e6 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02040e6:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040e8:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02040ea:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040ec:	c7cfc0ef          	jal	ra,ffffffffc0200568 <ide_device_valid>
ffffffffc02040f0:	cd01                	beqz	a0,ffffffffc0204108 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040f2:	4505                	li	a0,1
ffffffffc02040f4:	c7afc0ef          	jal	ra,ffffffffc020056e <ide_device_size>
}
ffffffffc02040f8:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040fa:	810d                	srli	a0,a0,0x3
ffffffffc02040fc:	00012797          	auipc	a5,0x12
ffffffffc0204100:	48a7b623          	sd	a0,1164(a5) # ffffffffc0216588 <max_swap_offset>
}
ffffffffc0204104:	0141                	addi	sp,sp,16
ffffffffc0204106:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204108:	00003617          	auipc	a2,0x3
ffffffffc020410c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0206bc8 <default_pmm_manager+0xf88>
ffffffffc0204110:	45b5                	li	a1,13
ffffffffc0204112:	00003517          	auipc	a0,0x3
ffffffffc0204116:	ad650513          	addi	a0,a0,-1322 # ffffffffc0206be8 <default_pmm_manager+0xfa8>
ffffffffc020411a:	b2cfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020411e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc020411e:	1141                	addi	sp,sp,-16
ffffffffc0204120:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204122:	00855793          	srli	a5,a0,0x8
ffffffffc0204126:	cbb1                	beqz	a5,ffffffffc020417a <swapfs_read+0x5c>
ffffffffc0204128:	00012717          	auipc	a4,0x12
ffffffffc020412c:	46073703          	ld	a4,1120(a4) # ffffffffc0216588 <max_swap_offset>
ffffffffc0204130:	04e7f563          	bgeu	a5,a4,ffffffffc020417a <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204134:	00012617          	auipc	a2,0x12
ffffffffc0204138:	43c63603          	ld	a2,1084(a2) # ffffffffc0216570 <pages>
ffffffffc020413c:	8d91                	sub	a1,a1,a2
ffffffffc020413e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204142:	00003717          	auipc	a4,0x3
ffffffffc0204146:	ed673703          	ld	a4,-298(a4) # ffffffffc0207018 <nbase>
ffffffffc020414a:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc020414c:	00c61713          	slli	a4,a2,0xc
ffffffffc0204150:	8331                	srli	a4,a4,0xc
ffffffffc0204152:	00012697          	auipc	a3,0x12
ffffffffc0204156:	4166b683          	ld	a3,1046(a3) # ffffffffc0216568 <npage>
ffffffffc020415a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc020415e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204160:	02d77963          	bgeu	a4,a3,ffffffffc0204192 <swapfs_read+0x74>
}
ffffffffc0204164:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204166:	00012797          	auipc	a5,0x12
ffffffffc020416a:	41a7b783          	ld	a5,1050(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc020416e:	46a1                	li	a3,8
ffffffffc0204170:	963e                	add	a2,a2,a5
ffffffffc0204172:	4505                	li	a0,1
}
ffffffffc0204174:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204176:	bfefc06f          	j	ffffffffc0200574 <ide_read_secs>
ffffffffc020417a:	86aa                	mv	a3,a0
ffffffffc020417c:	00003617          	auipc	a2,0x3
ffffffffc0204180:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206c00 <default_pmm_manager+0xfc0>
ffffffffc0204184:	45d1                	li	a1,20
ffffffffc0204186:	00003517          	auipc	a0,0x3
ffffffffc020418a:	a6250513          	addi	a0,a0,-1438 # ffffffffc0206be8 <default_pmm_manager+0xfa8>
ffffffffc020418e:	ab8fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0204192:	86b2                	mv	a3,a2
ffffffffc0204194:	06900593          	li	a1,105
ffffffffc0204198:	00002617          	auipc	a2,0x2
ffffffffc020419c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc02041a0:	00002517          	auipc	a0,0x2
ffffffffc02041a4:	b0050513          	addi	a0,a0,-1280 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc02041a8:	a9efc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02041ac <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02041ac:	1141                	addi	sp,sp,-16
ffffffffc02041ae:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041b0:	00855793          	srli	a5,a0,0x8
ffffffffc02041b4:	cbb1                	beqz	a5,ffffffffc0204208 <swapfs_write+0x5c>
ffffffffc02041b6:	00012717          	auipc	a4,0x12
ffffffffc02041ba:	3d273703          	ld	a4,978(a4) # ffffffffc0216588 <max_swap_offset>
ffffffffc02041be:	04e7f563          	bgeu	a5,a4,ffffffffc0204208 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc02041c2:	00012617          	auipc	a2,0x12
ffffffffc02041c6:	3ae63603          	ld	a2,942(a2) # ffffffffc0216570 <pages>
ffffffffc02041ca:	8d91                	sub	a1,a1,a2
ffffffffc02041cc:	4065d613          	srai	a2,a1,0x6
ffffffffc02041d0:	00003717          	auipc	a4,0x3
ffffffffc02041d4:	e4873703          	ld	a4,-440(a4) # ffffffffc0207018 <nbase>
ffffffffc02041d8:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc02041da:	00c61713          	slli	a4,a2,0xc
ffffffffc02041de:	8331                	srli	a4,a4,0xc
ffffffffc02041e0:	00012697          	auipc	a3,0x12
ffffffffc02041e4:	3886b683          	ld	a3,904(a3) # ffffffffc0216568 <npage>
ffffffffc02041e8:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041ec:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02041ee:	02d77963          	bgeu	a4,a3,ffffffffc0204220 <swapfs_write+0x74>
}
ffffffffc02041f2:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041f4:	00012797          	auipc	a5,0x12
ffffffffc02041f8:	38c7b783          	ld	a5,908(a5) # ffffffffc0216580 <va_pa_offset>
ffffffffc02041fc:	46a1                	li	a3,8
ffffffffc02041fe:	963e                	add	a2,a2,a5
ffffffffc0204200:	4505                	li	a0,1
}
ffffffffc0204202:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204204:	b94fc06f          	j	ffffffffc0200598 <ide_write_secs>
ffffffffc0204208:	86aa                	mv	a3,a0
ffffffffc020420a:	00003617          	auipc	a2,0x3
ffffffffc020420e:	9f660613          	addi	a2,a2,-1546 # ffffffffc0206c00 <default_pmm_manager+0xfc0>
ffffffffc0204212:	45e5                	li	a1,25
ffffffffc0204214:	00003517          	auipc	a0,0x3
ffffffffc0204218:	9d450513          	addi	a0,a0,-1580 # ffffffffc0206be8 <default_pmm_manager+0xfa8>
ffffffffc020421c:	a2afc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0204220:	86b2                	mv	a3,a2
ffffffffc0204222:	06900593          	li	a1,105
ffffffffc0204226:	00002617          	auipc	a2,0x2
ffffffffc020422a:	a5260613          	addi	a2,a2,-1454 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc020422e:	00002517          	auipc	a0,0x2
ffffffffc0204232:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc0204236:	a10fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020423a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020423a:	8526                	mv	a0,s1
	jalr s0
ffffffffc020423c:	9402                	jalr	s0

	jal do_exit
ffffffffc020423e:	42c000ef          	jal	ra,ffffffffc020466a <do_exit>

ffffffffc0204242 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204242:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204244:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0204248:	e022                	sd	s0,0(sp)
ffffffffc020424a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020424c:	e02fd0ef          	jal	ra,ffffffffc020184e <kmalloc>
ffffffffc0204250:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204252:	c521                	beqz	a0,ffffffffc020429a <alloc_proc+0x58>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT;
ffffffffc0204254:	57fd                	li	a5,-1
ffffffffc0204256:	1782                	slli	a5,a5,0x20
ffffffffc0204258:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc020425a:	07000613          	li	a2,112
ffffffffc020425e:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc0204260:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204264:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204268:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL;
ffffffffc020426c:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204270:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204274:	03050513          	addi	a0,a0,48
ffffffffc0204278:	429000ef          	jal	ra,ffffffffc0204ea0 <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc020427c:	00012797          	auipc	a5,0x12
ffffffffc0204280:	2dc7b783          	ld	a5,732(a5) # ffffffffc0216558 <boot_cr3>
    proc->tf = NULL;
ffffffffc0204284:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204288:	f45c                	sd	a5,168(s0)
    proc->flags = 0;
ffffffffc020428a:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc020428e:	4641                	li	a2,16
ffffffffc0204290:	4581                	li	a1,0
ffffffffc0204292:	0b440513          	addi	a0,s0,180
ffffffffc0204296:	40b000ef          	jal	ra,ffffffffc0204ea0 <memset>

    }
    return proc;
}
ffffffffc020429a:	60a2                	ld	ra,8(sp)
ffffffffc020429c:	8522                	mv	a0,s0
ffffffffc020429e:	6402                	ld	s0,0(sp)
ffffffffc02042a0:	0141                	addi	sp,sp,16
ffffffffc02042a2:	8082                	ret

ffffffffc02042a4 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc02042a4:	00012797          	auipc	a5,0x12
ffffffffc02042a8:	30c7b783          	ld	a5,780(a5) # ffffffffc02165b0 <current>
ffffffffc02042ac:	73c8                	ld	a0,160(a5)
ffffffffc02042ae:	8bffc06f          	j	ffffffffc0200b6c <forkrets>

ffffffffc02042b2 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02042b2:	7179                	addi	sp,sp,-48
ffffffffc02042b4:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042b6:	00012497          	auipc	s1,0x12
ffffffffc02042ba:	26248493          	addi	s1,s1,610 # ffffffffc0216518 <name.2>
init_main(void *arg) {
ffffffffc02042be:	f022                	sd	s0,32(sp)
ffffffffc02042c0:	e84a                	sd	s2,16(sp)
ffffffffc02042c2:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042c4:	00012917          	auipc	s2,0x12
ffffffffc02042c8:	2ec93903          	ld	s2,748(s2) # ffffffffc02165b0 <current>
    memset(name, 0, sizeof(name));
ffffffffc02042cc:	4641                	li	a2,16
ffffffffc02042ce:	4581                	li	a1,0
ffffffffc02042d0:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc02042d2:	f406                	sd	ra,40(sp)
ffffffffc02042d4:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042d6:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc02042da:	3c7000ef          	jal	ra,ffffffffc0204ea0 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042de:	0b490593          	addi	a1,s2,180
ffffffffc02042e2:	463d                	li	a2,15
ffffffffc02042e4:	8526                	mv	a0,s1
ffffffffc02042e6:	3cd000ef          	jal	ra,ffffffffc0204eb2 <memcpy>
ffffffffc02042ea:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042ec:	85ce                	mv	a1,s3
ffffffffc02042ee:	00003517          	auipc	a0,0x3
ffffffffc02042f2:	93250513          	addi	a0,a0,-1742 # ffffffffc0206c20 <default_pmm_manager+0xfe0>
ffffffffc02042f6:	e8bfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02042fa:	85a2                	mv	a1,s0
ffffffffc02042fc:	00003517          	auipc	a0,0x3
ffffffffc0204300:	94c50513          	addi	a0,a0,-1716 # ffffffffc0206c48 <default_pmm_manager+0x1008>
ffffffffc0204304:	e7dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204308:	00003517          	auipc	a0,0x3
ffffffffc020430c:	95050513          	addi	a0,a0,-1712 # ffffffffc0206c58 <default_pmm_manager+0x1018>
ffffffffc0204310:	e71fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0204314:	70a2                	ld	ra,40(sp)
ffffffffc0204316:	7402                	ld	s0,32(sp)
ffffffffc0204318:	64e2                	ld	s1,24(sp)
ffffffffc020431a:	6942                	ld	s2,16(sp)
ffffffffc020431c:	69a2                	ld	s3,8(sp)
ffffffffc020431e:	4501                	li	a0,0
ffffffffc0204320:	6145                	addi	sp,sp,48
ffffffffc0204322:	8082                	ret

ffffffffc0204324 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204324:	7179                	addi	sp,sp,-48
ffffffffc0204326:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204328:	00012917          	auipc	s2,0x12
ffffffffc020432c:	28890913          	addi	s2,s2,648 # ffffffffc02165b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204330:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204332:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204336:	f406                	sd	ra,40(sp)
ffffffffc0204338:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc020433a:	02a48d63          	beq	s1,a0,ffffffffc0204374 <proc_run+0x50>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020433e:	100027f3          	csrr	a5,sstatus
ffffffffc0204342:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204344:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204346:	e7a1                	bnez	a5,ffffffffc020438e <proc_run+0x6a>
            next->context.sp = next->kstack + KSTACKSIZE;
ffffffffc0204348:	6918                	ld	a4,16(a0)
            lcr3(proc->cr3);
ffffffffc020434a:	755c                	ld	a5,168(a0)
            next->context.sp = next->kstack + KSTACKSIZE;
ffffffffc020434c:	6689                	lui	a3,0x2
ffffffffc020434e:	9736                	add	a4,a4,a3
ffffffffc0204350:	fd18                	sd	a4,56(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204352:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204356:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc020435a:	00a93023          	sd	a0,0(s2)
ffffffffc020435e:	8fd9                	or	a5,a5,a4
ffffffffc0204360:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204364:	03050593          	addi	a1,a0,48
ffffffffc0204368:	03048513          	addi	a0,s1,48
ffffffffc020436c:	584000ef          	jal	ra,ffffffffc02048f0 <switch_to>
    if (flag) {
ffffffffc0204370:	00099863          	bnez	s3,ffffffffc0204380 <proc_run+0x5c>
}
ffffffffc0204374:	70a2                	ld	ra,40(sp)
ffffffffc0204376:	7482                	ld	s1,32(sp)
ffffffffc0204378:	6962                	ld	s2,24(sp)
ffffffffc020437a:	69c2                	ld	s3,16(sp)
ffffffffc020437c:	6145                	addi	sp,sp,48
ffffffffc020437e:	8082                	ret
ffffffffc0204380:	70a2                	ld	ra,40(sp)
ffffffffc0204382:	7482                	ld	s1,32(sp)
ffffffffc0204384:	6962                	ld	s2,24(sp)
ffffffffc0204386:	69c2                	ld	s3,16(sp)
ffffffffc0204388:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020438a:	a32fc06f          	j	ffffffffc02005bc <intr_enable>
ffffffffc020438e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204390:	a32fc0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0204394:	6522                	ld	a0,8(sp)
ffffffffc0204396:	4985                	li	s3,1
ffffffffc0204398:	bf45                	j	ffffffffc0204348 <proc_run+0x24>

ffffffffc020439a <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020439a:	7179                	addi	sp,sp,-48
ffffffffc020439c:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020439e:	00012997          	auipc	s3,0x12
ffffffffc02043a2:	22a98993          	addi	s3,s3,554 # ffffffffc02165c8 <nr_process>
ffffffffc02043a6:	0009a703          	lw	a4,0(s3)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043aa:	f406                	sd	ra,40(sp)
ffffffffc02043ac:	f022                	sd	s0,32(sp)
ffffffffc02043ae:	ec26                	sd	s1,24(sp)
ffffffffc02043b0:	e84a                	sd	s2,16(sp)
ffffffffc02043b2:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043b4:	6785                	lui	a5,0x1
ffffffffc02043b6:	20f75f63          	bge	a4,a5,ffffffffc02045d4 <do_fork+0x23a>
    if(alloc_proc() == NULL){
ffffffffc02043ba:	84ae                	mv	s1,a1
ffffffffc02043bc:	8432                	mv	s0,a2
ffffffffc02043be:	e85ff0ef          	jal	ra,ffffffffc0204242 <alloc_proc>
ffffffffc02043c2:	20050e63          	beqz	a0,ffffffffc02045de <do_fork+0x244>
    proc = alloc_proc();
ffffffffc02043c6:	e7dff0ef          	jal	ra,ffffffffc0204242 <alloc_proc>
    proc->parent = current;
ffffffffc02043ca:	00012a17          	auipc	s4,0x12
ffffffffc02043ce:	1e6a0a13          	addi	s4,s4,486 # ffffffffc02165b0 <current>
ffffffffc02043d2:	000a3783          	ld	a5,0(s4)
    proc = alloc_proc();
ffffffffc02043d6:	892a                	mv	s2,a0
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043d8:	4509                	li	a0,2
    proc->parent = current;
ffffffffc02043da:	02f93023          	sd	a5,32(s2)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043de:	e4efd0ef          	jal	ra,ffffffffc0201a2c <alloc_pages>
    if (page != NULL) {
ffffffffc02043e2:	1e050463          	beqz	a0,ffffffffc02045ca <do_fork+0x230>
    return page - pages + nbase;
ffffffffc02043e6:	00012697          	auipc	a3,0x12
ffffffffc02043ea:	18a6b683          	ld	a3,394(a3) # ffffffffc0216570 <pages>
ffffffffc02043ee:	40d506b3          	sub	a3,a0,a3
ffffffffc02043f2:	8699                	srai	a3,a3,0x6
ffffffffc02043f4:	00003517          	auipc	a0,0x3
ffffffffc02043f8:	c2453503          	ld	a0,-988(a0) # ffffffffc0207018 <nbase>
ffffffffc02043fc:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02043fe:	00c69793          	slli	a5,a3,0xc
ffffffffc0204402:	83b1                	srli	a5,a5,0xc
ffffffffc0204404:	00012717          	auipc	a4,0x12
ffffffffc0204408:	16473703          	ld	a4,356(a4) # ffffffffc0216568 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020440c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020440e:	1ee7fa63          	bgeu	a5,a4,ffffffffc0204602 <do_fork+0x268>
    assert(current->mm == NULL);
ffffffffc0204412:	000a3783          	ld	a5,0(s4)
ffffffffc0204416:	00012717          	auipc	a4,0x12
ffffffffc020441a:	16a73703          	ld	a4,362(a4) # ffffffffc0216580 <va_pa_offset>
ffffffffc020441e:	96ba                	add	a3,a3,a4
ffffffffc0204420:	779c                	ld	a5,40(a5)
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204422:	00d93823          	sd	a3,16(s2)
    assert(current->mm == NULL);
ffffffffc0204426:	1a079e63          	bnez	a5,ffffffffc02045e2 <do_fork+0x248>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020442a:	6789                	lui	a5,0x2
ffffffffc020442c:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0204430:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204432:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204434:	0ad93023          	sd	a3,160(s2)
    *(proc->tf) = *tf;
ffffffffc0204438:	87b6                	mv	a5,a3
ffffffffc020443a:	12040893          	addi	a7,s0,288
ffffffffc020443e:	00063803          	ld	a6,0(a2)
ffffffffc0204442:	6608                	ld	a0,8(a2)
ffffffffc0204444:	6a0c                	ld	a1,16(a2)
ffffffffc0204446:	6e18                	ld	a4,24(a2)
ffffffffc0204448:	0107b023          	sd	a6,0(a5)
ffffffffc020444c:	e788                	sd	a0,8(a5)
ffffffffc020444e:	eb8c                	sd	a1,16(a5)
ffffffffc0204450:	ef98                	sd	a4,24(a5)
ffffffffc0204452:	02060613          	addi	a2,a2,32
ffffffffc0204456:	02078793          	addi	a5,a5,32
ffffffffc020445a:	ff1612e3          	bne	a2,a7,ffffffffc020443e <do_fork+0xa4>
    proc->tf->gpr.a0 = 0;
ffffffffc020445e:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204462:	12048263          	beqz	s1,ffffffffc0204586 <do_fork+0x1ec>
ffffffffc0204466:	ea84                	sd	s1,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204468:	00000797          	auipc	a5,0x0
ffffffffc020446c:	e3c78793          	addi	a5,a5,-452 # ffffffffc02042a4 <forkret>
ffffffffc0204470:	02f93823          	sd	a5,48(s2)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204474:	02d93c23          	sd	a3,56(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204478:	100027f3          	csrr	a5,sstatus
ffffffffc020447c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020447e:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204480:	12079363          	bnez	a5,ffffffffc02045a6 <do_fork+0x20c>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204484:	00007317          	auipc	t1,0x7
ffffffffc0204488:	bd430313          	addi	t1,t1,-1068 # ffffffffc020b058 <last_pid.1>
ffffffffc020448c:	00032783          	lw	a5,0(t1)
ffffffffc0204490:	00012617          	auipc	a2,0x12
ffffffffc0204494:	09860613          	addi	a2,a2,152 # ffffffffc0216528 <proc_list>
ffffffffc0204498:	6709                	lui	a4,0x2
ffffffffc020449a:	0017851b          	addiw	a0,a5,1
ffffffffc020449e:	00a32023          	sw	a0,0(t1)
ffffffffc02044a2:	00863883          	ld	a7,8(a2)
ffffffffc02044a6:	06e55e63          	bge	a0,a4,ffffffffc0204522 <do_fork+0x188>
    if (last_pid >= next_safe) {
ffffffffc02044aa:	00007e97          	auipc	t4,0x7
ffffffffc02044ae:	bb2e8e93          	addi	t4,t4,-1102 # ffffffffc020b05c <next_safe.0>
ffffffffc02044b2:	000ea783          	lw	a5,0(t4)
ffffffffc02044b6:	06f55e63          	bge	a0,a5,ffffffffc0204532 <do_fork+0x198>
    nr_process ++;
ffffffffc02044ba:	0009a783          	lw	a5,0(s3)
    proc->pid = get_pid();
ffffffffc02044be:	00a92223          	sw	a0,4(s2)
    list_add(&proc_list ,&(proc->list_link));//list_add(&proc_list ,&(*proc).list_link);
ffffffffc02044c2:	0c890713          	addi	a4,s2,200
    prev->next = next->prev = elm;
ffffffffc02044c6:	00e8b023          	sd	a4,0(a7)
    nr_process ++;
ffffffffc02044ca:	2785                	addiw	a5,a5,1
    elm->next = next;
ffffffffc02044cc:	0d193823          	sd	a7,208(s2)
    elm->prev = prev;
ffffffffc02044d0:	0cc93423          	sd	a2,200(s2)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044d4:	45a9                	li	a1,10
ffffffffc02044d6:	2501                	sext.w	a0,a0
    nr_process ++;
ffffffffc02044d8:	00f9a023          	sw	a5,0(s3)
    prev->next = next->prev = elm;
ffffffffc02044dc:	e618                	sd	a4,8(a2)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044de:	542000ef          	jal	ra,ffffffffc0204a20 <hash32>
ffffffffc02044e2:	02051793          	slli	a5,a0,0x20
ffffffffc02044e6:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044ea:	0000e797          	auipc	a5,0xe
ffffffffc02044ee:	02e78793          	addi	a5,a5,46 # ffffffffc0212518 <hash_list>
ffffffffc02044f2:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044f4:	651c                	ld	a5,8(a0)
ffffffffc02044f6:	0d890713          	addi	a4,s2,216
    prev->next = next->prev = elm;
ffffffffc02044fa:	e398                	sd	a4,0(a5)
ffffffffc02044fc:	e518                	sd	a4,8(a0)
    elm->next = next;
ffffffffc02044fe:	0ef93023          	sd	a5,224(s2)
    elm->prev = prev;
ffffffffc0204502:	0ca93c23          	sd	a0,216(s2)
    if (flag) {
ffffffffc0204506:	e445                	bnez	s0,ffffffffc02045ae <do_fork+0x214>
    wakeup_proc(proc);
ffffffffc0204508:	854a                	mv	a0,s2
ffffffffc020450a:	450000ef          	jal	ra,ffffffffc020495a <wakeup_proc>
    ret = proc->pid;
ffffffffc020450e:	00492503          	lw	a0,4(s2)
}
ffffffffc0204512:	70a2                	ld	ra,40(sp)
ffffffffc0204514:	7402                	ld	s0,32(sp)
ffffffffc0204516:	64e2                	ld	s1,24(sp)
ffffffffc0204518:	6942                	ld	s2,16(sp)
ffffffffc020451a:	69a2                	ld	s3,8(sp)
ffffffffc020451c:	6a02                	ld	s4,0(sp)
ffffffffc020451e:	6145                	addi	sp,sp,48
ffffffffc0204520:	8082                	ret
        last_pid = 1;
ffffffffc0204522:	4785                	li	a5,1
ffffffffc0204524:	00f32023          	sw	a5,0(t1)
        goto inside;
ffffffffc0204528:	4505                	li	a0,1
ffffffffc020452a:	00007e97          	auipc	t4,0x7
ffffffffc020452e:	b32e8e93          	addi	t4,t4,-1230 # ffffffffc020b05c <next_safe.0>
        next_safe = MAX_PID;
ffffffffc0204532:	6789                	lui	a5,0x2
ffffffffc0204534:	00fea023          	sw	a5,0(t4)
ffffffffc0204538:	86aa                	mv	a3,a0
ffffffffc020453a:	4801                	li	a6,0
        while ((le = list_next(le)) != list) {
ffffffffc020453c:	6f09                	lui	t5,0x2
ffffffffc020453e:	08c88063          	beq	a7,a2,ffffffffc02045be <do_fork+0x224>
ffffffffc0204542:	8e42                	mv	t3,a6
ffffffffc0204544:	87c6                	mv	a5,a7
ffffffffc0204546:	6589                	lui	a1,0x2
ffffffffc0204548:	a811                	j	ffffffffc020455c <do_fork+0x1c2>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020454a:	00e6d663          	bge	a3,a4,ffffffffc0204556 <do_fork+0x1bc>
ffffffffc020454e:	00b75463          	bge	a4,a1,ffffffffc0204556 <do_fork+0x1bc>
ffffffffc0204552:	85ba                	mv	a1,a4
ffffffffc0204554:	4e05                	li	t3,1
    return listelm->next;
ffffffffc0204556:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204558:	00c78d63          	beq	a5,a2,ffffffffc0204572 <do_fork+0x1d8>
            if (proc->pid == last_pid) {
ffffffffc020455c:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc0204560:	fed715e3          	bne	a4,a3,ffffffffc020454a <do_fork+0x1b0>
                if (++ last_pid >= next_safe) {
ffffffffc0204564:	2685                	addiw	a3,a3,1
ffffffffc0204566:	04b6d763          	bge	a3,a1,ffffffffc02045b4 <do_fork+0x21a>
ffffffffc020456a:	679c                	ld	a5,8(a5)
ffffffffc020456c:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc020456e:	fec797e3          	bne	a5,a2,ffffffffc020455c <do_fork+0x1c2>
ffffffffc0204572:	00080563          	beqz	a6,ffffffffc020457c <do_fork+0x1e2>
ffffffffc0204576:	00d32023          	sw	a3,0(t1)
ffffffffc020457a:	8536                	mv	a0,a3
ffffffffc020457c:	f20e0fe3          	beqz	t3,ffffffffc02044ba <do_fork+0x120>
ffffffffc0204580:	00bea023          	sw	a1,0(t4)
ffffffffc0204584:	bf1d                	j	ffffffffc02044ba <do_fork+0x120>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204586:	84b6                	mv	s1,a3
ffffffffc0204588:	ea84                	sd	s1,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020458a:	00000797          	auipc	a5,0x0
ffffffffc020458e:	d1a78793          	addi	a5,a5,-742 # ffffffffc02042a4 <forkret>
ffffffffc0204592:	02f93823          	sd	a5,48(s2)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204596:	02d93c23          	sd	a3,56(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020459a:	100027f3          	csrr	a5,sstatus
ffffffffc020459e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045a0:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045a2:	ee0781e3          	beqz	a5,ffffffffc0204484 <do_fork+0xea>
        intr_disable();
ffffffffc02045a6:	81cfc0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc02045aa:	4405                	li	s0,1
ffffffffc02045ac:	bde1                	j	ffffffffc0204484 <do_fork+0xea>
        intr_enable();
ffffffffc02045ae:	80efc0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02045b2:	bf99                	j	ffffffffc0204508 <do_fork+0x16e>
                    if (last_pid >= MAX_PID) {
ffffffffc02045b4:	01e6c363          	blt	a3,t5,ffffffffc02045ba <do_fork+0x220>
                        last_pid = 1;
ffffffffc02045b8:	4685                	li	a3,1
                    goto repeat;
ffffffffc02045ba:	4805                	li	a6,1
ffffffffc02045bc:	b749                	j	ffffffffc020453e <do_fork+0x1a4>
ffffffffc02045be:	00080d63          	beqz	a6,ffffffffc02045d8 <do_fork+0x23e>
ffffffffc02045c2:	00d32023          	sw	a3,0(t1)
    return last_pid;
ffffffffc02045c6:	8536                	mv	a0,a3
ffffffffc02045c8:	bdcd                	j	ffffffffc02044ba <do_fork+0x120>
    kfree(proc);
ffffffffc02045ca:	854a                	mv	a0,s2
ffffffffc02045cc:	b32fd0ef          	jal	ra,ffffffffc02018fe <kfree>
    ret = -E_NO_MEM;
ffffffffc02045d0:	5571                	li	a0,-4
    goto fork_out;
ffffffffc02045d2:	b781                	j	ffffffffc0204512 <do_fork+0x178>
    int ret = -E_NO_FREE_PROC;
ffffffffc02045d4:	556d                	li	a0,-5
ffffffffc02045d6:	bf35                	j	ffffffffc0204512 <do_fork+0x178>
    return last_pid;
ffffffffc02045d8:	00032503          	lw	a0,0(t1)
ffffffffc02045dc:	bdf9                	j	ffffffffc02044ba <do_fork+0x120>
    ret = -E_NO_MEM;
ffffffffc02045de:	5571                	li	a0,-4
    return ret;
ffffffffc02045e0:	bf0d                	j	ffffffffc0204512 <do_fork+0x178>
    assert(current->mm == NULL);
ffffffffc02045e2:	00002697          	auipc	a3,0x2
ffffffffc02045e6:	69668693          	addi	a3,a3,1686 # ffffffffc0206c78 <default_pmm_manager+0x1038>
ffffffffc02045ea:	00001617          	auipc	a2,0x1
ffffffffc02045ee:	2a660613          	addi	a2,a2,678 # ffffffffc0205890 <commands+0x738>
ffffffffc02045f2:	11200593          	li	a1,274
ffffffffc02045f6:	00002517          	auipc	a0,0x2
ffffffffc02045fa:	69a50513          	addi	a0,a0,1690 # ffffffffc0206c90 <default_pmm_manager+0x1050>
ffffffffc02045fe:	e49fb0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0204602:	00001617          	auipc	a2,0x1
ffffffffc0204606:	67660613          	addi	a2,a2,1654 # ffffffffc0205c78 <default_pmm_manager+0x38>
ffffffffc020460a:	06900593          	li	a1,105
ffffffffc020460e:	00001517          	auipc	a0,0x1
ffffffffc0204612:	69250513          	addi	a0,a0,1682 # ffffffffc0205ca0 <default_pmm_manager+0x60>
ffffffffc0204616:	e31fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020461a <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020461a:	7129                	addi	sp,sp,-320
ffffffffc020461c:	fa22                	sd	s0,304(sp)
ffffffffc020461e:	f626                	sd	s1,296(sp)
ffffffffc0204620:	f24a                	sd	s2,288(sp)
ffffffffc0204622:	84ae                	mv	s1,a1
ffffffffc0204624:	892a                	mv	s2,a0
ffffffffc0204626:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204628:	4581                	li	a1,0
ffffffffc020462a:	12000613          	li	a2,288
ffffffffc020462e:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204630:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204632:	06f000ef          	jal	ra,ffffffffc0204ea0 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204636:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204638:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020463a:	100027f3          	csrr	a5,sstatus
ffffffffc020463e:	edd7f793          	andi	a5,a5,-291
ffffffffc0204642:	1207e793          	ori	a5,a5,288
ffffffffc0204646:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204648:	860a                	mv	a2,sp
ffffffffc020464a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020464e:	00000797          	auipc	a5,0x0
ffffffffc0204652:	bec78793          	addi	a5,a5,-1044 # ffffffffc020423a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204656:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204658:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020465a:	d41ff0ef          	jal	ra,ffffffffc020439a <do_fork>
}
ffffffffc020465e:	70f2                	ld	ra,312(sp)
ffffffffc0204660:	7452                	ld	s0,304(sp)
ffffffffc0204662:	74b2                	ld	s1,296(sp)
ffffffffc0204664:	7912                	ld	s2,288(sp)
ffffffffc0204666:	6131                	addi	sp,sp,320
ffffffffc0204668:	8082                	ret

ffffffffc020466a <do_exit>:
do_exit(int error_code) {
ffffffffc020466a:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc020466c:	00002617          	auipc	a2,0x2
ffffffffc0204670:	63c60613          	addi	a2,a2,1596 # ffffffffc0206ca8 <default_pmm_manager+0x1068>
ffffffffc0204674:	17100593          	li	a1,369
ffffffffc0204678:	00002517          	auipc	a0,0x2
ffffffffc020467c:	61850513          	addi	a0,a0,1560 # ffffffffc0206c90 <default_pmm_manager+0x1050>
do_exit(int error_code) {
ffffffffc0204680:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204682:	dc5fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204686 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204686:	7179                	addi	sp,sp,-48
ffffffffc0204688:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc020468a:	00012797          	auipc	a5,0x12
ffffffffc020468e:	e9e78793          	addi	a5,a5,-354 # ffffffffc0216528 <proc_list>
ffffffffc0204692:	f406                	sd	ra,40(sp)
ffffffffc0204694:	f022                	sd	s0,32(sp)
ffffffffc0204696:	e84a                	sd	s2,16(sp)
ffffffffc0204698:	e44e                	sd	s3,8(sp)
ffffffffc020469a:	0000e497          	auipc	s1,0xe
ffffffffc020469e:	e7e48493          	addi	s1,s1,-386 # ffffffffc0212518 <hash_list>
ffffffffc02046a2:	e79c                	sd	a5,8(a5)
ffffffffc02046a4:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02046a6:	00012717          	auipc	a4,0x12
ffffffffc02046aa:	e7270713          	addi	a4,a4,-398 # ffffffffc0216518 <name.2>
ffffffffc02046ae:	87a6                	mv	a5,s1
ffffffffc02046b0:	e79c                	sd	a5,8(a5)
ffffffffc02046b2:	e39c                	sd	a5,0(a5)
ffffffffc02046b4:	07c1                	addi	a5,a5,16
ffffffffc02046b6:	fef71de3          	bne	a4,a5,ffffffffc02046b0 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02046ba:	b89ff0ef          	jal	ra,ffffffffc0204242 <alloc_proc>
ffffffffc02046be:	00012917          	auipc	s2,0x12
ffffffffc02046c2:	efa90913          	addi	s2,s2,-262 # ffffffffc02165b8 <idleproc>
ffffffffc02046c6:	00a93023          	sd	a0,0(s2)
ffffffffc02046ca:	18050d63          	beqz	a0,ffffffffc0204864 <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046ce:	07000513          	li	a0,112
ffffffffc02046d2:	97cfd0ef          	jal	ra,ffffffffc020184e <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046d6:	07000613          	li	a2,112
ffffffffc02046da:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046dc:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046de:	7c2000ef          	jal	ra,ffffffffc0204ea0 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02046e2:	00093503          	ld	a0,0(s2)
ffffffffc02046e6:	85a2                	mv	a1,s0
ffffffffc02046e8:	07000613          	li	a2,112
ffffffffc02046ec:	03050513          	addi	a0,a0,48
ffffffffc02046f0:	7da000ef          	jal	ra,ffffffffc0204eca <memcmp>
ffffffffc02046f4:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046f6:	453d                	li	a0,15
ffffffffc02046f8:	956fd0ef          	jal	ra,ffffffffc020184e <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02046fc:	463d                	li	a2,15
ffffffffc02046fe:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204700:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204702:	79e000ef          	jal	ra,ffffffffc0204ea0 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0204706:	00093503          	ld	a0,0(s2)
ffffffffc020470a:	463d                	li	a2,15
ffffffffc020470c:	85a2                	mv	a1,s0
ffffffffc020470e:	0b450513          	addi	a0,a0,180
ffffffffc0204712:	7b8000ef          	jal	ra,ffffffffc0204eca <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204716:	00093783          	ld	a5,0(s2)
ffffffffc020471a:	00012717          	auipc	a4,0x12
ffffffffc020471e:	e3e73703          	ld	a4,-450(a4) # ffffffffc0216558 <boot_cr3>
ffffffffc0204722:	77d4                	ld	a3,168(a5)
ffffffffc0204724:	0ee68463          	beq	a3,a4,ffffffffc020480c <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204728:	4709                	li	a4,2
ffffffffc020472a:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc020472c:	00004717          	auipc	a4,0x4
ffffffffc0204730:	8d470713          	addi	a4,a4,-1836 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204734:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204738:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc020473a:	4705                	li	a4,1
ffffffffc020473c:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020473e:	4641                	li	a2,16
ffffffffc0204740:	4581                	li	a1,0
ffffffffc0204742:	8522                	mv	a0,s0
ffffffffc0204744:	75c000ef          	jal	ra,ffffffffc0204ea0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204748:	463d                	li	a2,15
ffffffffc020474a:	00002597          	auipc	a1,0x2
ffffffffc020474e:	5a658593          	addi	a1,a1,1446 # ffffffffc0206cf0 <default_pmm_manager+0x10b0>
ffffffffc0204752:	8522                	mv	a0,s0
ffffffffc0204754:	75e000ef          	jal	ra,ffffffffc0204eb2 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204758:	00012717          	auipc	a4,0x12
ffffffffc020475c:	e7070713          	addi	a4,a4,-400 # ffffffffc02165c8 <nr_process>
ffffffffc0204760:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0204762:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204766:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204768:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020476a:	00002597          	auipc	a1,0x2
ffffffffc020476e:	58e58593          	addi	a1,a1,1422 # ffffffffc0206cf8 <default_pmm_manager+0x10b8>
ffffffffc0204772:	00000517          	auipc	a0,0x0
ffffffffc0204776:	b4050513          	addi	a0,a0,-1216 # ffffffffc02042b2 <init_main>
    nr_process ++;
ffffffffc020477a:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020477c:	00012797          	auipc	a5,0x12
ffffffffc0204780:	e2d7ba23          	sd	a3,-460(a5) # ffffffffc02165b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204784:	e97ff0ef          	jal	ra,ffffffffc020461a <kernel_thread>
ffffffffc0204788:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc020478a:	0ea05963          	blez	a0,ffffffffc020487c <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020478e:	6789                	lui	a5,0x2
ffffffffc0204790:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204794:	17f9                	addi	a5,a5,-2
ffffffffc0204796:	2501                	sext.w	a0,a0
ffffffffc0204798:	02e7e363          	bltu	a5,a4,ffffffffc02047be <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020479c:	45a9                	li	a1,10
ffffffffc020479e:	282000ef          	jal	ra,ffffffffc0204a20 <hash32>
ffffffffc02047a2:	02051793          	slli	a5,a0,0x20
ffffffffc02047a6:	01c7d693          	srli	a3,a5,0x1c
ffffffffc02047aa:	96a6                	add	a3,a3,s1
ffffffffc02047ac:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02047ae:	a029                	j	ffffffffc02047b8 <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc02047b0:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc02047b4:	0a870563          	beq	a4,s0,ffffffffc020485e <proc_init+0x1d8>
    return listelm->next;
ffffffffc02047b8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02047ba:	fef69be3          	bne	a3,a5,ffffffffc02047b0 <proc_init+0x12a>
    return NULL;
ffffffffc02047be:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047c0:	0b478493          	addi	s1,a5,180
ffffffffc02047c4:	4641                	li	a2,16
ffffffffc02047c6:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02047c8:	00012417          	auipc	s0,0x12
ffffffffc02047cc:	df840413          	addi	s0,s0,-520 # ffffffffc02165c0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047d0:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02047d2:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047d4:	6cc000ef          	jal	ra,ffffffffc0204ea0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02047d8:	463d                	li	a2,15
ffffffffc02047da:	00002597          	auipc	a1,0x2
ffffffffc02047de:	54e58593          	addi	a1,a1,1358 # ffffffffc0206d28 <default_pmm_manager+0x10e8>
ffffffffc02047e2:	8526                	mv	a0,s1
ffffffffc02047e4:	6ce000ef          	jal	ra,ffffffffc0204eb2 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02047e8:	00093783          	ld	a5,0(s2)
ffffffffc02047ec:	c7e1                	beqz	a5,ffffffffc02048b4 <proc_init+0x22e>
ffffffffc02047ee:	43dc                	lw	a5,4(a5)
ffffffffc02047f0:	e3f1                	bnez	a5,ffffffffc02048b4 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02047f2:	601c                	ld	a5,0(s0)
ffffffffc02047f4:	c3c5                	beqz	a5,ffffffffc0204894 <proc_init+0x20e>
ffffffffc02047f6:	43d8                	lw	a4,4(a5)
ffffffffc02047f8:	4785                	li	a5,1
ffffffffc02047fa:	08f71d63          	bne	a4,a5,ffffffffc0204894 <proc_init+0x20e>
}
ffffffffc02047fe:	70a2                	ld	ra,40(sp)
ffffffffc0204800:	7402                	ld	s0,32(sp)
ffffffffc0204802:	64e2                	ld	s1,24(sp)
ffffffffc0204804:	6942                	ld	s2,16(sp)
ffffffffc0204806:	69a2                	ld	s3,8(sp)
ffffffffc0204808:	6145                	addi	sp,sp,48
ffffffffc020480a:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020480c:	73d8                	ld	a4,160(a5)
ffffffffc020480e:	ff09                	bnez	a4,ffffffffc0204728 <proc_init+0xa2>
ffffffffc0204810:	f0099ce3          	bnez	s3,ffffffffc0204728 <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204814:	6394                	ld	a3,0(a5)
ffffffffc0204816:	577d                	li	a4,-1
ffffffffc0204818:	1702                	slli	a4,a4,0x20
ffffffffc020481a:	f0e697e3          	bne	a3,a4,ffffffffc0204728 <proc_init+0xa2>
ffffffffc020481e:	4798                	lw	a4,8(a5)
ffffffffc0204820:	f00714e3          	bnez	a4,ffffffffc0204728 <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204824:	6b98                	ld	a4,16(a5)
ffffffffc0204826:	f00711e3          	bnez	a4,ffffffffc0204728 <proc_init+0xa2>
ffffffffc020482a:	4f98                	lw	a4,24(a5)
ffffffffc020482c:	2701                	sext.w	a4,a4
ffffffffc020482e:	ee071de3          	bnez	a4,ffffffffc0204728 <proc_init+0xa2>
ffffffffc0204832:	7398                	ld	a4,32(a5)
ffffffffc0204834:	ee071ae3          	bnez	a4,ffffffffc0204728 <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204838:	7798                	ld	a4,40(a5)
ffffffffc020483a:	ee0717e3          	bnez	a4,ffffffffc0204728 <proc_init+0xa2>
ffffffffc020483e:	0b07a703          	lw	a4,176(a5)
ffffffffc0204842:	8d59                	or	a0,a0,a4
ffffffffc0204844:	0005071b          	sext.w	a4,a0
ffffffffc0204848:	ee0710e3          	bnez	a4,ffffffffc0204728 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc020484c:	00002517          	auipc	a0,0x2
ffffffffc0204850:	48c50513          	addi	a0,a0,1164 # ffffffffc0206cd8 <default_pmm_manager+0x1098>
ffffffffc0204854:	92dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    idleproc->pid = 0;
ffffffffc0204858:	00093783          	ld	a5,0(s2)
ffffffffc020485c:	b5f1                	j	ffffffffc0204728 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020485e:	f2878793          	addi	a5,a5,-216
ffffffffc0204862:	bfb9                	j	ffffffffc02047c0 <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc0204864:	00002617          	auipc	a2,0x2
ffffffffc0204868:	45c60613          	addi	a2,a2,1116 # ffffffffc0206cc0 <default_pmm_manager+0x1080>
ffffffffc020486c:	18900593          	li	a1,393
ffffffffc0204870:	00002517          	auipc	a0,0x2
ffffffffc0204874:	42050513          	addi	a0,a0,1056 # ffffffffc0206c90 <default_pmm_manager+0x1050>
ffffffffc0204878:	bcffb0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("create init_main failed.\n");
ffffffffc020487c:	00002617          	auipc	a2,0x2
ffffffffc0204880:	48c60613          	addi	a2,a2,1164 # ffffffffc0206d08 <default_pmm_manager+0x10c8>
ffffffffc0204884:	1a900593          	li	a1,425
ffffffffc0204888:	00002517          	auipc	a0,0x2
ffffffffc020488c:	40850513          	addi	a0,a0,1032 # ffffffffc0206c90 <default_pmm_manager+0x1050>
ffffffffc0204890:	bb7fb0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204894:	00002697          	auipc	a3,0x2
ffffffffc0204898:	4c468693          	addi	a3,a3,1220 # ffffffffc0206d58 <default_pmm_manager+0x1118>
ffffffffc020489c:	00001617          	auipc	a2,0x1
ffffffffc02048a0:	ff460613          	addi	a2,a2,-12 # ffffffffc0205890 <commands+0x738>
ffffffffc02048a4:	1b000593          	li	a1,432
ffffffffc02048a8:	00002517          	auipc	a0,0x2
ffffffffc02048ac:	3e850513          	addi	a0,a0,1000 # ffffffffc0206c90 <default_pmm_manager+0x1050>
ffffffffc02048b0:	b97fb0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02048b4:	00002697          	auipc	a3,0x2
ffffffffc02048b8:	47c68693          	addi	a3,a3,1148 # ffffffffc0206d30 <default_pmm_manager+0x10f0>
ffffffffc02048bc:	00001617          	auipc	a2,0x1
ffffffffc02048c0:	fd460613          	addi	a2,a2,-44 # ffffffffc0205890 <commands+0x738>
ffffffffc02048c4:	1af00593          	li	a1,431
ffffffffc02048c8:	00002517          	auipc	a0,0x2
ffffffffc02048cc:	3c850513          	addi	a0,a0,968 # ffffffffc0206c90 <default_pmm_manager+0x1050>
ffffffffc02048d0:	b77fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02048d4 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02048d4:	1141                	addi	sp,sp,-16
ffffffffc02048d6:	e022                	sd	s0,0(sp)
ffffffffc02048d8:	e406                	sd	ra,8(sp)
ffffffffc02048da:	00012417          	auipc	s0,0x12
ffffffffc02048de:	cd640413          	addi	s0,s0,-810 # ffffffffc02165b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02048e2:	6018                	ld	a4,0(s0)
ffffffffc02048e4:	4f1c                	lw	a5,24(a4)
ffffffffc02048e6:	2781                	sext.w	a5,a5
ffffffffc02048e8:	dff5                	beqz	a5,ffffffffc02048e4 <cpu_idle+0x10>
            schedule();
ffffffffc02048ea:	0a2000ef          	jal	ra,ffffffffc020498c <schedule>
ffffffffc02048ee:	bfd5                	j	ffffffffc02048e2 <cpu_idle+0xe>

ffffffffc02048f0 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02048f0:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02048f4:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02048f8:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02048fa:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02048fc:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204900:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204904:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204908:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020490c:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204910:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204914:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204918:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020491c:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204920:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204924:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204928:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020492c:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020492e:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204930:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204934:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204938:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020493c:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204940:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204944:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204948:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020494c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204950:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204954:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204958:	8082                	ret

ffffffffc020495a <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020495a:	411c                	lw	a5,0(a0)
ffffffffc020495c:	4705                	li	a4,1
ffffffffc020495e:	37f9                	addiw	a5,a5,-2
ffffffffc0204960:	00f77563          	bgeu	a4,a5,ffffffffc020496a <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204964:	4789                	li	a5,2
ffffffffc0204966:	c11c                	sw	a5,0(a0)
ffffffffc0204968:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc020496a:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020496c:	00002697          	auipc	a3,0x2
ffffffffc0204970:	41468693          	addi	a3,a3,1044 # ffffffffc0206d80 <default_pmm_manager+0x1140>
ffffffffc0204974:	00001617          	auipc	a2,0x1
ffffffffc0204978:	f1c60613          	addi	a2,a2,-228 # ffffffffc0205890 <commands+0x738>
ffffffffc020497c:	45a5                	li	a1,9
ffffffffc020497e:	00002517          	auipc	a0,0x2
ffffffffc0204982:	44250513          	addi	a0,a0,1090 # ffffffffc0206dc0 <default_pmm_manager+0x1180>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204986:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204988:	abffb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020498c <schedule>:
}

void
schedule(void) {
ffffffffc020498c:	1141                	addi	sp,sp,-16
ffffffffc020498e:	e406                	sd	ra,8(sp)
ffffffffc0204990:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204992:	100027f3          	csrr	a5,sstatus
ffffffffc0204996:	8b89                	andi	a5,a5,2
ffffffffc0204998:	4401                	li	s0,0
ffffffffc020499a:	efbd                	bnez	a5,ffffffffc0204a18 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020499c:	00012897          	auipc	a7,0x12
ffffffffc02049a0:	c148b883          	ld	a7,-1004(a7) # ffffffffc02165b0 <current>
ffffffffc02049a4:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049a8:	00012517          	auipc	a0,0x12
ffffffffc02049ac:	c1053503          	ld	a0,-1008(a0) # ffffffffc02165b8 <idleproc>
ffffffffc02049b0:	04a88e63          	beq	a7,a0,ffffffffc0204a0c <schedule+0x80>
ffffffffc02049b4:	0c888693          	addi	a3,a7,200
ffffffffc02049b8:	00012617          	auipc	a2,0x12
ffffffffc02049bc:	b7060613          	addi	a2,a2,-1168 # ffffffffc0216528 <proc_list>
        le = last;
ffffffffc02049c0:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02049c2:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049c4:	4809                	li	a6,2
ffffffffc02049c6:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02049c8:	00c78863          	beq	a5,a2,ffffffffc02049d8 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049cc:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02049d0:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02049d4:	03070163          	beq	a4,a6,ffffffffc02049f6 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02049d8:	fef697e3          	bne	a3,a5,ffffffffc02049c6 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049dc:	ed89                	bnez	a1,ffffffffc02049f6 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02049de:	451c                	lw	a5,8(a0)
ffffffffc02049e0:	2785                	addiw	a5,a5,1
ffffffffc02049e2:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02049e4:	00a88463          	beq	a7,a0,ffffffffc02049ec <schedule+0x60>
            proc_run(next);
ffffffffc02049e8:	93dff0ef          	jal	ra,ffffffffc0204324 <proc_run>
    if (flag) {
ffffffffc02049ec:	e819                	bnez	s0,ffffffffc0204a02 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02049ee:	60a2                	ld	ra,8(sp)
ffffffffc02049f0:	6402                	ld	s0,0(sp)
ffffffffc02049f2:	0141                	addi	sp,sp,16
ffffffffc02049f4:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049f6:	4198                	lw	a4,0(a1)
ffffffffc02049f8:	4789                	li	a5,2
ffffffffc02049fa:	fef712e3          	bne	a4,a5,ffffffffc02049de <schedule+0x52>
ffffffffc02049fe:	852e                	mv	a0,a1
ffffffffc0204a00:	bff9                	j	ffffffffc02049de <schedule+0x52>
}
ffffffffc0204a02:	6402                	ld	s0,0(sp)
ffffffffc0204a04:	60a2                	ld	ra,8(sp)
ffffffffc0204a06:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204a08:	bb5fb06f          	j	ffffffffc02005bc <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204a0c:	00012617          	auipc	a2,0x12
ffffffffc0204a10:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0216528 <proc_list>
ffffffffc0204a14:	86b2                	mv	a3,a2
ffffffffc0204a16:	b76d                	j	ffffffffc02049c0 <schedule+0x34>
        intr_disable();
ffffffffc0204a18:	babfb0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0204a1c:	4405                	li	s0,1
ffffffffc0204a1e:	bfbd                	j	ffffffffc020499c <schedule+0x10>

ffffffffc0204a20 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204a20:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204a24:	2785                	addiw	a5,a5,1
ffffffffc0204a26:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204a2a:	02000793          	li	a5,32
ffffffffc0204a2e:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204a30:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204a34:	8082                	ret

ffffffffc0204a36 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204a36:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a3a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204a3c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a40:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204a42:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a46:	f022                	sd	s0,32(sp)
ffffffffc0204a48:	ec26                	sd	s1,24(sp)
ffffffffc0204a4a:	e84a                	sd	s2,16(sp)
ffffffffc0204a4c:	f406                	sd	ra,40(sp)
ffffffffc0204a4e:	e44e                	sd	s3,8(sp)
ffffffffc0204a50:	84aa                	mv	s1,a0
ffffffffc0204a52:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204a54:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204a58:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204a5a:	03067e63          	bgeu	a2,a6,ffffffffc0204a96 <printnum+0x60>
ffffffffc0204a5e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204a60:	00805763          	blez	s0,ffffffffc0204a6e <printnum+0x38>
ffffffffc0204a64:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204a66:	85ca                	mv	a1,s2
ffffffffc0204a68:	854e                	mv	a0,s3
ffffffffc0204a6a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204a6c:	fc65                	bnez	s0,ffffffffc0204a64 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a6e:	1a02                	slli	s4,s4,0x20
ffffffffc0204a70:	00002797          	auipc	a5,0x2
ffffffffc0204a74:	36878793          	addi	a5,a5,872 # ffffffffc0206dd8 <default_pmm_manager+0x1198>
ffffffffc0204a78:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204a7c:	9a3e                	add	s4,s4,a5
}
ffffffffc0204a7e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a80:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204a84:	70a2                	ld	ra,40(sp)
ffffffffc0204a86:	69a2                	ld	s3,8(sp)
ffffffffc0204a88:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a8a:	85ca                	mv	a1,s2
ffffffffc0204a8c:	87a6                	mv	a5,s1
}
ffffffffc0204a8e:	6942                	ld	s2,16(sp)
ffffffffc0204a90:	64e2                	ld	s1,24(sp)
ffffffffc0204a92:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a94:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204a96:	03065633          	divu	a2,a2,a6
ffffffffc0204a9a:	8722                	mv	a4,s0
ffffffffc0204a9c:	f9bff0ef          	jal	ra,ffffffffc0204a36 <printnum>
ffffffffc0204aa0:	b7f9                	j	ffffffffc0204a6e <printnum+0x38>

ffffffffc0204aa2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204aa2:	7119                	addi	sp,sp,-128
ffffffffc0204aa4:	f4a6                	sd	s1,104(sp)
ffffffffc0204aa6:	f0ca                	sd	s2,96(sp)
ffffffffc0204aa8:	ecce                	sd	s3,88(sp)
ffffffffc0204aaa:	e8d2                	sd	s4,80(sp)
ffffffffc0204aac:	e4d6                	sd	s5,72(sp)
ffffffffc0204aae:	e0da                	sd	s6,64(sp)
ffffffffc0204ab0:	fc5e                	sd	s7,56(sp)
ffffffffc0204ab2:	f06a                	sd	s10,32(sp)
ffffffffc0204ab4:	fc86                	sd	ra,120(sp)
ffffffffc0204ab6:	f8a2                	sd	s0,112(sp)
ffffffffc0204ab8:	f862                	sd	s8,48(sp)
ffffffffc0204aba:	f466                	sd	s9,40(sp)
ffffffffc0204abc:	ec6e                	sd	s11,24(sp)
ffffffffc0204abe:	892a                	mv	s2,a0
ffffffffc0204ac0:	84ae                	mv	s1,a1
ffffffffc0204ac2:	8d32                	mv	s10,a2
ffffffffc0204ac4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204ac6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204aca:	5b7d                	li	s6,-1
ffffffffc0204acc:	00002a97          	auipc	s5,0x2
ffffffffc0204ad0:	338a8a93          	addi	s5,s5,824 # ffffffffc0206e04 <default_pmm_manager+0x11c4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204ad4:	00002b97          	auipc	s7,0x2
ffffffffc0204ad8:	50cb8b93          	addi	s7,s7,1292 # ffffffffc0206fe0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204adc:	000d4503          	lbu	a0,0(s10)
ffffffffc0204ae0:	001d0413          	addi	s0,s10,1
ffffffffc0204ae4:	01350a63          	beq	a0,s3,ffffffffc0204af8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204ae8:	c121                	beqz	a0,ffffffffc0204b28 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204aea:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204aec:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204aee:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204af0:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204af4:	ff351ae3          	bne	a0,s3,ffffffffc0204ae8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204af8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204afc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b00:	4c81                	li	s9,0
ffffffffc0204b02:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204b04:	5c7d                	li	s8,-1
ffffffffc0204b06:	5dfd                	li	s11,-1
ffffffffc0204b08:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204b0c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b0e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204b12:	0ff5f593          	zext.b	a1,a1
ffffffffc0204b16:	00140d13          	addi	s10,s0,1
ffffffffc0204b1a:	04b56263          	bltu	a0,a1,ffffffffc0204b5e <vprintfmt+0xbc>
ffffffffc0204b1e:	058a                	slli	a1,a1,0x2
ffffffffc0204b20:	95d6                	add	a1,a1,s5
ffffffffc0204b22:	4194                	lw	a3,0(a1)
ffffffffc0204b24:	96d6                	add	a3,a3,s5
ffffffffc0204b26:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204b28:	70e6                	ld	ra,120(sp)
ffffffffc0204b2a:	7446                	ld	s0,112(sp)
ffffffffc0204b2c:	74a6                	ld	s1,104(sp)
ffffffffc0204b2e:	7906                	ld	s2,96(sp)
ffffffffc0204b30:	69e6                	ld	s3,88(sp)
ffffffffc0204b32:	6a46                	ld	s4,80(sp)
ffffffffc0204b34:	6aa6                	ld	s5,72(sp)
ffffffffc0204b36:	6b06                	ld	s6,64(sp)
ffffffffc0204b38:	7be2                	ld	s7,56(sp)
ffffffffc0204b3a:	7c42                	ld	s8,48(sp)
ffffffffc0204b3c:	7ca2                	ld	s9,40(sp)
ffffffffc0204b3e:	7d02                	ld	s10,32(sp)
ffffffffc0204b40:	6de2                	ld	s11,24(sp)
ffffffffc0204b42:	6109                	addi	sp,sp,128
ffffffffc0204b44:	8082                	ret
            padc = '0';
ffffffffc0204b46:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204b48:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b4c:	846a                	mv	s0,s10
ffffffffc0204b4e:	00140d13          	addi	s10,s0,1
ffffffffc0204b52:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204b56:	0ff5f593          	zext.b	a1,a1
ffffffffc0204b5a:	fcb572e3          	bgeu	a0,a1,ffffffffc0204b1e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204b5e:	85a6                	mv	a1,s1
ffffffffc0204b60:	02500513          	li	a0,37
ffffffffc0204b64:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204b66:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204b6a:	8d22                	mv	s10,s0
ffffffffc0204b6c:	f73788e3          	beq	a5,s3,ffffffffc0204adc <vprintfmt+0x3a>
ffffffffc0204b70:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204b74:	1d7d                	addi	s10,s10,-1
ffffffffc0204b76:	ff379de3          	bne	a5,s3,ffffffffc0204b70 <vprintfmt+0xce>
ffffffffc0204b7a:	b78d                	j	ffffffffc0204adc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204b7c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204b80:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b84:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204b86:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204b8a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204b8e:	02d86463          	bltu	a6,a3,ffffffffc0204bb6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204b92:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204b96:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204b9a:	0186873b          	addw	a4,a3,s8
ffffffffc0204b9e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204ba2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204ba4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204ba8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204baa:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204bae:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204bb2:	fed870e3          	bgeu	a6,a3,ffffffffc0204b92 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204bb6:	f40ddce3          	bgez	s11,ffffffffc0204b0e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204bba:	8de2                	mv	s11,s8
ffffffffc0204bbc:	5c7d                	li	s8,-1
ffffffffc0204bbe:	bf81                	j	ffffffffc0204b0e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204bc0:	fffdc693          	not	a3,s11
ffffffffc0204bc4:	96fd                	srai	a3,a3,0x3f
ffffffffc0204bc6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bca:	00144603          	lbu	a2,1(s0)
ffffffffc0204bce:	2d81                	sext.w	s11,s11
ffffffffc0204bd0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204bd2:	bf35                	j	ffffffffc0204b0e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204bd4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bd8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204bdc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bde:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204be0:	bfd9                	j	ffffffffc0204bb6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204be2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204be4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204be8:	01174463          	blt	a4,a7,ffffffffc0204bf0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204bec:	1a088e63          	beqz	a7,ffffffffc0204da8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204bf0:	000a3603          	ld	a2,0(s4)
ffffffffc0204bf4:	46c1                	li	a3,16
ffffffffc0204bf6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204bf8:	2781                	sext.w	a5,a5
ffffffffc0204bfa:	876e                	mv	a4,s11
ffffffffc0204bfc:	85a6                	mv	a1,s1
ffffffffc0204bfe:	854a                	mv	a0,s2
ffffffffc0204c00:	e37ff0ef          	jal	ra,ffffffffc0204a36 <printnum>
            break;
ffffffffc0204c04:	bde1                	j	ffffffffc0204adc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204c06:	000a2503          	lw	a0,0(s4)
ffffffffc0204c0a:	85a6                	mv	a1,s1
ffffffffc0204c0c:	0a21                	addi	s4,s4,8
ffffffffc0204c0e:	9902                	jalr	s2
            break;
ffffffffc0204c10:	b5f1                	j	ffffffffc0204adc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c12:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c14:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c18:	01174463          	blt	a4,a7,ffffffffc0204c20 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204c1c:	18088163          	beqz	a7,ffffffffc0204d9e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204c20:	000a3603          	ld	a2,0(s4)
ffffffffc0204c24:	46a9                	li	a3,10
ffffffffc0204c26:	8a2e                	mv	s4,a1
ffffffffc0204c28:	bfc1                	j	ffffffffc0204bf8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c2a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204c2e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c30:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c32:	bdf1                	j	ffffffffc0204b0e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204c34:	85a6                	mv	a1,s1
ffffffffc0204c36:	02500513          	li	a0,37
ffffffffc0204c3a:	9902                	jalr	s2
            break;
ffffffffc0204c3c:	b545                	j	ffffffffc0204adc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c3e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204c42:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c44:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c46:	b5e1                	j	ffffffffc0204b0e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204c48:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c4a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c4e:	01174463          	blt	a4,a7,ffffffffc0204c56 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204c52:	14088163          	beqz	a7,ffffffffc0204d94 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204c56:	000a3603          	ld	a2,0(s4)
ffffffffc0204c5a:	46a1                	li	a3,8
ffffffffc0204c5c:	8a2e                	mv	s4,a1
ffffffffc0204c5e:	bf69                	j	ffffffffc0204bf8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204c60:	03000513          	li	a0,48
ffffffffc0204c64:	85a6                	mv	a1,s1
ffffffffc0204c66:	e03e                	sd	a5,0(sp)
ffffffffc0204c68:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204c6a:	85a6                	mv	a1,s1
ffffffffc0204c6c:	07800513          	li	a0,120
ffffffffc0204c70:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204c72:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204c74:	6782                	ld	a5,0(sp)
ffffffffc0204c76:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204c78:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204c7c:	bfb5                	j	ffffffffc0204bf8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204c7e:	000a3403          	ld	s0,0(s4)
ffffffffc0204c82:	008a0713          	addi	a4,s4,8
ffffffffc0204c86:	e03a                	sd	a4,0(sp)
ffffffffc0204c88:	14040263          	beqz	s0,ffffffffc0204dcc <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204c8c:	0fb05763          	blez	s11,ffffffffc0204d7a <vprintfmt+0x2d8>
ffffffffc0204c90:	02d00693          	li	a3,45
ffffffffc0204c94:	0cd79163          	bne	a5,a3,ffffffffc0204d56 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c98:	00044783          	lbu	a5,0(s0)
ffffffffc0204c9c:	0007851b          	sext.w	a0,a5
ffffffffc0204ca0:	cf85                	beqz	a5,ffffffffc0204cd8 <vprintfmt+0x236>
ffffffffc0204ca2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204ca6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204caa:	000c4563          	bltz	s8,ffffffffc0204cb4 <vprintfmt+0x212>
ffffffffc0204cae:	3c7d                	addiw	s8,s8,-1
ffffffffc0204cb0:	036c0263          	beq	s8,s6,ffffffffc0204cd4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204cb4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204cb6:	0e0c8e63          	beqz	s9,ffffffffc0204db2 <vprintfmt+0x310>
ffffffffc0204cba:	3781                	addiw	a5,a5,-32
ffffffffc0204cbc:	0ef47b63          	bgeu	s0,a5,ffffffffc0204db2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204cc0:	03f00513          	li	a0,63
ffffffffc0204cc4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cc6:	000a4783          	lbu	a5,0(s4)
ffffffffc0204cca:	3dfd                	addiw	s11,s11,-1
ffffffffc0204ccc:	0a05                	addi	s4,s4,1
ffffffffc0204cce:	0007851b          	sext.w	a0,a5
ffffffffc0204cd2:	ffe1                	bnez	a5,ffffffffc0204caa <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204cd4:	01b05963          	blez	s11,ffffffffc0204ce6 <vprintfmt+0x244>
ffffffffc0204cd8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204cda:	85a6                	mv	a1,s1
ffffffffc0204cdc:	02000513          	li	a0,32
ffffffffc0204ce0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204ce2:	fe0d9be3          	bnez	s11,ffffffffc0204cd8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204ce6:	6a02                	ld	s4,0(sp)
ffffffffc0204ce8:	bbd5                	j	ffffffffc0204adc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204cea:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204cec:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204cf0:	01174463          	blt	a4,a7,ffffffffc0204cf8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204cf4:	08088d63          	beqz	a7,ffffffffc0204d8e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204cf8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204cfc:	0a044d63          	bltz	s0,ffffffffc0204db6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204d00:	8622                	mv	a2,s0
ffffffffc0204d02:	8a66                	mv	s4,s9
ffffffffc0204d04:	46a9                	li	a3,10
ffffffffc0204d06:	bdcd                	j	ffffffffc0204bf8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204d08:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d0c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204d0e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204d10:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204d14:	8fb5                	xor	a5,a5,a3
ffffffffc0204d16:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d1a:	02d74163          	blt	a4,a3,ffffffffc0204d3c <vprintfmt+0x29a>
ffffffffc0204d1e:	00369793          	slli	a5,a3,0x3
ffffffffc0204d22:	97de                	add	a5,a5,s7
ffffffffc0204d24:	639c                	ld	a5,0(a5)
ffffffffc0204d26:	cb99                	beqz	a5,ffffffffc0204d3c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204d28:	86be                	mv	a3,a5
ffffffffc0204d2a:	00000617          	auipc	a2,0x0
ffffffffc0204d2e:	1ee60613          	addi	a2,a2,494 # ffffffffc0204f18 <etext+0x2a>
ffffffffc0204d32:	85a6                	mv	a1,s1
ffffffffc0204d34:	854a                	mv	a0,s2
ffffffffc0204d36:	0ce000ef          	jal	ra,ffffffffc0204e04 <printfmt>
ffffffffc0204d3a:	b34d                	j	ffffffffc0204adc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204d3c:	00002617          	auipc	a2,0x2
ffffffffc0204d40:	0bc60613          	addi	a2,a2,188 # ffffffffc0206df8 <default_pmm_manager+0x11b8>
ffffffffc0204d44:	85a6                	mv	a1,s1
ffffffffc0204d46:	854a                	mv	a0,s2
ffffffffc0204d48:	0bc000ef          	jal	ra,ffffffffc0204e04 <printfmt>
ffffffffc0204d4c:	bb41                	j	ffffffffc0204adc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204d4e:	00002417          	auipc	s0,0x2
ffffffffc0204d52:	0a240413          	addi	s0,s0,162 # ffffffffc0206df0 <default_pmm_manager+0x11b0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d56:	85e2                	mv	a1,s8
ffffffffc0204d58:	8522                	mv	a0,s0
ffffffffc0204d5a:	e43e                	sd	a5,8(sp)
ffffffffc0204d5c:	0e2000ef          	jal	ra,ffffffffc0204e3e <strnlen>
ffffffffc0204d60:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204d64:	01b05b63          	blez	s11,ffffffffc0204d7a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204d68:	67a2                	ld	a5,8(sp)
ffffffffc0204d6a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d6e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204d70:	85a6                	mv	a1,s1
ffffffffc0204d72:	8552                	mv	a0,s4
ffffffffc0204d74:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d76:	fe0d9ce3          	bnez	s11,ffffffffc0204d6e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d7a:	00044783          	lbu	a5,0(s0)
ffffffffc0204d7e:	00140a13          	addi	s4,s0,1
ffffffffc0204d82:	0007851b          	sext.w	a0,a5
ffffffffc0204d86:	d3a5                	beqz	a5,ffffffffc0204ce6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204d88:	05e00413          	li	s0,94
ffffffffc0204d8c:	bf39                	j	ffffffffc0204caa <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204d8e:	000a2403          	lw	s0,0(s4)
ffffffffc0204d92:	b7ad                	j	ffffffffc0204cfc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204d94:	000a6603          	lwu	a2,0(s4)
ffffffffc0204d98:	46a1                	li	a3,8
ffffffffc0204d9a:	8a2e                	mv	s4,a1
ffffffffc0204d9c:	bdb1                	j	ffffffffc0204bf8 <vprintfmt+0x156>
ffffffffc0204d9e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204da2:	46a9                	li	a3,10
ffffffffc0204da4:	8a2e                	mv	s4,a1
ffffffffc0204da6:	bd89                	j	ffffffffc0204bf8 <vprintfmt+0x156>
ffffffffc0204da8:	000a6603          	lwu	a2,0(s4)
ffffffffc0204dac:	46c1                	li	a3,16
ffffffffc0204dae:	8a2e                	mv	s4,a1
ffffffffc0204db0:	b5a1                	j	ffffffffc0204bf8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204db2:	9902                	jalr	s2
ffffffffc0204db4:	bf09                	j	ffffffffc0204cc6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204db6:	85a6                	mv	a1,s1
ffffffffc0204db8:	02d00513          	li	a0,45
ffffffffc0204dbc:	e03e                	sd	a5,0(sp)
ffffffffc0204dbe:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204dc0:	6782                	ld	a5,0(sp)
ffffffffc0204dc2:	8a66                	mv	s4,s9
ffffffffc0204dc4:	40800633          	neg	a2,s0
ffffffffc0204dc8:	46a9                	li	a3,10
ffffffffc0204dca:	b53d                	j	ffffffffc0204bf8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204dcc:	03b05163          	blez	s11,ffffffffc0204dee <vprintfmt+0x34c>
ffffffffc0204dd0:	02d00693          	li	a3,45
ffffffffc0204dd4:	f6d79de3          	bne	a5,a3,ffffffffc0204d4e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204dd8:	00002417          	auipc	s0,0x2
ffffffffc0204ddc:	01840413          	addi	s0,s0,24 # ffffffffc0206df0 <default_pmm_manager+0x11b0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204de0:	02800793          	li	a5,40
ffffffffc0204de4:	02800513          	li	a0,40
ffffffffc0204de8:	00140a13          	addi	s4,s0,1
ffffffffc0204dec:	bd6d                	j	ffffffffc0204ca6 <vprintfmt+0x204>
ffffffffc0204dee:	00002a17          	auipc	s4,0x2
ffffffffc0204df2:	003a0a13          	addi	s4,s4,3 # ffffffffc0206df1 <default_pmm_manager+0x11b1>
ffffffffc0204df6:	02800513          	li	a0,40
ffffffffc0204dfa:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204dfe:	05e00413          	li	s0,94
ffffffffc0204e02:	b565                	j	ffffffffc0204caa <vprintfmt+0x208>

ffffffffc0204e04 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e04:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e06:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e0a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e0c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e0e:	ec06                	sd	ra,24(sp)
ffffffffc0204e10:	f83a                	sd	a4,48(sp)
ffffffffc0204e12:	fc3e                	sd	a5,56(sp)
ffffffffc0204e14:	e0c2                	sd	a6,64(sp)
ffffffffc0204e16:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204e18:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e1a:	c89ff0ef          	jal	ra,ffffffffc0204aa2 <vprintfmt>
}
ffffffffc0204e1e:	60e2                	ld	ra,24(sp)
ffffffffc0204e20:	6161                	addi	sp,sp,80
ffffffffc0204e22:	8082                	ret

ffffffffc0204e24 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204e24:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204e28:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204e2a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204e2c:	cb81                	beqz	a5,ffffffffc0204e3c <strlen+0x18>
        cnt ++;
ffffffffc0204e2e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204e30:	00a707b3          	add	a5,a4,a0
ffffffffc0204e34:	0007c783          	lbu	a5,0(a5)
ffffffffc0204e38:	fbfd                	bnez	a5,ffffffffc0204e2e <strlen+0xa>
ffffffffc0204e3a:	8082                	ret
    }
    return cnt;
}
ffffffffc0204e3c:	8082                	ret

ffffffffc0204e3e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204e3e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e40:	e589                	bnez	a1,ffffffffc0204e4a <strnlen+0xc>
ffffffffc0204e42:	a811                	j	ffffffffc0204e56 <strnlen+0x18>
        cnt ++;
ffffffffc0204e44:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e46:	00f58863          	beq	a1,a5,ffffffffc0204e56 <strnlen+0x18>
ffffffffc0204e4a:	00f50733          	add	a4,a0,a5
ffffffffc0204e4e:	00074703          	lbu	a4,0(a4)
ffffffffc0204e52:	fb6d                	bnez	a4,ffffffffc0204e44 <strnlen+0x6>
ffffffffc0204e54:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204e56:	852e                	mv	a0,a1
ffffffffc0204e58:	8082                	ret

ffffffffc0204e5a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204e5a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204e5c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e60:	0785                	addi	a5,a5,1
ffffffffc0204e62:	0585                	addi	a1,a1,1
ffffffffc0204e64:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204e68:	fb75                	bnez	a4,ffffffffc0204e5c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204e6a:	8082                	ret

ffffffffc0204e6c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e6c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204e70:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e74:	cb89                	beqz	a5,ffffffffc0204e86 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204e76:	0505                	addi	a0,a0,1
ffffffffc0204e78:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e7a:	fee789e3          	beq	a5,a4,ffffffffc0204e6c <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204e7e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204e82:	9d19                	subw	a0,a0,a4
ffffffffc0204e84:	8082                	ret
ffffffffc0204e86:	4501                	li	a0,0
ffffffffc0204e88:	bfed                	j	ffffffffc0204e82 <strcmp+0x16>

ffffffffc0204e8a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204e8a:	00054783          	lbu	a5,0(a0)
ffffffffc0204e8e:	c799                	beqz	a5,ffffffffc0204e9c <strchr+0x12>
        if (*s == c) {
ffffffffc0204e90:	00f58763          	beq	a1,a5,ffffffffc0204e9e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204e94:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204e98:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204e9a:	fbfd                	bnez	a5,ffffffffc0204e90 <strchr+0x6>
    }
    return NULL;
ffffffffc0204e9c:	4501                	li	a0,0
}
ffffffffc0204e9e:	8082                	ret

ffffffffc0204ea0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204ea0:	ca01                	beqz	a2,ffffffffc0204eb0 <memset+0x10>
ffffffffc0204ea2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204ea4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204ea6:	0785                	addi	a5,a5,1
ffffffffc0204ea8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204eac:	fec79de3          	bne	a5,a2,ffffffffc0204ea6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204eb0:	8082                	ret

ffffffffc0204eb2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204eb2:	ca19                	beqz	a2,ffffffffc0204ec8 <memcpy+0x16>
ffffffffc0204eb4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204eb6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204eb8:	0005c703          	lbu	a4,0(a1)
ffffffffc0204ebc:	0585                	addi	a1,a1,1
ffffffffc0204ebe:	0785                	addi	a5,a5,1
ffffffffc0204ec0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204ec4:	fec59ae3          	bne	a1,a2,ffffffffc0204eb8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204ec8:	8082                	ret

ffffffffc0204eca <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204eca:	c205                	beqz	a2,ffffffffc0204eea <memcmp+0x20>
ffffffffc0204ecc:	962e                	add	a2,a2,a1
ffffffffc0204ece:	a019                	j	ffffffffc0204ed4 <memcmp+0xa>
ffffffffc0204ed0:	00c58d63          	beq	a1,a2,ffffffffc0204eea <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0204ed4:	00054783          	lbu	a5,0(a0)
ffffffffc0204ed8:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204edc:	0505                	addi	a0,a0,1
ffffffffc0204ede:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0204ee0:	fee788e3          	beq	a5,a4,ffffffffc0204ed0 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204ee4:	40e7853b          	subw	a0,a5,a4
ffffffffc0204ee8:	8082                	ret
    }
    return 0;
ffffffffc0204eea:	4501                	li	a0,0
}
ffffffffc0204eec:	8082                	ret