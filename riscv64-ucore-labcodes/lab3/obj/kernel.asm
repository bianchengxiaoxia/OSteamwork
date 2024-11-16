
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02082b7          	lui	t0,0xc0208
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
ffffffffc0200024:	c0208137          	lui	sp,0xc0208

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00009517          	auipc	a0,0x9
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc0209040 <ide>
ffffffffc020003a:	00010617          	auipc	a2,0x10
ffffffffc020003e:	51a60613          	addi	a2,a2,1306 # ffffffffc0210554 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	164040ef          	jal	ra,ffffffffc02041ae <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	18a58593          	addi	a1,a1,394 # ffffffffc02041d8 <etext>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	1a250513          	addi	a0,a0,418 # ffffffffc02041f8 <etext+0x20>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	221010ef          	jal	ra,ffffffffc0201a86 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4d6000ef          	jal	ra,ffffffffc0200540 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	4ce030ef          	jal	ra,ffffffffc020353c <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	075020ef          	jal	ra,ffffffffc02028ea <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	39a000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	44f030ef          	jal	ra,ffffffffc0203cfc <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	419030ef          	jal	ra,ffffffffc0203cfc <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	ae0d                	j	ffffffffc0200422 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	360000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200102:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	0fc50513          	addi	a0,a0,252 # ffffffffc0204200 <etext+0x28>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	10650513          	addi	a0,a0,262 # ffffffffc0204220 <etext+0x48>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	0b258593          	addi	a1,a1,178 # ffffffffc02041d8 <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	11250513          	addi	a0,a0,274 # ffffffffc0204240 <etext+0x68>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	00009597          	auipc	a1,0x9
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc0209040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	11e50513          	addi	a0,a0,286 # ffffffffc0204260 <etext+0x88>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00010597          	auipc	a1,0x10
ffffffffc0200152:	40658593          	addi	a1,a1,1030 # ffffffffc0210554 <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	12a50513          	addi	a0,a0,298 # ffffffffc0204280 <etext+0xa8>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00010597          	auipc	a1,0x10
ffffffffc0200166:	7f158593          	addi	a1,a1,2033 # ffffffffc0210953 <end+0x3ff>
ffffffffc020016a:	00000797          	auipc	a5,0x0
ffffffffc020016e:	ec878793          	addi	a5,a5,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200176:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200180:	95be                	add	a1,a1,a5
ffffffffc0200182:	85a9                	srai	a1,a1,0xa
ffffffffc0200184:	00004517          	auipc	a0,0x4
ffffffffc0200188:	11c50513          	addi	a0,a0,284 # ffffffffc02042a0 <etext+0xc8>
}
ffffffffc020018c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018e:	b735                	j	ffffffffc02000ba <cprintf>

ffffffffc0200190 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200190:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200192:	00004617          	auipc	a2,0x4
ffffffffc0200196:	13e60613          	addi	a2,a2,318 # ffffffffc02042d0 <etext+0xf8>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	14a50513          	addi	a0,a0,330 # ffffffffc02042e8 <etext+0x110>
void print_stackframe(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a8:	1cc000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001ac <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ac:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ae:	00004617          	auipc	a2,0x4
ffffffffc02001b2:	15260613          	addi	a2,a2,338 # ffffffffc0204300 <etext+0x128>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	16a58593          	addi	a1,a1,362 # ffffffffc0204320 <etext+0x148>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	16a50513          	addi	a0,a0,362 # ffffffffc0204328 <etext+0x150>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	16c60613          	addi	a2,a2,364 # ffffffffc0204338 <etext+0x160>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	18c58593          	addi	a1,a1,396 # ffffffffc0204360 <etext+0x188>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	14c50513          	addi	a0,a0,332 # ffffffffc0204328 <etext+0x150>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	18860613          	addi	a2,a2,392 # ffffffffc0204370 <etext+0x198>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	1a058593          	addi	a1,a1,416 # ffffffffc0204390 <etext+0x1b8>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	13050513          	addi	a0,a0,304 # ffffffffc0204328 <etext+0x150>
ffffffffc0200200:	ebbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200204:	60a2                	ld	ra,8(sp)
ffffffffc0200206:	4501                	li	a0,0
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200210:	ef3ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200220:	f71ff0ef          	jal	ra,ffffffffc0200190 <print_stackframe>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022c:	7115                	addi	sp,sp,-224
ffffffffc020022e:	ed5e                	sd	s7,152(sp)
ffffffffc0200230:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200232:	00004517          	auipc	a0,0x4
ffffffffc0200236:	16e50513          	addi	a0,a0,366 # ffffffffc02043a0 <etext+0x1c8>
kmonitor(struct trapframe *tf) {
ffffffffc020023a:	ed86                	sd	ra,216(sp)
ffffffffc020023c:	e9a2                	sd	s0,208(sp)
ffffffffc020023e:	e5a6                	sd	s1,200(sp)
ffffffffc0200240:	e1ca                	sd	s2,192(sp)
ffffffffc0200242:	fd4e                	sd	s3,184(sp)
ffffffffc0200244:	f952                	sd	s4,176(sp)
ffffffffc0200246:	f556                	sd	s5,168(sp)
ffffffffc0200248:	f15a                	sd	s6,160(sp)
ffffffffc020024a:	e962                	sd	s8,144(sp)
ffffffffc020024c:	e566                	sd	s9,136(sp)
ffffffffc020024e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200250:	e6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	17450513          	addi	a0,a0,372 # ffffffffc02043c8 <etext+0x1f0>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4c4000ef          	jal	ra,ffffffffc020072a <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	1c6c0c13          	addi	s8,s8,454 # ffffffffc0204430 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00005917          	auipc	s2,0x5
ffffffffc0200276:	5ce90913          	addi	s2,s2,1486 # ffffffffc0205840 <default_pmm_manager+0x928>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	17648493          	addi	s1,s1,374 # ffffffffc02043f0 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	174b0b13          	addi	s6,s6,372 # ffffffffc02043f8 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	094a0a13          	addi	s4,s4,148 # ffffffffc0204320 <etext+0x148>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	5e7030ef          	jal	ra,ffffffffc020407e <readline>
ffffffffc020029c:	842a                	mv	s0,a0
ffffffffc020029e:	dd65                	beqz	a0,ffffffffc0200296 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a6:	e1bd                	bnez	a1,ffffffffc020030c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002a8:	fe0c87e3          	beqz	s9,ffffffffc0200296 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ac:	6582                	ld	a1,0(sp)
ffffffffc02002ae:	00004d17          	auipc	s10,0x4
ffffffffc02002b2:	182d0d13          	addi	s10,s10,386 # ffffffffc0204430 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	6bf030ef          	jal	ra,ffffffffc020417a <strcmp>
ffffffffc02002c0:	c919                	beqz	a0,ffffffffc02002d6 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	0b540063          	beq	s0,s5,ffffffffc0200364 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c8:	000d3503          	ld	a0,0(s10)
ffffffffc02002cc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	6ab030ef          	jal	ra,ffffffffc020417a <strcmp>
ffffffffc02002d4:	f57d                	bnez	a0,ffffffffc02002c2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002d6:	00141793          	slli	a5,s0,0x1
ffffffffc02002da:	97a2                	add	a5,a5,s0
ffffffffc02002dc:	078e                	slli	a5,a5,0x3
ffffffffc02002de:	97e2                	add	a5,a5,s8
ffffffffc02002e0:	6b9c                	ld	a5,16(a5)
ffffffffc02002e2:	865e                	mv	a2,s7
ffffffffc02002e4:	002c                	addi	a1,sp,8
ffffffffc02002e6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ea:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002ec:	fa0555e3          	bgez	a0,ffffffffc0200296 <kmonitor+0x6a>
}
ffffffffc02002f0:	60ee                	ld	ra,216(sp)
ffffffffc02002f2:	644e                	ld	s0,208(sp)
ffffffffc02002f4:	64ae                	ld	s1,200(sp)
ffffffffc02002f6:	690e                	ld	s2,192(sp)
ffffffffc02002f8:	79ea                	ld	s3,184(sp)
ffffffffc02002fa:	7a4a                	ld	s4,176(sp)
ffffffffc02002fc:	7aaa                	ld	s5,168(sp)
ffffffffc02002fe:	7b0a                	ld	s6,160(sp)
ffffffffc0200300:	6bea                	ld	s7,152(sp)
ffffffffc0200302:	6c4a                	ld	s8,144(sp)
ffffffffc0200304:	6caa                	ld	s9,136(sp)
ffffffffc0200306:	6d0a                	ld	s10,128(sp)
ffffffffc0200308:	612d                	addi	sp,sp,224
ffffffffc020030a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	8526                	mv	a0,s1
ffffffffc020030e:	68b030ef          	jal	ra,ffffffffc0204198 <strchr>
ffffffffc0200312:	c901                	beqz	a0,ffffffffc0200322 <kmonitor+0xf6>
ffffffffc0200314:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200318:	00040023          	sb	zero,0(s0)
ffffffffc020031c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	d5c9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200320:	b7f5                	j	ffffffffc020030c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200322:	00044783          	lbu	a5,0(s0)
ffffffffc0200326:	d3c9                	beqz	a5,ffffffffc02002a8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200328:	033c8963          	beq	s9,s3,ffffffffc020035a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020032c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200330:	0118                	addi	a4,sp,128
ffffffffc0200332:	97ba                	add	a5,a5,a4
ffffffffc0200334:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200338:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033e:	e591                	bnez	a1,ffffffffc020034a <kmonitor+0x11e>
ffffffffc0200340:	b7b5                	j	ffffffffc02002ac <kmonitor+0x80>
ffffffffc0200342:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200346:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200348:	d1a5                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc020034a:	8526                	mv	a0,s1
ffffffffc020034c:	64d030ef          	jal	ra,ffffffffc0204198 <strchr>
ffffffffc0200350:	d96d                	beqz	a0,ffffffffc0200342 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	00044583          	lbu	a1,0(s0)
ffffffffc0200356:	d9a9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200358:	bf55                	j	ffffffffc020030c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200362:	b7e9                	j	ffffffffc020032c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	0b250513          	addi	a0,a0,178 # ffffffffc0204418 <etext+0x240>
ffffffffc020036e:	d4dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc0200372:	b715                	j	ffffffffc0200296 <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00010317          	auipc	t1,0x10
ffffffffc0200378:	17430313          	addi	t1,t1,372 # ffffffffc02104e8 <is_panic>
ffffffffc020037c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	020e1a63          	bnez	t3,ffffffffc02003c4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039a:	8432                	mv	s0,a2
ffffffffc020039c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039e:	862e                	mv	a2,a1
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	0d650513          	addi	a0,a0,214 # ffffffffc0204478 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	ce7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	fd850513          	addi	a0,a0,-40 # ffffffffc0205390 <default_pmm_manager+0x478>
ffffffffc02003c0:	cfbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	106000ef          	jal	ra,ffffffffc02004ca <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e63ff0ef          	jal	ra,ffffffffc020022c <kmonitor>
    while (1) {
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x54>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00010717          	auipc	a4,0x10
ffffffffc02003da:	12f73123          	sd	a5,290(a4) # ffffffffc02104f8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	0a250513          	addi	a0,a0,162 # ffffffffc0204498 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00010797          	auipc	a5,0x10
ffffffffc0200402:	0e07b923          	sd	zero,242(a5) # ffffffffc02104f0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b955                	j	ffffffffc02000ba <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00010797          	auipc	a5,0x10
ffffffffc0200410:	0ec7b783          	ld	a5,236(a5) # ffffffffc02104f8 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	zext.b	a0,a0
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	08a000ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a885                	j	ffffffffc02004c4 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	058000ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	03e000ef          	jal	ra,ffffffffc02004c4 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004a0:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004a4:	00009517          	auipc	a0,0x9
ffffffffc02004a8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0209040 <ide>
                   size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004b0:	953e                	add	a0,a0,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004b8:	509030ef          	jal	ra,ffffffffc02041c0 <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004c4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004c8:	8082                	ret

ffffffffc02004ca <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ca:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004ce:	8082                	ret

ffffffffc02004d0 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004d0:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004d4:	1141                	addi	sp,sp,-16
ffffffffc02004d6:	e022                	sd	s0,0(sp)
ffffffffc02004d8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004da:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004de:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e2:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004e4:	05500613          	li	a2,85
ffffffffc02004e8:	c399                	beqz	a5,ffffffffc02004ee <pgfault_handler+0x1e>
ffffffffc02004ea:	04b00613          	li	a2,75
ffffffffc02004ee:	11843703          	ld	a4,280(s0)
ffffffffc02004f2:	47bd                	li	a5,15
ffffffffc02004f4:	05700693          	li	a3,87
ffffffffc02004f8:	00f70463          	beq	a4,a5,ffffffffc0200500 <pgfault_handler+0x30>
ffffffffc02004fc:	05200693          	li	a3,82
ffffffffc0200500:	00004517          	auipc	a0,0x4
ffffffffc0200504:	fb850513          	addi	a0,a0,-72 # ffffffffc02044b8 <commands+0x88>
ffffffffc0200508:	bb3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020050c:	00010517          	auipc	a0,0x10
ffffffffc0200510:	03c53503          	ld	a0,60(a0) # ffffffffc0210548 <check_mm_struct>
ffffffffc0200514:	c911                	beqz	a0,ffffffffc0200528 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200516:	11043603          	ld	a2,272(s0)
ffffffffc020051a:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020051e:	6402                	ld	s0,0(sp)
ffffffffc0200520:	60a2                	ld	ra,8(sp)
ffffffffc0200522:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200524:	5f00306f          	j	ffffffffc0203b14 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200528:	00004617          	auipc	a2,0x4
ffffffffc020052c:	fb060613          	addi	a2,a2,-80 # ffffffffc02044d8 <commands+0xa8>
ffffffffc0200530:	07800593          	li	a1,120
ffffffffc0200534:	00004517          	auipc	a0,0x4
ffffffffc0200538:	fbc50513          	addi	a0,a0,-68 # ffffffffc02044f0 <commands+0xc0>
ffffffffc020053c:	e39ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200540 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200540:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200544:	00000797          	auipc	a5,0x0
ffffffffc0200548:	47c78793          	addi	a5,a5,1148 # ffffffffc02009c0 <__alltraps>
ffffffffc020054c:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200550:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200554:	000407b7          	lui	a5,0x40
ffffffffc0200558:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020055c:	8082                	ret

ffffffffc020055e <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020055e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200560:	1141                	addi	sp,sp,-16
ffffffffc0200562:	e022                	sd	s0,0(sp)
ffffffffc0200564:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	fa250513          	addi	a0,a0,-94 # ffffffffc0204508 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200570:	b4bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200574:	640c                	ld	a1,8(s0)
ffffffffc0200576:	00004517          	auipc	a0,0x4
ffffffffc020057a:	faa50513          	addi	a0,a0,-86 # ffffffffc0204520 <commands+0xf0>
ffffffffc020057e:	b3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200582:	680c                	ld	a1,16(s0)
ffffffffc0200584:	00004517          	auipc	a0,0x4
ffffffffc0200588:	fb450513          	addi	a0,a0,-76 # ffffffffc0204538 <commands+0x108>
ffffffffc020058c:	b2fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200590:	6c0c                	ld	a1,24(s0)
ffffffffc0200592:	00004517          	auipc	a0,0x4
ffffffffc0200596:	fbe50513          	addi	a0,a0,-66 # ffffffffc0204550 <commands+0x120>
ffffffffc020059a:	b21ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020059e:	700c                	ld	a1,32(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	fc850513          	addi	a0,a0,-56 # ffffffffc0204568 <commands+0x138>
ffffffffc02005a8:	b13ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005ac:	740c                	ld	a1,40(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	fd250513          	addi	a0,a0,-46 # ffffffffc0204580 <commands+0x150>
ffffffffc02005b6:	b05ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ba:	780c                	ld	a1,48(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0204598 <commands+0x168>
ffffffffc02005c4:	af7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005c8:	7c0c                	ld	a1,56(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	fe650513          	addi	a0,a0,-26 # ffffffffc02045b0 <commands+0x180>
ffffffffc02005d2:	ae9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005d6:	602c                	ld	a1,64(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	ff050513          	addi	a0,a0,-16 # ffffffffc02045c8 <commands+0x198>
ffffffffc02005e0:	adbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005e4:	642c                	ld	a1,72(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	ffa50513          	addi	a0,a0,-6 # ffffffffc02045e0 <commands+0x1b0>
ffffffffc02005ee:	acdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02005f2:	682c                	ld	a1,80(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	00450513          	addi	a0,a0,4 # ffffffffc02045f8 <commands+0x1c8>
ffffffffc02005fc:	abfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200600:	6c2c                	ld	a1,88(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	00e50513          	addi	a0,a0,14 # ffffffffc0204610 <commands+0x1e0>
ffffffffc020060a:	ab1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020060e:	702c                	ld	a1,96(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	01850513          	addi	a0,a0,24 # ffffffffc0204628 <commands+0x1f8>
ffffffffc0200618:	aa3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020061c:	742c                	ld	a1,104(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	02250513          	addi	a0,a0,34 # ffffffffc0204640 <commands+0x210>
ffffffffc0200626:	a95ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020062a:	782c                	ld	a1,112(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	02c50513          	addi	a0,a0,44 # ffffffffc0204658 <commands+0x228>
ffffffffc0200634:	a87ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200638:	7c2c                	ld	a1,120(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	03650513          	addi	a0,a0,54 # ffffffffc0204670 <commands+0x240>
ffffffffc0200642:	a79ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200646:	604c                	ld	a1,128(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	04050513          	addi	a0,a0,64 # ffffffffc0204688 <commands+0x258>
ffffffffc0200650:	a6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200654:	644c                	ld	a1,136(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	04a50513          	addi	a0,a0,74 # ffffffffc02046a0 <commands+0x270>
ffffffffc020065e:	a5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200662:	684c                	ld	a1,144(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	05450513          	addi	a0,a0,84 # ffffffffc02046b8 <commands+0x288>
ffffffffc020066c:	a4fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200670:	6c4c                	ld	a1,152(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	05e50513          	addi	a0,a0,94 # ffffffffc02046d0 <commands+0x2a0>
ffffffffc020067a:	a41ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020067e:	704c                	ld	a1,160(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	06850513          	addi	a0,a0,104 # ffffffffc02046e8 <commands+0x2b8>
ffffffffc0200688:	a33ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020068c:	744c                	ld	a1,168(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	07250513          	addi	a0,a0,114 # ffffffffc0204700 <commands+0x2d0>
ffffffffc0200696:	a25ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020069a:	784c                	ld	a1,176(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	07c50513          	addi	a0,a0,124 # ffffffffc0204718 <commands+0x2e8>
ffffffffc02006a4:	a17ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006a8:	7c4c                	ld	a1,184(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	08650513          	addi	a0,a0,134 # ffffffffc0204730 <commands+0x300>
ffffffffc02006b2:	a09ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006b6:	606c                	ld	a1,192(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	09050513          	addi	a0,a0,144 # ffffffffc0204748 <commands+0x318>
ffffffffc02006c0:	9fbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006c4:	646c                	ld	a1,200(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	09a50513          	addi	a0,a0,154 # ffffffffc0204760 <commands+0x330>
ffffffffc02006ce:	9edff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006d2:	686c                	ld	a1,208(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	0a450513          	addi	a0,a0,164 # ffffffffc0204778 <commands+0x348>
ffffffffc02006dc:	9dfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006e0:	6c6c                	ld	a1,216(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	0ae50513          	addi	a0,a0,174 # ffffffffc0204790 <commands+0x360>
ffffffffc02006ea:	9d1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02006ee:	706c                	ld	a1,224(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	0b850513          	addi	a0,a0,184 # ffffffffc02047a8 <commands+0x378>
ffffffffc02006f8:	9c3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02006fc:	746c                	ld	a1,232(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	0c250513          	addi	a0,a0,194 # ffffffffc02047c0 <commands+0x390>
ffffffffc0200706:	9b5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020070a:	786c                	ld	a1,240(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	0cc50513          	addi	a0,a0,204 # ffffffffc02047d8 <commands+0x3a8>
ffffffffc0200714:	9a7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200718:	7c6c                	ld	a1,248(s0)
}
ffffffffc020071a:	6402                	ld	s0,0(sp)
ffffffffc020071c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020071e:	00004517          	auipc	a0,0x4
ffffffffc0200722:	0d250513          	addi	a0,a0,210 # ffffffffc02047f0 <commands+0x3c0>
}
ffffffffc0200726:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200728:	ba49                	j	ffffffffc02000ba <cprintf>

ffffffffc020072a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020072a:	1141                	addi	sp,sp,-16
ffffffffc020072c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020072e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200730:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200732:	00004517          	auipc	a0,0x4
ffffffffc0200736:	0d650513          	addi	a0,a0,214 # ffffffffc0204808 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020073a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020073c:	97fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200740:	8522                	mv	a0,s0
ffffffffc0200742:	e1dff0ef          	jal	ra,ffffffffc020055e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200746:	10043583          	ld	a1,256(s0)
ffffffffc020074a:	00004517          	auipc	a0,0x4
ffffffffc020074e:	0d650513          	addi	a0,a0,214 # ffffffffc0204820 <commands+0x3f0>
ffffffffc0200752:	969ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200756:	10843583          	ld	a1,264(s0)
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	0de50513          	addi	a0,a0,222 # ffffffffc0204838 <commands+0x408>
ffffffffc0200762:	959ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200766:	11043583          	ld	a1,272(s0)
ffffffffc020076a:	00004517          	auipc	a0,0x4
ffffffffc020076e:	0e650513          	addi	a0,a0,230 # ffffffffc0204850 <commands+0x420>
ffffffffc0200772:	949ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200776:	11843583          	ld	a1,280(s0)
}
ffffffffc020077a:	6402                	ld	s0,0(sp)
ffffffffc020077c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	0ea50513          	addi	a0,a0,234 # ffffffffc0204868 <commands+0x438>
}
ffffffffc0200786:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200788:	933ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc020078c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020078c:	11853783          	ld	a5,280(a0)
ffffffffc0200790:	472d                	li	a4,11
ffffffffc0200792:	0786                	slli	a5,a5,0x1
ffffffffc0200794:	8385                	srli	a5,a5,0x1
ffffffffc0200796:	06f76c63          	bltu	a4,a5,ffffffffc020080e <interrupt_handler+0x82>
ffffffffc020079a:	00004717          	auipc	a4,0x4
ffffffffc020079e:	19670713          	addi	a4,a4,406 # ffffffffc0204930 <commands+0x500>
ffffffffc02007a2:	078a                	slli	a5,a5,0x2
ffffffffc02007a4:	97ba                	add	a5,a5,a4
ffffffffc02007a6:	439c                	lw	a5,0(a5)
ffffffffc02007a8:	97ba                	add	a5,a5,a4
ffffffffc02007aa:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007ac:	00004517          	auipc	a0,0x4
ffffffffc02007b0:	13450513          	addi	a0,a0,308 # ffffffffc02048e0 <commands+0x4b0>
ffffffffc02007b4:	907ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007b8:	00004517          	auipc	a0,0x4
ffffffffc02007bc:	10850513          	addi	a0,a0,264 # ffffffffc02048c0 <commands+0x490>
ffffffffc02007c0:	8fbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007c4:	00004517          	auipc	a0,0x4
ffffffffc02007c8:	0bc50513          	addi	a0,a0,188 # ffffffffc0204880 <commands+0x450>
ffffffffc02007cc:	8efff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	0d050513          	addi	a0,a0,208 # ffffffffc02048a0 <commands+0x470>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007dc:	1141                	addi	sp,sp,-16
ffffffffc02007de:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02007e0:	c29ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02007e4:	00010697          	auipc	a3,0x10
ffffffffc02007e8:	d0c68693          	addi	a3,a3,-756 # ffffffffc02104f0 <ticks>
ffffffffc02007ec:	629c                	ld	a5,0(a3)
ffffffffc02007ee:	06400713          	li	a4,100
ffffffffc02007f2:	0785                	addi	a5,a5,1
ffffffffc02007f4:	02e7f733          	remu	a4,a5,a4
ffffffffc02007f8:	e29c                	sd	a5,0(a3)
ffffffffc02007fa:	cb19                	beqz	a4,ffffffffc0200810 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02007fc:	60a2                	ld	ra,8(sp)
ffffffffc02007fe:	0141                	addi	sp,sp,16
ffffffffc0200800:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200802:	00004517          	auipc	a0,0x4
ffffffffc0200806:	10e50513          	addi	a0,a0,270 # ffffffffc0204910 <commands+0x4e0>
ffffffffc020080a:	8b1ff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc020080e:	bf31                	j	ffffffffc020072a <print_trapframe>
}
ffffffffc0200810:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200812:	06400593          	li	a1,100
ffffffffc0200816:	00004517          	auipc	a0,0x4
ffffffffc020081a:	0ea50513          	addi	a0,a0,234 # ffffffffc0204900 <commands+0x4d0>
}
ffffffffc020081e:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200820:	89bff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200824 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200824:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200828:	1101                	addi	sp,sp,-32
ffffffffc020082a:	e822                	sd	s0,16(sp)
ffffffffc020082c:	ec06                	sd	ra,24(sp)
ffffffffc020082e:	e426                	sd	s1,8(sp)
ffffffffc0200830:	473d                	li	a4,15
ffffffffc0200832:	842a                	mv	s0,a0
ffffffffc0200834:	14f76a63          	bltu	a4,a5,ffffffffc0200988 <exception_handler+0x164>
ffffffffc0200838:	00004717          	auipc	a4,0x4
ffffffffc020083c:	2e070713          	addi	a4,a4,736 # ffffffffc0204b18 <commands+0x6e8>
ffffffffc0200840:	078a                	slli	a5,a5,0x2
ffffffffc0200842:	97ba                	add	a5,a5,a4
ffffffffc0200844:	439c                	lw	a5,0(a5)
ffffffffc0200846:	97ba                	add	a5,a5,a4
ffffffffc0200848:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020084a:	00004517          	auipc	a0,0x4
ffffffffc020084e:	2b650513          	addi	a0,a0,694 # ffffffffc0204b00 <commands+0x6d0>
ffffffffc0200852:	869ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200856:	8522                	mv	a0,s0
ffffffffc0200858:	c79ff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc020085c:	84aa                	mv	s1,a0
ffffffffc020085e:	12051b63          	bnez	a0,ffffffffc0200994 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200862:	60e2                	ld	ra,24(sp)
ffffffffc0200864:	6442                	ld	s0,16(sp)
ffffffffc0200866:	64a2                	ld	s1,8(sp)
ffffffffc0200868:	6105                	addi	sp,sp,32
ffffffffc020086a:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020086c:	00004517          	auipc	a0,0x4
ffffffffc0200870:	0f450513          	addi	a0,a0,244 # ffffffffc0204960 <commands+0x530>
}
ffffffffc0200874:	6442                	ld	s0,16(sp)
ffffffffc0200876:	60e2                	ld	ra,24(sp)
ffffffffc0200878:	64a2                	ld	s1,8(sp)
ffffffffc020087a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc020087c:	83fff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc0200880:	00004517          	auipc	a0,0x4
ffffffffc0200884:	10050513          	addi	a0,a0,256 # ffffffffc0204980 <commands+0x550>
ffffffffc0200888:	b7f5                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020088a:	00004517          	auipc	a0,0x4
ffffffffc020088e:	11650513          	addi	a0,a0,278 # ffffffffc02049a0 <commands+0x570>
ffffffffc0200892:	b7cd                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200894:	00004517          	auipc	a0,0x4
ffffffffc0200898:	12450513          	addi	a0,a0,292 # ffffffffc02049b8 <commands+0x588>
ffffffffc020089c:	bfe1                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc020089e:	00004517          	auipc	a0,0x4
ffffffffc02008a2:	12a50513          	addi	a0,a0,298 # ffffffffc02049c8 <commands+0x598>
ffffffffc02008a6:	b7f9                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008a8:	00004517          	auipc	a0,0x4
ffffffffc02008ac:	14050513          	addi	a0,a0,320 # ffffffffc02049e8 <commands+0x5b8>
ffffffffc02008b0:	80bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008b4:	8522                	mv	a0,s0
ffffffffc02008b6:	c1bff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc02008ba:	84aa                	mv	s1,a0
ffffffffc02008bc:	d15d                	beqz	a0,ffffffffc0200862 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008be:	8522                	mv	a0,s0
ffffffffc02008c0:	e6bff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008c4:	86a6                	mv	a3,s1
ffffffffc02008c6:	00004617          	auipc	a2,0x4
ffffffffc02008ca:	13a60613          	addi	a2,a2,314 # ffffffffc0204a00 <commands+0x5d0>
ffffffffc02008ce:	0ca00593          	li	a1,202
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	c1e50513          	addi	a0,a0,-994 # ffffffffc02044f0 <commands+0xc0>
ffffffffc02008da:	a9bff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02008de:	00004517          	auipc	a0,0x4
ffffffffc02008e2:	14250513          	addi	a0,a0,322 # ffffffffc0204a20 <commands+0x5f0>
ffffffffc02008e6:	b779                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02008e8:	00004517          	auipc	a0,0x4
ffffffffc02008ec:	15050513          	addi	a0,a0,336 # ffffffffc0204a38 <commands+0x608>
ffffffffc02008f0:	fcaff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f4:	8522                	mv	a0,s0
ffffffffc02008f6:	bdbff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc02008fa:	84aa                	mv	s1,a0
ffffffffc02008fc:	d13d                	beqz	a0,ffffffffc0200862 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fe:	8522                	mv	a0,s0
ffffffffc0200900:	e2bff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200904:	86a6                	mv	a3,s1
ffffffffc0200906:	00004617          	auipc	a2,0x4
ffffffffc020090a:	0fa60613          	addi	a2,a2,250 # ffffffffc0204a00 <commands+0x5d0>
ffffffffc020090e:	0d400593          	li	a1,212
ffffffffc0200912:	00004517          	auipc	a0,0x4
ffffffffc0200916:	bde50513          	addi	a0,a0,-1058 # ffffffffc02044f0 <commands+0xc0>
ffffffffc020091a:	a5bff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020091e:	00004517          	auipc	a0,0x4
ffffffffc0200922:	13250513          	addi	a0,a0,306 # ffffffffc0204a50 <commands+0x620>
ffffffffc0200926:	b7b9                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200928:	00004517          	auipc	a0,0x4
ffffffffc020092c:	14850513          	addi	a0,a0,328 # ffffffffc0204a70 <commands+0x640>
ffffffffc0200930:	b791                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	15e50513          	addi	a0,a0,350 # ffffffffc0204a90 <commands+0x660>
ffffffffc020093a:	bf2d                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	17450513          	addi	a0,a0,372 # ffffffffc0204ab0 <commands+0x680>
ffffffffc0200944:	bf05                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	18a50513          	addi	a0,a0,394 # ffffffffc0204ad0 <commands+0x6a0>
ffffffffc020094e:	b71d                	j	ffffffffc0200874 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	19850513          	addi	a0,a0,408 # ffffffffc0204ae8 <commands+0x6b8>
ffffffffc0200958:	f62ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	b73ff0ef          	jal	ra,ffffffffc02004d0 <pgfault_handler>
ffffffffc0200962:	84aa                	mv	s1,a0
ffffffffc0200964:	ee050fe3          	beqz	a0,ffffffffc0200862 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200968:	8522                	mv	a0,s0
ffffffffc020096a:	dc1ff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020096e:	86a6                	mv	a3,s1
ffffffffc0200970:	00004617          	auipc	a2,0x4
ffffffffc0200974:	09060613          	addi	a2,a2,144 # ffffffffc0204a00 <commands+0x5d0>
ffffffffc0200978:	0ea00593          	li	a1,234
ffffffffc020097c:	00004517          	auipc	a0,0x4
ffffffffc0200980:	b7450513          	addi	a0,a0,-1164 # ffffffffc02044f0 <commands+0xc0>
ffffffffc0200984:	9f1ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            print_trapframe(tf);
ffffffffc0200988:	8522                	mv	a0,s0
}
ffffffffc020098a:	6442                	ld	s0,16(sp)
ffffffffc020098c:	60e2                	ld	ra,24(sp)
ffffffffc020098e:	64a2                	ld	s1,8(sp)
ffffffffc0200990:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200992:	bb61                	j	ffffffffc020072a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200994:	8522                	mv	a0,s0
ffffffffc0200996:	d95ff0ef          	jal	ra,ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020099a:	86a6                	mv	a3,s1
ffffffffc020099c:	00004617          	auipc	a2,0x4
ffffffffc02009a0:	06460613          	addi	a2,a2,100 # ffffffffc0204a00 <commands+0x5d0>
ffffffffc02009a4:	0f100593          	li	a1,241
ffffffffc02009a8:	00004517          	auipc	a0,0x4
ffffffffc02009ac:	b4850513          	addi	a0,a0,-1208 # ffffffffc02044f0 <commands+0xc0>
ffffffffc02009b0:	9c5ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02009b4 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009b4:	11853783          	ld	a5,280(a0)
ffffffffc02009b8:	0007c363          	bltz	a5,ffffffffc02009be <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009bc:	b5a5                	j	ffffffffc0200824 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009be:	b3f9                	j	ffffffffc020078c <interrupt_handler>

ffffffffc02009c0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009c0:	14011073          	csrw	sscratch,sp
ffffffffc02009c4:	712d                	addi	sp,sp,-288
ffffffffc02009c6:	e406                	sd	ra,8(sp)
ffffffffc02009c8:	ec0e                	sd	gp,24(sp)
ffffffffc02009ca:	f012                	sd	tp,32(sp)
ffffffffc02009cc:	f416                	sd	t0,40(sp)
ffffffffc02009ce:	f81a                	sd	t1,48(sp)
ffffffffc02009d0:	fc1e                	sd	t2,56(sp)
ffffffffc02009d2:	e0a2                	sd	s0,64(sp)
ffffffffc02009d4:	e4a6                	sd	s1,72(sp)
ffffffffc02009d6:	e8aa                	sd	a0,80(sp)
ffffffffc02009d8:	ecae                	sd	a1,88(sp)
ffffffffc02009da:	f0b2                	sd	a2,96(sp)
ffffffffc02009dc:	f4b6                	sd	a3,104(sp)
ffffffffc02009de:	f8ba                	sd	a4,112(sp)
ffffffffc02009e0:	fcbe                	sd	a5,120(sp)
ffffffffc02009e2:	e142                	sd	a6,128(sp)
ffffffffc02009e4:	e546                	sd	a7,136(sp)
ffffffffc02009e6:	e94a                	sd	s2,144(sp)
ffffffffc02009e8:	ed4e                	sd	s3,152(sp)
ffffffffc02009ea:	f152                	sd	s4,160(sp)
ffffffffc02009ec:	f556                	sd	s5,168(sp)
ffffffffc02009ee:	f95a                	sd	s6,176(sp)
ffffffffc02009f0:	fd5e                	sd	s7,184(sp)
ffffffffc02009f2:	e1e2                	sd	s8,192(sp)
ffffffffc02009f4:	e5e6                	sd	s9,200(sp)
ffffffffc02009f6:	e9ea                	sd	s10,208(sp)
ffffffffc02009f8:	edee                	sd	s11,216(sp)
ffffffffc02009fa:	f1f2                	sd	t3,224(sp)
ffffffffc02009fc:	f5f6                	sd	t4,232(sp)
ffffffffc02009fe:	f9fa                	sd	t5,240(sp)
ffffffffc0200a00:	fdfe                	sd	t6,248(sp)
ffffffffc0200a02:	14002473          	csrr	s0,sscratch
ffffffffc0200a06:	100024f3          	csrr	s1,sstatus
ffffffffc0200a0a:	14102973          	csrr	s2,sepc
ffffffffc0200a0e:	143029f3          	csrr	s3,stval
ffffffffc0200a12:	14202a73          	csrr	s4,scause
ffffffffc0200a16:	e822                	sd	s0,16(sp)
ffffffffc0200a18:	e226                	sd	s1,256(sp)
ffffffffc0200a1a:	e64a                	sd	s2,264(sp)
ffffffffc0200a1c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a1e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a20:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a22:	f93ff0ef          	jal	ra,ffffffffc02009b4 <trap>

ffffffffc0200a26 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a26:	6492                	ld	s1,256(sp)
ffffffffc0200a28:	6932                	ld	s2,264(sp)
ffffffffc0200a2a:	10049073          	csrw	sstatus,s1
ffffffffc0200a2e:	14191073          	csrw	sepc,s2
ffffffffc0200a32:	60a2                	ld	ra,8(sp)
ffffffffc0200a34:	61e2                	ld	gp,24(sp)
ffffffffc0200a36:	7202                	ld	tp,32(sp)
ffffffffc0200a38:	72a2                	ld	t0,40(sp)
ffffffffc0200a3a:	7342                	ld	t1,48(sp)
ffffffffc0200a3c:	73e2                	ld	t2,56(sp)
ffffffffc0200a3e:	6406                	ld	s0,64(sp)
ffffffffc0200a40:	64a6                	ld	s1,72(sp)
ffffffffc0200a42:	6546                	ld	a0,80(sp)
ffffffffc0200a44:	65e6                	ld	a1,88(sp)
ffffffffc0200a46:	7606                	ld	a2,96(sp)
ffffffffc0200a48:	76a6                	ld	a3,104(sp)
ffffffffc0200a4a:	7746                	ld	a4,112(sp)
ffffffffc0200a4c:	77e6                	ld	a5,120(sp)
ffffffffc0200a4e:	680a                	ld	a6,128(sp)
ffffffffc0200a50:	68aa                	ld	a7,136(sp)
ffffffffc0200a52:	694a                	ld	s2,144(sp)
ffffffffc0200a54:	69ea                	ld	s3,152(sp)
ffffffffc0200a56:	7a0a                	ld	s4,160(sp)
ffffffffc0200a58:	7aaa                	ld	s5,168(sp)
ffffffffc0200a5a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a5c:	7bea                	ld	s7,184(sp)
ffffffffc0200a5e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a60:	6cae                	ld	s9,200(sp)
ffffffffc0200a62:	6d4e                	ld	s10,208(sp)
ffffffffc0200a64:	6dee                	ld	s11,216(sp)
ffffffffc0200a66:	7e0e                	ld	t3,224(sp)
ffffffffc0200a68:	7eae                	ld	t4,232(sp)
ffffffffc0200a6a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a6c:	7fee                	ld	t6,248(sp)
ffffffffc0200a6e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200a70:	10200073          	sret
	...

ffffffffc0200a80 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a80:	0000f797          	auipc	a5,0xf
ffffffffc0200a84:	5c078793          	addi	a5,a5,1472 # ffffffffc0210040 <free_area>
ffffffffc0200a88:	e79c                	sd	a5,8(a5)
ffffffffc0200a8a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200a8c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200a90:	8082                	ret

ffffffffc0200a92 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200a92:	0000f517          	auipc	a0,0xf
ffffffffc0200a96:	5be56503          	lwu	a0,1470(a0) # ffffffffc0210050 <free_area+0x10>
ffffffffc0200a9a:	8082                	ret

ffffffffc0200a9c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200a9c:	715d                	addi	sp,sp,-80
ffffffffc0200a9e:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200aa0:	0000f417          	auipc	s0,0xf
ffffffffc0200aa4:	5a040413          	addi	s0,s0,1440 # ffffffffc0210040 <free_area>
ffffffffc0200aa8:	641c                	ld	a5,8(s0)
ffffffffc0200aaa:	e486                	sd	ra,72(sp)
ffffffffc0200aac:	fc26                	sd	s1,56(sp)
ffffffffc0200aae:	f84a                	sd	s2,48(sp)
ffffffffc0200ab0:	f44e                	sd	s3,40(sp)
ffffffffc0200ab2:	f052                	sd	s4,32(sp)
ffffffffc0200ab4:	ec56                	sd	s5,24(sp)
ffffffffc0200ab6:	e85a                	sd	s6,16(sp)
ffffffffc0200ab8:	e45e                	sd	s7,8(sp)
ffffffffc0200aba:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200abc:	2c878763          	beq	a5,s0,ffffffffc0200d8a <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200ac0:	4481                	li	s1,0
ffffffffc0200ac2:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ac4:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ac8:	8b09                	andi	a4,a4,2
ffffffffc0200aca:	2c070463          	beqz	a4,ffffffffc0200d92 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200ace:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ad2:	679c                	ld	a5,8(a5)
ffffffffc0200ad4:	2905                	addiw	s2,s2,1
ffffffffc0200ad6:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ad8:	fe8796e3          	bne	a5,s0,ffffffffc0200ac4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200adc:	89a6                	mv	s3,s1
ffffffffc0200ade:	385000ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
ffffffffc0200ae2:	71351863          	bne	a0,s3,ffffffffc02011f2 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ae6:	4505                	li	a0,1
ffffffffc0200ae8:	2a9000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200aec:	8a2a                	mv	s4,a0
ffffffffc0200aee:	44050263          	beqz	a0,ffffffffc0200f32 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200af2:	4505                	li	a0,1
ffffffffc0200af4:	29d000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200af8:	89aa                	mv	s3,a0
ffffffffc0200afa:	70050c63          	beqz	a0,ffffffffc0201212 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200afe:	4505                	li	a0,1
ffffffffc0200b00:	291000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200b04:	8aaa                	mv	s5,a0
ffffffffc0200b06:	4a050663          	beqz	a0,ffffffffc0200fb2 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b0a:	2b3a0463          	beq	s4,s3,ffffffffc0200db2 <default_check+0x316>
ffffffffc0200b0e:	2aaa0263          	beq	s4,a0,ffffffffc0200db2 <default_check+0x316>
ffffffffc0200b12:	2aa98063          	beq	s3,a0,ffffffffc0200db2 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b16:	000a2783          	lw	a5,0(s4)
ffffffffc0200b1a:	2a079c63          	bnez	a5,ffffffffc0200dd2 <default_check+0x336>
ffffffffc0200b1e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b22:	2a079863          	bnez	a5,ffffffffc0200dd2 <default_check+0x336>
ffffffffc0200b26:	411c                	lw	a5,0(a0)
ffffffffc0200b28:	2a079563          	bnez	a5,ffffffffc0200dd2 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b2c:	00010797          	auipc	a5,0x10
ffffffffc0200b30:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc0210518 <pages>
ffffffffc0200b34:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b38:	870d                	srai	a4,a4,0x3
ffffffffc0200b3a:	00005597          	auipc	a1,0x5
ffffffffc0200b3e:	4265b583          	ld	a1,1062(a1) # ffffffffc0205f60 <error_string+0x38>
ffffffffc0200b42:	02b70733          	mul	a4,a4,a1
ffffffffc0200b46:	00005617          	auipc	a2,0x5
ffffffffc0200b4a:	42263603          	ld	a2,1058(a2) # ffffffffc0205f68 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b4e:	00010697          	auipc	a3,0x10
ffffffffc0200b52:	9c26b683          	ld	a3,-1598(a3) # ffffffffc0210510 <npage>
ffffffffc0200b56:	06b2                	slli	a3,a3,0xc
ffffffffc0200b58:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b5a:	0732                	slli	a4,a4,0xc
ffffffffc0200b5c:	28d77b63          	bgeu	a4,a3,ffffffffc0200df2 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b60:	40f98733          	sub	a4,s3,a5
ffffffffc0200b64:	870d                	srai	a4,a4,0x3
ffffffffc0200b66:	02b70733          	mul	a4,a4,a1
ffffffffc0200b6a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b6c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b6e:	4cd77263          	bgeu	a4,a3,ffffffffc0201032 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b72:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b76:	878d                	srai	a5,a5,0x3
ffffffffc0200b78:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b7c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b7e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200b80:	30d7f963          	bgeu	a5,a3,ffffffffc0200e92 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200b84:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b86:	00043c03          	ld	s8,0(s0)
ffffffffc0200b8a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200b8e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200b92:	e400                	sd	s0,8(s0)
ffffffffc0200b94:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200b96:	0000f797          	auipc	a5,0xf
ffffffffc0200b9a:	4a07ad23          	sw	zero,1210(a5) # ffffffffc0210050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200b9e:	1f3000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200ba2:	2c051863          	bnez	a0,ffffffffc0200e72 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200ba6:	4585                	li	a1,1
ffffffffc0200ba8:	8552                	mv	a0,s4
ffffffffc0200baa:	279000ef          	jal	ra,ffffffffc0201622 <free_pages>
    free_page(p1);
ffffffffc0200bae:	4585                	li	a1,1
ffffffffc0200bb0:	854e                	mv	a0,s3
ffffffffc0200bb2:	271000ef          	jal	ra,ffffffffc0201622 <free_pages>
    free_page(p2);
ffffffffc0200bb6:	4585                	li	a1,1
ffffffffc0200bb8:	8556                	mv	a0,s5
ffffffffc0200bba:	269000ef          	jal	ra,ffffffffc0201622 <free_pages>
    assert(nr_free == 3);
ffffffffc0200bbe:	4818                	lw	a4,16(s0)
ffffffffc0200bc0:	478d                	li	a5,3
ffffffffc0200bc2:	28f71863          	bne	a4,a5,ffffffffc0200e52 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bc6:	4505                	li	a0,1
ffffffffc0200bc8:	1c9000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200bcc:	89aa                	mv	s3,a0
ffffffffc0200bce:	26050263          	beqz	a0,ffffffffc0200e32 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bd2:	4505                	li	a0,1
ffffffffc0200bd4:	1bd000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200bd8:	8aaa                	mv	s5,a0
ffffffffc0200bda:	3a050c63          	beqz	a0,ffffffffc0200f92 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bde:	4505                	li	a0,1
ffffffffc0200be0:	1b1000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200be4:	8a2a                	mv	s4,a0
ffffffffc0200be6:	38050663          	beqz	a0,ffffffffc0200f72 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200bea:	4505                	li	a0,1
ffffffffc0200bec:	1a5000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200bf0:	36051163          	bnez	a0,ffffffffc0200f52 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200bf4:	4585                	li	a1,1
ffffffffc0200bf6:	854e                	mv	a0,s3
ffffffffc0200bf8:	22b000ef          	jal	ra,ffffffffc0201622 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200bfc:	641c                	ld	a5,8(s0)
ffffffffc0200bfe:	20878a63          	beq	a5,s0,ffffffffc0200e12 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c02:	4505                	li	a0,1
ffffffffc0200c04:	18d000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200c08:	30a99563          	bne	s3,a0,ffffffffc0200f12 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c0c:	4505                	li	a0,1
ffffffffc0200c0e:	183000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200c12:	2e051063          	bnez	a0,ffffffffc0200ef2 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c16:	481c                	lw	a5,16(s0)
ffffffffc0200c18:	2a079d63          	bnez	a5,ffffffffc0200ed2 <default_check+0x436>
    free_page(p);
ffffffffc0200c1c:	854e                	mv	a0,s3
ffffffffc0200c1e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c20:	01843023          	sd	s8,0(s0)
ffffffffc0200c24:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c28:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c2c:	1f7000ef          	jal	ra,ffffffffc0201622 <free_pages>
    free_page(p1);
ffffffffc0200c30:	4585                	li	a1,1
ffffffffc0200c32:	8556                	mv	a0,s5
ffffffffc0200c34:	1ef000ef          	jal	ra,ffffffffc0201622 <free_pages>
    free_page(p2);
ffffffffc0200c38:	4585                	li	a1,1
ffffffffc0200c3a:	8552                	mv	a0,s4
ffffffffc0200c3c:	1e7000ef          	jal	ra,ffffffffc0201622 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c40:	4515                	li	a0,5
ffffffffc0200c42:	14f000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200c46:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c48:	26050563          	beqz	a0,ffffffffc0200eb2 <default_check+0x416>
ffffffffc0200c4c:	651c                	ld	a5,8(a0)
ffffffffc0200c4e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c50:	8b85                	andi	a5,a5,1
ffffffffc0200c52:	54079063          	bnez	a5,ffffffffc0201192 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c56:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c58:	00043b03          	ld	s6,0(s0)
ffffffffc0200c5c:	00843a83          	ld	s5,8(s0)
ffffffffc0200c60:	e000                	sd	s0,0(s0)
ffffffffc0200c62:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c64:	12d000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200c68:	50051563          	bnez	a0,ffffffffc0201172 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200c6c:	09098a13          	addi	s4,s3,144
ffffffffc0200c70:	8552                	mv	a0,s4
ffffffffc0200c72:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200c74:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200c78:	0000f797          	auipc	a5,0xf
ffffffffc0200c7c:	3c07ac23          	sw	zero,984(a5) # ffffffffc0210050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200c80:	1a3000ef          	jal	ra,ffffffffc0201622 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200c84:	4511                	li	a0,4
ffffffffc0200c86:	10b000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200c8a:	4c051463          	bnez	a0,ffffffffc0201152 <default_check+0x6b6>
ffffffffc0200c8e:	0989b783          	ld	a5,152(s3)
ffffffffc0200c92:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200c94:	8b85                	andi	a5,a5,1
ffffffffc0200c96:	48078e63          	beqz	a5,ffffffffc0201132 <default_check+0x696>
ffffffffc0200c9a:	0a89a703          	lw	a4,168(s3)
ffffffffc0200c9e:	478d                	li	a5,3
ffffffffc0200ca0:	48f71963          	bne	a4,a5,ffffffffc0201132 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200ca4:	450d                	li	a0,3
ffffffffc0200ca6:	0eb000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200caa:	8c2a                	mv	s8,a0
ffffffffc0200cac:	46050363          	beqz	a0,ffffffffc0201112 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200cb0:	4505                	li	a0,1
ffffffffc0200cb2:	0df000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200cb6:	42051e63          	bnez	a0,ffffffffc02010f2 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200cba:	418a1c63          	bne	s4,s8,ffffffffc02010d2 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200cbe:	4585                	li	a1,1
ffffffffc0200cc0:	854e                	mv	a0,s3
ffffffffc0200cc2:	161000ef          	jal	ra,ffffffffc0201622 <free_pages>
    free_pages(p1, 3);
ffffffffc0200cc6:	458d                	li	a1,3
ffffffffc0200cc8:	8552                	mv	a0,s4
ffffffffc0200cca:	159000ef          	jal	ra,ffffffffc0201622 <free_pages>
ffffffffc0200cce:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200cd2:	04898c13          	addi	s8,s3,72
ffffffffc0200cd6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200cd8:	8b85                	andi	a5,a5,1
ffffffffc0200cda:	3c078c63          	beqz	a5,ffffffffc02010b2 <default_check+0x616>
ffffffffc0200cde:	0189a703          	lw	a4,24(s3)
ffffffffc0200ce2:	4785                	li	a5,1
ffffffffc0200ce4:	3cf71763          	bne	a4,a5,ffffffffc02010b2 <default_check+0x616>
ffffffffc0200ce8:	008a3783          	ld	a5,8(s4)
ffffffffc0200cec:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200cee:	8b85                	andi	a5,a5,1
ffffffffc0200cf0:	3a078163          	beqz	a5,ffffffffc0201092 <default_check+0x5f6>
ffffffffc0200cf4:	018a2703          	lw	a4,24(s4)
ffffffffc0200cf8:	478d                	li	a5,3
ffffffffc0200cfa:	38f71c63          	bne	a4,a5,ffffffffc0201092 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200cfe:	4505                	li	a0,1
ffffffffc0200d00:	091000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200d04:	36a99763          	bne	s3,a0,ffffffffc0201072 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d08:	4585                	li	a1,1
ffffffffc0200d0a:	119000ef          	jal	ra,ffffffffc0201622 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d0e:	4509                	li	a0,2
ffffffffc0200d10:	081000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200d14:	32aa1f63          	bne	s4,a0,ffffffffc0201052 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d18:	4589                	li	a1,2
ffffffffc0200d1a:	109000ef          	jal	ra,ffffffffc0201622 <free_pages>
    free_page(p2);
ffffffffc0200d1e:	4585                	li	a1,1
ffffffffc0200d20:	8562                	mv	a0,s8
ffffffffc0200d22:	101000ef          	jal	ra,ffffffffc0201622 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d26:	4515                	li	a0,5
ffffffffc0200d28:	069000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200d2c:	89aa                	mv	s3,a0
ffffffffc0200d2e:	48050263          	beqz	a0,ffffffffc02011b2 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d32:	4505                	li	a0,1
ffffffffc0200d34:	05d000ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0200d38:	2c051d63          	bnez	a0,ffffffffc0201012 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d3c:	481c                	lw	a5,16(s0)
ffffffffc0200d3e:	2a079a63          	bnez	a5,ffffffffc0200ff2 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d42:	4595                	li	a1,5
ffffffffc0200d44:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d46:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d4a:	01643023          	sd	s6,0(s0)
ffffffffc0200d4e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200d52:	0d1000ef          	jal	ra,ffffffffc0201622 <free_pages>
    return listelm->next;
ffffffffc0200d56:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d58:	00878963          	beq	a5,s0,ffffffffc0200d6a <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d5c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d60:	679c                	ld	a5,8(a5)
ffffffffc0200d62:	397d                	addiw	s2,s2,-1
ffffffffc0200d64:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d66:	fe879be3          	bne	a5,s0,ffffffffc0200d5c <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200d6a:	26091463          	bnez	s2,ffffffffc0200fd2 <default_check+0x536>
    assert(total == 0);
ffffffffc0200d6e:	46049263          	bnez	s1,ffffffffc02011d2 <default_check+0x736>
}
ffffffffc0200d72:	60a6                	ld	ra,72(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	74e2                	ld	s1,56(sp)
ffffffffc0200d78:	7942                	ld	s2,48(sp)
ffffffffc0200d7a:	79a2                	ld	s3,40(sp)
ffffffffc0200d7c:	7a02                	ld	s4,32(sp)
ffffffffc0200d7e:	6ae2                	ld	s5,24(sp)
ffffffffc0200d80:	6b42                	ld	s6,16(sp)
ffffffffc0200d82:	6ba2                	ld	s7,8(sp)
ffffffffc0200d84:	6c02                	ld	s8,0(sp)
ffffffffc0200d86:	6161                	addi	sp,sp,80
ffffffffc0200d88:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d8a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200d8c:	4481                	li	s1,0
ffffffffc0200d8e:	4901                	li	s2,0
ffffffffc0200d90:	b3b9                	j	ffffffffc0200ade <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200d92:	00004697          	auipc	a3,0x4
ffffffffc0200d96:	dc668693          	addi	a3,a3,-570 # ffffffffc0204b58 <commands+0x728>
ffffffffc0200d9a:	00004617          	auipc	a2,0x4
ffffffffc0200d9e:	dce60613          	addi	a2,a2,-562 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200da2:	0f000593          	li	a1,240
ffffffffc0200da6:	00004517          	auipc	a0,0x4
ffffffffc0200daa:	dda50513          	addi	a0,a0,-550 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200dae:	dc6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200db2:	00004697          	auipc	a3,0x4
ffffffffc0200db6:	e6668693          	addi	a3,a3,-410 # ffffffffc0204c18 <commands+0x7e8>
ffffffffc0200dba:	00004617          	auipc	a2,0x4
ffffffffc0200dbe:	dae60613          	addi	a2,a2,-594 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200dc2:	0bd00593          	li	a1,189
ffffffffc0200dc6:	00004517          	auipc	a0,0x4
ffffffffc0200dca:	dba50513          	addi	a0,a0,-582 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200dce:	da6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200dd2:	00004697          	auipc	a3,0x4
ffffffffc0200dd6:	e6e68693          	addi	a3,a3,-402 # ffffffffc0204c40 <commands+0x810>
ffffffffc0200dda:	00004617          	auipc	a2,0x4
ffffffffc0200dde:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200de2:	0be00593          	li	a1,190
ffffffffc0200de6:	00004517          	auipc	a0,0x4
ffffffffc0200dea:	d9a50513          	addi	a0,a0,-614 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200dee:	d86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200df2:	00004697          	auipc	a3,0x4
ffffffffc0200df6:	e8e68693          	addi	a3,a3,-370 # ffffffffc0204c80 <commands+0x850>
ffffffffc0200dfa:	00004617          	auipc	a2,0x4
ffffffffc0200dfe:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200e02:	0c000593          	li	a1,192
ffffffffc0200e06:	00004517          	auipc	a0,0x4
ffffffffc0200e0a:	d7a50513          	addi	a0,a0,-646 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200e0e:	d66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e12:	00004697          	auipc	a3,0x4
ffffffffc0200e16:	ef668693          	addi	a3,a3,-266 # ffffffffc0204d08 <commands+0x8d8>
ffffffffc0200e1a:	00004617          	auipc	a2,0x4
ffffffffc0200e1e:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200e22:	0d900593          	li	a1,217
ffffffffc0200e26:	00004517          	auipc	a0,0x4
ffffffffc0200e2a:	d5a50513          	addi	a0,a0,-678 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200e2e:	d46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	d8668693          	addi	a3,a3,-634 # ffffffffc0204bb8 <commands+0x788>
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200e42:	0d200593          	li	a1,210
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200e4e:	d26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200e52:	00004697          	auipc	a3,0x4
ffffffffc0200e56:	ea668693          	addi	a3,a3,-346 # ffffffffc0204cf8 <commands+0x8c8>
ffffffffc0200e5a:	00004617          	auipc	a2,0x4
ffffffffc0200e5e:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200e62:	0d000593          	li	a1,208
ffffffffc0200e66:	00004517          	auipc	a0,0x4
ffffffffc0200e6a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200e6e:	d06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e72:	00004697          	auipc	a3,0x4
ffffffffc0200e76:	e6e68693          	addi	a3,a3,-402 # ffffffffc0204ce0 <commands+0x8b0>
ffffffffc0200e7a:	00004617          	auipc	a2,0x4
ffffffffc0200e7e:	cee60613          	addi	a2,a2,-786 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200e82:	0cb00593          	li	a1,203
ffffffffc0200e86:	00004517          	auipc	a0,0x4
ffffffffc0200e8a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200e8e:	ce6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e92:	00004697          	auipc	a3,0x4
ffffffffc0200e96:	e2e68693          	addi	a3,a3,-466 # ffffffffc0204cc0 <commands+0x890>
ffffffffc0200e9a:	00004617          	auipc	a2,0x4
ffffffffc0200e9e:	cce60613          	addi	a2,a2,-818 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200ea2:	0c200593          	li	a1,194
ffffffffc0200ea6:	00004517          	auipc	a0,0x4
ffffffffc0200eaa:	cda50513          	addi	a0,a0,-806 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200eae:	cc6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200eb2:	00004697          	auipc	a3,0x4
ffffffffc0200eb6:	e9e68693          	addi	a3,a3,-354 # ffffffffc0204d50 <commands+0x920>
ffffffffc0200eba:	00004617          	auipc	a2,0x4
ffffffffc0200ebe:	cae60613          	addi	a2,a2,-850 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200ec2:	0f800593          	li	a1,248
ffffffffc0200ec6:	00004517          	auipc	a0,0x4
ffffffffc0200eca:	cba50513          	addi	a0,a0,-838 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200ece:	ca6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200ed2:	00004697          	auipc	a3,0x4
ffffffffc0200ed6:	e6e68693          	addi	a3,a3,-402 # ffffffffc0204d40 <commands+0x910>
ffffffffc0200eda:	00004617          	auipc	a2,0x4
ffffffffc0200ede:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200ee2:	0df00593          	li	a1,223
ffffffffc0200ee6:	00004517          	auipc	a0,0x4
ffffffffc0200eea:	c9a50513          	addi	a0,a0,-870 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200eee:	c86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ef2:	00004697          	auipc	a3,0x4
ffffffffc0200ef6:	dee68693          	addi	a3,a3,-530 # ffffffffc0204ce0 <commands+0x8b0>
ffffffffc0200efa:	00004617          	auipc	a2,0x4
ffffffffc0200efe:	c6e60613          	addi	a2,a2,-914 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200f02:	0dd00593          	li	a1,221
ffffffffc0200f06:	00004517          	auipc	a0,0x4
ffffffffc0200f0a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200f0e:	c66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f12:	00004697          	auipc	a3,0x4
ffffffffc0200f16:	e0e68693          	addi	a3,a3,-498 # ffffffffc0204d20 <commands+0x8f0>
ffffffffc0200f1a:	00004617          	auipc	a2,0x4
ffffffffc0200f1e:	c4e60613          	addi	a2,a2,-946 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200f22:	0dc00593          	li	a1,220
ffffffffc0200f26:	00004517          	auipc	a0,0x4
ffffffffc0200f2a:	c5a50513          	addi	a0,a0,-934 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200f2e:	c46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f32:	00004697          	auipc	a3,0x4
ffffffffc0200f36:	c8668693          	addi	a3,a3,-890 # ffffffffc0204bb8 <commands+0x788>
ffffffffc0200f3a:	00004617          	auipc	a2,0x4
ffffffffc0200f3e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200f42:	0b900593          	li	a1,185
ffffffffc0200f46:	00004517          	auipc	a0,0x4
ffffffffc0200f4a:	c3a50513          	addi	a0,a0,-966 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200f4e:	c26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f52:	00004697          	auipc	a3,0x4
ffffffffc0200f56:	d8e68693          	addi	a3,a3,-626 # ffffffffc0204ce0 <commands+0x8b0>
ffffffffc0200f5a:	00004617          	auipc	a2,0x4
ffffffffc0200f5e:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200f62:	0d600593          	li	a1,214
ffffffffc0200f66:	00004517          	auipc	a0,0x4
ffffffffc0200f6a:	c1a50513          	addi	a0,a0,-998 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200f6e:	c06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f72:	00004697          	auipc	a3,0x4
ffffffffc0200f76:	c8668693          	addi	a3,a3,-890 # ffffffffc0204bf8 <commands+0x7c8>
ffffffffc0200f7a:	00004617          	auipc	a2,0x4
ffffffffc0200f7e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200f82:	0d400593          	li	a1,212
ffffffffc0200f86:	00004517          	auipc	a0,0x4
ffffffffc0200f8a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200f8e:	be6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f92:	00004697          	auipc	a3,0x4
ffffffffc0200f96:	c4668693          	addi	a3,a3,-954 # ffffffffc0204bd8 <commands+0x7a8>
ffffffffc0200f9a:	00004617          	auipc	a2,0x4
ffffffffc0200f9e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200fa2:	0d300593          	li	a1,211
ffffffffc0200fa6:	00004517          	auipc	a0,0x4
ffffffffc0200faa:	bda50513          	addi	a0,a0,-1062 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200fae:	bc6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fb2:	00004697          	auipc	a3,0x4
ffffffffc0200fb6:	c4668693          	addi	a3,a3,-954 # ffffffffc0204bf8 <commands+0x7c8>
ffffffffc0200fba:	00004617          	auipc	a2,0x4
ffffffffc0200fbe:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200fc2:	0bb00593          	li	a1,187
ffffffffc0200fc6:	00004517          	auipc	a0,0x4
ffffffffc0200fca:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200fce:	ba6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0200fd2:	00004697          	auipc	a3,0x4
ffffffffc0200fd6:	ece68693          	addi	a3,a3,-306 # ffffffffc0204ea0 <commands+0xa70>
ffffffffc0200fda:	00004617          	auipc	a2,0x4
ffffffffc0200fde:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0204b68 <commands+0x738>
ffffffffc0200fe2:	12500593          	li	a1,293
ffffffffc0200fe6:	00004517          	auipc	a0,0x4
ffffffffc0200fea:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0204b80 <commands+0x750>
ffffffffc0200fee:	b86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200ff2:	00004697          	auipc	a3,0x4
ffffffffc0200ff6:	d4e68693          	addi	a3,a3,-690 # ffffffffc0204d40 <commands+0x910>
ffffffffc0200ffa:	00004617          	auipc	a2,0x4
ffffffffc0200ffe:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201002:	11a00593          	li	a1,282
ffffffffc0201006:	00004517          	auipc	a0,0x4
ffffffffc020100a:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0204b80 <commands+0x750>
ffffffffc020100e:	b66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201012:	00004697          	auipc	a3,0x4
ffffffffc0201016:	cce68693          	addi	a3,a3,-818 # ffffffffc0204ce0 <commands+0x8b0>
ffffffffc020101a:	00004617          	auipc	a2,0x4
ffffffffc020101e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201022:	11800593          	li	a1,280
ffffffffc0201026:	00004517          	auipc	a0,0x4
ffffffffc020102a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0204b80 <commands+0x750>
ffffffffc020102e:	b46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201032:	00004697          	auipc	a3,0x4
ffffffffc0201036:	c6e68693          	addi	a3,a3,-914 # ffffffffc0204ca0 <commands+0x870>
ffffffffc020103a:	00004617          	auipc	a2,0x4
ffffffffc020103e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201042:	0c100593          	li	a1,193
ffffffffc0201046:	00004517          	auipc	a0,0x4
ffffffffc020104a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0204b80 <commands+0x750>
ffffffffc020104e:	b26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201052:	00004697          	auipc	a3,0x4
ffffffffc0201056:	e0e68693          	addi	a3,a3,-498 # ffffffffc0204e60 <commands+0xa30>
ffffffffc020105a:	00004617          	auipc	a2,0x4
ffffffffc020105e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201062:	11200593          	li	a1,274
ffffffffc0201066:	00004517          	auipc	a0,0x4
ffffffffc020106a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0204b80 <commands+0x750>
ffffffffc020106e:	b06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201072:	00004697          	auipc	a3,0x4
ffffffffc0201076:	dce68693          	addi	a3,a3,-562 # ffffffffc0204e40 <commands+0xa10>
ffffffffc020107a:	00004617          	auipc	a2,0x4
ffffffffc020107e:	aee60613          	addi	a2,a2,-1298 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201082:	11000593          	li	a1,272
ffffffffc0201086:	00004517          	auipc	a0,0x4
ffffffffc020108a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0204b80 <commands+0x750>
ffffffffc020108e:	ae6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201092:	00004697          	auipc	a3,0x4
ffffffffc0201096:	d8668693          	addi	a3,a3,-634 # ffffffffc0204e18 <commands+0x9e8>
ffffffffc020109a:	00004617          	auipc	a2,0x4
ffffffffc020109e:	ace60613          	addi	a2,a2,-1330 # ffffffffc0204b68 <commands+0x738>
ffffffffc02010a2:	10e00593          	li	a1,270
ffffffffc02010a6:	00004517          	auipc	a0,0x4
ffffffffc02010aa:	ada50513          	addi	a0,a0,-1318 # ffffffffc0204b80 <commands+0x750>
ffffffffc02010ae:	ac6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010b2:	00004697          	auipc	a3,0x4
ffffffffc02010b6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0204df0 <commands+0x9c0>
ffffffffc02010ba:	00004617          	auipc	a2,0x4
ffffffffc02010be:	aae60613          	addi	a2,a2,-1362 # ffffffffc0204b68 <commands+0x738>
ffffffffc02010c2:	10d00593          	li	a1,269
ffffffffc02010c6:	00004517          	auipc	a0,0x4
ffffffffc02010ca:	aba50513          	addi	a0,a0,-1350 # ffffffffc0204b80 <commands+0x750>
ffffffffc02010ce:	aa6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02010d2:	00004697          	auipc	a3,0x4
ffffffffc02010d6:	d0e68693          	addi	a3,a3,-754 # ffffffffc0204de0 <commands+0x9b0>
ffffffffc02010da:	00004617          	auipc	a2,0x4
ffffffffc02010de:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0204b68 <commands+0x738>
ffffffffc02010e2:	10800593          	li	a1,264
ffffffffc02010e6:	00004517          	auipc	a0,0x4
ffffffffc02010ea:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0204b80 <commands+0x750>
ffffffffc02010ee:	a86ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010f2:	00004697          	auipc	a3,0x4
ffffffffc02010f6:	bee68693          	addi	a3,a3,-1042 # ffffffffc0204ce0 <commands+0x8b0>
ffffffffc02010fa:	00004617          	auipc	a2,0x4
ffffffffc02010fe:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201102:	10700593          	li	a1,263
ffffffffc0201106:	00004517          	auipc	a0,0x4
ffffffffc020110a:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0204b80 <commands+0x750>
ffffffffc020110e:	a66ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201112:	00004697          	auipc	a3,0x4
ffffffffc0201116:	cae68693          	addi	a3,a3,-850 # ffffffffc0204dc0 <commands+0x990>
ffffffffc020111a:	00004617          	auipc	a2,0x4
ffffffffc020111e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201122:	10600593          	li	a1,262
ffffffffc0201126:	00004517          	auipc	a0,0x4
ffffffffc020112a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0204b80 <commands+0x750>
ffffffffc020112e:	a46ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201132:	00004697          	auipc	a3,0x4
ffffffffc0201136:	c5e68693          	addi	a3,a3,-930 # ffffffffc0204d90 <commands+0x960>
ffffffffc020113a:	00004617          	auipc	a2,0x4
ffffffffc020113e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201142:	10500593          	li	a1,261
ffffffffc0201146:	00004517          	auipc	a0,0x4
ffffffffc020114a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0204b80 <commands+0x750>
ffffffffc020114e:	a26ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201152:	00004697          	auipc	a3,0x4
ffffffffc0201156:	c2668693          	addi	a3,a3,-986 # ffffffffc0204d78 <commands+0x948>
ffffffffc020115a:	00004617          	auipc	a2,0x4
ffffffffc020115e:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201162:	10400593          	li	a1,260
ffffffffc0201166:	00004517          	auipc	a0,0x4
ffffffffc020116a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0204b80 <commands+0x750>
ffffffffc020116e:	a06ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201172:	00004697          	auipc	a3,0x4
ffffffffc0201176:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0204ce0 <commands+0x8b0>
ffffffffc020117a:	00004617          	auipc	a2,0x4
ffffffffc020117e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201182:	0fe00593          	li	a1,254
ffffffffc0201186:	00004517          	auipc	a0,0x4
ffffffffc020118a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0204b80 <commands+0x750>
ffffffffc020118e:	9e6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201192:	00004697          	auipc	a3,0x4
ffffffffc0201196:	bce68693          	addi	a3,a3,-1074 # ffffffffc0204d60 <commands+0x930>
ffffffffc020119a:	00004617          	auipc	a2,0x4
ffffffffc020119e:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204b68 <commands+0x738>
ffffffffc02011a2:	0f900593          	li	a1,249
ffffffffc02011a6:	00004517          	auipc	a0,0x4
ffffffffc02011aa:	9da50513          	addi	a0,a0,-1574 # ffffffffc0204b80 <commands+0x750>
ffffffffc02011ae:	9c6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011b2:	00004697          	auipc	a3,0x4
ffffffffc02011b6:	cce68693          	addi	a3,a3,-818 # ffffffffc0204e80 <commands+0xa50>
ffffffffc02011ba:	00004617          	auipc	a2,0x4
ffffffffc02011be:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204b68 <commands+0x738>
ffffffffc02011c2:	11700593          	li	a1,279
ffffffffc02011c6:	00004517          	auipc	a0,0x4
ffffffffc02011ca:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0204b80 <commands+0x750>
ffffffffc02011ce:	9a6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc02011d2:	00004697          	auipc	a3,0x4
ffffffffc02011d6:	cde68693          	addi	a3,a3,-802 # ffffffffc0204eb0 <commands+0xa80>
ffffffffc02011da:	00004617          	auipc	a2,0x4
ffffffffc02011de:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204b68 <commands+0x738>
ffffffffc02011e2:	12600593          	li	a1,294
ffffffffc02011e6:	00004517          	auipc	a0,0x4
ffffffffc02011ea:	99a50513          	addi	a0,a0,-1638 # ffffffffc0204b80 <commands+0x750>
ffffffffc02011ee:	986ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc02011f2:	00004697          	auipc	a3,0x4
ffffffffc02011f6:	9a668693          	addi	a3,a3,-1626 # ffffffffc0204b98 <commands+0x768>
ffffffffc02011fa:	00004617          	auipc	a2,0x4
ffffffffc02011fe:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201202:	0f300593          	li	a1,243
ffffffffc0201206:	00004517          	auipc	a0,0x4
ffffffffc020120a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0204b80 <commands+0x750>
ffffffffc020120e:	966ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201212:	00004697          	auipc	a3,0x4
ffffffffc0201216:	9c668693          	addi	a3,a3,-1594 # ffffffffc0204bd8 <commands+0x7a8>
ffffffffc020121a:	00004617          	auipc	a2,0x4
ffffffffc020121e:	94e60613          	addi	a2,a2,-1714 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201222:	0ba00593          	li	a1,186
ffffffffc0201226:	00004517          	auipc	a0,0x4
ffffffffc020122a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0204b80 <commands+0x750>
ffffffffc020122e:	946ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201232 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201232:	1141                	addi	sp,sp,-16
ffffffffc0201234:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201236:	14058a63          	beqz	a1,ffffffffc020138a <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020123a:	00359693          	slli	a3,a1,0x3
ffffffffc020123e:	96ae                	add	a3,a3,a1
ffffffffc0201240:	068e                	slli	a3,a3,0x3
ffffffffc0201242:	96aa                	add	a3,a3,a0
ffffffffc0201244:	87aa                	mv	a5,a0
ffffffffc0201246:	02d50263          	beq	a0,a3,ffffffffc020126a <default_free_pages+0x38>
ffffffffc020124a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020124c:	8b05                	andi	a4,a4,1
ffffffffc020124e:	10071e63          	bnez	a4,ffffffffc020136a <default_free_pages+0x138>
ffffffffc0201252:	6798                	ld	a4,8(a5)
ffffffffc0201254:	8b09                	andi	a4,a4,2
ffffffffc0201256:	10071a63          	bnez	a4,ffffffffc020136a <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020125a:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020125e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201262:	04878793          	addi	a5,a5,72
ffffffffc0201266:	fed792e3          	bne	a5,a3,ffffffffc020124a <default_free_pages+0x18>
    base->property = n;
ffffffffc020126a:	2581                	sext.w	a1,a1
ffffffffc020126c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020126e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201272:	4789                	li	a5,2
ffffffffc0201274:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201278:	0000f697          	auipc	a3,0xf
ffffffffc020127c:	dc868693          	addi	a3,a3,-568 # ffffffffc0210040 <free_area>
ffffffffc0201280:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201282:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201284:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201288:	9db9                	addw	a1,a1,a4
ffffffffc020128a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020128c:	0ad78863          	beq	a5,a3,ffffffffc020133c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201290:	fe078713          	addi	a4,a5,-32
ffffffffc0201294:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201298:	4581                	li	a1,0
            if (base < page) {
ffffffffc020129a:	00e56a63          	bltu	a0,a4,ffffffffc02012ae <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020129e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012a0:	06d70263          	beq	a4,a3,ffffffffc0201304 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02012a4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012a6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012aa:	fee57ae3          	bgeu	a0,a4,ffffffffc020129e <default_free_pages+0x6c>
ffffffffc02012ae:	c199                	beqz	a1,ffffffffc02012b4 <default_free_pages+0x82>
ffffffffc02012b0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012b4:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012b6:	e390                	sd	a2,0(a5)
ffffffffc02012b8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012ba:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02012bc:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012be:	02d70063          	beq	a4,a3,ffffffffc02012de <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02012c2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02012c6:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02012ca:	02081613          	slli	a2,a6,0x20
ffffffffc02012ce:	9201                	srli	a2,a2,0x20
ffffffffc02012d0:	00361793          	slli	a5,a2,0x3
ffffffffc02012d4:	97b2                	add	a5,a5,a2
ffffffffc02012d6:	078e                	slli	a5,a5,0x3
ffffffffc02012d8:	97ae                	add	a5,a5,a1
ffffffffc02012da:	02f50f63          	beq	a0,a5,ffffffffc0201318 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02012de:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02012e0:	00d70f63          	beq	a4,a3,ffffffffc02012fe <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02012e4:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02012e6:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02012ea:	02059613          	slli	a2,a1,0x20
ffffffffc02012ee:	9201                	srli	a2,a2,0x20
ffffffffc02012f0:	00361793          	slli	a5,a2,0x3
ffffffffc02012f4:	97b2                	add	a5,a5,a2
ffffffffc02012f6:	078e                	slli	a5,a5,0x3
ffffffffc02012f8:	97aa                	add	a5,a5,a0
ffffffffc02012fa:	04f68863          	beq	a3,a5,ffffffffc020134a <default_free_pages+0x118>
}
ffffffffc02012fe:	60a2                	ld	ra,8(sp)
ffffffffc0201300:	0141                	addi	sp,sp,16
ffffffffc0201302:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201304:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201306:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201308:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020130a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020130c:	02d70563          	beq	a4,a3,ffffffffc0201336 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201310:	8832                	mv	a6,a2
ffffffffc0201312:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201314:	87ba                	mv	a5,a4
ffffffffc0201316:	bf41                	j	ffffffffc02012a6 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201318:	4d1c                	lw	a5,24(a0)
ffffffffc020131a:	0107883b          	addw	a6,a5,a6
ffffffffc020131e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201322:	57f5                	li	a5,-3
ffffffffc0201324:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201328:	7110                	ld	a2,32(a0)
ffffffffc020132a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020132c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020132e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201330:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201332:	e390                	sd	a2,0(a5)
ffffffffc0201334:	b775                	j	ffffffffc02012e0 <default_free_pages+0xae>
ffffffffc0201336:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201338:	873e                	mv	a4,a5
ffffffffc020133a:	b761                	j	ffffffffc02012c2 <default_free_pages+0x90>
}
ffffffffc020133c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020133e:	e390                	sd	a2,0(a5)
ffffffffc0201340:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201342:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201344:	f11c                	sd	a5,32(a0)
ffffffffc0201346:	0141                	addi	sp,sp,16
ffffffffc0201348:	8082                	ret
            base->property += p->property;
ffffffffc020134a:	ff872783          	lw	a5,-8(a4)
ffffffffc020134e:	fe870693          	addi	a3,a4,-24
ffffffffc0201352:	9dbd                	addw	a1,a1,a5
ffffffffc0201354:	cd0c                	sw	a1,24(a0)
ffffffffc0201356:	57f5                	li	a5,-3
ffffffffc0201358:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020135c:	6314                	ld	a3,0(a4)
ffffffffc020135e:	671c                	ld	a5,8(a4)
}
ffffffffc0201360:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201362:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201364:	e394                	sd	a3,0(a5)
ffffffffc0201366:	0141                	addi	sp,sp,16
ffffffffc0201368:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020136a:	00004697          	auipc	a3,0x4
ffffffffc020136e:	b5e68693          	addi	a3,a3,-1186 # ffffffffc0204ec8 <commands+0xa98>
ffffffffc0201372:	00003617          	auipc	a2,0x3
ffffffffc0201376:	7f660613          	addi	a2,a2,2038 # ffffffffc0204b68 <commands+0x738>
ffffffffc020137a:	08300593          	li	a1,131
ffffffffc020137e:	00004517          	auipc	a0,0x4
ffffffffc0201382:	80250513          	addi	a0,a0,-2046 # ffffffffc0204b80 <commands+0x750>
ffffffffc0201386:	feffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc020138a:	00004697          	auipc	a3,0x4
ffffffffc020138e:	b3668693          	addi	a3,a3,-1226 # ffffffffc0204ec0 <commands+0xa90>
ffffffffc0201392:	00003617          	auipc	a2,0x3
ffffffffc0201396:	7d660613          	addi	a2,a2,2006 # ffffffffc0204b68 <commands+0x738>
ffffffffc020139a:	08000593          	li	a1,128
ffffffffc020139e:	00003517          	auipc	a0,0x3
ffffffffc02013a2:	7e250513          	addi	a0,a0,2018 # ffffffffc0204b80 <commands+0x750>
ffffffffc02013a6:	fcffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02013aa <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013aa:	c959                	beqz	a0,ffffffffc0201440 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013ac:	0000f597          	auipc	a1,0xf
ffffffffc02013b0:	c9458593          	addi	a1,a1,-876 # ffffffffc0210040 <free_area>
ffffffffc02013b4:	0105a803          	lw	a6,16(a1)
ffffffffc02013b8:	862a                	mv	a2,a0
ffffffffc02013ba:	02081793          	slli	a5,a6,0x20
ffffffffc02013be:	9381                	srli	a5,a5,0x20
ffffffffc02013c0:	00a7ee63          	bltu	a5,a0,ffffffffc02013dc <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02013c4:	87ae                	mv	a5,a1
ffffffffc02013c6:	a801                	j	ffffffffc02013d6 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02013c8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013cc:	02071693          	slli	a3,a4,0x20
ffffffffc02013d0:	9281                	srli	a3,a3,0x20
ffffffffc02013d2:	00c6f763          	bgeu	a3,a2,ffffffffc02013e0 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02013d6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02013d8:	feb798e3          	bne	a5,a1,ffffffffc02013c8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02013dc:	4501                	li	a0,0
}
ffffffffc02013de:	8082                	ret
    return listelm->prev;
ffffffffc02013e0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013e4:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02013e8:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02013ec:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02013f0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02013f4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02013f8:	02d67b63          	bgeu	a2,a3,ffffffffc020142e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02013fc:	00361693          	slli	a3,a2,0x3
ffffffffc0201400:	96b2                	add	a3,a3,a2
ffffffffc0201402:	068e                	slli	a3,a3,0x3
ffffffffc0201404:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201406:	41c7073b          	subw	a4,a4,t3
ffffffffc020140a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020140c:	00868613          	addi	a2,a3,8
ffffffffc0201410:	4709                	li	a4,2
ffffffffc0201412:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201416:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020141a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020141e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201422:	e310                	sd	a2,0(a4)
ffffffffc0201424:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201428:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020142a:	0316b023          	sd	a7,32(a3)
ffffffffc020142e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201432:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201436:	5775                	li	a4,-3
ffffffffc0201438:	17a1                	addi	a5,a5,-24
ffffffffc020143a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020143e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201440:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201442:	00004697          	auipc	a3,0x4
ffffffffc0201446:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0204ec0 <commands+0xa90>
ffffffffc020144a:	00003617          	auipc	a2,0x3
ffffffffc020144e:	71e60613          	addi	a2,a2,1822 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201452:	06200593          	li	a1,98
ffffffffc0201456:	00003517          	auipc	a0,0x3
ffffffffc020145a:	72a50513          	addi	a0,a0,1834 # ffffffffc0204b80 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc020145e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201460:	f15fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201464 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201464:	1141                	addi	sp,sp,-16
ffffffffc0201466:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201468:	c9e1                	beqz	a1,ffffffffc0201538 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020146a:	00359693          	slli	a3,a1,0x3
ffffffffc020146e:	96ae                	add	a3,a3,a1
ffffffffc0201470:	068e                	slli	a3,a3,0x3
ffffffffc0201472:	96aa                	add	a3,a3,a0
ffffffffc0201474:	87aa                	mv	a5,a0
ffffffffc0201476:	00d50f63          	beq	a0,a3,ffffffffc0201494 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020147a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020147c:	8b05                	andi	a4,a4,1
ffffffffc020147e:	cf49                	beqz	a4,ffffffffc0201518 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201480:	0007ac23          	sw	zero,24(a5)
ffffffffc0201484:	0007b423          	sd	zero,8(a5)
ffffffffc0201488:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020148c:	04878793          	addi	a5,a5,72
ffffffffc0201490:	fed795e3          	bne	a5,a3,ffffffffc020147a <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201494:	2581                	sext.w	a1,a1
ffffffffc0201496:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201498:	4789                	li	a5,2
ffffffffc020149a:	00850713          	addi	a4,a0,8
ffffffffc020149e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014a2:	0000f697          	auipc	a3,0xf
ffffffffc02014a6:	b9e68693          	addi	a3,a3,-1122 # ffffffffc0210040 <free_area>
ffffffffc02014aa:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014ac:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02014ae:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02014b2:	9db9                	addw	a1,a1,a4
ffffffffc02014b4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02014b6:	04d78a63          	beq	a5,a3,ffffffffc020150a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02014ba:	fe078713          	addi	a4,a5,-32
ffffffffc02014be:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014c2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02014c4:	00e56a63          	bltu	a0,a4,ffffffffc02014d8 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02014c8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014ca:	02d70263          	beq	a4,a3,ffffffffc02014ee <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02014ce:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02014d0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02014d4:	fee57ae3          	bgeu	a0,a4,ffffffffc02014c8 <default_init_memmap+0x64>
ffffffffc02014d8:	c199                	beqz	a1,ffffffffc02014de <default_init_memmap+0x7a>
ffffffffc02014da:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014de:	6398                	ld	a4,0(a5)
}
ffffffffc02014e0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02014e2:	e390                	sd	a2,0(a5)
ffffffffc02014e4:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02014e6:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02014e8:	f118                	sd	a4,32(a0)
ffffffffc02014ea:	0141                	addi	sp,sp,16
ffffffffc02014ec:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02014ee:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014f0:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02014f2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02014f4:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014f6:	00d70663          	beq	a4,a3,ffffffffc0201502 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02014fa:	8832                	mv	a6,a2
ffffffffc02014fc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02014fe:	87ba                	mv	a5,a4
ffffffffc0201500:	bfc1                	j	ffffffffc02014d0 <default_init_memmap+0x6c>
}
ffffffffc0201502:	60a2                	ld	ra,8(sp)
ffffffffc0201504:	e290                	sd	a2,0(a3)
ffffffffc0201506:	0141                	addi	sp,sp,16
ffffffffc0201508:	8082                	ret
ffffffffc020150a:	60a2                	ld	ra,8(sp)
ffffffffc020150c:	e390                	sd	a2,0(a5)
ffffffffc020150e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201510:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201512:	f11c                	sd	a5,32(a0)
ffffffffc0201514:	0141                	addi	sp,sp,16
ffffffffc0201516:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201518:	00004697          	auipc	a3,0x4
ffffffffc020151c:	9d868693          	addi	a3,a3,-1576 # ffffffffc0204ef0 <commands+0xac0>
ffffffffc0201520:	00003617          	auipc	a2,0x3
ffffffffc0201524:	64860613          	addi	a2,a2,1608 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201528:	04900593          	li	a1,73
ffffffffc020152c:	00003517          	auipc	a0,0x3
ffffffffc0201530:	65450513          	addi	a0,a0,1620 # ffffffffc0204b80 <commands+0x750>
ffffffffc0201534:	e41fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201538:	00004697          	auipc	a3,0x4
ffffffffc020153c:	98868693          	addi	a3,a3,-1656 # ffffffffc0204ec0 <commands+0xa90>
ffffffffc0201540:	00003617          	auipc	a2,0x3
ffffffffc0201544:	62860613          	addi	a2,a2,1576 # ffffffffc0204b68 <commands+0x738>
ffffffffc0201548:	04600593          	li	a1,70
ffffffffc020154c:	00003517          	auipc	a0,0x3
ffffffffc0201550:	63450513          	addi	a0,a0,1588 # ffffffffc0204b80 <commands+0x750>
ffffffffc0201554:	e21fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201558 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201558:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020155a:	00004617          	auipc	a2,0x4
ffffffffc020155e:	9f660613          	addi	a2,a2,-1546 # ffffffffc0204f50 <default_pmm_manager+0x38>
ffffffffc0201562:	06500593          	li	a1,101
ffffffffc0201566:	00004517          	auipc	a0,0x4
ffffffffc020156a:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0204f70 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc020156e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201570:	e05fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201574 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0201574:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201576:	00004617          	auipc	a2,0x4
ffffffffc020157a:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0204f80 <default_pmm_manager+0x68>
ffffffffc020157e:	07000593          	li	a1,112
ffffffffc0201582:	00004517          	auipc	a0,0x4
ffffffffc0201586:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0204f70 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc020158a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc020158c:	de9fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201590 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201590:	7139                	addi	sp,sp,-64
ffffffffc0201592:	f426                	sd	s1,40(sp)
ffffffffc0201594:	f04a                	sd	s2,32(sp)
ffffffffc0201596:	ec4e                	sd	s3,24(sp)
ffffffffc0201598:	e852                	sd	s4,16(sp)
ffffffffc020159a:	e456                	sd	s5,8(sp)
ffffffffc020159c:	e05a                	sd	s6,0(sp)
ffffffffc020159e:	fc06                	sd	ra,56(sp)
ffffffffc02015a0:	f822                	sd	s0,48(sp)
ffffffffc02015a2:	84aa                	mv	s1,a0
ffffffffc02015a4:	0000f917          	auipc	s2,0xf
ffffffffc02015a8:	f7c90913          	addi	s2,s2,-132 # ffffffffc0210520 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015ac:	4a05                	li	s4,1
ffffffffc02015ae:	0000fa97          	auipc	s5,0xf
ffffffffc02015b2:	f92a8a93          	addi	s5,s5,-110 # ffffffffc0210540 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02015b6:	0005099b          	sext.w	s3,a0
ffffffffc02015ba:	0000fb17          	auipc	s6,0xf
ffffffffc02015be:	f8eb0b13          	addi	s6,s6,-114 # ffffffffc0210548 <check_mm_struct>
ffffffffc02015c2:	a01d                	j	ffffffffc02015e8 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02015c4:	00093783          	ld	a5,0(s2)
ffffffffc02015c8:	6f9c                	ld	a5,24(a5)
ffffffffc02015ca:	9782                	jalr	a5
ffffffffc02015cc:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc02015ce:	4601                	li	a2,0
ffffffffc02015d0:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015d2:	ec0d                	bnez	s0,ffffffffc020160c <alloc_pages+0x7c>
ffffffffc02015d4:	029a6c63          	bltu	s4,s1,ffffffffc020160c <alloc_pages+0x7c>
ffffffffc02015d8:	000aa783          	lw	a5,0(s5)
ffffffffc02015dc:	2781                	sext.w	a5,a5
ffffffffc02015de:	c79d                	beqz	a5,ffffffffc020160c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc02015e0:	000b3503          	ld	a0,0(s6)
ffffffffc02015e4:	189010ef          	jal	ra,ffffffffc0202f6c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02015e8:	100027f3          	csrr	a5,sstatus
ffffffffc02015ec:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02015ee:	8526                	mv	a0,s1
ffffffffc02015f0:	dbf1                	beqz	a5,ffffffffc02015c4 <alloc_pages+0x34>
        intr_disable();
ffffffffc02015f2:	ed9fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc02015f6:	00093783          	ld	a5,0(s2)
ffffffffc02015fa:	8526                	mv	a0,s1
ffffffffc02015fc:	6f9c                	ld	a5,24(a5)
ffffffffc02015fe:	9782                	jalr	a5
ffffffffc0201600:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201602:	ec3fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201606:	4601                	li	a2,0
ffffffffc0201608:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020160a:	d469                	beqz	s0,ffffffffc02015d4 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020160c:	70e2                	ld	ra,56(sp)
ffffffffc020160e:	8522                	mv	a0,s0
ffffffffc0201610:	7442                	ld	s0,48(sp)
ffffffffc0201612:	74a2                	ld	s1,40(sp)
ffffffffc0201614:	7902                	ld	s2,32(sp)
ffffffffc0201616:	69e2                	ld	s3,24(sp)
ffffffffc0201618:	6a42                	ld	s4,16(sp)
ffffffffc020161a:	6aa2                	ld	s5,8(sp)
ffffffffc020161c:	6b02                	ld	s6,0(sp)
ffffffffc020161e:	6121                	addi	sp,sp,64
ffffffffc0201620:	8082                	ret

ffffffffc0201622 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201622:	100027f3          	csrr	a5,sstatus
ffffffffc0201626:	8b89                	andi	a5,a5,2
ffffffffc0201628:	e799                	bnez	a5,ffffffffc0201636 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020162a:	0000f797          	auipc	a5,0xf
ffffffffc020162e:	ef67b783          	ld	a5,-266(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0201632:	739c                	ld	a5,32(a5)
ffffffffc0201634:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201636:	1101                	addi	sp,sp,-32
ffffffffc0201638:	ec06                	sd	ra,24(sp)
ffffffffc020163a:	e822                	sd	s0,16(sp)
ffffffffc020163c:	e426                	sd	s1,8(sp)
ffffffffc020163e:	842a                	mv	s0,a0
ffffffffc0201640:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201642:	e89fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201646:	0000f797          	auipc	a5,0xf
ffffffffc020164a:	eda7b783          	ld	a5,-294(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc020164e:	739c                	ld	a5,32(a5)
ffffffffc0201650:	85a6                	mv	a1,s1
ffffffffc0201652:	8522                	mv	a0,s0
ffffffffc0201654:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201656:	6442                	ld	s0,16(sp)
ffffffffc0201658:	60e2                	ld	ra,24(sp)
ffffffffc020165a:	64a2                	ld	s1,8(sp)
ffffffffc020165c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020165e:	e67fe06f          	j	ffffffffc02004c4 <intr_enable>

ffffffffc0201662 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201662:	100027f3          	csrr	a5,sstatus
ffffffffc0201666:	8b89                	andi	a5,a5,2
ffffffffc0201668:	e799                	bnez	a5,ffffffffc0201676 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020166a:	0000f797          	auipc	a5,0xf
ffffffffc020166e:	eb67b783          	ld	a5,-330(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0201672:	779c                	ld	a5,40(a5)
ffffffffc0201674:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201676:	1141                	addi	sp,sp,-16
ffffffffc0201678:	e406                	sd	ra,8(sp)
ffffffffc020167a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020167c:	e4ffe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201680:	0000f797          	auipc	a5,0xf
ffffffffc0201684:	ea07b783          	ld	a5,-352(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0201688:	779c                	ld	a5,40(a5)
ffffffffc020168a:	9782                	jalr	a5
ffffffffc020168c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020168e:	e37fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201692:	60a2                	ld	ra,8(sp)
ffffffffc0201694:	8522                	mv	a0,s0
ffffffffc0201696:	6402                	ld	s0,0(sp)
ffffffffc0201698:	0141                	addi	sp,sp,16
ffffffffc020169a:	8082                	ret

ffffffffc020169c <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020169c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016a0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016a4:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016a6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016a8:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016aa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016ae:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016b0:	f84a                	sd	s2,48(sp)
ffffffffc02016b2:	f44e                	sd	s3,40(sp)
ffffffffc02016b4:	f052                	sd	s4,32(sp)
ffffffffc02016b6:	e486                	sd	ra,72(sp)
ffffffffc02016b8:	e0a2                	sd	s0,64(sp)
ffffffffc02016ba:	ec56                	sd	s5,24(sp)
ffffffffc02016bc:	e85a                	sd	s6,16(sp)
ffffffffc02016be:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016c0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016c4:	892e                	mv	s2,a1
ffffffffc02016c6:	8a32                	mv	s4,a2
ffffffffc02016c8:	0000f997          	auipc	s3,0xf
ffffffffc02016cc:	e4898993          	addi	s3,s3,-440 # ffffffffc0210510 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016d0:	efb5                	bnez	a5,ffffffffc020174c <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02016d2:	14060c63          	beqz	a2,ffffffffc020182a <get_pte+0x18e>
ffffffffc02016d6:	4505                	li	a0,1
ffffffffc02016d8:	eb9ff0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc02016dc:	842a                	mv	s0,a0
ffffffffc02016de:	14050663          	beqz	a0,ffffffffc020182a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02016e2:	0000fb97          	auipc	s7,0xf
ffffffffc02016e6:	e36b8b93          	addi	s7,s7,-458 # ffffffffc0210518 <pages>
ffffffffc02016ea:	000bb503          	ld	a0,0(s7)
ffffffffc02016ee:	00005b17          	auipc	s6,0x5
ffffffffc02016f2:	872b3b03          	ld	s6,-1934(s6) # ffffffffc0205f60 <error_string+0x38>
ffffffffc02016f6:	00080ab7          	lui	s5,0x80
ffffffffc02016fa:	40a40533          	sub	a0,s0,a0
ffffffffc02016fe:	850d                	srai	a0,a0,0x3
ffffffffc0201700:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201704:	0000f997          	auipc	s3,0xf
ffffffffc0201708:	e0c98993          	addi	s3,s3,-500 # ffffffffc0210510 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020170c:	4785                	li	a5,1
ffffffffc020170e:	0009b703          	ld	a4,0(s3)
ffffffffc0201712:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201714:	9556                	add	a0,a0,s5
ffffffffc0201716:	00c51793          	slli	a5,a0,0xc
ffffffffc020171a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020171c:	0532                	slli	a0,a0,0xc
ffffffffc020171e:	14e7fd63          	bgeu	a5,a4,ffffffffc0201878 <get_pte+0x1dc>
ffffffffc0201722:	0000f797          	auipc	a5,0xf
ffffffffc0201726:	e067b783          	ld	a5,-506(a5) # ffffffffc0210528 <va_pa_offset>
ffffffffc020172a:	6605                	lui	a2,0x1
ffffffffc020172c:	4581                	li	a1,0
ffffffffc020172e:	953e                	add	a0,a0,a5
ffffffffc0201730:	27f020ef          	jal	ra,ffffffffc02041ae <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201734:	000bb683          	ld	a3,0(s7)
ffffffffc0201738:	40d406b3          	sub	a3,s0,a3
ffffffffc020173c:	868d                	srai	a3,a3,0x3
ffffffffc020173e:	036686b3          	mul	a3,a3,s6
ffffffffc0201742:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201744:	06aa                	slli	a3,a3,0xa
ffffffffc0201746:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020174a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020174c:	77fd                	lui	a5,0xfffff
ffffffffc020174e:	068a                	slli	a3,a3,0x2
ffffffffc0201750:	0009b703          	ld	a4,0(s3)
ffffffffc0201754:	8efd                	and	a3,a3,a5
ffffffffc0201756:	00c6d793          	srli	a5,a3,0xc
ffffffffc020175a:	0ce7fa63          	bgeu	a5,a4,ffffffffc020182e <get_pte+0x192>
ffffffffc020175e:	0000fa97          	auipc	s5,0xf
ffffffffc0201762:	dcaa8a93          	addi	s5,s5,-566 # ffffffffc0210528 <va_pa_offset>
ffffffffc0201766:	000ab403          	ld	s0,0(s5)
ffffffffc020176a:	01595793          	srli	a5,s2,0x15
ffffffffc020176e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201772:	96a2                	add	a3,a3,s0
ffffffffc0201774:	00379413          	slli	s0,a5,0x3
ffffffffc0201778:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020177a:	6014                	ld	a3,0(s0)
ffffffffc020177c:	0016f793          	andi	a5,a3,1
ffffffffc0201780:	ebad                	bnez	a5,ffffffffc02017f2 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201782:	0a0a0463          	beqz	s4,ffffffffc020182a <get_pte+0x18e>
ffffffffc0201786:	4505                	li	a0,1
ffffffffc0201788:	e09ff0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc020178c:	84aa                	mv	s1,a0
ffffffffc020178e:	cd51                	beqz	a0,ffffffffc020182a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201790:	0000fb97          	auipc	s7,0xf
ffffffffc0201794:	d88b8b93          	addi	s7,s7,-632 # ffffffffc0210518 <pages>
ffffffffc0201798:	000bb503          	ld	a0,0(s7)
ffffffffc020179c:	00004b17          	auipc	s6,0x4
ffffffffc02017a0:	7c4b3b03          	ld	s6,1988(s6) # ffffffffc0205f60 <error_string+0x38>
ffffffffc02017a4:	00080a37          	lui	s4,0x80
ffffffffc02017a8:	40a48533          	sub	a0,s1,a0
ffffffffc02017ac:	850d                	srai	a0,a0,0x3
ffffffffc02017ae:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017b2:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017b4:	0009b703          	ld	a4,0(s3)
ffffffffc02017b8:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017ba:	9552                	add	a0,a0,s4
ffffffffc02017bc:	00c51793          	slli	a5,a0,0xc
ffffffffc02017c0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017c2:	0532                	slli	a0,a0,0xc
ffffffffc02017c4:	08e7fd63          	bgeu	a5,a4,ffffffffc020185e <get_pte+0x1c2>
ffffffffc02017c8:	000ab783          	ld	a5,0(s5)
ffffffffc02017cc:	6605                	lui	a2,0x1
ffffffffc02017ce:	4581                	li	a1,0
ffffffffc02017d0:	953e                	add	a0,a0,a5
ffffffffc02017d2:	1dd020ef          	jal	ra,ffffffffc02041ae <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017d6:	000bb683          	ld	a3,0(s7)
ffffffffc02017da:	40d486b3          	sub	a3,s1,a3
ffffffffc02017de:	868d                	srai	a3,a3,0x3
ffffffffc02017e0:	036686b3          	mul	a3,a3,s6
ffffffffc02017e4:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017e6:	06aa                	slli	a3,a3,0xa
ffffffffc02017e8:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017ec:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02017ee:	0009b703          	ld	a4,0(s3)
ffffffffc02017f2:	068a                	slli	a3,a3,0x2
ffffffffc02017f4:	757d                	lui	a0,0xfffff
ffffffffc02017f6:	8ee9                	and	a3,a3,a0
ffffffffc02017f8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017fc:	04e7f563          	bgeu	a5,a4,ffffffffc0201846 <get_pte+0x1aa>
ffffffffc0201800:	000ab503          	ld	a0,0(s5)
ffffffffc0201804:	00c95913          	srli	s2,s2,0xc
ffffffffc0201808:	1ff97913          	andi	s2,s2,511
ffffffffc020180c:	96aa                	add	a3,a3,a0
ffffffffc020180e:	00391513          	slli	a0,s2,0x3
ffffffffc0201812:	9536                	add	a0,a0,a3
}
ffffffffc0201814:	60a6                	ld	ra,72(sp)
ffffffffc0201816:	6406                	ld	s0,64(sp)
ffffffffc0201818:	74e2                	ld	s1,56(sp)
ffffffffc020181a:	7942                	ld	s2,48(sp)
ffffffffc020181c:	79a2                	ld	s3,40(sp)
ffffffffc020181e:	7a02                	ld	s4,32(sp)
ffffffffc0201820:	6ae2                	ld	s5,24(sp)
ffffffffc0201822:	6b42                	ld	s6,16(sp)
ffffffffc0201824:	6ba2                	ld	s7,8(sp)
ffffffffc0201826:	6161                	addi	sp,sp,80
ffffffffc0201828:	8082                	ret
            return NULL;
ffffffffc020182a:	4501                	li	a0,0
ffffffffc020182c:	b7e5                	j	ffffffffc0201814 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020182e:	00003617          	auipc	a2,0x3
ffffffffc0201832:	77a60613          	addi	a2,a2,1914 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc0201836:	10200593          	li	a1,258
ffffffffc020183a:	00003517          	auipc	a0,0x3
ffffffffc020183e:	79650513          	addi	a0,a0,1942 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0201842:	b33fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201846:	00003617          	auipc	a2,0x3
ffffffffc020184a:	76260613          	addi	a2,a2,1890 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc020184e:	10f00593          	li	a1,271
ffffffffc0201852:	00003517          	auipc	a0,0x3
ffffffffc0201856:	77e50513          	addi	a0,a0,1918 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020185a:	b1bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020185e:	86aa                	mv	a3,a0
ffffffffc0201860:	00003617          	auipc	a2,0x3
ffffffffc0201864:	74860613          	addi	a2,a2,1864 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc0201868:	10b00593          	li	a1,267
ffffffffc020186c:	00003517          	auipc	a0,0x3
ffffffffc0201870:	76450513          	addi	a0,a0,1892 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0201874:	b01fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201878:	86aa                	mv	a3,a0
ffffffffc020187a:	00003617          	auipc	a2,0x3
ffffffffc020187e:	72e60613          	addi	a2,a2,1838 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc0201882:	0ff00593          	li	a1,255
ffffffffc0201886:	00003517          	auipc	a0,0x3
ffffffffc020188a:	74a50513          	addi	a0,a0,1866 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020188e:	ae7fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201892 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201892:	1141                	addi	sp,sp,-16
ffffffffc0201894:	e022                	sd	s0,0(sp)
ffffffffc0201896:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201898:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020189a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020189c:	e01ff0ef          	jal	ra,ffffffffc020169c <get_pte>
    if (ptep_store != NULL) {
ffffffffc02018a0:	c011                	beqz	s0,ffffffffc02018a4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02018a2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018a4:	c511                	beqz	a0,ffffffffc02018b0 <get_page+0x1e>
ffffffffc02018a6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02018a8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018aa:	0017f713          	andi	a4,a5,1
ffffffffc02018ae:	e709                	bnez	a4,ffffffffc02018b8 <get_page+0x26>
}
ffffffffc02018b0:	60a2                	ld	ra,8(sp)
ffffffffc02018b2:	6402                	ld	s0,0(sp)
ffffffffc02018b4:	0141                	addi	sp,sp,16
ffffffffc02018b6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02018b8:	078a                	slli	a5,a5,0x2
ffffffffc02018ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018bc:	0000f717          	auipc	a4,0xf
ffffffffc02018c0:	c5473703          	ld	a4,-940(a4) # ffffffffc0210510 <npage>
ffffffffc02018c4:	02e7f263          	bgeu	a5,a4,ffffffffc02018e8 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc02018c8:	fff80537          	lui	a0,0xfff80
ffffffffc02018cc:	97aa                	add	a5,a5,a0
ffffffffc02018ce:	60a2                	ld	ra,8(sp)
ffffffffc02018d0:	6402                	ld	s0,0(sp)
ffffffffc02018d2:	00379513          	slli	a0,a5,0x3
ffffffffc02018d6:	97aa                	add	a5,a5,a0
ffffffffc02018d8:	078e                	slli	a5,a5,0x3
ffffffffc02018da:	0000f517          	auipc	a0,0xf
ffffffffc02018de:	c3e53503          	ld	a0,-962(a0) # ffffffffc0210518 <pages>
ffffffffc02018e2:	953e                	add	a0,a0,a5
ffffffffc02018e4:	0141                	addi	sp,sp,16
ffffffffc02018e6:	8082                	ret
ffffffffc02018e8:	c71ff0ef          	jal	ra,ffffffffc0201558 <pa2page.part.0>

ffffffffc02018ec <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02018ec:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018ee:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02018f0:	ec06                	sd	ra,24(sp)
ffffffffc02018f2:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018f4:	da9ff0ef          	jal	ra,ffffffffc020169c <get_pte>
    if (ptep != NULL) {
ffffffffc02018f8:	c511                	beqz	a0,ffffffffc0201904 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02018fa:	611c                	ld	a5,0(a0)
ffffffffc02018fc:	842a                	mv	s0,a0
ffffffffc02018fe:	0017f713          	andi	a4,a5,1
ffffffffc0201902:	e709                	bnez	a4,ffffffffc020190c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201904:	60e2                	ld	ra,24(sp)
ffffffffc0201906:	6442                	ld	s0,16(sp)
ffffffffc0201908:	6105                	addi	sp,sp,32
ffffffffc020190a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020190c:	078a                	slli	a5,a5,0x2
ffffffffc020190e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201910:	0000f717          	auipc	a4,0xf
ffffffffc0201914:	c0073703          	ld	a4,-1024(a4) # ffffffffc0210510 <npage>
ffffffffc0201918:	06e7f563          	bgeu	a5,a4,ffffffffc0201982 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020191c:	fff80737          	lui	a4,0xfff80
ffffffffc0201920:	97ba                	add	a5,a5,a4
ffffffffc0201922:	00379513          	slli	a0,a5,0x3
ffffffffc0201926:	97aa                	add	a5,a5,a0
ffffffffc0201928:	078e                	slli	a5,a5,0x3
ffffffffc020192a:	0000f517          	auipc	a0,0xf
ffffffffc020192e:	bee53503          	ld	a0,-1042(a0) # ffffffffc0210518 <pages>
ffffffffc0201932:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201934:	411c                	lw	a5,0(a0)
ffffffffc0201936:	fff7871b          	addiw	a4,a5,-1
ffffffffc020193a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020193c:	cb09                	beqz	a4,ffffffffc020194e <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020193e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201942:	12000073          	sfence.vma
}
ffffffffc0201946:	60e2                	ld	ra,24(sp)
ffffffffc0201948:	6442                	ld	s0,16(sp)
ffffffffc020194a:	6105                	addi	sp,sp,32
ffffffffc020194c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020194e:	100027f3          	csrr	a5,sstatus
ffffffffc0201952:	8b89                	andi	a5,a5,2
ffffffffc0201954:	eb89                	bnez	a5,ffffffffc0201966 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201956:	0000f797          	auipc	a5,0xf
ffffffffc020195a:	bca7b783          	ld	a5,-1078(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc020195e:	739c                	ld	a5,32(a5)
ffffffffc0201960:	4585                	li	a1,1
ffffffffc0201962:	9782                	jalr	a5
    if (flag) {
ffffffffc0201964:	bfe9                	j	ffffffffc020193e <page_remove+0x52>
        intr_disable();
ffffffffc0201966:	e42a                	sd	a0,8(sp)
ffffffffc0201968:	b63fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc020196c:	0000f797          	auipc	a5,0xf
ffffffffc0201970:	bb47b783          	ld	a5,-1100(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0201974:	739c                	ld	a5,32(a5)
ffffffffc0201976:	6522                	ld	a0,8(sp)
ffffffffc0201978:	4585                	li	a1,1
ffffffffc020197a:	9782                	jalr	a5
        intr_enable();
ffffffffc020197c:	b49fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0201980:	bf7d                	j	ffffffffc020193e <page_remove+0x52>
ffffffffc0201982:	bd7ff0ef          	jal	ra,ffffffffc0201558 <pa2page.part.0>

ffffffffc0201986 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201986:	7179                	addi	sp,sp,-48
ffffffffc0201988:	87b2                	mv	a5,a2
ffffffffc020198a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020198c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020198e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201990:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201992:	ec26                	sd	s1,24(sp)
ffffffffc0201994:	f406                	sd	ra,40(sp)
ffffffffc0201996:	e84a                	sd	s2,16(sp)
ffffffffc0201998:	e44e                	sd	s3,8(sp)
ffffffffc020199a:	e052                	sd	s4,0(sp)
ffffffffc020199c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020199e:	cffff0ef          	jal	ra,ffffffffc020169c <get_pte>
    if (ptep == NULL) {
ffffffffc02019a2:	cd71                	beqz	a0,ffffffffc0201a7e <page_insert+0xf8>
    page->ref += 1;
ffffffffc02019a4:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc02019a6:	611c                	ld	a5,0(a0)
ffffffffc02019a8:	89aa                	mv	s3,a0
ffffffffc02019aa:	0016871b          	addiw	a4,a3,1
ffffffffc02019ae:	c018                	sw	a4,0(s0)
ffffffffc02019b0:	0017f713          	andi	a4,a5,1
ffffffffc02019b4:	e331                	bnez	a4,ffffffffc02019f8 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02019b6:	0000f797          	auipc	a5,0xf
ffffffffc02019ba:	b627b783          	ld	a5,-1182(a5) # ffffffffc0210518 <pages>
ffffffffc02019be:	40f407b3          	sub	a5,s0,a5
ffffffffc02019c2:	878d                	srai	a5,a5,0x3
ffffffffc02019c4:	00004417          	auipc	s0,0x4
ffffffffc02019c8:	59c43403          	ld	s0,1436(s0) # ffffffffc0205f60 <error_string+0x38>
ffffffffc02019cc:	028787b3          	mul	a5,a5,s0
ffffffffc02019d0:	00080437          	lui	s0,0x80
ffffffffc02019d4:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02019d6:	07aa                	slli	a5,a5,0xa
ffffffffc02019d8:	8cdd                	or	s1,s1,a5
ffffffffc02019da:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02019de:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019e2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc02019e6:	4501                	li	a0,0
}
ffffffffc02019e8:	70a2                	ld	ra,40(sp)
ffffffffc02019ea:	7402                	ld	s0,32(sp)
ffffffffc02019ec:	64e2                	ld	s1,24(sp)
ffffffffc02019ee:	6942                	ld	s2,16(sp)
ffffffffc02019f0:	69a2                	ld	s3,8(sp)
ffffffffc02019f2:	6a02                	ld	s4,0(sp)
ffffffffc02019f4:	6145                	addi	sp,sp,48
ffffffffc02019f6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02019f8:	00279713          	slli	a4,a5,0x2
ffffffffc02019fc:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019fe:	0000f797          	auipc	a5,0xf
ffffffffc0201a02:	b127b783          	ld	a5,-1262(a5) # ffffffffc0210510 <npage>
ffffffffc0201a06:	06f77e63          	bgeu	a4,a5,ffffffffc0201a82 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a0a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a0e:	973e                	add	a4,a4,a5
ffffffffc0201a10:	0000fa17          	auipc	s4,0xf
ffffffffc0201a14:	b08a0a13          	addi	s4,s4,-1272 # ffffffffc0210518 <pages>
ffffffffc0201a18:	000a3783          	ld	a5,0(s4)
ffffffffc0201a1c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a20:	993a                	add	s2,s2,a4
ffffffffc0201a22:	090e                	slli	s2,s2,0x3
ffffffffc0201a24:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a26:	03240063          	beq	s0,s2,ffffffffc0201a46 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a2a:	00092783          	lw	a5,0(s2)
ffffffffc0201a2e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a32:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201a36:	cb11                	beqz	a4,ffffffffc0201a4a <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a38:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a3c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a40:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201a44:	bfad                	j	ffffffffc02019be <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201a46:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201a48:	bf9d                	j	ffffffffc02019be <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a4a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a4e:	8b89                	andi	a5,a5,2
ffffffffc0201a50:	eb91                	bnez	a5,ffffffffc0201a64 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201a52:	0000f797          	auipc	a5,0xf
ffffffffc0201a56:	ace7b783          	ld	a5,-1330(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0201a5a:	739c                	ld	a5,32(a5)
ffffffffc0201a5c:	4585                	li	a1,1
ffffffffc0201a5e:	854a                	mv	a0,s2
ffffffffc0201a60:	9782                	jalr	a5
    if (flag) {
ffffffffc0201a62:	bfd9                	j	ffffffffc0201a38 <page_insert+0xb2>
        intr_disable();
ffffffffc0201a64:	a67fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0201a68:	0000f797          	auipc	a5,0xf
ffffffffc0201a6c:	ab87b783          	ld	a5,-1352(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0201a70:	739c                	ld	a5,32(a5)
ffffffffc0201a72:	4585                	li	a1,1
ffffffffc0201a74:	854a                	mv	a0,s2
ffffffffc0201a76:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a78:	a4dfe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0201a7c:	bf75                	j	ffffffffc0201a38 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201a7e:	5571                	li	a0,-4
ffffffffc0201a80:	b7a5                	j	ffffffffc02019e8 <page_insert+0x62>
ffffffffc0201a82:	ad7ff0ef          	jal	ra,ffffffffc0201558 <pa2page.part.0>

ffffffffc0201a86 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201a86:	00003797          	auipc	a5,0x3
ffffffffc0201a8a:	49278793          	addi	a5,a5,1170 # ffffffffc0204f18 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201a8e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201a90:	7159                	addi	sp,sp,-112
ffffffffc0201a92:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201a94:	00003517          	auipc	a0,0x3
ffffffffc0201a98:	54c50513          	addi	a0,a0,1356 # ffffffffc0204fe0 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201a9c:	0000fb97          	auipc	s7,0xf
ffffffffc0201aa0:	a84b8b93          	addi	s7,s7,-1404 # ffffffffc0210520 <pmm_manager>
void pmm_init(void) {
ffffffffc0201aa4:	f486                	sd	ra,104(sp)
ffffffffc0201aa6:	f0a2                	sd	s0,96(sp)
ffffffffc0201aa8:	eca6                	sd	s1,88(sp)
ffffffffc0201aaa:	e8ca                	sd	s2,80(sp)
ffffffffc0201aac:	e4ce                	sd	s3,72(sp)
ffffffffc0201aae:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ab0:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201ab4:	e0d2                	sd	s4,64(sp)
ffffffffc0201ab6:	fc56                	sd	s5,56(sp)
ffffffffc0201ab8:	f062                	sd	s8,32(sp)
ffffffffc0201aba:	ec66                	sd	s9,24(sp)
ffffffffc0201abc:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201abe:	dfcfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201ac2:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201ac6:	4445                	li	s0,17
ffffffffc0201ac8:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201acc:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201ace:	0000f997          	auipc	s3,0xf
ffffffffc0201ad2:	a5a98993          	addi	s3,s3,-1446 # ffffffffc0210528 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201ad6:	0000f497          	auipc	s1,0xf
ffffffffc0201ada:	a3a48493          	addi	s1,s1,-1478 # ffffffffc0210510 <npage>
    pmm_manager->init();
ffffffffc0201ade:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201ae0:	57f5                	li	a5,-3
ffffffffc0201ae2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201ae4:	07e006b7          	lui	a3,0x7e00
ffffffffc0201ae8:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201aec:	01591593          	slli	a1,s2,0x15
ffffffffc0201af0:	00003517          	auipc	a0,0x3
ffffffffc0201af4:	50850513          	addi	a0,a0,1288 # ffffffffc0204ff8 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201af8:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201afc:	dbefe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b00:	00003517          	auipc	a0,0x3
ffffffffc0201b04:	52850513          	addi	a0,a0,1320 # ffffffffc0205028 <default_pmm_manager+0x110>
ffffffffc0201b08:	db2fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b0c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b10:	16fd                	addi	a3,a3,-1
ffffffffc0201b12:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b16:	01591613          	slli	a2,s2,0x15
ffffffffc0201b1a:	00003517          	auipc	a0,0x3
ffffffffc0201b1e:	52650513          	addi	a0,a0,1318 # ffffffffc0205040 <default_pmm_manager+0x128>
ffffffffc0201b22:	d98fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b26:	777d                	lui	a4,0xfffff
ffffffffc0201b28:	00010797          	auipc	a5,0x10
ffffffffc0201b2c:	a2b78793          	addi	a5,a5,-1493 # ffffffffc0211553 <end+0xfff>
ffffffffc0201b30:	8ff9                	and	a5,a5,a4
ffffffffc0201b32:	0000fb17          	auipc	s6,0xf
ffffffffc0201b36:	9e6b0b13          	addi	s6,s6,-1562 # ffffffffc0210518 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201b3a:	00088737          	lui	a4,0x88
ffffffffc0201b3e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b40:	00fb3023          	sd	a5,0(s6)
ffffffffc0201b44:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b46:	4701                	li	a4,0
ffffffffc0201b48:	4505                	li	a0,1
ffffffffc0201b4a:	fff805b7          	lui	a1,0xfff80
ffffffffc0201b4e:	a019                	j	ffffffffc0201b54 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201b50:	000b3783          	ld	a5,0(s6)
ffffffffc0201b54:	97b6                	add	a5,a5,a3
ffffffffc0201b56:	07a1                	addi	a5,a5,8
ffffffffc0201b58:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b5c:	609c                	ld	a5,0(s1)
ffffffffc0201b5e:	0705                	addi	a4,a4,1
ffffffffc0201b60:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201b64:	00b78633          	add	a2,a5,a1
ffffffffc0201b68:	fec764e3          	bltu	a4,a2,ffffffffc0201b50 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201b6c:	000b3503          	ld	a0,0(s6)
ffffffffc0201b70:	00379693          	slli	a3,a5,0x3
ffffffffc0201b74:	96be                	add	a3,a3,a5
ffffffffc0201b76:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201b7a:	972a                	add	a4,a4,a0
ffffffffc0201b7c:	068e                	slli	a3,a3,0x3
ffffffffc0201b7e:	96ba                	add	a3,a3,a4
ffffffffc0201b80:	c0200737          	lui	a4,0xc0200
ffffffffc0201b84:	64e6e463          	bltu	a3,a4,ffffffffc02021cc <pmm_init+0x746>
ffffffffc0201b88:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201b8c:	4645                	li	a2,17
ffffffffc0201b8e:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201b90:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201b92:	4ec6e263          	bltu	a3,a2,ffffffffc0202076 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201b96:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201b9a:	0000f917          	auipc	s2,0xf
ffffffffc0201b9e:	96e90913          	addi	s2,s2,-1682 # ffffffffc0210508 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201ba2:	7b9c                	ld	a5,48(a5)
ffffffffc0201ba4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201ba6:	00003517          	auipc	a0,0x3
ffffffffc0201baa:	4ea50513          	addi	a0,a0,1258 # ffffffffc0205090 <default_pmm_manager+0x178>
ffffffffc0201bae:	d0cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bb2:	00006697          	auipc	a3,0x6
ffffffffc0201bb6:	44e68693          	addi	a3,a3,1102 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0201bba:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201bbe:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bc2:	62f6e163          	bltu	a3,a5,ffffffffc02021e4 <pmm_init+0x75e>
ffffffffc0201bc6:	0009b783          	ld	a5,0(s3)
ffffffffc0201bca:	8e9d                	sub	a3,a3,a5
ffffffffc0201bcc:	0000f797          	auipc	a5,0xf
ffffffffc0201bd0:	92d7ba23          	sd	a3,-1740(a5) # ffffffffc0210500 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bd4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bd8:	8b89                	andi	a5,a5,2
ffffffffc0201bda:	4c079763          	bnez	a5,ffffffffc02020a8 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201bde:	000bb783          	ld	a5,0(s7)
ffffffffc0201be2:	779c                	ld	a5,40(a5)
ffffffffc0201be4:	9782                	jalr	a5
ffffffffc0201be6:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201be8:	6098                	ld	a4,0(s1)
ffffffffc0201bea:	c80007b7          	lui	a5,0xc8000
ffffffffc0201bee:	83b1                	srli	a5,a5,0xc
ffffffffc0201bf0:	62e7e663          	bltu	a5,a4,ffffffffc020221c <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201bf4:	00093503          	ld	a0,0(s2)
ffffffffc0201bf8:	60050263          	beqz	a0,ffffffffc02021fc <pmm_init+0x776>
ffffffffc0201bfc:	03451793          	slli	a5,a0,0x34
ffffffffc0201c00:	5e079e63          	bnez	a5,ffffffffc02021fc <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c04:	4601                	li	a2,0
ffffffffc0201c06:	4581                	li	a1,0
ffffffffc0201c08:	c8bff0ef          	jal	ra,ffffffffc0201892 <get_page>
ffffffffc0201c0c:	66051a63          	bnez	a0,ffffffffc0202280 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c10:	4505                	li	a0,1
ffffffffc0201c12:	97fff0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0201c16:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c18:	00093503          	ld	a0,0(s2)
ffffffffc0201c1c:	4681                	li	a3,0
ffffffffc0201c1e:	4601                	li	a2,0
ffffffffc0201c20:	85d2                	mv	a1,s4
ffffffffc0201c22:	d65ff0ef          	jal	ra,ffffffffc0201986 <page_insert>
ffffffffc0201c26:	62051d63          	bnez	a0,ffffffffc0202260 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c2a:	00093503          	ld	a0,0(s2)
ffffffffc0201c2e:	4601                	li	a2,0
ffffffffc0201c30:	4581                	li	a1,0
ffffffffc0201c32:	a6bff0ef          	jal	ra,ffffffffc020169c <get_pte>
ffffffffc0201c36:	60050563          	beqz	a0,ffffffffc0202240 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c3a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c3c:	0017f713          	andi	a4,a5,1
ffffffffc0201c40:	5e070e63          	beqz	a4,ffffffffc020223c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201c44:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c46:	078a                	slli	a5,a5,0x2
ffffffffc0201c48:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c4a:	56c7ff63          	bgeu	a5,a2,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c4e:	fff80737          	lui	a4,0xfff80
ffffffffc0201c52:	97ba                	add	a5,a5,a4
ffffffffc0201c54:	000b3683          	ld	a3,0(s6)
ffffffffc0201c58:	00379713          	slli	a4,a5,0x3
ffffffffc0201c5c:	97ba                	add	a5,a5,a4
ffffffffc0201c5e:	078e                	slli	a5,a5,0x3
ffffffffc0201c60:	97b6                	add	a5,a5,a3
ffffffffc0201c62:	14fa18e3          	bne	s4,a5,ffffffffc02025b2 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0201c66:	000a2703          	lw	a4,0(s4)
ffffffffc0201c6a:	4785                	li	a5,1
ffffffffc0201c6c:	16f71fe3          	bne	a4,a5,ffffffffc02025ea <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201c70:	00093503          	ld	a0,0(s2)
ffffffffc0201c74:	77fd                	lui	a5,0xfffff
ffffffffc0201c76:	6114                	ld	a3,0(a0)
ffffffffc0201c78:	068a                	slli	a3,a3,0x2
ffffffffc0201c7a:	8efd                	and	a3,a3,a5
ffffffffc0201c7c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201c80:	14c779e3          	bgeu	a4,a2,ffffffffc02025d2 <pmm_init+0xb4c>
ffffffffc0201c84:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201c88:	96e2                	add	a3,a3,s8
ffffffffc0201c8a:	0006ba83          	ld	s5,0(a3)
ffffffffc0201c8e:	0a8a                	slli	s5,s5,0x2
ffffffffc0201c90:	00fafab3          	and	s5,s5,a5
ffffffffc0201c94:	00cad793          	srli	a5,s5,0xc
ffffffffc0201c98:	66c7f463          	bgeu	a5,a2,ffffffffc0202300 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201c9c:	4601                	li	a2,0
ffffffffc0201c9e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ca0:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ca2:	9fbff0ef          	jal	ra,ffffffffc020169c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ca6:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ca8:	63551c63          	bne	a0,s5,ffffffffc02022e0 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0201cac:	4505                	li	a0,1
ffffffffc0201cae:	8e3ff0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0201cb2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201cb4:	00093503          	ld	a0,0(s2)
ffffffffc0201cb8:	46d1                	li	a3,20
ffffffffc0201cba:	6605                	lui	a2,0x1
ffffffffc0201cbc:	85d6                	mv	a1,s5
ffffffffc0201cbe:	cc9ff0ef          	jal	ra,ffffffffc0201986 <page_insert>
ffffffffc0201cc2:	5c051f63          	bnez	a0,ffffffffc02022a0 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201cc6:	00093503          	ld	a0,0(s2)
ffffffffc0201cca:	4601                	li	a2,0
ffffffffc0201ccc:	6585                	lui	a1,0x1
ffffffffc0201cce:	9cfff0ef          	jal	ra,ffffffffc020169c <get_pte>
ffffffffc0201cd2:	12050ce3          	beqz	a0,ffffffffc020260a <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0201cd6:	611c                	ld	a5,0(a0)
ffffffffc0201cd8:	0107f713          	andi	a4,a5,16
ffffffffc0201cdc:	72070f63          	beqz	a4,ffffffffc020241a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201ce0:	8b91                	andi	a5,a5,4
ffffffffc0201ce2:	6e078c63          	beqz	a5,ffffffffc02023da <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201ce6:	00093503          	ld	a0,0(s2)
ffffffffc0201cea:	611c                	ld	a5,0(a0)
ffffffffc0201cec:	8bc1                	andi	a5,a5,16
ffffffffc0201cee:	6c078663          	beqz	a5,ffffffffc02023ba <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0201cf2:	000aa703          	lw	a4,0(s5)
ffffffffc0201cf6:	4785                	li	a5,1
ffffffffc0201cf8:	5cf71463          	bne	a4,a5,ffffffffc02022c0 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201cfc:	4681                	li	a3,0
ffffffffc0201cfe:	6605                	lui	a2,0x1
ffffffffc0201d00:	85d2                	mv	a1,s4
ffffffffc0201d02:	c85ff0ef          	jal	ra,ffffffffc0201986 <page_insert>
ffffffffc0201d06:	66051a63          	bnez	a0,ffffffffc020237a <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0201d0a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d0e:	4789                	li	a5,2
ffffffffc0201d10:	64f71563          	bne	a4,a5,ffffffffc020235a <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0201d14:	000aa783          	lw	a5,0(s5)
ffffffffc0201d18:	62079163          	bnez	a5,ffffffffc020233a <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d1c:	00093503          	ld	a0,0(s2)
ffffffffc0201d20:	4601                	li	a2,0
ffffffffc0201d22:	6585                	lui	a1,0x1
ffffffffc0201d24:	979ff0ef          	jal	ra,ffffffffc020169c <get_pte>
ffffffffc0201d28:	5e050963          	beqz	a0,ffffffffc020231a <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d2c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d2e:	00177793          	andi	a5,a4,1
ffffffffc0201d32:	50078563          	beqz	a5,ffffffffc020223c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d36:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d38:	00271793          	slli	a5,a4,0x2
ffffffffc0201d3c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d3e:	48d7f563          	bgeu	a5,a3,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d42:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d46:	97b6                	add	a5,a5,a3
ffffffffc0201d48:	000b3603          	ld	a2,0(s6)
ffffffffc0201d4c:	00379693          	slli	a3,a5,0x3
ffffffffc0201d50:	97b6                	add	a5,a5,a3
ffffffffc0201d52:	078e                	slli	a5,a5,0x3
ffffffffc0201d54:	97b2                	add	a5,a5,a2
ffffffffc0201d56:	72fa1263          	bne	s4,a5,ffffffffc020247a <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201d5a:	8b41                	andi	a4,a4,16
ffffffffc0201d5c:	6e071f63          	bnez	a4,ffffffffc020245a <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201d60:	00093503          	ld	a0,0(s2)
ffffffffc0201d64:	4581                	li	a1,0
ffffffffc0201d66:	b87ff0ef          	jal	ra,ffffffffc02018ec <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201d6a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d6e:	4785                	li	a5,1
ffffffffc0201d70:	6cf71563          	bne	a4,a5,ffffffffc020243a <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0201d74:	000aa783          	lw	a5,0(s5)
ffffffffc0201d78:	78079d63          	bnez	a5,ffffffffc0202512 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201d7c:	00093503          	ld	a0,0(s2)
ffffffffc0201d80:	6585                	lui	a1,0x1
ffffffffc0201d82:	b6bff0ef          	jal	ra,ffffffffc02018ec <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201d86:	000a2783          	lw	a5,0(s4)
ffffffffc0201d8a:	76079463          	bnez	a5,ffffffffc02024f2 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0201d8e:	000aa783          	lw	a5,0(s5)
ffffffffc0201d92:	74079063          	bnez	a5,ffffffffc02024d2 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201d96:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201d9a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201d9c:	000a3783          	ld	a5,0(s4)
ffffffffc0201da0:	078a                	slli	a5,a5,0x2
ffffffffc0201da2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201da4:	42c7f263          	bgeu	a5,a2,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201da8:	fff80737          	lui	a4,0xfff80
ffffffffc0201dac:	973e                	add	a4,a4,a5
ffffffffc0201dae:	00371793          	slli	a5,a4,0x3
ffffffffc0201db2:	000b3503          	ld	a0,0(s6)
ffffffffc0201db6:	97ba                	add	a5,a5,a4
ffffffffc0201db8:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201dba:	00f50733          	add	a4,a0,a5
ffffffffc0201dbe:	4314                	lw	a3,0(a4)
ffffffffc0201dc0:	4705                	li	a4,1
ffffffffc0201dc2:	6ee69863          	bne	a3,a4,ffffffffc02024b2 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201dc6:	4037d693          	srai	a3,a5,0x3
ffffffffc0201dca:	00004c97          	auipc	s9,0x4
ffffffffc0201dce:	196cbc83          	ld	s9,406(s9) # ffffffffc0205f60 <error_string+0x38>
ffffffffc0201dd2:	039686b3          	mul	a3,a3,s9
ffffffffc0201dd6:	000805b7          	lui	a1,0x80
ffffffffc0201dda:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ddc:	00c69713          	slli	a4,a3,0xc
ffffffffc0201de0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201de2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201de4:	6ac77b63          	bgeu	a4,a2,ffffffffc020249a <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201de8:	0009b703          	ld	a4,0(s3)
ffffffffc0201dec:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dee:	629c                	ld	a5,0(a3)
ffffffffc0201df0:	078a                	slli	a5,a5,0x2
ffffffffc0201df2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201df4:	3cc7fa63          	bgeu	a5,a2,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201df8:	8f8d                	sub	a5,a5,a1
ffffffffc0201dfa:	00379713          	slli	a4,a5,0x3
ffffffffc0201dfe:	97ba                	add	a5,a5,a4
ffffffffc0201e00:	078e                	slli	a5,a5,0x3
ffffffffc0201e02:	953e                	add	a0,a0,a5
ffffffffc0201e04:	100027f3          	csrr	a5,sstatus
ffffffffc0201e08:	8b89                	andi	a5,a5,2
ffffffffc0201e0a:	2e079963          	bnez	a5,ffffffffc02020fc <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e0e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e12:	4585                	li	a1,1
ffffffffc0201e14:	739c                	ld	a5,32(a5)
ffffffffc0201e16:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e18:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e1c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e1e:	078a                	slli	a5,a5,0x2
ffffffffc0201e20:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e22:	3ae7f363          	bgeu	a5,a4,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e26:	fff80737          	lui	a4,0xfff80
ffffffffc0201e2a:	97ba                	add	a5,a5,a4
ffffffffc0201e2c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e30:	00379713          	slli	a4,a5,0x3
ffffffffc0201e34:	97ba                	add	a5,a5,a4
ffffffffc0201e36:	078e                	slli	a5,a5,0x3
ffffffffc0201e38:	953e                	add	a0,a0,a5
ffffffffc0201e3a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e3e:	8b89                	andi	a5,a5,2
ffffffffc0201e40:	2a079263          	bnez	a5,ffffffffc02020e4 <pmm_init+0x65e>
ffffffffc0201e44:	000bb783          	ld	a5,0(s7)
ffffffffc0201e48:	4585                	li	a1,1
ffffffffc0201e4a:	739c                	ld	a5,32(a5)
ffffffffc0201e4c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201e4e:	00093783          	ld	a5,0(s2)
ffffffffc0201e52:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeeaac>
ffffffffc0201e56:	100027f3          	csrr	a5,sstatus
ffffffffc0201e5a:	8b89                	andi	a5,a5,2
ffffffffc0201e5c:	26079a63          	bnez	a5,ffffffffc02020d0 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201e60:	000bb783          	ld	a5,0(s7)
ffffffffc0201e64:	779c                	ld	a5,40(a5)
ffffffffc0201e66:	9782                	jalr	a5
ffffffffc0201e68:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201e6a:	73441463          	bne	s0,s4,ffffffffc0202592 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201e6e:	00003517          	auipc	a0,0x3
ffffffffc0201e72:	50a50513          	addi	a0,a0,1290 # ffffffffc0205378 <default_pmm_manager+0x460>
ffffffffc0201e76:	a44fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201e7a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e7e:	8b89                	andi	a5,a5,2
ffffffffc0201e80:	22079e63          	bnez	a5,ffffffffc02020bc <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201e84:	000bb783          	ld	a5,0(s7)
ffffffffc0201e88:	779c                	ld	a5,40(a5)
ffffffffc0201e8a:	9782                	jalr	a5
ffffffffc0201e8c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201e8e:	6098                	ld	a4,0(s1)
ffffffffc0201e90:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201e94:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201e96:	00c71793          	slli	a5,a4,0xc
ffffffffc0201e9a:	6a05                	lui	s4,0x1
ffffffffc0201e9c:	02f47c63          	bgeu	s0,a5,ffffffffc0201ed4 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ea0:	00c45793          	srli	a5,s0,0xc
ffffffffc0201ea4:	00093503          	ld	a0,0(s2)
ffffffffc0201ea8:	30e7f363          	bgeu	a5,a4,ffffffffc02021ae <pmm_init+0x728>
ffffffffc0201eac:	0009b583          	ld	a1,0(s3)
ffffffffc0201eb0:	4601                	li	a2,0
ffffffffc0201eb2:	95a2                	add	a1,a1,s0
ffffffffc0201eb4:	fe8ff0ef          	jal	ra,ffffffffc020169c <get_pte>
ffffffffc0201eb8:	2c050b63          	beqz	a0,ffffffffc020218e <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ebc:	611c                	ld	a5,0(a0)
ffffffffc0201ebe:	078a                	slli	a5,a5,0x2
ffffffffc0201ec0:	0157f7b3          	and	a5,a5,s5
ffffffffc0201ec4:	2a879563          	bne	a5,s0,ffffffffc020216e <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ec8:	6098                	ld	a4,0(s1)
ffffffffc0201eca:	9452                	add	s0,s0,s4
ffffffffc0201ecc:	00c71793          	slli	a5,a4,0xc
ffffffffc0201ed0:	fcf468e3          	bltu	s0,a5,ffffffffc0201ea0 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201ed4:	00093783          	ld	a5,0(s2)
ffffffffc0201ed8:	639c                	ld	a5,0(a5)
ffffffffc0201eda:	68079c63          	bnez	a5,ffffffffc0202572 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201ede:	4505                	li	a0,1
ffffffffc0201ee0:	eb0ff0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0201ee4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201ee6:	00093503          	ld	a0,0(s2)
ffffffffc0201eea:	4699                	li	a3,6
ffffffffc0201eec:	10000613          	li	a2,256
ffffffffc0201ef0:	85d6                	mv	a1,s5
ffffffffc0201ef2:	a95ff0ef          	jal	ra,ffffffffc0201986 <page_insert>
ffffffffc0201ef6:	64051e63          	bnez	a0,ffffffffc0202552 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201efa:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeeaac>
ffffffffc0201efe:	4785                	li	a5,1
ffffffffc0201f00:	62f71963          	bne	a4,a5,ffffffffc0202532 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f04:	00093503          	ld	a0,0(s2)
ffffffffc0201f08:	6405                	lui	s0,0x1
ffffffffc0201f0a:	4699                	li	a3,6
ffffffffc0201f0c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f10:	85d6                	mv	a1,s5
ffffffffc0201f12:	a75ff0ef          	jal	ra,ffffffffc0201986 <page_insert>
ffffffffc0201f16:	48051263          	bnez	a0,ffffffffc020239a <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f1a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f1e:	4789                	li	a5,2
ffffffffc0201f20:	74f71563          	bne	a4,a5,ffffffffc020266a <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f24:	00003597          	auipc	a1,0x3
ffffffffc0201f28:	58c58593          	addi	a1,a1,1420 # ffffffffc02054b0 <default_pmm_manager+0x598>
ffffffffc0201f2c:	10000513          	li	a0,256
ffffffffc0201f30:	238020ef          	jal	ra,ffffffffc0204168 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f34:	10040593          	addi	a1,s0,256
ffffffffc0201f38:	10000513          	li	a0,256
ffffffffc0201f3c:	23e020ef          	jal	ra,ffffffffc020417a <strcmp>
ffffffffc0201f40:	70051563          	bnez	a0,ffffffffc020264a <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f44:	000b3683          	ld	a3,0(s6)
ffffffffc0201f48:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f4c:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f4e:	40da86b3          	sub	a3,s5,a3
ffffffffc0201f52:	868d                	srai	a3,a3,0x3
ffffffffc0201f54:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f58:	609c                	ld	a5,0(s1)
ffffffffc0201f5a:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f5c:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f5e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f62:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f64:	52f77b63          	bgeu	a4,a5,ffffffffc020249a <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f68:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f6c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f70:	96be                	add	a3,a3,a5
ffffffffc0201f72:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6fbac>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f76:	1bc020ef          	jal	ra,ffffffffc0204132 <strlen>
ffffffffc0201f7a:	6a051863          	bnez	a0,ffffffffc020262a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201f7e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201f82:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f84:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201f88:	078a                	slli	a5,a5,0x2
ffffffffc0201f8a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f8c:	22e7fe63          	bgeu	a5,a4,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f90:	41a787b3          	sub	a5,a5,s10
ffffffffc0201f94:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f98:	96be                	add	a3,a3,a5
ffffffffc0201f9a:	03968cb3          	mul	s9,a3,s9
ffffffffc0201f9e:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fa2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fa4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fa6:	4ee47a63          	bgeu	s0,a4,ffffffffc020249a <pmm_init+0xa14>
ffffffffc0201faa:	0009b403          	ld	s0,0(s3)
ffffffffc0201fae:	9436                	add	s0,s0,a3
ffffffffc0201fb0:	100027f3          	csrr	a5,sstatus
ffffffffc0201fb4:	8b89                	andi	a5,a5,2
ffffffffc0201fb6:	1a079163          	bnez	a5,ffffffffc0202158 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201fba:	000bb783          	ld	a5,0(s7)
ffffffffc0201fbe:	4585                	li	a1,1
ffffffffc0201fc0:	8556                	mv	a0,s5
ffffffffc0201fc2:	739c                	ld	a5,32(a5)
ffffffffc0201fc4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fc6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201fc8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fca:	078a                	slli	a5,a5,0x2
ffffffffc0201fcc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fce:	1ee7fd63          	bgeu	a5,a4,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fd2:	fff80737          	lui	a4,0xfff80
ffffffffc0201fd6:	97ba                	add	a5,a5,a4
ffffffffc0201fd8:	000b3503          	ld	a0,0(s6)
ffffffffc0201fdc:	00379713          	slli	a4,a5,0x3
ffffffffc0201fe0:	97ba                	add	a5,a5,a4
ffffffffc0201fe2:	078e                	slli	a5,a5,0x3
ffffffffc0201fe4:	953e                	add	a0,a0,a5
ffffffffc0201fe6:	100027f3          	csrr	a5,sstatus
ffffffffc0201fea:	8b89                	andi	a5,a5,2
ffffffffc0201fec:	14079a63          	bnez	a5,ffffffffc0202140 <pmm_init+0x6ba>
ffffffffc0201ff0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ff4:	4585                	li	a1,1
ffffffffc0201ff6:	739c                	ld	a5,32(a5)
ffffffffc0201ff8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ffa:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201ffe:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202000:	078a                	slli	a5,a5,0x2
ffffffffc0202002:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202004:	1ce7f263          	bgeu	a5,a4,ffffffffc02021c8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202008:	fff80737          	lui	a4,0xfff80
ffffffffc020200c:	97ba                	add	a5,a5,a4
ffffffffc020200e:	000b3503          	ld	a0,0(s6)
ffffffffc0202012:	00379713          	slli	a4,a5,0x3
ffffffffc0202016:	97ba                	add	a5,a5,a4
ffffffffc0202018:	078e                	slli	a5,a5,0x3
ffffffffc020201a:	953e                	add	a0,a0,a5
ffffffffc020201c:	100027f3          	csrr	a5,sstatus
ffffffffc0202020:	8b89                	andi	a5,a5,2
ffffffffc0202022:	10079363          	bnez	a5,ffffffffc0202128 <pmm_init+0x6a2>
ffffffffc0202026:	000bb783          	ld	a5,0(s7)
ffffffffc020202a:	4585                	li	a1,1
ffffffffc020202c:	739c                	ld	a5,32(a5)
ffffffffc020202e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202030:	00093783          	ld	a5,0(s2)
ffffffffc0202034:	0007b023          	sd	zero,0(a5)
ffffffffc0202038:	100027f3          	csrr	a5,sstatus
ffffffffc020203c:	8b89                	andi	a5,a5,2
ffffffffc020203e:	0c079b63          	bnez	a5,ffffffffc0202114 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202042:	000bb783          	ld	a5,0(s7)
ffffffffc0202046:	779c                	ld	a5,40(a5)
ffffffffc0202048:	9782                	jalr	a5
ffffffffc020204a:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020204c:	3a8c1763          	bne	s8,s0,ffffffffc02023fa <pmm_init+0x974>
}
ffffffffc0202050:	7406                	ld	s0,96(sp)
ffffffffc0202052:	70a6                	ld	ra,104(sp)
ffffffffc0202054:	64e6                	ld	s1,88(sp)
ffffffffc0202056:	6946                	ld	s2,80(sp)
ffffffffc0202058:	69a6                	ld	s3,72(sp)
ffffffffc020205a:	6a06                	ld	s4,64(sp)
ffffffffc020205c:	7ae2                	ld	s5,56(sp)
ffffffffc020205e:	7b42                	ld	s6,48(sp)
ffffffffc0202060:	7ba2                	ld	s7,40(sp)
ffffffffc0202062:	7c02                	ld	s8,32(sp)
ffffffffc0202064:	6ce2                	ld	s9,24(sp)
ffffffffc0202066:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202068:	00003517          	auipc	a0,0x3
ffffffffc020206c:	4c050513          	addi	a0,a0,1216 # ffffffffc0205528 <default_pmm_manager+0x610>
}
ffffffffc0202070:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202072:	848fe06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202076:	6705                	lui	a4,0x1
ffffffffc0202078:	177d                	addi	a4,a4,-1
ffffffffc020207a:	96ba                	add	a3,a3,a4
ffffffffc020207c:	777d                	lui	a4,0xfffff
ffffffffc020207e:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0202080:	00c75693          	srli	a3,a4,0xc
ffffffffc0202084:	14f6f263          	bgeu	a3,a5,ffffffffc02021c8 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc0202088:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020208c:	95b6                	add	a1,a1,a3
ffffffffc020208e:	00359793          	slli	a5,a1,0x3
ffffffffc0202092:	97ae                	add	a5,a5,a1
ffffffffc0202094:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202098:	40e60733          	sub	a4,a2,a4
ffffffffc020209c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020209e:	00c75593          	srli	a1,a4,0xc
ffffffffc02020a2:	953e                	add	a0,a0,a5
ffffffffc02020a4:	9682                	jalr	a3
}
ffffffffc02020a6:	bcc5                	j	ffffffffc0201b96 <pmm_init+0x110>
        intr_disable();
ffffffffc02020a8:	c22fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020ac:	000bb783          	ld	a5,0(s7)
ffffffffc02020b0:	779c                	ld	a5,40(a5)
ffffffffc02020b2:	9782                	jalr	a5
ffffffffc02020b4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02020b6:	c0efe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc02020ba:	b63d                	j	ffffffffc0201be8 <pmm_init+0x162>
        intr_disable();
ffffffffc02020bc:	c0efe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc02020c0:	000bb783          	ld	a5,0(s7)
ffffffffc02020c4:	779c                	ld	a5,40(a5)
ffffffffc02020c6:	9782                	jalr	a5
ffffffffc02020c8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02020ca:	bfafe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc02020ce:	b3c1                	j	ffffffffc0201e8e <pmm_init+0x408>
        intr_disable();
ffffffffc02020d0:	bfafe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc02020d4:	000bb783          	ld	a5,0(s7)
ffffffffc02020d8:	779c                	ld	a5,40(a5)
ffffffffc02020da:	9782                	jalr	a5
ffffffffc02020dc:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02020de:	be6fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc02020e2:	b361                	j	ffffffffc0201e6a <pmm_init+0x3e4>
ffffffffc02020e4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020e6:	be4fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02020ea:	000bb783          	ld	a5,0(s7)
ffffffffc02020ee:	6522                	ld	a0,8(sp)
ffffffffc02020f0:	4585                	li	a1,1
ffffffffc02020f2:	739c                	ld	a5,32(a5)
ffffffffc02020f4:	9782                	jalr	a5
        intr_enable();
ffffffffc02020f6:	bcefe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc02020fa:	bb91                	j	ffffffffc0201e4e <pmm_init+0x3c8>
ffffffffc02020fc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020fe:	bccfe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0202102:	000bb783          	ld	a5,0(s7)
ffffffffc0202106:	6522                	ld	a0,8(sp)
ffffffffc0202108:	4585                	li	a1,1
ffffffffc020210a:	739c                	ld	a5,32(a5)
ffffffffc020210c:	9782                	jalr	a5
        intr_enable();
ffffffffc020210e:	bb6fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0202112:	b319                	j	ffffffffc0201e18 <pmm_init+0x392>
        intr_disable();
ffffffffc0202114:	bb6fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202118:	000bb783          	ld	a5,0(s7)
ffffffffc020211c:	779c                	ld	a5,40(a5)
ffffffffc020211e:	9782                	jalr	a5
ffffffffc0202120:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202122:	ba2fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0202126:	b71d                	j	ffffffffc020204c <pmm_init+0x5c6>
ffffffffc0202128:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020212a:	ba0fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020212e:	000bb783          	ld	a5,0(s7)
ffffffffc0202132:	6522                	ld	a0,8(sp)
ffffffffc0202134:	4585                	li	a1,1
ffffffffc0202136:	739c                	ld	a5,32(a5)
ffffffffc0202138:	9782                	jalr	a5
        intr_enable();
ffffffffc020213a:	b8afe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc020213e:	bdcd                	j	ffffffffc0202030 <pmm_init+0x5aa>
ffffffffc0202140:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202142:	b88fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0202146:	000bb783          	ld	a5,0(s7)
ffffffffc020214a:	6522                	ld	a0,8(sp)
ffffffffc020214c:	4585                	li	a1,1
ffffffffc020214e:	739c                	ld	a5,32(a5)
ffffffffc0202150:	9782                	jalr	a5
        intr_enable();
ffffffffc0202152:	b72fe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0202156:	b555                	j	ffffffffc0201ffa <pmm_init+0x574>
        intr_disable();
ffffffffc0202158:	b72fe0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc020215c:	000bb783          	ld	a5,0(s7)
ffffffffc0202160:	4585                	li	a1,1
ffffffffc0202162:	8556                	mv	a0,s5
ffffffffc0202164:	739c                	ld	a5,32(a5)
ffffffffc0202166:	9782                	jalr	a5
        intr_enable();
ffffffffc0202168:	b5cfe0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc020216c:	bda9                	j	ffffffffc0201fc6 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020216e:	00003697          	auipc	a3,0x3
ffffffffc0202172:	26a68693          	addi	a3,a3,618 # ffffffffc02053d8 <default_pmm_manager+0x4c0>
ffffffffc0202176:	00003617          	auipc	a2,0x3
ffffffffc020217a:	9f260613          	addi	a2,a2,-1550 # ffffffffc0204b68 <commands+0x738>
ffffffffc020217e:	1ce00593          	li	a1,462
ffffffffc0202182:	00003517          	auipc	a0,0x3
ffffffffc0202186:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020218a:	9eafe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020218e:	00003697          	auipc	a3,0x3
ffffffffc0202192:	20a68693          	addi	a3,a3,522 # ffffffffc0205398 <default_pmm_manager+0x480>
ffffffffc0202196:	00003617          	auipc	a2,0x3
ffffffffc020219a:	9d260613          	addi	a2,a2,-1582 # ffffffffc0204b68 <commands+0x738>
ffffffffc020219e:	1cd00593          	li	a1,461
ffffffffc02021a2:	00003517          	auipc	a0,0x3
ffffffffc02021a6:	e2e50513          	addi	a0,a0,-466 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02021aa:	9cafe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02021ae:	86a2                	mv	a3,s0
ffffffffc02021b0:	00003617          	auipc	a2,0x3
ffffffffc02021b4:	df860613          	addi	a2,a2,-520 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc02021b8:	1cd00593          	li	a1,461
ffffffffc02021bc:	00003517          	auipc	a0,0x3
ffffffffc02021c0:	e1450513          	addi	a0,a0,-492 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02021c4:	9b0fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02021c8:	b90ff0ef          	jal	ra,ffffffffc0201558 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021cc:	00003617          	auipc	a2,0x3
ffffffffc02021d0:	e9c60613          	addi	a2,a2,-356 # ffffffffc0205068 <default_pmm_manager+0x150>
ffffffffc02021d4:	07700593          	li	a1,119
ffffffffc02021d8:	00003517          	auipc	a0,0x3
ffffffffc02021dc:	df850513          	addi	a0,a0,-520 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02021e0:	994fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02021e4:	00003617          	auipc	a2,0x3
ffffffffc02021e8:	e8460613          	addi	a2,a2,-380 # ffffffffc0205068 <default_pmm_manager+0x150>
ffffffffc02021ec:	0bd00593          	li	a1,189
ffffffffc02021f0:	00003517          	auipc	a0,0x3
ffffffffc02021f4:	de050513          	addi	a0,a0,-544 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02021f8:	97cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02021fc:	00003697          	auipc	a3,0x3
ffffffffc0202200:	ed468693          	addi	a3,a3,-300 # ffffffffc02050d0 <default_pmm_manager+0x1b8>
ffffffffc0202204:	00003617          	auipc	a2,0x3
ffffffffc0202208:	96460613          	addi	a2,a2,-1692 # ffffffffc0204b68 <commands+0x738>
ffffffffc020220c:	19300593          	li	a1,403
ffffffffc0202210:	00003517          	auipc	a0,0x3
ffffffffc0202214:	dc050513          	addi	a0,a0,-576 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202218:	95cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020221c:	00003697          	auipc	a3,0x3
ffffffffc0202220:	e9468693          	addi	a3,a3,-364 # ffffffffc02050b0 <default_pmm_manager+0x198>
ffffffffc0202224:	00003617          	auipc	a2,0x3
ffffffffc0202228:	94460613          	addi	a2,a2,-1724 # ffffffffc0204b68 <commands+0x738>
ffffffffc020222c:	19200593          	li	a1,402
ffffffffc0202230:	00003517          	auipc	a0,0x3
ffffffffc0202234:	da050513          	addi	a0,a0,-608 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202238:	93cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020223c:	b38ff0ef          	jal	ra,ffffffffc0201574 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202240:	00003697          	auipc	a3,0x3
ffffffffc0202244:	f2068693          	addi	a3,a3,-224 # ffffffffc0205160 <default_pmm_manager+0x248>
ffffffffc0202248:	00003617          	auipc	a2,0x3
ffffffffc020224c:	92060613          	addi	a2,a2,-1760 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202250:	19a00593          	li	a1,410
ffffffffc0202254:	00003517          	auipc	a0,0x3
ffffffffc0202258:	d7c50513          	addi	a0,a0,-644 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020225c:	918fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202260:	00003697          	auipc	a3,0x3
ffffffffc0202264:	ed068693          	addi	a3,a3,-304 # ffffffffc0205130 <default_pmm_manager+0x218>
ffffffffc0202268:	00003617          	auipc	a2,0x3
ffffffffc020226c:	90060613          	addi	a2,a2,-1792 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202270:	19800593          	li	a1,408
ffffffffc0202274:	00003517          	auipc	a0,0x3
ffffffffc0202278:	d5c50513          	addi	a0,a0,-676 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020227c:	8f8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202280:	00003697          	auipc	a3,0x3
ffffffffc0202284:	e8868693          	addi	a3,a3,-376 # ffffffffc0205108 <default_pmm_manager+0x1f0>
ffffffffc0202288:	00003617          	auipc	a2,0x3
ffffffffc020228c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202290:	19400593          	li	a1,404
ffffffffc0202294:	00003517          	auipc	a0,0x3
ffffffffc0202298:	d3c50513          	addi	a0,a0,-708 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020229c:	8d8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	f4868693          	addi	a3,a3,-184 # ffffffffc02051e8 <default_pmm_manager+0x2d0>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204b68 <commands+0x738>
ffffffffc02022b0:	1a300593          	li	a1,419
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	d1c50513          	addi	a0,a0,-740 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02022bc:	8b8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	fc868693          	addi	a3,a3,-56 # ffffffffc0205288 <default_pmm_manager+0x370>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204b68 <commands+0x738>
ffffffffc02022d0:	1a800593          	li	a1,424
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	cfc50513          	addi	a0,a0,-772 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02022dc:	898fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	ee068693          	addi	a3,a3,-288 # ffffffffc02051c0 <default_pmm_manager+0x2a8>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	88060613          	addi	a2,a2,-1920 # ffffffffc0204b68 <commands+0x738>
ffffffffc02022f0:	1a000593          	li	a1,416
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	cdc50513          	addi	a0,a0,-804 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02022fc:	878fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202300:	86d6                	mv	a3,s5
ffffffffc0202302:	00003617          	auipc	a2,0x3
ffffffffc0202306:	ca660613          	addi	a2,a2,-858 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc020230a:	19f00593          	li	a1,415
ffffffffc020230e:	00003517          	auipc	a0,0x3
ffffffffc0202312:	cc250513          	addi	a0,a0,-830 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202316:	85efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020231a:	00003697          	auipc	a3,0x3
ffffffffc020231e:	f0668693          	addi	a3,a3,-250 # ffffffffc0205220 <default_pmm_manager+0x308>
ffffffffc0202322:	00003617          	auipc	a2,0x3
ffffffffc0202326:	84660613          	addi	a2,a2,-1978 # ffffffffc0204b68 <commands+0x738>
ffffffffc020232a:	1ad00593          	li	a1,429
ffffffffc020232e:	00003517          	auipc	a0,0x3
ffffffffc0202332:	ca250513          	addi	a0,a0,-862 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202336:	83efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020233a:	00003697          	auipc	a3,0x3
ffffffffc020233e:	fae68693          	addi	a3,a3,-82 # ffffffffc02052e8 <default_pmm_manager+0x3d0>
ffffffffc0202342:	00003617          	auipc	a2,0x3
ffffffffc0202346:	82660613          	addi	a2,a2,-2010 # ffffffffc0204b68 <commands+0x738>
ffffffffc020234a:	1ac00593          	li	a1,428
ffffffffc020234e:	00003517          	auipc	a0,0x3
ffffffffc0202352:	c8250513          	addi	a0,a0,-894 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202356:	81efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020235a:	00003697          	auipc	a3,0x3
ffffffffc020235e:	f7668693          	addi	a3,a3,-138 # ffffffffc02052d0 <default_pmm_manager+0x3b8>
ffffffffc0202362:	00003617          	auipc	a2,0x3
ffffffffc0202366:	80660613          	addi	a2,a2,-2042 # ffffffffc0204b68 <commands+0x738>
ffffffffc020236a:	1ab00593          	li	a1,427
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	c6250513          	addi	a0,a0,-926 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202376:	ffffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	f2668693          	addi	a3,a3,-218 # ffffffffc02052a0 <default_pmm_manager+0x388>
ffffffffc0202382:	00002617          	auipc	a2,0x2
ffffffffc0202386:	7e660613          	addi	a2,a2,2022 # ffffffffc0204b68 <commands+0x738>
ffffffffc020238a:	1aa00593          	li	a1,426
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	c4250513          	addi	a0,a0,-958 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202396:	fdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	0be68693          	addi	a3,a3,190 # ffffffffc0205458 <default_pmm_manager+0x540>
ffffffffc02023a2:	00002617          	auipc	a2,0x2
ffffffffc02023a6:	7c660613          	addi	a2,a2,1990 # ffffffffc0204b68 <commands+0x738>
ffffffffc02023aa:	1d800593          	li	a1,472
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	c2250513          	addi	a0,a0,-990 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02023b6:	fbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	eb668693          	addi	a3,a3,-330 # ffffffffc0205270 <default_pmm_manager+0x358>
ffffffffc02023c2:	00002617          	auipc	a2,0x2
ffffffffc02023c6:	7a660613          	addi	a2,a2,1958 # ffffffffc0204b68 <commands+0x738>
ffffffffc02023ca:	1a700593          	li	a1,423
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	c0250513          	addi	a0,a0,-1022 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02023d6:	f9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	e8668693          	addi	a3,a3,-378 # ffffffffc0205260 <default_pmm_manager+0x348>
ffffffffc02023e2:	00002617          	auipc	a2,0x2
ffffffffc02023e6:	78660613          	addi	a2,a2,1926 # ffffffffc0204b68 <commands+0x738>
ffffffffc02023ea:	1a600593          	li	a1,422
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	be250513          	addi	a0,a0,-1054 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02023f6:	f7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	f5e68693          	addi	a3,a3,-162 # ffffffffc0205358 <default_pmm_manager+0x440>
ffffffffc0202402:	00002617          	auipc	a2,0x2
ffffffffc0202406:	76660613          	addi	a2,a2,1894 # ffffffffc0204b68 <commands+0x738>
ffffffffc020240a:	1e800593          	li	a1,488
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	bc250513          	addi	a0,a0,-1086 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202416:	f5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	e3668693          	addi	a3,a3,-458 # ffffffffc0205250 <default_pmm_manager+0x338>
ffffffffc0202422:	00002617          	auipc	a2,0x2
ffffffffc0202426:	74660613          	addi	a2,a2,1862 # ffffffffc0204b68 <commands+0x738>
ffffffffc020242a:	1a500593          	li	a1,421
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	ba250513          	addi	a0,a0,-1118 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202436:	f3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	d6e68693          	addi	a3,a3,-658 # ffffffffc02051a8 <default_pmm_manager+0x290>
ffffffffc0202442:	00002617          	auipc	a2,0x2
ffffffffc0202446:	72660613          	addi	a2,a2,1830 # ffffffffc0204b68 <commands+0x738>
ffffffffc020244a:	1b200593          	li	a1,434
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	b8250513          	addi	a0,a0,-1150 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202456:	f1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	ea668693          	addi	a3,a3,-346 # ffffffffc0205300 <default_pmm_manager+0x3e8>
ffffffffc0202462:	00002617          	auipc	a2,0x2
ffffffffc0202466:	70660613          	addi	a2,a2,1798 # ffffffffc0204b68 <commands+0x738>
ffffffffc020246a:	1af00593          	li	a1,431
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	b6250513          	addi	a0,a0,-1182 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202476:	efffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	d1668693          	addi	a3,a3,-746 # ffffffffc0205190 <default_pmm_manager+0x278>
ffffffffc0202482:	00002617          	auipc	a2,0x2
ffffffffc0202486:	6e660613          	addi	a2,a2,1766 # ffffffffc0204b68 <commands+0x738>
ffffffffc020248a:	1ae00593          	li	a1,430
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	b4250513          	addi	a0,a0,-1214 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202496:	edffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020249a:	00003617          	auipc	a2,0x3
ffffffffc020249e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc02024a2:	06a00593          	li	a1,106
ffffffffc02024a6:	00003517          	auipc	a0,0x3
ffffffffc02024aa:	aca50513          	addi	a0,a0,-1334 # ffffffffc0204f70 <default_pmm_manager+0x58>
ffffffffc02024ae:	ec7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024b2:	00003697          	auipc	a3,0x3
ffffffffc02024b6:	e7e68693          	addi	a3,a3,-386 # ffffffffc0205330 <default_pmm_manager+0x418>
ffffffffc02024ba:	00002617          	auipc	a2,0x2
ffffffffc02024be:	6ae60613          	addi	a2,a2,1710 # ffffffffc0204b68 <commands+0x738>
ffffffffc02024c2:	1b900593          	li	a1,441
ffffffffc02024c6:	00003517          	auipc	a0,0x3
ffffffffc02024ca:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02024ce:	ea7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024d2:	00003697          	auipc	a3,0x3
ffffffffc02024d6:	e1668693          	addi	a3,a3,-490 # ffffffffc02052e8 <default_pmm_manager+0x3d0>
ffffffffc02024da:	00002617          	auipc	a2,0x2
ffffffffc02024de:	68e60613          	addi	a2,a2,1678 # ffffffffc0204b68 <commands+0x738>
ffffffffc02024e2:	1b700593          	li	a1,439
ffffffffc02024e6:	00003517          	auipc	a0,0x3
ffffffffc02024ea:	aea50513          	addi	a0,a0,-1302 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02024ee:	e87fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02024f2:	00003697          	auipc	a3,0x3
ffffffffc02024f6:	e2668693          	addi	a3,a3,-474 # ffffffffc0205318 <default_pmm_manager+0x400>
ffffffffc02024fa:	00002617          	auipc	a2,0x2
ffffffffc02024fe:	66e60613          	addi	a2,a2,1646 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202502:	1b600593          	li	a1,438
ffffffffc0202506:	00003517          	auipc	a0,0x3
ffffffffc020250a:	aca50513          	addi	a0,a0,-1334 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020250e:	e67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202512:	00003697          	auipc	a3,0x3
ffffffffc0202516:	dd668693          	addi	a3,a3,-554 # ffffffffc02052e8 <default_pmm_manager+0x3d0>
ffffffffc020251a:	00002617          	auipc	a2,0x2
ffffffffc020251e:	64e60613          	addi	a2,a2,1614 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202522:	1b300593          	li	a1,435
ffffffffc0202526:	00003517          	auipc	a0,0x3
ffffffffc020252a:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020252e:	e47fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202532:	00003697          	auipc	a3,0x3
ffffffffc0202536:	f0e68693          	addi	a3,a3,-242 # ffffffffc0205440 <default_pmm_manager+0x528>
ffffffffc020253a:	00002617          	auipc	a2,0x2
ffffffffc020253e:	62e60613          	addi	a2,a2,1582 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202542:	1d700593          	li	a1,471
ffffffffc0202546:	00003517          	auipc	a0,0x3
ffffffffc020254a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020254e:	e27fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202552:	00003697          	auipc	a3,0x3
ffffffffc0202556:	eb668693          	addi	a3,a3,-330 # ffffffffc0205408 <default_pmm_manager+0x4f0>
ffffffffc020255a:	00002617          	auipc	a2,0x2
ffffffffc020255e:	60e60613          	addi	a2,a2,1550 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202562:	1d600593          	li	a1,470
ffffffffc0202566:	00003517          	auipc	a0,0x3
ffffffffc020256a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020256e:	e07fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202572:	00003697          	auipc	a3,0x3
ffffffffc0202576:	e7e68693          	addi	a3,a3,-386 # ffffffffc02053f0 <default_pmm_manager+0x4d8>
ffffffffc020257a:	00002617          	auipc	a2,0x2
ffffffffc020257e:	5ee60613          	addi	a2,a2,1518 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202582:	1d200593          	li	a1,466
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020258e:	de7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202592:	00003697          	auipc	a3,0x3
ffffffffc0202596:	dc668693          	addi	a3,a3,-570 # ffffffffc0205358 <default_pmm_manager+0x440>
ffffffffc020259a:	00002617          	auipc	a2,0x2
ffffffffc020259e:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204b68 <commands+0x738>
ffffffffc02025a2:	1c000593          	li	a1,448
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02025ae:	dc7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	bde68693          	addi	a3,a3,-1058 # ffffffffc0205190 <default_pmm_manager+0x278>
ffffffffc02025ba:	00002617          	auipc	a2,0x2
ffffffffc02025be:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204b68 <commands+0x738>
ffffffffc02025c2:	19b00593          	li	a1,411
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02025ce:	da7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02025d2:	00003617          	auipc	a2,0x3
ffffffffc02025d6:	9d660613          	addi	a2,a2,-1578 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc02025da:	19e00593          	li	a1,414
ffffffffc02025de:	00003517          	auipc	a0,0x3
ffffffffc02025e2:	9f250513          	addi	a0,a0,-1550 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02025e6:	d8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02025ea:	00003697          	auipc	a3,0x3
ffffffffc02025ee:	bbe68693          	addi	a3,a3,-1090 # ffffffffc02051a8 <default_pmm_manager+0x290>
ffffffffc02025f2:	00002617          	auipc	a2,0x2
ffffffffc02025f6:	57660613          	addi	a2,a2,1398 # ffffffffc0204b68 <commands+0x738>
ffffffffc02025fa:	19c00593          	li	a1,412
ffffffffc02025fe:	00003517          	auipc	a0,0x3
ffffffffc0202602:	9d250513          	addi	a0,a0,-1582 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202606:	d6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020260a:	00003697          	auipc	a3,0x3
ffffffffc020260e:	c1668693          	addi	a3,a3,-1002 # ffffffffc0205220 <default_pmm_manager+0x308>
ffffffffc0202612:	00002617          	auipc	a2,0x2
ffffffffc0202616:	55660613          	addi	a2,a2,1366 # ffffffffc0204b68 <commands+0x738>
ffffffffc020261a:	1a400593          	li	a1,420
ffffffffc020261e:	00003517          	auipc	a0,0x3
ffffffffc0202622:	9b250513          	addi	a0,a0,-1614 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202626:	d4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020262a:	00003697          	auipc	a3,0x3
ffffffffc020262e:	ed668693          	addi	a3,a3,-298 # ffffffffc0205500 <default_pmm_manager+0x5e8>
ffffffffc0202632:	00002617          	auipc	a2,0x2
ffffffffc0202636:	53660613          	addi	a2,a2,1334 # ffffffffc0204b68 <commands+0x738>
ffffffffc020263a:	1e000593          	li	a1,480
ffffffffc020263e:	00003517          	auipc	a0,0x3
ffffffffc0202642:	99250513          	addi	a0,a0,-1646 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202646:	d2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020264a:	00003697          	auipc	a3,0x3
ffffffffc020264e:	e7e68693          	addi	a3,a3,-386 # ffffffffc02054c8 <default_pmm_manager+0x5b0>
ffffffffc0202652:	00002617          	auipc	a2,0x2
ffffffffc0202656:	51660613          	addi	a2,a2,1302 # ffffffffc0204b68 <commands+0x738>
ffffffffc020265a:	1dd00593          	li	a1,477
ffffffffc020265e:	00003517          	auipc	a0,0x3
ffffffffc0202662:	97250513          	addi	a0,a0,-1678 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202666:	d0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020266a:	00003697          	auipc	a3,0x3
ffffffffc020266e:	e2e68693          	addi	a3,a3,-466 # ffffffffc0205498 <default_pmm_manager+0x580>
ffffffffc0202672:	00002617          	auipc	a2,0x2
ffffffffc0202676:	4f660613          	addi	a2,a2,1270 # ffffffffc0204b68 <commands+0x738>
ffffffffc020267a:	1d900593          	li	a1,473
ffffffffc020267e:	00003517          	auipc	a0,0x3
ffffffffc0202682:	95250513          	addi	a0,a0,-1710 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc0202686:	ceffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020268a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc020268a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc020268e:	8082                	ret

ffffffffc0202690 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202690:	7179                	addi	sp,sp,-48
ffffffffc0202692:	e84a                	sd	s2,16(sp)
ffffffffc0202694:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202696:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202698:	f022                	sd	s0,32(sp)
ffffffffc020269a:	ec26                	sd	s1,24(sp)
ffffffffc020269c:	e44e                	sd	s3,8(sp)
ffffffffc020269e:	f406                	sd	ra,40(sp)
ffffffffc02026a0:	84ae                	mv	s1,a1
ffffffffc02026a2:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02026a4:	eedfe0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc02026a8:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02026aa:	cd09                	beqz	a0,ffffffffc02026c4 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02026ac:	85aa                	mv	a1,a0
ffffffffc02026ae:	86ce                	mv	a3,s3
ffffffffc02026b0:	8626                	mv	a2,s1
ffffffffc02026b2:	854a                	mv	a0,s2
ffffffffc02026b4:	ad2ff0ef          	jal	ra,ffffffffc0201986 <page_insert>
ffffffffc02026b8:	ed21                	bnez	a0,ffffffffc0202710 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc02026ba:	0000e797          	auipc	a5,0xe
ffffffffc02026be:	e867a783          	lw	a5,-378(a5) # ffffffffc0210540 <swap_init_ok>
ffffffffc02026c2:	eb89                	bnez	a5,ffffffffc02026d4 <pgdir_alloc_page+0x44>
}
ffffffffc02026c4:	70a2                	ld	ra,40(sp)
ffffffffc02026c6:	8522                	mv	a0,s0
ffffffffc02026c8:	7402                	ld	s0,32(sp)
ffffffffc02026ca:	64e2                	ld	s1,24(sp)
ffffffffc02026cc:	6942                	ld	s2,16(sp)
ffffffffc02026ce:	69a2                	ld	s3,8(sp)
ffffffffc02026d0:	6145                	addi	sp,sp,48
ffffffffc02026d2:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02026d4:	4681                	li	a3,0
ffffffffc02026d6:	8622                	mv	a2,s0
ffffffffc02026d8:	85a6                	mv	a1,s1
ffffffffc02026da:	0000e517          	auipc	a0,0xe
ffffffffc02026de:	e6e53503          	ld	a0,-402(a0) # ffffffffc0210548 <check_mm_struct>
ffffffffc02026e2:	07f000ef          	jal	ra,ffffffffc0202f60 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02026e6:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02026e8:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02026ea:	4785                	li	a5,1
ffffffffc02026ec:	fcf70ce3          	beq	a4,a5,ffffffffc02026c4 <pgdir_alloc_page+0x34>
ffffffffc02026f0:	00003697          	auipc	a3,0x3
ffffffffc02026f4:	e5868693          	addi	a3,a3,-424 # ffffffffc0205548 <default_pmm_manager+0x630>
ffffffffc02026f8:	00002617          	auipc	a2,0x2
ffffffffc02026fc:	47060613          	addi	a2,a2,1136 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202700:	17a00593          	li	a1,378
ffffffffc0202704:	00003517          	auipc	a0,0x3
ffffffffc0202708:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc020270c:	c69fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202710:	100027f3          	csrr	a5,sstatus
ffffffffc0202714:	8b89                	andi	a5,a5,2
ffffffffc0202716:	eb99                	bnez	a5,ffffffffc020272c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202718:	0000e797          	auipc	a5,0xe
ffffffffc020271c:	e087b783          	ld	a5,-504(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0202720:	739c                	ld	a5,32(a5)
ffffffffc0202722:	8522                	mv	a0,s0
ffffffffc0202724:	4585                	li	a1,1
ffffffffc0202726:	9782                	jalr	a5
            return NULL;
ffffffffc0202728:	4401                	li	s0,0
ffffffffc020272a:	bf69                	j	ffffffffc02026c4 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020272c:	d9ffd0ef          	jal	ra,ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202730:	0000e797          	auipc	a5,0xe
ffffffffc0202734:	df07b783          	ld	a5,-528(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc0202738:	739c                	ld	a5,32(a5)
ffffffffc020273a:	8522                	mv	a0,s0
ffffffffc020273c:	4585                	li	a1,1
ffffffffc020273e:	9782                	jalr	a5
            return NULL;
ffffffffc0202740:	4401                	li	s0,0
        intr_enable();
ffffffffc0202742:	d83fd0ef          	jal	ra,ffffffffc02004c4 <intr_enable>
ffffffffc0202746:	bfbd                	j	ffffffffc02026c4 <pgdir_alloc_page+0x34>

ffffffffc0202748 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0202748:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020274a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020274c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020274e:	fff50713          	addi	a4,a0,-1
ffffffffc0202752:	17f9                	addi	a5,a5,-2
ffffffffc0202754:	04e7ea63          	bltu	a5,a4,ffffffffc02027a8 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202758:	6785                	lui	a5,0x1
ffffffffc020275a:	17fd                	addi	a5,a5,-1
ffffffffc020275c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc020275e:	8131                	srli	a0,a0,0xc
ffffffffc0202760:	e31fe0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
    assert(base != NULL);
ffffffffc0202764:	cd3d                	beqz	a0,ffffffffc02027e2 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202766:	0000e797          	auipc	a5,0xe
ffffffffc020276a:	db27b783          	ld	a5,-590(a5) # ffffffffc0210518 <pages>
ffffffffc020276e:	8d1d                	sub	a0,a0,a5
ffffffffc0202770:	00003697          	auipc	a3,0x3
ffffffffc0202774:	7f06b683          	ld	a3,2032(a3) # ffffffffc0205f60 <error_string+0x38>
ffffffffc0202778:	850d                	srai	a0,a0,0x3
ffffffffc020277a:	02d50533          	mul	a0,a0,a3
ffffffffc020277e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202782:	0000e717          	auipc	a4,0xe
ffffffffc0202786:	d8e73703          	ld	a4,-626(a4) # ffffffffc0210510 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020278a:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020278c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202790:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202792:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202794:	02e7fa63          	bgeu	a5,a4,ffffffffc02027c8 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0202798:	60a2                	ld	ra,8(sp)
ffffffffc020279a:	0000e797          	auipc	a5,0xe
ffffffffc020279e:	d8e7b783          	ld	a5,-626(a5) # ffffffffc0210528 <va_pa_offset>
ffffffffc02027a2:	953e                	add	a0,a0,a5
ffffffffc02027a4:	0141                	addi	sp,sp,16
ffffffffc02027a6:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027a8:	00003697          	auipc	a3,0x3
ffffffffc02027ac:	db868693          	addi	a3,a3,-584 # ffffffffc0205560 <default_pmm_manager+0x648>
ffffffffc02027b0:	00002617          	auipc	a2,0x2
ffffffffc02027b4:	3b860613          	addi	a2,a2,952 # ffffffffc0204b68 <commands+0x738>
ffffffffc02027b8:	1f000593          	li	a1,496
ffffffffc02027bc:	00003517          	auipc	a0,0x3
ffffffffc02027c0:	81450513          	addi	a0,a0,-2028 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02027c4:	bb1fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027c8:	86aa                	mv	a3,a0
ffffffffc02027ca:	00002617          	auipc	a2,0x2
ffffffffc02027ce:	7de60613          	addi	a2,a2,2014 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc02027d2:	06a00593          	li	a1,106
ffffffffc02027d6:	00002517          	auipc	a0,0x2
ffffffffc02027da:	79a50513          	addi	a0,a0,1946 # ffffffffc0204f70 <default_pmm_manager+0x58>
ffffffffc02027de:	b97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc02027e2:	00003697          	auipc	a3,0x3
ffffffffc02027e6:	d9e68693          	addi	a3,a3,-610 # ffffffffc0205580 <default_pmm_manager+0x668>
ffffffffc02027ea:	00002617          	auipc	a2,0x2
ffffffffc02027ee:	37e60613          	addi	a2,a2,894 # ffffffffc0204b68 <commands+0x738>
ffffffffc02027f2:	1f300593          	li	a1,499
ffffffffc02027f6:	00002517          	auipc	a0,0x2
ffffffffc02027fa:	7da50513          	addi	a0,a0,2010 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02027fe:	b77fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202802 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202802:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202804:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202806:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202808:	fff58713          	addi	a4,a1,-1
ffffffffc020280c:	17f9                	addi	a5,a5,-2
ffffffffc020280e:	0ae7ee63          	bltu	a5,a4,ffffffffc02028ca <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202812:	cd41                	beqz	a0,ffffffffc02028aa <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202814:	6785                	lui	a5,0x1
ffffffffc0202816:	17fd                	addi	a5,a5,-1
ffffffffc0202818:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020281a:	c02007b7          	lui	a5,0xc0200
ffffffffc020281e:	81b1                	srli	a1,a1,0xc
ffffffffc0202820:	06f56863          	bltu	a0,a5,ffffffffc0202890 <kfree+0x8e>
ffffffffc0202824:	0000e697          	auipc	a3,0xe
ffffffffc0202828:	d046b683          	ld	a3,-764(a3) # ffffffffc0210528 <va_pa_offset>
ffffffffc020282c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020282e:	8131                	srli	a0,a0,0xc
ffffffffc0202830:	0000e797          	auipc	a5,0xe
ffffffffc0202834:	ce07b783          	ld	a5,-800(a5) # ffffffffc0210510 <npage>
ffffffffc0202838:	04f57a63          	bgeu	a0,a5,ffffffffc020288c <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020283c:	fff806b7          	lui	a3,0xfff80
ffffffffc0202840:	9536                	add	a0,a0,a3
ffffffffc0202842:	00351793          	slli	a5,a0,0x3
ffffffffc0202846:	953e                	add	a0,a0,a5
ffffffffc0202848:	050e                	slli	a0,a0,0x3
ffffffffc020284a:	0000e797          	auipc	a5,0xe
ffffffffc020284e:	cce7b783          	ld	a5,-818(a5) # ffffffffc0210518 <pages>
ffffffffc0202852:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202854:	100027f3          	csrr	a5,sstatus
ffffffffc0202858:	8b89                	andi	a5,a5,2
ffffffffc020285a:	eb89                	bnez	a5,ffffffffc020286c <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc020285c:	0000e797          	auipc	a5,0xe
ffffffffc0202860:	cc47b783          	ld	a5,-828(a5) # ffffffffc0210520 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202864:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0202866:	739c                	ld	a5,32(a5)
}
ffffffffc0202868:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc020286a:	8782                	jr	a5
        intr_disable();
ffffffffc020286c:	e42a                	sd	a0,8(sp)
ffffffffc020286e:	e02e                	sd	a1,0(sp)
ffffffffc0202870:	c5bfd0ef          	jal	ra,ffffffffc02004ca <intr_disable>
ffffffffc0202874:	0000e797          	auipc	a5,0xe
ffffffffc0202878:	cac7b783          	ld	a5,-852(a5) # ffffffffc0210520 <pmm_manager>
ffffffffc020287c:	6582                	ld	a1,0(sp)
ffffffffc020287e:	6522                	ld	a0,8(sp)
ffffffffc0202880:	739c                	ld	a5,32(a5)
ffffffffc0202882:	9782                	jalr	a5
}
ffffffffc0202884:	60e2                	ld	ra,24(sp)
ffffffffc0202886:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202888:	c3dfd06f          	j	ffffffffc02004c4 <intr_enable>
ffffffffc020288c:	ccdfe0ef          	jal	ra,ffffffffc0201558 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202890:	86aa                	mv	a3,a0
ffffffffc0202892:	00002617          	auipc	a2,0x2
ffffffffc0202896:	7d660613          	addi	a2,a2,2006 # ffffffffc0205068 <default_pmm_manager+0x150>
ffffffffc020289a:	06c00593          	li	a1,108
ffffffffc020289e:	00002517          	auipc	a0,0x2
ffffffffc02028a2:	6d250513          	addi	a0,a0,1746 # ffffffffc0204f70 <default_pmm_manager+0x58>
ffffffffc02028a6:	acffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc02028aa:	00003697          	auipc	a3,0x3
ffffffffc02028ae:	ce668693          	addi	a3,a3,-794 # ffffffffc0205590 <default_pmm_manager+0x678>
ffffffffc02028b2:	00002617          	auipc	a2,0x2
ffffffffc02028b6:	2b660613          	addi	a2,a2,694 # ffffffffc0204b68 <commands+0x738>
ffffffffc02028ba:	1fa00593          	li	a1,506
ffffffffc02028be:	00002517          	auipc	a0,0x2
ffffffffc02028c2:	71250513          	addi	a0,a0,1810 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02028c6:	aaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028ca:	00003697          	auipc	a3,0x3
ffffffffc02028ce:	c9668693          	addi	a3,a3,-874 # ffffffffc0205560 <default_pmm_manager+0x648>
ffffffffc02028d2:	00002617          	auipc	a2,0x2
ffffffffc02028d6:	29660613          	addi	a2,a2,662 # ffffffffc0204b68 <commands+0x738>
ffffffffc02028da:	1f900593          	li	a1,505
ffffffffc02028de:	00002517          	auipc	a0,0x2
ffffffffc02028e2:	6f250513          	addi	a0,a0,1778 # ffffffffc0204fd0 <default_pmm_manager+0xb8>
ffffffffc02028e6:	a8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02028ea <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02028ea:	7135                	addi	sp,sp,-160
ffffffffc02028ec:	ed06                	sd	ra,152(sp)
ffffffffc02028ee:	e922                	sd	s0,144(sp)
ffffffffc02028f0:	e526                	sd	s1,136(sp)
ffffffffc02028f2:	e14a                	sd	s2,128(sp)
ffffffffc02028f4:	fcce                	sd	s3,120(sp)
ffffffffc02028f6:	f8d2                	sd	s4,112(sp)
ffffffffc02028f8:	f4d6                	sd	s5,104(sp)
ffffffffc02028fa:	f0da                	sd	s6,96(sp)
ffffffffc02028fc:	ecde                	sd	s7,88(sp)
ffffffffc02028fe:	e8e2                	sd	s8,80(sp)
ffffffffc0202900:	e4e6                	sd	s9,72(sp)
ffffffffc0202902:	e0ea                	sd	s10,64(sp)
ffffffffc0202904:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202906:	2b8010ef          	jal	ra,ffffffffc0203bbe <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020290a:	0000e697          	auipc	a3,0xe
ffffffffc020290e:	c266b683          	ld	a3,-986(a3) # ffffffffc0210530 <max_swap_offset>
ffffffffc0202912:	010007b7          	lui	a5,0x1000
ffffffffc0202916:	ff968713          	addi	a4,a3,-7
ffffffffc020291a:	17e1                	addi	a5,a5,-8
ffffffffc020291c:	3ee7e063          	bltu	a5,a4,ffffffffc0202cfc <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202920:	00006797          	auipc	a5,0x6
ffffffffc0202924:	6e078793          	addi	a5,a5,1760 # ffffffffc0209000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0202928:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020292a:	0000eb17          	auipc	s6,0xe
ffffffffc020292e:	c0eb0b13          	addi	s6,s6,-1010 # ffffffffc0210538 <sm>
ffffffffc0202932:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202936:	9702                	jalr	a4
ffffffffc0202938:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc020293a:	c10d                	beqz	a0,ffffffffc020295c <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020293c:	60ea                	ld	ra,152(sp)
ffffffffc020293e:	644a                	ld	s0,144(sp)
ffffffffc0202940:	64aa                	ld	s1,136(sp)
ffffffffc0202942:	690a                	ld	s2,128(sp)
ffffffffc0202944:	7a46                	ld	s4,112(sp)
ffffffffc0202946:	7aa6                	ld	s5,104(sp)
ffffffffc0202948:	7b06                	ld	s6,96(sp)
ffffffffc020294a:	6be6                	ld	s7,88(sp)
ffffffffc020294c:	6c46                	ld	s8,80(sp)
ffffffffc020294e:	6ca6                	ld	s9,72(sp)
ffffffffc0202950:	6d06                	ld	s10,64(sp)
ffffffffc0202952:	7de2                	ld	s11,56(sp)
ffffffffc0202954:	854e                	mv	a0,s3
ffffffffc0202956:	79e6                	ld	s3,120(sp)
ffffffffc0202958:	610d                	addi	sp,sp,160
ffffffffc020295a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020295c:	000b3783          	ld	a5,0(s6)
ffffffffc0202960:	00003517          	auipc	a0,0x3
ffffffffc0202964:	c7050513          	addi	a0,a0,-912 # ffffffffc02055d0 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc0202968:	0000d497          	auipc	s1,0xd
ffffffffc020296c:	6d848493          	addi	s1,s1,1752 # ffffffffc0210040 <free_area>
ffffffffc0202970:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202972:	4785                	li	a5,1
ffffffffc0202974:	0000e717          	auipc	a4,0xe
ffffffffc0202978:	bcf72623          	sw	a5,-1076(a4) # ffffffffc0210540 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020297c:	f3efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202980:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202982:	4401                	li	s0,0
ffffffffc0202984:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202986:	2c978163          	beq	a5,s1,ffffffffc0202c48 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020298a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020298e:	8b09                	andi	a4,a4,2
ffffffffc0202990:	2a070e63          	beqz	a4,ffffffffc0202c4c <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0202994:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202998:	679c                	ld	a5,8(a5)
ffffffffc020299a:	2d05                	addiw	s10,s10,1
ffffffffc020299c:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020299e:	fe9796e3          	bne	a5,s1,ffffffffc020298a <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02029a2:	8922                	mv	s2,s0
ffffffffc02029a4:	cbffe0ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
ffffffffc02029a8:	47251663          	bne	a0,s2,ffffffffc0202e14 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02029ac:	8622                	mv	a2,s0
ffffffffc02029ae:	85ea                	mv	a1,s10
ffffffffc02029b0:	00003517          	auipc	a0,0x3
ffffffffc02029b4:	c3850513          	addi	a0,a0,-968 # ffffffffc02055e8 <default_pmm_manager+0x6d0>
ffffffffc02029b8:	f02fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02029bc:	1c5000ef          	jal	ra,ffffffffc0203380 <mm_create>
ffffffffc02029c0:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02029c2:	52050963          	beqz	a0,ffffffffc0202ef4 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02029c6:	0000e797          	auipc	a5,0xe
ffffffffc02029ca:	b8278793          	addi	a5,a5,-1150 # ffffffffc0210548 <check_mm_struct>
ffffffffc02029ce:	6398                	ld	a4,0(a5)
ffffffffc02029d0:	54071263          	bnez	a4,ffffffffc0202f14 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02029d4:	0000eb97          	auipc	s7,0xe
ffffffffc02029d8:	b34bbb83          	ld	s7,-1228(s7) # ffffffffc0210508 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc02029dc:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc02029e0:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02029e2:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02029e6:	3c071763          	bnez	a4,ffffffffc0202db4 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02029ea:	6599                	lui	a1,0x6
ffffffffc02029ec:	460d                	li	a2,3
ffffffffc02029ee:	6505                	lui	a0,0x1
ffffffffc02029f0:	1d9000ef          	jal	ra,ffffffffc02033c8 <vma_create>
ffffffffc02029f4:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02029f6:	3c050f63          	beqz	a0,ffffffffc0202dd4 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc02029fa:	8556                	mv	a0,s5
ffffffffc02029fc:	23b000ef          	jal	ra,ffffffffc0203436 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a00:	00003517          	auipc	a0,0x3
ffffffffc0202a04:	c5850513          	addi	a0,a0,-936 # ffffffffc0205658 <default_pmm_manager+0x740>
ffffffffc0202a08:	eb2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a0c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a10:	4605                	li	a2,1
ffffffffc0202a12:	6585                	lui	a1,0x1
ffffffffc0202a14:	c89fe0ef          	jal	ra,ffffffffc020169c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202a18:	3c050e63          	beqz	a0,ffffffffc0202df4 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a1c:	00003517          	auipc	a0,0x3
ffffffffc0202a20:	c8c50513          	addi	a0,a0,-884 # ffffffffc02056a8 <default_pmm_manager+0x790>
ffffffffc0202a24:	0000d917          	auipc	s2,0xd
ffffffffc0202a28:	65490913          	addi	s2,s2,1620 # ffffffffc0210078 <check_rp>
ffffffffc0202a2c:	e8efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a30:	0000da17          	auipc	s4,0xd
ffffffffc0202a34:	668a0a13          	addi	s4,s4,1640 # ffffffffc0210098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a38:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202a3a:	4505                	li	a0,1
ffffffffc0202a3c:	b55fe0ef          	jal	ra,ffffffffc0201590 <alloc_pages>
ffffffffc0202a40:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202a44:	28050c63          	beqz	a0,ffffffffc0202cdc <swap_init+0x3f2>
ffffffffc0202a48:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a4a:	8b89                	andi	a5,a5,2
ffffffffc0202a4c:	26079863          	bnez	a5,ffffffffc0202cbc <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a50:	0c21                	addi	s8,s8,8
ffffffffc0202a52:	ff4c14e3          	bne	s8,s4,ffffffffc0202a3a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202a56:	609c                	ld	a5,0(s1)
ffffffffc0202a58:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202a5c:	e084                	sd	s1,0(s1)
ffffffffc0202a5e:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202a60:	489c                	lw	a5,16(s1)
ffffffffc0202a62:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202a64:	0000dc17          	auipc	s8,0xd
ffffffffc0202a68:	614c0c13          	addi	s8,s8,1556 # ffffffffc0210078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202a6c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202a6e:	0000d797          	auipc	a5,0xd
ffffffffc0202a72:	5e07a123          	sw	zero,1506(a5) # ffffffffc0210050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202a76:	000c3503          	ld	a0,0(s8)
ffffffffc0202a7a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a7c:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202a7e:	ba5fe0ef          	jal	ra,ffffffffc0201622 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a82:	ff4c1ae3          	bne	s8,s4,ffffffffc0202a76 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a86:	0104ac03          	lw	s8,16(s1)
ffffffffc0202a8a:	4791                	li	a5,4
ffffffffc0202a8c:	4afc1463          	bne	s8,a5,ffffffffc0202f34 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a90:	00003517          	auipc	a0,0x3
ffffffffc0202a94:	ca050513          	addi	a0,a0,-864 # ffffffffc0205730 <default_pmm_manager+0x818>
ffffffffc0202a98:	e22fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a9c:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a9e:	0000e797          	auipc	a5,0xe
ffffffffc0202aa2:	aa07a923          	sw	zero,-1358(a5) # ffffffffc0210550 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202aa6:	4529                	li	a0,10
ffffffffc0202aa8:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202aac:	0000e597          	auipc	a1,0xe
ffffffffc0202ab0:	aa45a583          	lw	a1,-1372(a1) # ffffffffc0210550 <pgfault_num>
ffffffffc0202ab4:	4805                	li	a6,1
ffffffffc0202ab6:	0000e797          	auipc	a5,0xe
ffffffffc0202aba:	a9a78793          	addi	a5,a5,-1382 # ffffffffc0210550 <pgfault_num>
ffffffffc0202abe:	3f059b63          	bne	a1,a6,ffffffffc0202eb4 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202ac2:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0202ac6:	4390                	lw	a2,0(a5)
ffffffffc0202ac8:	2601                	sext.w	a2,a2
ffffffffc0202aca:	40b61563          	bne	a2,a1,ffffffffc0202ed4 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202ace:	6589                	lui	a1,0x2
ffffffffc0202ad0:	452d                	li	a0,11
ffffffffc0202ad2:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202ad6:	4390                	lw	a2,0(a5)
ffffffffc0202ad8:	4809                	li	a6,2
ffffffffc0202ada:	2601                	sext.w	a2,a2
ffffffffc0202adc:	35061c63          	bne	a2,a6,ffffffffc0202e34 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202ae0:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0202ae4:	438c                	lw	a1,0(a5)
ffffffffc0202ae6:	2581                	sext.w	a1,a1
ffffffffc0202ae8:	36c59663          	bne	a1,a2,ffffffffc0202e54 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202aec:	658d                	lui	a1,0x3
ffffffffc0202aee:	4531                	li	a0,12
ffffffffc0202af0:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202af4:	4390                	lw	a2,0(a5)
ffffffffc0202af6:	480d                	li	a6,3
ffffffffc0202af8:	2601                	sext.w	a2,a2
ffffffffc0202afa:	37061d63          	bne	a2,a6,ffffffffc0202e74 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202afe:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0202b02:	438c                	lw	a1,0(a5)
ffffffffc0202b04:	2581                	sext.w	a1,a1
ffffffffc0202b06:	38c59763          	bne	a1,a2,ffffffffc0202e94 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b0a:	6591                	lui	a1,0x4
ffffffffc0202b0c:	4535                	li	a0,13
ffffffffc0202b0e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202b12:	4390                	lw	a2,0(a5)
ffffffffc0202b14:	2601                	sext.w	a2,a2
ffffffffc0202b16:	21861f63          	bne	a2,s8,ffffffffc0202d34 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b1a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0202b1e:	439c                	lw	a5,0(a5)
ffffffffc0202b20:	2781                	sext.w	a5,a5
ffffffffc0202b22:	22c79963          	bne	a5,a2,ffffffffc0202d54 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202b26:	489c                	lw	a5,16(s1)
ffffffffc0202b28:	24079663          	bnez	a5,ffffffffc0202d74 <swap_init+0x48a>
ffffffffc0202b2c:	0000d797          	auipc	a5,0xd
ffffffffc0202b30:	56c78793          	addi	a5,a5,1388 # ffffffffc0210098 <swap_in_seq_no>
ffffffffc0202b34:	0000d617          	auipc	a2,0xd
ffffffffc0202b38:	58c60613          	addi	a2,a2,1420 # ffffffffc02100c0 <swap_out_seq_no>
ffffffffc0202b3c:	0000d517          	auipc	a0,0xd
ffffffffc0202b40:	58450513          	addi	a0,a0,1412 # ffffffffc02100c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202b44:	55fd                	li	a1,-1
ffffffffc0202b46:	c38c                	sw	a1,0(a5)
ffffffffc0202b48:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202b4a:	0791                	addi	a5,a5,4
ffffffffc0202b4c:	0611                	addi	a2,a2,4
ffffffffc0202b4e:	fef51ce3          	bne	a0,a5,ffffffffc0202b46 <swap_init+0x25c>
ffffffffc0202b52:	0000d817          	auipc	a6,0xd
ffffffffc0202b56:	50680813          	addi	a6,a6,1286 # ffffffffc0210058 <check_ptep>
ffffffffc0202b5a:	0000d897          	auipc	a7,0xd
ffffffffc0202b5e:	51e88893          	addi	a7,a7,1310 # ffffffffc0210078 <check_rp>
ffffffffc0202b62:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202b64:	0000ec97          	auipc	s9,0xe
ffffffffc0202b68:	9b4c8c93          	addi	s9,s9,-1612 # ffffffffc0210518 <pages>
ffffffffc0202b6c:	00003c17          	auipc	s8,0x3
ffffffffc0202b70:	3fcc0c13          	addi	s8,s8,1020 # ffffffffc0205f68 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202b74:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b78:	4601                	li	a2,0
ffffffffc0202b7a:	855e                	mv	a0,s7
ffffffffc0202b7c:	ec46                	sd	a7,24(sp)
ffffffffc0202b7e:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202b80:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b82:	b1bfe0ef          	jal	ra,ffffffffc020169c <get_pte>
ffffffffc0202b86:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b88:	65c2                	ld	a1,16(sp)
ffffffffc0202b8a:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b8c:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202b90:	0000e317          	auipc	t1,0xe
ffffffffc0202b94:	98030313          	addi	t1,t1,-1664 # ffffffffc0210510 <npage>
ffffffffc0202b98:	16050e63          	beqz	a0,ffffffffc0202d14 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b9c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b9e:	0017f613          	andi	a2,a5,1
ffffffffc0202ba2:	0e060563          	beqz	a2,ffffffffc0202c8c <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202ba6:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202baa:	078a                	slli	a5,a5,0x2
ffffffffc0202bac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bae:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202ca4 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bb2:	000c3603          	ld	a2,0(s8)
ffffffffc0202bb6:	000cb503          	ld	a0,0(s9)
ffffffffc0202bba:	0008bf03          	ld	t5,0(a7)
ffffffffc0202bbe:	8f91                	sub	a5,a5,a2
ffffffffc0202bc0:	00379613          	slli	a2,a5,0x3
ffffffffc0202bc4:	97b2                	add	a5,a5,a2
ffffffffc0202bc6:	078e                	slli	a5,a5,0x3
ffffffffc0202bc8:	97aa                	add	a5,a5,a0
ffffffffc0202bca:	0aff1163          	bne	t5,a5,ffffffffc0202c6c <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bce:	6785                	lui	a5,0x1
ffffffffc0202bd0:	95be                	add	a1,a1,a5
ffffffffc0202bd2:	6795                	lui	a5,0x5
ffffffffc0202bd4:	0821                	addi	a6,a6,8
ffffffffc0202bd6:	08a1                	addi	a7,a7,8
ffffffffc0202bd8:	f8f59ee3          	bne	a1,a5,ffffffffc0202b74 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202bdc:	00003517          	auipc	a0,0x3
ffffffffc0202be0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc02057d8 <default_pmm_manager+0x8c0>
ffffffffc0202be4:	cd6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202be8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bec:	7f9c                	ld	a5,56(a5)
ffffffffc0202bee:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202bf0:	1a051263          	bnez	a0,ffffffffc0202d94 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202bf4:	00093503          	ld	a0,0(s2)
ffffffffc0202bf8:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bfa:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202bfc:	a27fe0ef          	jal	ra,ffffffffc0201622 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c00:	ff491ae3          	bne	s2,s4,ffffffffc0202bf4 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202c04:	8556                	mv	a0,s5
ffffffffc0202c06:	101000ef          	jal	ra,ffffffffc0203506 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202c0a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c0c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c10:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c12:	7782                	ld	a5,32(sp)
ffffffffc0202c14:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c16:	009d8a63          	beq	s11,s1,ffffffffc0202c2a <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202c1a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c1e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c22:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c24:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c26:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c1a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202c2a:	8622                	mv	a2,s0
ffffffffc0202c2c:	85ea                	mv	a1,s10
ffffffffc0202c2e:	00003517          	auipc	a0,0x3
ffffffffc0202c32:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205808 <default_pmm_manager+0x8f0>
ffffffffc0202c36:	c84fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202c3a:	00003517          	auipc	a0,0x3
ffffffffc0202c3e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0205828 <default_pmm_manager+0x910>
ffffffffc0202c42:	c78fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202c46:	b9dd                	j	ffffffffc020293c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c48:	4901                	li	s2,0
ffffffffc0202c4a:	bba9                	j	ffffffffc02029a4 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202c4c:	00002697          	auipc	a3,0x2
ffffffffc0202c50:	f0c68693          	addi	a3,a3,-244 # ffffffffc0204b58 <commands+0x728>
ffffffffc0202c54:	00002617          	auipc	a2,0x2
ffffffffc0202c58:	f1460613          	addi	a2,a2,-236 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202c5c:	0ba00593          	li	a1,186
ffffffffc0202c60:	00003517          	auipc	a0,0x3
ffffffffc0202c64:	96050513          	addi	a0,a0,-1696 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202c68:	f0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c6c:	00003697          	auipc	a3,0x3
ffffffffc0202c70:	b4468693          	addi	a3,a3,-1212 # ffffffffc02057b0 <default_pmm_manager+0x898>
ffffffffc0202c74:	00002617          	auipc	a2,0x2
ffffffffc0202c78:	ef460613          	addi	a2,a2,-268 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202c7c:	0fa00593          	li	a1,250
ffffffffc0202c80:	00003517          	auipc	a0,0x3
ffffffffc0202c84:	94050513          	addi	a0,a0,-1728 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202c88:	eecfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c8c:	00002617          	auipc	a2,0x2
ffffffffc0202c90:	2f460613          	addi	a2,a2,756 # ffffffffc0204f80 <default_pmm_manager+0x68>
ffffffffc0202c94:	07000593          	li	a1,112
ffffffffc0202c98:	00002517          	auipc	a0,0x2
ffffffffc0202c9c:	2d850513          	addi	a0,a0,728 # ffffffffc0204f70 <default_pmm_manager+0x58>
ffffffffc0202ca0:	ed4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202ca4:	00002617          	auipc	a2,0x2
ffffffffc0202ca8:	2ac60613          	addi	a2,a2,684 # ffffffffc0204f50 <default_pmm_manager+0x38>
ffffffffc0202cac:	06500593          	li	a1,101
ffffffffc0202cb0:	00002517          	auipc	a0,0x2
ffffffffc0202cb4:	2c050513          	addi	a0,a0,704 # ffffffffc0204f70 <default_pmm_manager+0x58>
ffffffffc0202cb8:	ebcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202cbc:	00003697          	auipc	a3,0x3
ffffffffc0202cc0:	a2c68693          	addi	a3,a3,-1492 # ffffffffc02056e8 <default_pmm_manager+0x7d0>
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	ea460613          	addi	a2,a2,-348 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202ccc:	0db00593          	li	a1,219
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	8f050513          	addi	a0,a0,-1808 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202cd8:	e9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	9f468693          	addi	a3,a3,-1548 # ffffffffc02056d0 <default_pmm_manager+0x7b8>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	e8460613          	addi	a2,a2,-380 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202cec:	0da00593          	li	a1,218
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	8d050513          	addi	a0,a0,-1840 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202cfc:	00003617          	auipc	a2,0x3
ffffffffc0202d00:	8a460613          	addi	a2,a2,-1884 # ffffffffc02055a0 <default_pmm_manager+0x688>
ffffffffc0202d04:	02700593          	li	a1,39
ffffffffc0202d08:	00003517          	auipc	a0,0x3
ffffffffc0202d0c:	8b850513          	addi	a0,a0,-1864 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202d10:	e64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202d14:	00003697          	auipc	a3,0x3
ffffffffc0202d18:	a8468693          	addi	a3,a3,-1404 # ffffffffc0205798 <default_pmm_manager+0x880>
ffffffffc0202d1c:	00002617          	auipc	a2,0x2
ffffffffc0202d20:	e4c60613          	addi	a2,a2,-436 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202d24:	0f900593          	li	a1,249
ffffffffc0202d28:	00003517          	auipc	a0,0x3
ffffffffc0202d2c:	89850513          	addi	a0,a0,-1896 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202d30:	e44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d34:	00003697          	auipc	a3,0x3
ffffffffc0202d38:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205788 <default_pmm_manager+0x870>
ffffffffc0202d3c:	00002617          	auipc	a2,0x2
ffffffffc0202d40:	e2c60613          	addi	a2,a2,-468 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202d44:	09d00593          	li	a1,157
ffffffffc0202d48:	00003517          	auipc	a0,0x3
ffffffffc0202d4c:	87850513          	addi	a0,a0,-1928 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202d50:	e24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d54:	00003697          	auipc	a3,0x3
ffffffffc0202d58:	a3468693          	addi	a3,a3,-1484 # ffffffffc0205788 <default_pmm_manager+0x870>
ffffffffc0202d5c:	00002617          	auipc	a2,0x2
ffffffffc0202d60:	e0c60613          	addi	a2,a2,-500 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202d64:	09f00593          	li	a1,159
ffffffffc0202d68:	00003517          	auipc	a0,0x3
ffffffffc0202d6c:	85850513          	addi	a0,a0,-1960 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202d70:	e04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202d74:	00002697          	auipc	a3,0x2
ffffffffc0202d78:	fcc68693          	addi	a3,a3,-52 # ffffffffc0204d40 <commands+0x910>
ffffffffc0202d7c:	00002617          	auipc	a2,0x2
ffffffffc0202d80:	dec60613          	addi	a2,a2,-532 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202d84:	0f100593          	li	a1,241
ffffffffc0202d88:	00003517          	auipc	a0,0x3
ffffffffc0202d8c:	83850513          	addi	a0,a0,-1992 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202d90:	de4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202d94:	00003697          	auipc	a3,0x3
ffffffffc0202d98:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0205800 <default_pmm_manager+0x8e8>
ffffffffc0202d9c:	00002617          	auipc	a2,0x2
ffffffffc0202da0:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202da4:	10000593          	li	a1,256
ffffffffc0202da8:	00003517          	auipc	a0,0x3
ffffffffc0202dac:	81850513          	addi	a0,a0,-2024 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202db0:	dc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202db4:	00003697          	auipc	a3,0x3
ffffffffc0202db8:	88468693          	addi	a3,a3,-1916 # ffffffffc0205638 <default_pmm_manager+0x720>
ffffffffc0202dbc:	00002617          	auipc	a2,0x2
ffffffffc0202dc0:	dac60613          	addi	a2,a2,-596 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202dc4:	0ca00593          	li	a1,202
ffffffffc0202dc8:	00002517          	auipc	a0,0x2
ffffffffc0202dcc:	7f850513          	addi	a0,a0,2040 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202dd0:	da4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202dd4:	00003697          	auipc	a3,0x3
ffffffffc0202dd8:	87468693          	addi	a3,a3,-1932 # ffffffffc0205648 <default_pmm_manager+0x730>
ffffffffc0202ddc:	00002617          	auipc	a2,0x2
ffffffffc0202de0:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202de4:	0cd00593          	li	a1,205
ffffffffc0202de8:	00002517          	auipc	a0,0x2
ffffffffc0202dec:	7d850513          	addi	a0,a0,2008 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202df0:	d84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202df4:	00003697          	auipc	a3,0x3
ffffffffc0202df8:	89c68693          	addi	a3,a3,-1892 # ffffffffc0205690 <default_pmm_manager+0x778>
ffffffffc0202dfc:	00002617          	auipc	a2,0x2
ffffffffc0202e00:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202e04:	0d500593          	li	a1,213
ffffffffc0202e08:	00002517          	auipc	a0,0x2
ffffffffc0202e0c:	7b850513          	addi	a0,a0,1976 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202e10:	d64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e14:	00002697          	auipc	a3,0x2
ffffffffc0202e18:	d8468693          	addi	a3,a3,-636 # ffffffffc0204b98 <commands+0x768>
ffffffffc0202e1c:	00002617          	auipc	a2,0x2
ffffffffc0202e20:	d4c60613          	addi	a2,a2,-692 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202e24:	0bd00593          	li	a1,189
ffffffffc0202e28:	00002517          	auipc	a0,0x2
ffffffffc0202e2c:	79850513          	addi	a0,a0,1944 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202e30:	d44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202e34:	00003697          	auipc	a3,0x3
ffffffffc0202e38:	93468693          	addi	a3,a3,-1740 # ffffffffc0205768 <default_pmm_manager+0x850>
ffffffffc0202e3c:	00002617          	auipc	a2,0x2
ffffffffc0202e40:	d2c60613          	addi	a2,a2,-724 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202e44:	09500593          	li	a1,149
ffffffffc0202e48:	00002517          	auipc	a0,0x2
ffffffffc0202e4c:	77850513          	addi	a0,a0,1912 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202e50:	d24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202e54:	00003697          	auipc	a3,0x3
ffffffffc0202e58:	91468693          	addi	a3,a3,-1772 # ffffffffc0205768 <default_pmm_manager+0x850>
ffffffffc0202e5c:	00002617          	auipc	a2,0x2
ffffffffc0202e60:	d0c60613          	addi	a2,a2,-756 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202e64:	09700593          	li	a1,151
ffffffffc0202e68:	00002517          	auipc	a0,0x2
ffffffffc0202e6c:	75850513          	addi	a0,a0,1880 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202e70:	d04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202e74:	00003697          	auipc	a3,0x3
ffffffffc0202e78:	90468693          	addi	a3,a3,-1788 # ffffffffc0205778 <default_pmm_manager+0x860>
ffffffffc0202e7c:	00002617          	auipc	a2,0x2
ffffffffc0202e80:	cec60613          	addi	a2,a2,-788 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202e84:	09900593          	li	a1,153
ffffffffc0202e88:	00002517          	auipc	a0,0x2
ffffffffc0202e8c:	73850513          	addi	a0,a0,1848 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202e90:	ce4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202e94:	00003697          	auipc	a3,0x3
ffffffffc0202e98:	8e468693          	addi	a3,a3,-1820 # ffffffffc0205778 <default_pmm_manager+0x860>
ffffffffc0202e9c:	00002617          	auipc	a2,0x2
ffffffffc0202ea0:	ccc60613          	addi	a2,a2,-820 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202ea4:	09b00593          	li	a1,155
ffffffffc0202ea8:	00002517          	auipc	a0,0x2
ffffffffc0202eac:	71850513          	addi	a0,a0,1816 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202eb0:	cc4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202eb4:	00003697          	auipc	a3,0x3
ffffffffc0202eb8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0205758 <default_pmm_manager+0x840>
ffffffffc0202ebc:	00002617          	auipc	a2,0x2
ffffffffc0202ec0:	cac60613          	addi	a2,a2,-852 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202ec4:	09100593          	li	a1,145
ffffffffc0202ec8:	00002517          	auipc	a0,0x2
ffffffffc0202ecc:	6f850513          	addi	a0,a0,1784 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202ed0:	ca4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202ed4:	00003697          	auipc	a3,0x3
ffffffffc0202ed8:	88468693          	addi	a3,a3,-1916 # ffffffffc0205758 <default_pmm_manager+0x840>
ffffffffc0202edc:	00002617          	auipc	a2,0x2
ffffffffc0202ee0:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202ee4:	09300593          	li	a1,147
ffffffffc0202ee8:	00002517          	auipc	a0,0x2
ffffffffc0202eec:	6d850513          	addi	a0,a0,1752 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202ef0:	c84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202ef4:	00002697          	auipc	a3,0x2
ffffffffc0202ef8:	71c68693          	addi	a3,a3,1820 # ffffffffc0205610 <default_pmm_manager+0x6f8>
ffffffffc0202efc:	00002617          	auipc	a2,0x2
ffffffffc0202f00:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202f04:	0c200593          	li	a1,194
ffffffffc0202f08:	00002517          	auipc	a0,0x2
ffffffffc0202f0c:	6b850513          	addi	a0,a0,1720 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202f10:	c64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f14:	00002697          	auipc	a3,0x2
ffffffffc0202f18:	70c68693          	addi	a3,a3,1804 # ffffffffc0205620 <default_pmm_manager+0x708>
ffffffffc0202f1c:	00002617          	auipc	a2,0x2
ffffffffc0202f20:	c4c60613          	addi	a2,a2,-948 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202f24:	0c500593          	li	a1,197
ffffffffc0202f28:	00002517          	auipc	a0,0x2
ffffffffc0202f2c:	69850513          	addi	a0,a0,1688 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202f30:	c44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202f34:	00002697          	auipc	a3,0x2
ffffffffc0202f38:	7d468693          	addi	a3,a3,2004 # ffffffffc0205708 <default_pmm_manager+0x7f0>
ffffffffc0202f3c:	00002617          	auipc	a2,0x2
ffffffffc0202f40:	c2c60613          	addi	a2,a2,-980 # ffffffffc0204b68 <commands+0x738>
ffffffffc0202f44:	0e800593          	li	a1,232
ffffffffc0202f48:	00002517          	auipc	a0,0x2
ffffffffc0202f4c:	67850513          	addi	a0,a0,1656 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc0202f50:	c24fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202f54 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f54:	0000d797          	auipc	a5,0xd
ffffffffc0202f58:	5e47b783          	ld	a5,1508(a5) # ffffffffc0210538 <sm>
ffffffffc0202f5c:	6b9c                	ld	a5,16(a5)
ffffffffc0202f5e:	8782                	jr	a5

ffffffffc0202f60 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f60:	0000d797          	auipc	a5,0xd
ffffffffc0202f64:	5d87b783          	ld	a5,1496(a5) # ffffffffc0210538 <sm>
ffffffffc0202f68:	739c                	ld	a5,32(a5)
ffffffffc0202f6a:	8782                	jr	a5

ffffffffc0202f6c <swap_out>:
{
ffffffffc0202f6c:	711d                	addi	sp,sp,-96
ffffffffc0202f6e:	ec86                	sd	ra,88(sp)
ffffffffc0202f70:	e8a2                	sd	s0,80(sp)
ffffffffc0202f72:	e4a6                	sd	s1,72(sp)
ffffffffc0202f74:	e0ca                	sd	s2,64(sp)
ffffffffc0202f76:	fc4e                	sd	s3,56(sp)
ffffffffc0202f78:	f852                	sd	s4,48(sp)
ffffffffc0202f7a:	f456                	sd	s5,40(sp)
ffffffffc0202f7c:	f05a                	sd	s6,32(sp)
ffffffffc0202f7e:	ec5e                	sd	s7,24(sp)
ffffffffc0202f80:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f82:	cde9                	beqz	a1,ffffffffc020305c <swap_out+0xf0>
ffffffffc0202f84:	8a2e                	mv	s4,a1
ffffffffc0202f86:	892a                	mv	s2,a0
ffffffffc0202f88:	8ab2                	mv	s5,a2
ffffffffc0202f8a:	4401                	li	s0,0
ffffffffc0202f8c:	0000d997          	auipc	s3,0xd
ffffffffc0202f90:	5ac98993          	addi	s3,s3,1452 # ffffffffc0210538 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f94:	00003b17          	auipc	s6,0x3
ffffffffc0202f98:	914b0b13          	addi	s6,s6,-1772 # ffffffffc02058a8 <default_pmm_manager+0x990>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f9c:	00003b97          	auipc	s7,0x3
ffffffffc0202fa0:	8f4b8b93          	addi	s7,s7,-1804 # ffffffffc0205890 <default_pmm_manager+0x978>
ffffffffc0202fa4:	a825                	j	ffffffffc0202fdc <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202fa6:	67a2                	ld	a5,8(sp)
ffffffffc0202fa8:	8626                	mv	a2,s1
ffffffffc0202faa:	85a2                	mv	a1,s0
ffffffffc0202fac:	63b4                	ld	a3,64(a5)
ffffffffc0202fae:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202fb0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202fb2:	82b1                	srli	a3,a3,0xc
ffffffffc0202fb4:	0685                	addi	a3,a3,1
ffffffffc0202fb6:	904fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202fba:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202fbc:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202fbe:	613c                	ld	a5,64(a0)
ffffffffc0202fc0:	83b1                	srli	a5,a5,0xc
ffffffffc0202fc2:	0785                	addi	a5,a5,1
ffffffffc0202fc4:	07a2                	slli	a5,a5,0x8
ffffffffc0202fc6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202fca:	e58fe0ef          	jal	ra,ffffffffc0201622 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202fce:	01893503          	ld	a0,24(s2)
ffffffffc0202fd2:	85a6                	mv	a1,s1
ffffffffc0202fd4:	eb6ff0ef          	jal	ra,ffffffffc020268a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202fd8:	048a0d63          	beq	s4,s0,ffffffffc0203032 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202fdc:	0009b783          	ld	a5,0(s3)
ffffffffc0202fe0:	8656                	mv	a2,s5
ffffffffc0202fe2:	002c                	addi	a1,sp,8
ffffffffc0202fe4:	7b9c                	ld	a5,48(a5)
ffffffffc0202fe6:	854a                	mv	a0,s2
ffffffffc0202fe8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202fea:	e12d                	bnez	a0,ffffffffc020304c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202fec:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fee:	01893503          	ld	a0,24(s2)
ffffffffc0202ff2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202ff4:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202ff6:	85a6                	mv	a1,s1
ffffffffc0202ff8:	ea4fe0ef          	jal	ra,ffffffffc020169c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202ffc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202ffe:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203000:	8b85                	andi	a5,a5,1
ffffffffc0203002:	cfb9                	beqz	a5,ffffffffc0203060 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203004:	65a2                	ld	a1,8(sp)
ffffffffc0203006:	61bc                	ld	a5,64(a1)
ffffffffc0203008:	83b1                	srli	a5,a5,0xc
ffffffffc020300a:	0785                	addi	a5,a5,1
ffffffffc020300c:	00879513          	slli	a0,a5,0x8
ffffffffc0203010:	3e7000ef          	jal	ra,ffffffffc0203bf6 <swapfs_write>
ffffffffc0203014:	d949                	beqz	a0,ffffffffc0202fa6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203016:	855e                	mv	a0,s7
ffffffffc0203018:	8a2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020301c:	0009b783          	ld	a5,0(s3)
ffffffffc0203020:	6622                	ld	a2,8(sp)
ffffffffc0203022:	4681                	li	a3,0
ffffffffc0203024:	739c                	ld	a5,32(a5)
ffffffffc0203026:	85a6                	mv	a1,s1
ffffffffc0203028:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020302a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020302c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020302e:	fa8a17e3          	bne	s4,s0,ffffffffc0202fdc <swap_out+0x70>
}
ffffffffc0203032:	60e6                	ld	ra,88(sp)
ffffffffc0203034:	8522                	mv	a0,s0
ffffffffc0203036:	6446                	ld	s0,80(sp)
ffffffffc0203038:	64a6                	ld	s1,72(sp)
ffffffffc020303a:	6906                	ld	s2,64(sp)
ffffffffc020303c:	79e2                	ld	s3,56(sp)
ffffffffc020303e:	7a42                	ld	s4,48(sp)
ffffffffc0203040:	7aa2                	ld	s5,40(sp)
ffffffffc0203042:	7b02                	ld	s6,32(sp)
ffffffffc0203044:	6be2                	ld	s7,24(sp)
ffffffffc0203046:	6c42                	ld	s8,16(sp)
ffffffffc0203048:	6125                	addi	sp,sp,96
ffffffffc020304a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020304c:	85a2                	mv	a1,s0
ffffffffc020304e:	00002517          	auipc	a0,0x2
ffffffffc0203052:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205848 <default_pmm_manager+0x930>
ffffffffc0203056:	864fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc020305a:	bfe1                	j	ffffffffc0203032 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020305c:	4401                	li	s0,0
ffffffffc020305e:	bfd1                	j	ffffffffc0203032 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203060:	00003697          	auipc	a3,0x3
ffffffffc0203064:	81868693          	addi	a3,a3,-2024 # ffffffffc0205878 <default_pmm_manager+0x960>
ffffffffc0203068:	00002617          	auipc	a2,0x2
ffffffffc020306c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203070:	06600593          	li	a1,102
ffffffffc0203074:	00002517          	auipc	a0,0x2
ffffffffc0203078:	54c50513          	addi	a0,a0,1356 # ffffffffc02055c0 <default_pmm_manager+0x6a8>
ffffffffc020307c:	af8fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203080 <_clock_init_mm>:
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203080:	4501                	li	a0,0
ffffffffc0203082:	8082                	ret

ffffffffc0203084 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203084:	4501                	li	a0,0
ffffffffc0203086:	8082                	ret

ffffffffc0203088 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203088:	4501                	li	a0,0
ffffffffc020308a:	8082                	ret

ffffffffc020308c <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc020308c:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020308e:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203090:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203092:	678d                	lui	a5,0x3
ffffffffc0203094:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203098:	0000d697          	auipc	a3,0xd
ffffffffc020309c:	4b86a683          	lw	a3,1208(a3) # ffffffffc0210550 <pgfault_num>
ffffffffc02030a0:	4711                	li	a4,4
ffffffffc02030a2:	0ae69363          	bne	a3,a4,ffffffffc0203148 <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02030a6:	6705                	lui	a4,0x1
ffffffffc02030a8:	4629                	li	a2,10
ffffffffc02030aa:	0000d797          	auipc	a5,0xd
ffffffffc02030ae:	4a678793          	addi	a5,a5,1190 # ffffffffc0210550 <pgfault_num>
ffffffffc02030b2:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02030b6:	4398                	lw	a4,0(a5)
ffffffffc02030b8:	2701                	sext.w	a4,a4
ffffffffc02030ba:	20d71763          	bne	a4,a3,ffffffffc02032c8 <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030be:	6691                	lui	a3,0x4
ffffffffc02030c0:	4635                	li	a2,13
ffffffffc02030c2:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02030c6:	4394                	lw	a3,0(a5)
ffffffffc02030c8:	2681                	sext.w	a3,a3
ffffffffc02030ca:	1ce69f63          	bne	a3,a4,ffffffffc02032a8 <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030ce:	6709                	lui	a4,0x2
ffffffffc02030d0:	462d                	li	a2,11
ffffffffc02030d2:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02030d6:	4398                	lw	a4,0(a5)
ffffffffc02030d8:	2701                	sext.w	a4,a4
ffffffffc02030da:	1ad71763          	bne	a4,a3,ffffffffc0203288 <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030de:	6715                	lui	a4,0x5
ffffffffc02030e0:	46b9                	li	a3,14
ffffffffc02030e2:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02030e6:	4398                	lw	a4,0(a5)
ffffffffc02030e8:	4695                	li	a3,5
ffffffffc02030ea:	2701                	sext.w	a4,a4
ffffffffc02030ec:	16d71e63          	bne	a4,a3,ffffffffc0203268 <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc02030f0:	4394                	lw	a3,0(a5)
ffffffffc02030f2:	2681                	sext.w	a3,a3
ffffffffc02030f4:	14e69a63          	bne	a3,a4,ffffffffc0203248 <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc02030f8:	4398                	lw	a4,0(a5)
ffffffffc02030fa:	2701                	sext.w	a4,a4
ffffffffc02030fc:	12d71663          	bne	a4,a3,ffffffffc0203228 <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc0203100:	4394                	lw	a3,0(a5)
ffffffffc0203102:	2681                	sext.w	a3,a3
ffffffffc0203104:	10e69263          	bne	a3,a4,ffffffffc0203208 <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc0203108:	4398                	lw	a4,0(a5)
ffffffffc020310a:	2701                	sext.w	a4,a4
ffffffffc020310c:	0cd71e63          	bne	a4,a3,ffffffffc02031e8 <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc0203110:	4394                	lw	a3,0(a5)
ffffffffc0203112:	2681                	sext.w	a3,a3
ffffffffc0203114:	0ae69a63          	bne	a3,a4,ffffffffc02031c8 <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203118:	6715                	lui	a4,0x5
ffffffffc020311a:	46b9                	li	a3,14
ffffffffc020311c:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203120:	4398                	lw	a4,0(a5)
ffffffffc0203122:	4695                	li	a3,5
ffffffffc0203124:	2701                	sext.w	a4,a4
ffffffffc0203126:	08d71163          	bne	a4,a3,ffffffffc02031a8 <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020312a:	6705                	lui	a4,0x1
ffffffffc020312c:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203130:	4729                	li	a4,10
ffffffffc0203132:	04e69b63          	bne	a3,a4,ffffffffc0203188 <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc0203136:	439c                	lw	a5,0(a5)
ffffffffc0203138:	4719                	li	a4,6
ffffffffc020313a:	2781                	sext.w	a5,a5
ffffffffc020313c:	02e79663          	bne	a5,a4,ffffffffc0203168 <_clock_check_swap+0xdc>
}
ffffffffc0203140:	60a2                	ld	ra,8(sp)
ffffffffc0203142:	4501                	li	a0,0
ffffffffc0203144:	0141                	addi	sp,sp,16
ffffffffc0203146:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203148:	00002697          	auipc	a3,0x2
ffffffffc020314c:	64068693          	addi	a3,a3,1600 # ffffffffc0205788 <default_pmm_manager+0x870>
ffffffffc0203150:	00002617          	auipc	a2,0x2
ffffffffc0203154:	a1860613          	addi	a2,a2,-1512 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203158:	07700593          	li	a1,119
ffffffffc020315c:	00002517          	auipc	a0,0x2
ffffffffc0203160:	78c50513          	addi	a0,a0,1932 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203164:	a10fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc0203168:	00002697          	auipc	a3,0x2
ffffffffc020316c:	7d068693          	addi	a3,a3,2000 # ffffffffc0205938 <default_pmm_manager+0xa20>
ffffffffc0203170:	00002617          	auipc	a2,0x2
ffffffffc0203174:	9f860613          	addi	a2,a2,-1544 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203178:	08e00593          	li	a1,142
ffffffffc020317c:	00002517          	auipc	a0,0x2
ffffffffc0203180:	76c50513          	addi	a0,a0,1900 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203184:	9f0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203188:	00002697          	auipc	a3,0x2
ffffffffc020318c:	78868693          	addi	a3,a3,1928 # ffffffffc0205910 <default_pmm_manager+0x9f8>
ffffffffc0203190:	00002617          	auipc	a2,0x2
ffffffffc0203194:	9d860613          	addi	a2,a2,-1576 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203198:	08c00593          	li	a1,140
ffffffffc020319c:	00002517          	auipc	a0,0x2
ffffffffc02031a0:	74c50513          	addi	a0,a0,1868 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc02031a4:	9d0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031a8:	00002697          	auipc	a3,0x2
ffffffffc02031ac:	75868693          	addi	a3,a3,1880 # ffffffffc0205900 <default_pmm_manager+0x9e8>
ffffffffc02031b0:	00002617          	auipc	a2,0x2
ffffffffc02031b4:	9b860613          	addi	a2,a2,-1608 # ffffffffc0204b68 <commands+0x738>
ffffffffc02031b8:	08b00593          	li	a1,139
ffffffffc02031bc:	00002517          	auipc	a0,0x2
ffffffffc02031c0:	72c50513          	addi	a0,a0,1836 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc02031c4:	9b0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031c8:	00002697          	auipc	a3,0x2
ffffffffc02031cc:	73868693          	addi	a3,a3,1848 # ffffffffc0205900 <default_pmm_manager+0x9e8>
ffffffffc02031d0:	00002617          	auipc	a2,0x2
ffffffffc02031d4:	99860613          	addi	a2,a2,-1640 # ffffffffc0204b68 <commands+0x738>
ffffffffc02031d8:	08900593          	li	a1,137
ffffffffc02031dc:	00002517          	auipc	a0,0x2
ffffffffc02031e0:	70c50513          	addi	a0,a0,1804 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc02031e4:	990fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031e8:	00002697          	auipc	a3,0x2
ffffffffc02031ec:	71868693          	addi	a3,a3,1816 # ffffffffc0205900 <default_pmm_manager+0x9e8>
ffffffffc02031f0:	00002617          	auipc	a2,0x2
ffffffffc02031f4:	97860613          	addi	a2,a2,-1672 # ffffffffc0204b68 <commands+0x738>
ffffffffc02031f8:	08700593          	li	a1,135
ffffffffc02031fc:	00002517          	auipc	a0,0x2
ffffffffc0203200:	6ec50513          	addi	a0,a0,1772 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203204:	970fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203208:	00002697          	auipc	a3,0x2
ffffffffc020320c:	6f868693          	addi	a3,a3,1784 # ffffffffc0205900 <default_pmm_manager+0x9e8>
ffffffffc0203210:	00002617          	auipc	a2,0x2
ffffffffc0203214:	95860613          	addi	a2,a2,-1704 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203218:	08500593          	li	a1,133
ffffffffc020321c:	00002517          	auipc	a0,0x2
ffffffffc0203220:	6cc50513          	addi	a0,a0,1740 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203224:	950fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203228:	00002697          	auipc	a3,0x2
ffffffffc020322c:	6d868693          	addi	a3,a3,1752 # ffffffffc0205900 <default_pmm_manager+0x9e8>
ffffffffc0203230:	00002617          	auipc	a2,0x2
ffffffffc0203234:	93860613          	addi	a2,a2,-1736 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203238:	08300593          	li	a1,131
ffffffffc020323c:	00002517          	auipc	a0,0x2
ffffffffc0203240:	6ac50513          	addi	a0,a0,1708 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203244:	930fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203248:	00002697          	auipc	a3,0x2
ffffffffc020324c:	6b868693          	addi	a3,a3,1720 # ffffffffc0205900 <default_pmm_manager+0x9e8>
ffffffffc0203250:	00002617          	auipc	a2,0x2
ffffffffc0203254:	91860613          	addi	a2,a2,-1768 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203258:	08100593          	li	a1,129
ffffffffc020325c:	00002517          	auipc	a0,0x2
ffffffffc0203260:	68c50513          	addi	a0,a0,1676 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203264:	910fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203268:	00002697          	auipc	a3,0x2
ffffffffc020326c:	69868693          	addi	a3,a3,1688 # ffffffffc0205900 <default_pmm_manager+0x9e8>
ffffffffc0203270:	00002617          	auipc	a2,0x2
ffffffffc0203274:	8f860613          	addi	a2,a2,-1800 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203278:	07f00593          	li	a1,127
ffffffffc020327c:	00002517          	auipc	a0,0x2
ffffffffc0203280:	66c50513          	addi	a0,a0,1644 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203284:	8f0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203288:	00002697          	auipc	a3,0x2
ffffffffc020328c:	50068693          	addi	a3,a3,1280 # ffffffffc0205788 <default_pmm_manager+0x870>
ffffffffc0203290:	00002617          	auipc	a2,0x2
ffffffffc0203294:	8d860613          	addi	a2,a2,-1832 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203298:	07d00593          	li	a1,125
ffffffffc020329c:	00002517          	auipc	a0,0x2
ffffffffc02032a0:	64c50513          	addi	a0,a0,1612 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc02032a4:	8d0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032a8:	00002697          	auipc	a3,0x2
ffffffffc02032ac:	4e068693          	addi	a3,a3,1248 # ffffffffc0205788 <default_pmm_manager+0x870>
ffffffffc02032b0:	00002617          	auipc	a2,0x2
ffffffffc02032b4:	8b860613          	addi	a2,a2,-1864 # ffffffffc0204b68 <commands+0x738>
ffffffffc02032b8:	07b00593          	li	a1,123
ffffffffc02032bc:	00002517          	auipc	a0,0x2
ffffffffc02032c0:	62c50513          	addi	a0,a0,1580 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc02032c4:	8b0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032c8:	00002697          	auipc	a3,0x2
ffffffffc02032cc:	4c068693          	addi	a3,a3,1216 # ffffffffc0205788 <default_pmm_manager+0x870>
ffffffffc02032d0:	00002617          	auipc	a2,0x2
ffffffffc02032d4:	89860613          	addi	a2,a2,-1896 # ffffffffc0204b68 <commands+0x738>
ffffffffc02032d8:	07900593          	li	a1,121
ffffffffc02032dc:	00002517          	auipc	a0,0x2
ffffffffc02032e0:	60c50513          	addi	a0,a0,1548 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc02032e4:	890fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032e8 <_clock_swap_out_victim>:
         assert(head != NULL);
ffffffffc02032e8:	751c                	ld	a5,40(a0)
{
ffffffffc02032ea:	1141                	addi	sp,sp,-16
ffffffffc02032ec:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02032ee:	c39d                	beqz	a5,ffffffffc0203314 <_clock_swap_out_victim+0x2c>
     assert(in_tick==0);
ffffffffc02032f0:	e211                	bnez	a2,ffffffffc02032f4 <_clock_swap_out_victim+0xc>
    while (1) {
ffffffffc02032f2:	a001                	j	ffffffffc02032f2 <_clock_swap_out_victim+0xa>
     assert(in_tick==0);
ffffffffc02032f4:	00002697          	auipc	a3,0x2
ffffffffc02032f8:	66468693          	addi	a3,a3,1636 # ffffffffc0205958 <default_pmm_manager+0xa40>
ffffffffc02032fc:	00002617          	auipc	a2,0x2
ffffffffc0203300:	86c60613          	addi	a2,a2,-1940 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203304:	04400593          	li	a1,68
ffffffffc0203308:	00002517          	auipc	a0,0x2
ffffffffc020330c:	5e050513          	addi	a0,a0,1504 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203310:	864fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(head != NULL);
ffffffffc0203314:	00002697          	auipc	a3,0x2
ffffffffc0203318:	63468693          	addi	a3,a3,1588 # ffffffffc0205948 <default_pmm_manager+0xa30>
ffffffffc020331c:	00002617          	auipc	a2,0x2
ffffffffc0203320:	84c60613          	addi	a2,a2,-1972 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203324:	04300593          	li	a1,67
ffffffffc0203328:	00002517          	auipc	a0,0x2
ffffffffc020332c:	5c050513          	addi	a0,a0,1472 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
ffffffffc0203330:	844fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203334 <_clock_map_swappable>:
{
ffffffffc0203334:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203336:	00002697          	auipc	a3,0x2
ffffffffc020333a:	63268693          	addi	a3,a3,1586 # ffffffffc0205968 <default_pmm_manager+0xa50>
ffffffffc020333e:	00002617          	auipc	a2,0x2
ffffffffc0203342:	82a60613          	addi	a2,a2,-2006 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203346:	03300593          	li	a1,51
ffffffffc020334a:	00002517          	auipc	a0,0x2
ffffffffc020334e:	59e50513          	addi	a0,a0,1438 # ffffffffc02058e8 <default_pmm_manager+0x9d0>
{
ffffffffc0203352:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203354:	820fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203358 <_clock_tick_event>:
ffffffffc0203358:	4501                	li	a0,0
ffffffffc020335a:	8082                	ret

ffffffffc020335c <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020335c:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020335e:	00002697          	auipc	a3,0x2
ffffffffc0203362:	64a68693          	addi	a3,a3,1610 # ffffffffc02059a8 <default_pmm_manager+0xa90>
ffffffffc0203366:	00002617          	auipc	a2,0x2
ffffffffc020336a:	80260613          	addi	a2,a2,-2046 # ffffffffc0204b68 <commands+0x738>
ffffffffc020336e:	07d00593          	li	a1,125
ffffffffc0203372:	00002517          	auipc	a0,0x2
ffffffffc0203376:	65650513          	addi	a0,a0,1622 # ffffffffc02059c8 <default_pmm_manager+0xab0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020337a:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020337c:	ff9fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203380 <mm_create>:
mm_create(void) {
ffffffffc0203380:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203382:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203386:	e022                	sd	s0,0(sp)
ffffffffc0203388:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020338a:	bbeff0ef          	jal	ra,ffffffffc0202748 <kmalloc>
ffffffffc020338e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203390:	c105                	beqz	a0,ffffffffc02033b0 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0203392:	e408                	sd	a0,8(s0)
ffffffffc0203394:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203396:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020339a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020339e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02033a2:	0000d797          	auipc	a5,0xd
ffffffffc02033a6:	19e7a783          	lw	a5,414(a5) # ffffffffc0210540 <swap_init_ok>
ffffffffc02033aa:	eb81                	bnez	a5,ffffffffc02033ba <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02033ac:	02053423          	sd	zero,40(a0)
}
ffffffffc02033b0:	60a2                	ld	ra,8(sp)
ffffffffc02033b2:	8522                	mv	a0,s0
ffffffffc02033b4:	6402                	ld	s0,0(sp)
ffffffffc02033b6:	0141                	addi	sp,sp,16
ffffffffc02033b8:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02033ba:	b9bff0ef          	jal	ra,ffffffffc0202f54 <swap_init_mm>
}
ffffffffc02033be:	60a2                	ld	ra,8(sp)
ffffffffc02033c0:	8522                	mv	a0,s0
ffffffffc02033c2:	6402                	ld	s0,0(sp)
ffffffffc02033c4:	0141                	addi	sp,sp,16
ffffffffc02033c6:	8082                	ret

ffffffffc02033c8 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02033c8:	1101                	addi	sp,sp,-32
ffffffffc02033ca:	e04a                	sd	s2,0(sp)
ffffffffc02033cc:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02033ce:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02033d2:	e822                	sd	s0,16(sp)
ffffffffc02033d4:	e426                	sd	s1,8(sp)
ffffffffc02033d6:	ec06                	sd	ra,24(sp)
ffffffffc02033d8:	84ae                	mv	s1,a1
ffffffffc02033da:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02033dc:	b6cff0ef          	jal	ra,ffffffffc0202748 <kmalloc>
    if (vma != NULL) {
ffffffffc02033e0:	c509                	beqz	a0,ffffffffc02033ea <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02033e2:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02033e6:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02033e8:	ed00                	sd	s0,24(a0)
}
ffffffffc02033ea:	60e2                	ld	ra,24(sp)
ffffffffc02033ec:	6442                	ld	s0,16(sp)
ffffffffc02033ee:	64a2                	ld	s1,8(sp)
ffffffffc02033f0:	6902                	ld	s2,0(sp)
ffffffffc02033f2:	6105                	addi	sp,sp,32
ffffffffc02033f4:	8082                	ret

ffffffffc02033f6 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02033f6:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02033f8:	c505                	beqz	a0,ffffffffc0203420 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02033fa:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02033fc:	c501                	beqz	a0,ffffffffc0203404 <find_vma+0xe>
ffffffffc02033fe:	651c                	ld	a5,8(a0)
ffffffffc0203400:	02f5f263          	bgeu	a1,a5,ffffffffc0203424 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203404:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203406:	00f68d63          	beq	a3,a5,ffffffffc0203420 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020340a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020340e:	00e5e663          	bltu	a1,a4,ffffffffc020341a <find_vma+0x24>
ffffffffc0203412:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203416:	00e5ec63          	bltu	a1,a4,ffffffffc020342e <find_vma+0x38>
ffffffffc020341a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020341c:	fef697e3          	bne	a3,a5,ffffffffc020340a <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203420:	4501                	li	a0,0
}
ffffffffc0203422:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203424:	691c                	ld	a5,16(a0)
ffffffffc0203426:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203404 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020342a:	ea88                	sd	a0,16(a3)
ffffffffc020342c:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020342e:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203432:	ea88                	sd	a0,16(a3)
ffffffffc0203434:	8082                	ret

ffffffffc0203436 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203436:	6590                	ld	a2,8(a1)
ffffffffc0203438:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020343c:	1141                	addi	sp,sp,-16
ffffffffc020343e:	e406                	sd	ra,8(sp)
ffffffffc0203440:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203442:	01066763          	bltu	a2,a6,ffffffffc0203450 <insert_vma_struct+0x1a>
ffffffffc0203446:	a085                	j	ffffffffc02034a6 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203448:	fe87b703          	ld	a4,-24(a5)
ffffffffc020344c:	04e66863          	bltu	a2,a4,ffffffffc020349c <insert_vma_struct+0x66>
ffffffffc0203450:	86be                	mv	a3,a5
ffffffffc0203452:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203454:	fef51ae3          	bne	a0,a5,ffffffffc0203448 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203458:	02a68463          	beq	a3,a0,ffffffffc0203480 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020345c:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203460:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203464:	08e8f163          	bgeu	a7,a4,ffffffffc02034e6 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203468:	04e66f63          	bltu	a2,a4,ffffffffc02034c6 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc020346c:	00f50a63          	beq	a0,a5,ffffffffc0203480 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203470:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203474:	05076963          	bltu	a4,a6,ffffffffc02034c6 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203478:	ff07b603          	ld	a2,-16(a5)
ffffffffc020347c:	02c77363          	bgeu	a4,a2,ffffffffc02034a2 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203480:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203482:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203484:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203488:	e390                	sd	a2,0(a5)
ffffffffc020348a:	e690                	sd	a2,8(a3)
}
ffffffffc020348c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020348e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203490:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0203492:	0017079b          	addiw	a5,a4,1
ffffffffc0203496:	d11c                	sw	a5,32(a0)
}
ffffffffc0203498:	0141                	addi	sp,sp,16
ffffffffc020349a:	8082                	ret
    if (le_prev != list) {
ffffffffc020349c:	fca690e3          	bne	a3,a0,ffffffffc020345c <insert_vma_struct+0x26>
ffffffffc02034a0:	bfd1                	j	ffffffffc0203474 <insert_vma_struct+0x3e>
ffffffffc02034a2:	ebbff0ef          	jal	ra,ffffffffc020335c <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02034a6:	00002697          	auipc	a3,0x2
ffffffffc02034aa:	53268693          	addi	a3,a3,1330 # ffffffffc02059d8 <default_pmm_manager+0xac0>
ffffffffc02034ae:	00001617          	auipc	a2,0x1
ffffffffc02034b2:	6ba60613          	addi	a2,a2,1722 # ffffffffc0204b68 <commands+0x738>
ffffffffc02034b6:	08400593          	li	a1,132
ffffffffc02034ba:	00002517          	auipc	a0,0x2
ffffffffc02034be:	50e50513          	addi	a0,a0,1294 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc02034c2:	eb3fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02034c6:	00002697          	auipc	a3,0x2
ffffffffc02034ca:	55268693          	addi	a3,a3,1362 # ffffffffc0205a18 <default_pmm_manager+0xb00>
ffffffffc02034ce:	00001617          	auipc	a2,0x1
ffffffffc02034d2:	69a60613          	addi	a2,a2,1690 # ffffffffc0204b68 <commands+0x738>
ffffffffc02034d6:	07c00593          	li	a1,124
ffffffffc02034da:	00002517          	auipc	a0,0x2
ffffffffc02034de:	4ee50513          	addi	a0,a0,1262 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc02034e2:	e93fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02034e6:	00002697          	auipc	a3,0x2
ffffffffc02034ea:	51268693          	addi	a3,a3,1298 # ffffffffc02059f8 <default_pmm_manager+0xae0>
ffffffffc02034ee:	00001617          	auipc	a2,0x1
ffffffffc02034f2:	67a60613          	addi	a2,a2,1658 # ffffffffc0204b68 <commands+0x738>
ffffffffc02034f6:	07b00593          	li	a1,123
ffffffffc02034fa:	00002517          	auipc	a0,0x2
ffffffffc02034fe:	4ce50513          	addi	a0,a0,1230 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203502:	e73fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203506 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203506:	1141                	addi	sp,sp,-16
ffffffffc0203508:	e022                	sd	s0,0(sp)
ffffffffc020350a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020350c:	6508                	ld	a0,8(a0)
ffffffffc020350e:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203510:	00a40e63          	beq	s0,a0,ffffffffc020352c <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203514:	6118                	ld	a4,0(a0)
ffffffffc0203516:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203518:	03000593          	li	a1,48
ffffffffc020351c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020351e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203520:	e398                	sd	a4,0(a5)
ffffffffc0203522:	ae0ff0ef          	jal	ra,ffffffffc0202802 <kfree>
    return listelm->next;
ffffffffc0203526:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203528:	fea416e3          	bne	s0,a0,ffffffffc0203514 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020352c:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020352e:	6402                	ld	s0,0(sp)
ffffffffc0203530:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203532:	03000593          	li	a1,48
}
ffffffffc0203536:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203538:	acaff06f          	j	ffffffffc0202802 <kfree>

ffffffffc020353c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020353c:	715d                	addi	sp,sp,-80
ffffffffc020353e:	e486                	sd	ra,72(sp)
ffffffffc0203540:	f44e                	sd	s3,40(sp)
ffffffffc0203542:	f052                	sd	s4,32(sp)
ffffffffc0203544:	e0a2                	sd	s0,64(sp)
ffffffffc0203546:	fc26                	sd	s1,56(sp)
ffffffffc0203548:	f84a                	sd	s2,48(sp)
ffffffffc020354a:	ec56                	sd	s5,24(sp)
ffffffffc020354c:	e85a                	sd	s6,16(sp)
ffffffffc020354e:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203550:	912fe0ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
ffffffffc0203554:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203556:	90cfe0ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
ffffffffc020355a:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020355c:	03000513          	li	a0,48
ffffffffc0203560:	9e8ff0ef          	jal	ra,ffffffffc0202748 <kmalloc>
    if (mm != NULL) {
ffffffffc0203564:	56050863          	beqz	a0,ffffffffc0203ad4 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0203568:	e508                	sd	a0,8(a0)
ffffffffc020356a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020356c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203570:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203574:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203578:	0000d797          	auipc	a5,0xd
ffffffffc020357c:	fc87a783          	lw	a5,-56(a5) # ffffffffc0210540 <swap_init_ok>
ffffffffc0203580:	84aa                	mv	s1,a0
ffffffffc0203582:	e7b9                	bnez	a5,ffffffffc02035d0 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0203584:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0203588:	03200413          	li	s0,50
ffffffffc020358c:	a811                	j	ffffffffc02035a0 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc020358e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203590:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203592:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0203596:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203598:	8526                	mv	a0,s1
ffffffffc020359a:	e9dff0ef          	jal	ra,ffffffffc0203436 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020359e:	cc05                	beqz	s0,ffffffffc02035d6 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02035a0:	03000513          	li	a0,48
ffffffffc02035a4:	9a4ff0ef          	jal	ra,ffffffffc0202748 <kmalloc>
ffffffffc02035a8:	85aa                	mv	a1,a0
ffffffffc02035aa:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02035ae:	f165                	bnez	a0,ffffffffc020358e <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc02035b0:	00002697          	auipc	a3,0x2
ffffffffc02035b4:	09868693          	addi	a3,a3,152 # ffffffffc0205648 <default_pmm_manager+0x730>
ffffffffc02035b8:	00001617          	auipc	a2,0x1
ffffffffc02035bc:	5b060613          	addi	a2,a2,1456 # ffffffffc0204b68 <commands+0x738>
ffffffffc02035c0:	0ce00593          	li	a1,206
ffffffffc02035c4:	00002517          	auipc	a0,0x2
ffffffffc02035c8:	40450513          	addi	a0,a0,1028 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc02035cc:	da9fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02035d0:	985ff0ef          	jal	ra,ffffffffc0202f54 <swap_init_mm>
ffffffffc02035d4:	bf55                	j	ffffffffc0203588 <vmm_init+0x4c>
ffffffffc02035d6:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02035da:	1f900913          	li	s2,505
ffffffffc02035de:	a819                	j	ffffffffc02035f4 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc02035e0:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02035e2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02035e4:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02035e8:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02035ea:	8526                	mv	a0,s1
ffffffffc02035ec:	e4bff0ef          	jal	ra,ffffffffc0203436 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02035f0:	03240a63          	beq	s0,s2,ffffffffc0203624 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02035f4:	03000513          	li	a0,48
ffffffffc02035f8:	950ff0ef          	jal	ra,ffffffffc0202748 <kmalloc>
ffffffffc02035fc:	85aa                	mv	a1,a0
ffffffffc02035fe:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203602:	fd79                	bnez	a0,ffffffffc02035e0 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0203604:	00002697          	auipc	a3,0x2
ffffffffc0203608:	04468693          	addi	a3,a3,68 # ffffffffc0205648 <default_pmm_manager+0x730>
ffffffffc020360c:	00001617          	auipc	a2,0x1
ffffffffc0203610:	55c60613          	addi	a2,a2,1372 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203614:	0d400593          	li	a1,212
ffffffffc0203618:	00002517          	auipc	a0,0x2
ffffffffc020361c:	3b050513          	addi	a0,a0,944 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203620:	d55fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc0203624:	649c                	ld	a5,8(s1)
ffffffffc0203626:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203628:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020362c:	2ef48463          	beq	s1,a5,ffffffffc0203914 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203630:	fe87b603          	ld	a2,-24(a5)
ffffffffc0203634:	ffe70693          	addi	a3,a4,-2
ffffffffc0203638:	26d61e63          	bne	a2,a3,ffffffffc02038b4 <vmm_init+0x378>
ffffffffc020363c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203640:	26e69a63          	bne	a3,a4,ffffffffc02038b4 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203644:	0715                	addi	a4,a4,5
ffffffffc0203646:	679c                	ld	a5,8(a5)
ffffffffc0203648:	feb712e3          	bne	a4,a1,ffffffffc020362c <vmm_init+0xf0>
ffffffffc020364c:	4b1d                	li	s6,7
ffffffffc020364e:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203650:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203654:	85a2                	mv	a1,s0
ffffffffc0203656:	8526                	mv	a0,s1
ffffffffc0203658:	d9fff0ef          	jal	ra,ffffffffc02033f6 <find_vma>
ffffffffc020365c:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020365e:	2c050b63          	beqz	a0,ffffffffc0203934 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203662:	00140593          	addi	a1,s0,1
ffffffffc0203666:	8526                	mv	a0,s1
ffffffffc0203668:	d8fff0ef          	jal	ra,ffffffffc02033f6 <find_vma>
ffffffffc020366c:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc020366e:	2e050363          	beqz	a0,ffffffffc0203954 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203672:	85da                	mv	a1,s6
ffffffffc0203674:	8526                	mv	a0,s1
ffffffffc0203676:	d81ff0ef          	jal	ra,ffffffffc02033f6 <find_vma>
        assert(vma3 == NULL);
ffffffffc020367a:	2e051d63          	bnez	a0,ffffffffc0203974 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020367e:	00340593          	addi	a1,s0,3
ffffffffc0203682:	8526                	mv	a0,s1
ffffffffc0203684:	d73ff0ef          	jal	ra,ffffffffc02033f6 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203688:	30051663          	bnez	a0,ffffffffc0203994 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020368c:	00440593          	addi	a1,s0,4
ffffffffc0203690:	8526                	mv	a0,s1
ffffffffc0203692:	d65ff0ef          	jal	ra,ffffffffc02033f6 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203696:	30051f63          	bnez	a0,ffffffffc02039b4 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020369a:	00893783          	ld	a5,8(s2)
ffffffffc020369e:	24879b63          	bne	a5,s0,ffffffffc02038f4 <vmm_init+0x3b8>
ffffffffc02036a2:	01093783          	ld	a5,16(s2)
ffffffffc02036a6:	25679763          	bne	a5,s6,ffffffffc02038f4 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02036aa:	008ab783          	ld	a5,8(s5)
ffffffffc02036ae:	22879363          	bne	a5,s0,ffffffffc02038d4 <vmm_init+0x398>
ffffffffc02036b2:	010ab783          	ld	a5,16(s5)
ffffffffc02036b6:	21679f63          	bne	a5,s6,ffffffffc02038d4 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02036ba:	0415                	addi	s0,s0,5
ffffffffc02036bc:	0b15                	addi	s6,s6,5
ffffffffc02036be:	f9741be3          	bne	s0,s7,ffffffffc0203654 <vmm_init+0x118>
ffffffffc02036c2:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02036c4:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02036c6:	85a2                	mv	a1,s0
ffffffffc02036c8:	8526                	mv	a0,s1
ffffffffc02036ca:	d2dff0ef          	jal	ra,ffffffffc02033f6 <find_vma>
ffffffffc02036ce:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02036d2:	c90d                	beqz	a0,ffffffffc0203704 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02036d4:	6914                	ld	a3,16(a0)
ffffffffc02036d6:	6510                	ld	a2,8(a0)
ffffffffc02036d8:	00002517          	auipc	a0,0x2
ffffffffc02036dc:	46050513          	addi	a0,a0,1120 # ffffffffc0205b38 <default_pmm_manager+0xc20>
ffffffffc02036e0:	9dbfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02036e4:	00002697          	auipc	a3,0x2
ffffffffc02036e8:	47c68693          	addi	a3,a3,1148 # ffffffffc0205b60 <default_pmm_manager+0xc48>
ffffffffc02036ec:	00001617          	auipc	a2,0x1
ffffffffc02036f0:	47c60613          	addi	a2,a2,1148 # ffffffffc0204b68 <commands+0x738>
ffffffffc02036f4:	0f600593          	li	a1,246
ffffffffc02036f8:	00002517          	auipc	a0,0x2
ffffffffc02036fc:	2d050513          	addi	a0,a0,720 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203700:	c75fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203704:	147d                	addi	s0,s0,-1
ffffffffc0203706:	fd2410e3          	bne	s0,s2,ffffffffc02036c6 <vmm_init+0x18a>
ffffffffc020370a:	a811                	j	ffffffffc020371e <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc020370c:	6118                	ld	a4,0(a0)
ffffffffc020370e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203710:	03000593          	li	a1,48
ffffffffc0203714:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203716:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203718:	e398                	sd	a4,0(a5)
ffffffffc020371a:	8e8ff0ef          	jal	ra,ffffffffc0202802 <kfree>
    return listelm->next;
ffffffffc020371e:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203720:	fea496e3          	bne	s1,a0,ffffffffc020370c <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203724:	03000593          	li	a1,48
ffffffffc0203728:	8526                	mv	a0,s1
ffffffffc020372a:	8d8ff0ef          	jal	ra,ffffffffc0202802 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020372e:	f35fd0ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
ffffffffc0203732:	3caa1163          	bne	s4,a0,ffffffffc0203af4 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203736:	00002517          	auipc	a0,0x2
ffffffffc020373a:	46a50513          	addi	a0,a0,1130 # ffffffffc0205ba0 <default_pmm_manager+0xc88>
ffffffffc020373e:	97dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203742:	f21fd0ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
ffffffffc0203746:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203748:	03000513          	li	a0,48
ffffffffc020374c:	ffdfe0ef          	jal	ra,ffffffffc0202748 <kmalloc>
ffffffffc0203750:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203752:	2a050163          	beqz	a0,ffffffffc02039f4 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203756:	0000d797          	auipc	a5,0xd
ffffffffc020375a:	dea7a783          	lw	a5,-534(a5) # ffffffffc0210540 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020375e:	e508                	sd	a0,8(a0)
ffffffffc0203760:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203762:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203766:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020376a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020376e:	14079063          	bnez	a5,ffffffffc02038ae <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0203772:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203776:	0000d917          	auipc	s2,0xd
ffffffffc020377a:	d9293903          	ld	s2,-622(s2) # ffffffffc0210508 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020377e:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203782:	0000d717          	auipc	a4,0xd
ffffffffc0203786:	dc873323          	sd	s0,-570(a4) # ffffffffc0210548 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020378a:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc020378e:	24079363          	bnez	a5,ffffffffc02039d4 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203792:	03000513          	li	a0,48
ffffffffc0203796:	fb3fe0ef          	jal	ra,ffffffffc0202748 <kmalloc>
ffffffffc020379a:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020379c:	28050063          	beqz	a0,ffffffffc0203a1c <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02037a0:	002007b7          	lui	a5,0x200
ffffffffc02037a4:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02037a8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02037aa:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02037ac:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02037b0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02037b2:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02037b6:	c81ff0ef          	jal	ra,ffffffffc0203436 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02037ba:	10000593          	li	a1,256
ffffffffc02037be:	8522                	mv	a0,s0
ffffffffc02037c0:	c37ff0ef          	jal	ra,ffffffffc02033f6 <find_vma>
ffffffffc02037c4:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02037c8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02037cc:	26aa1863          	bne	s4,a0,ffffffffc0203a3c <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc02037d0:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc02037d4:	0785                	addi	a5,a5,1
ffffffffc02037d6:	fee79de3          	bne	a5,a4,ffffffffc02037d0 <vmm_init+0x294>
        sum += i;
ffffffffc02037da:	6705                	lui	a4,0x1
ffffffffc02037dc:	10000793          	li	a5,256
ffffffffc02037e0:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02037e4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02037e8:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02037ec:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02037ee:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02037f0:	fec79ce3          	bne	a5,a2,ffffffffc02037e8 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc02037f4:	26071463          	bnez	a4,ffffffffc0203a5c <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02037f8:	4581                	li	a1,0
ffffffffc02037fa:	854a                	mv	a0,s2
ffffffffc02037fc:	8f0fe0ef          	jal	ra,ffffffffc02018ec <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203800:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203804:	0000d717          	auipc	a4,0xd
ffffffffc0203808:	d0c73703          	ld	a4,-756(a4) # ffffffffc0210510 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc020380c:	078a                	slli	a5,a5,0x2
ffffffffc020380e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203810:	26e7f663          	bgeu	a5,a4,ffffffffc0203a7c <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203814:	00002717          	auipc	a4,0x2
ffffffffc0203818:	75473703          	ld	a4,1876(a4) # ffffffffc0205f68 <nbase>
ffffffffc020381c:	8f99                	sub	a5,a5,a4
ffffffffc020381e:	00379713          	slli	a4,a5,0x3
ffffffffc0203822:	97ba                	add	a5,a5,a4
ffffffffc0203824:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203826:	0000d517          	auipc	a0,0xd
ffffffffc020382a:	cf253503          	ld	a0,-782(a0) # ffffffffc0210518 <pages>
ffffffffc020382e:	953e                	add	a0,a0,a5
ffffffffc0203830:	4585                	li	a1,1
ffffffffc0203832:	df1fd0ef          	jal	ra,ffffffffc0201622 <free_pages>
    return listelm->next;
ffffffffc0203836:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203838:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc020383c:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203840:	00a40e63          	beq	s0,a0,ffffffffc020385c <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203844:	6118                	ld	a4,0(a0)
ffffffffc0203846:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203848:	03000593          	li	a1,48
ffffffffc020384c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020384e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203850:	e398                	sd	a4,0(a5)
ffffffffc0203852:	fb1fe0ef          	jal	ra,ffffffffc0202802 <kfree>
    return listelm->next;
ffffffffc0203856:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203858:	fea416e3          	bne	s0,a0,ffffffffc0203844 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020385c:	03000593          	li	a1,48
ffffffffc0203860:	8522                	mv	a0,s0
ffffffffc0203862:	fa1fe0ef          	jal	ra,ffffffffc0202802 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203866:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203868:	0000d797          	auipc	a5,0xd
ffffffffc020386c:	ce07b023          	sd	zero,-800(a5) # ffffffffc0210548 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203870:	df3fd0ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
ffffffffc0203874:	22a49063          	bne	s1,a0,ffffffffc0203a94 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203878:	00002517          	auipc	a0,0x2
ffffffffc020387c:	37850513          	addi	a0,a0,888 # ffffffffc0205bf0 <default_pmm_manager+0xcd8>
ffffffffc0203880:	83bfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203884:	ddffd0ef          	jal	ra,ffffffffc0201662 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203888:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020388a:	22a99563          	bne	s3,a0,ffffffffc0203ab4 <vmm_init+0x578>
}
ffffffffc020388e:	6406                	ld	s0,64(sp)
ffffffffc0203890:	60a6                	ld	ra,72(sp)
ffffffffc0203892:	74e2                	ld	s1,56(sp)
ffffffffc0203894:	7942                	ld	s2,48(sp)
ffffffffc0203896:	79a2                	ld	s3,40(sp)
ffffffffc0203898:	7a02                	ld	s4,32(sp)
ffffffffc020389a:	6ae2                	ld	s5,24(sp)
ffffffffc020389c:	6b42                	ld	s6,16(sp)
ffffffffc020389e:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038a0:	00002517          	auipc	a0,0x2
ffffffffc02038a4:	37050513          	addi	a0,a0,880 # ffffffffc0205c10 <default_pmm_manager+0xcf8>
}
ffffffffc02038a8:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038aa:	811fc06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038ae:	ea6ff0ef          	jal	ra,ffffffffc0202f54 <swap_init_mm>
ffffffffc02038b2:	b5d1                	j	ffffffffc0203776 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02038b4:	00002697          	auipc	a3,0x2
ffffffffc02038b8:	19c68693          	addi	a3,a3,412 # ffffffffc0205a50 <default_pmm_manager+0xb38>
ffffffffc02038bc:	00001617          	auipc	a2,0x1
ffffffffc02038c0:	2ac60613          	addi	a2,a2,684 # ffffffffc0204b68 <commands+0x738>
ffffffffc02038c4:	0dd00593          	li	a1,221
ffffffffc02038c8:	00002517          	auipc	a0,0x2
ffffffffc02038cc:	10050513          	addi	a0,a0,256 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc02038d0:	aa5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02038d4:	00002697          	auipc	a3,0x2
ffffffffc02038d8:	23468693          	addi	a3,a3,564 # ffffffffc0205b08 <default_pmm_manager+0xbf0>
ffffffffc02038dc:	00001617          	auipc	a2,0x1
ffffffffc02038e0:	28c60613          	addi	a2,a2,652 # ffffffffc0204b68 <commands+0x738>
ffffffffc02038e4:	0ee00593          	li	a1,238
ffffffffc02038e8:	00002517          	auipc	a0,0x2
ffffffffc02038ec:	0e050513          	addi	a0,a0,224 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc02038f0:	a85fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02038f4:	00002697          	auipc	a3,0x2
ffffffffc02038f8:	1e468693          	addi	a3,a3,484 # ffffffffc0205ad8 <default_pmm_manager+0xbc0>
ffffffffc02038fc:	00001617          	auipc	a2,0x1
ffffffffc0203900:	26c60613          	addi	a2,a2,620 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203904:	0ed00593          	li	a1,237
ffffffffc0203908:	00002517          	auipc	a0,0x2
ffffffffc020390c:	0c050513          	addi	a0,a0,192 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203910:	a65fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203914:	00002697          	auipc	a3,0x2
ffffffffc0203918:	12468693          	addi	a3,a3,292 # ffffffffc0205a38 <default_pmm_manager+0xb20>
ffffffffc020391c:	00001617          	auipc	a2,0x1
ffffffffc0203920:	24c60613          	addi	a2,a2,588 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203924:	0db00593          	li	a1,219
ffffffffc0203928:	00002517          	auipc	a0,0x2
ffffffffc020392c:	0a050513          	addi	a0,a0,160 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203930:	a45fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203934:	00002697          	auipc	a3,0x2
ffffffffc0203938:	15468693          	addi	a3,a3,340 # ffffffffc0205a88 <default_pmm_manager+0xb70>
ffffffffc020393c:	00001617          	auipc	a2,0x1
ffffffffc0203940:	22c60613          	addi	a2,a2,556 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203944:	0e300593          	li	a1,227
ffffffffc0203948:	00002517          	auipc	a0,0x2
ffffffffc020394c:	08050513          	addi	a0,a0,128 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203950:	a25fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203954:	00002697          	auipc	a3,0x2
ffffffffc0203958:	14468693          	addi	a3,a3,324 # ffffffffc0205a98 <default_pmm_manager+0xb80>
ffffffffc020395c:	00001617          	auipc	a2,0x1
ffffffffc0203960:	20c60613          	addi	a2,a2,524 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203964:	0e500593          	li	a1,229
ffffffffc0203968:	00002517          	auipc	a0,0x2
ffffffffc020396c:	06050513          	addi	a0,a0,96 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203970:	a05fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203974:	00002697          	auipc	a3,0x2
ffffffffc0203978:	13468693          	addi	a3,a3,308 # ffffffffc0205aa8 <default_pmm_manager+0xb90>
ffffffffc020397c:	00001617          	auipc	a2,0x1
ffffffffc0203980:	1ec60613          	addi	a2,a2,492 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203984:	0e700593          	li	a1,231
ffffffffc0203988:	00002517          	auipc	a0,0x2
ffffffffc020398c:	04050513          	addi	a0,a0,64 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203990:	9e5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203994:	00002697          	auipc	a3,0x2
ffffffffc0203998:	12468693          	addi	a3,a3,292 # ffffffffc0205ab8 <default_pmm_manager+0xba0>
ffffffffc020399c:	00001617          	auipc	a2,0x1
ffffffffc02039a0:	1cc60613          	addi	a2,a2,460 # ffffffffc0204b68 <commands+0x738>
ffffffffc02039a4:	0e900593          	li	a1,233
ffffffffc02039a8:	00002517          	auipc	a0,0x2
ffffffffc02039ac:	02050513          	addi	a0,a0,32 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc02039b0:	9c5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc02039b4:	00002697          	auipc	a3,0x2
ffffffffc02039b8:	11468693          	addi	a3,a3,276 # ffffffffc0205ac8 <default_pmm_manager+0xbb0>
ffffffffc02039bc:	00001617          	auipc	a2,0x1
ffffffffc02039c0:	1ac60613          	addi	a2,a2,428 # ffffffffc0204b68 <commands+0x738>
ffffffffc02039c4:	0eb00593          	li	a1,235
ffffffffc02039c8:	00002517          	auipc	a0,0x2
ffffffffc02039cc:	00050513          	mv	a0,a0
ffffffffc02039d0:	9a5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02039d4:	00002697          	auipc	a3,0x2
ffffffffc02039d8:	c6468693          	addi	a3,a3,-924 # ffffffffc0205638 <default_pmm_manager+0x720>
ffffffffc02039dc:	00001617          	auipc	a2,0x1
ffffffffc02039e0:	18c60613          	addi	a2,a2,396 # ffffffffc0204b68 <commands+0x738>
ffffffffc02039e4:	10d00593          	li	a1,269
ffffffffc02039e8:	00002517          	auipc	a0,0x2
ffffffffc02039ec:	fe050513          	addi	a0,a0,-32 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc02039f0:	985fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02039f4:	00002697          	auipc	a3,0x2
ffffffffc02039f8:	23468693          	addi	a3,a3,564 # ffffffffc0205c28 <default_pmm_manager+0xd10>
ffffffffc02039fc:	00001617          	auipc	a2,0x1
ffffffffc0203a00:	16c60613          	addi	a2,a2,364 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203a04:	10a00593          	li	a1,266
ffffffffc0203a08:	00002517          	auipc	a0,0x2
ffffffffc0203a0c:	fc050513          	addi	a0,a0,-64 # ffffffffc02059c8 <default_pmm_manager+0xab0>
    check_mm_struct = mm_create();
ffffffffc0203a10:	0000d797          	auipc	a5,0xd
ffffffffc0203a14:	b207bc23          	sd	zero,-1224(a5) # ffffffffc0210548 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203a18:	95dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203a1c:	00002697          	auipc	a3,0x2
ffffffffc0203a20:	c2c68693          	addi	a3,a3,-980 # ffffffffc0205648 <default_pmm_manager+0x730>
ffffffffc0203a24:	00001617          	auipc	a2,0x1
ffffffffc0203a28:	14460613          	addi	a2,a2,324 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203a2c:	11100593          	li	a1,273
ffffffffc0203a30:	00002517          	auipc	a0,0x2
ffffffffc0203a34:	f9850513          	addi	a0,a0,-104 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203a38:	93dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a3c:	00002697          	auipc	a3,0x2
ffffffffc0203a40:	18468693          	addi	a3,a3,388 # ffffffffc0205bc0 <default_pmm_manager+0xca8>
ffffffffc0203a44:	00001617          	auipc	a2,0x1
ffffffffc0203a48:	12460613          	addi	a2,a2,292 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203a4c:	11600593          	li	a1,278
ffffffffc0203a50:	00002517          	auipc	a0,0x2
ffffffffc0203a54:	f7850513          	addi	a0,a0,-136 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203a58:	91dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203a5c:	00002697          	auipc	a3,0x2
ffffffffc0203a60:	18468693          	addi	a3,a3,388 # ffffffffc0205be0 <default_pmm_manager+0xcc8>
ffffffffc0203a64:	00001617          	auipc	a2,0x1
ffffffffc0203a68:	10460613          	addi	a2,a2,260 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203a6c:	12000593          	li	a1,288
ffffffffc0203a70:	00002517          	auipc	a0,0x2
ffffffffc0203a74:	f5850513          	addi	a0,a0,-168 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203a78:	8fdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203a7c:	00001617          	auipc	a2,0x1
ffffffffc0203a80:	4d460613          	addi	a2,a2,1236 # ffffffffc0204f50 <default_pmm_manager+0x38>
ffffffffc0203a84:	06500593          	li	a1,101
ffffffffc0203a88:	00001517          	auipc	a0,0x1
ffffffffc0203a8c:	4e850513          	addi	a0,a0,1256 # ffffffffc0204f70 <default_pmm_manager+0x58>
ffffffffc0203a90:	8e5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a94:	00002697          	auipc	a3,0x2
ffffffffc0203a98:	0e468693          	addi	a3,a3,228 # ffffffffc0205b78 <default_pmm_manager+0xc60>
ffffffffc0203a9c:	00001617          	auipc	a2,0x1
ffffffffc0203aa0:	0cc60613          	addi	a2,a2,204 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203aa4:	12e00593          	li	a1,302
ffffffffc0203aa8:	00002517          	auipc	a0,0x2
ffffffffc0203aac:	f2050513          	addi	a0,a0,-224 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203ab0:	8c5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ab4:	00002697          	auipc	a3,0x2
ffffffffc0203ab8:	0c468693          	addi	a3,a3,196 # ffffffffc0205b78 <default_pmm_manager+0xc60>
ffffffffc0203abc:	00001617          	auipc	a2,0x1
ffffffffc0203ac0:	0ac60613          	addi	a2,a2,172 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203ac4:	0bd00593          	li	a1,189
ffffffffc0203ac8:	00002517          	auipc	a0,0x2
ffffffffc0203acc:	f0050513          	addi	a0,a0,-256 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203ad0:	8a5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203ad4:	00002697          	auipc	a3,0x2
ffffffffc0203ad8:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0205610 <default_pmm_manager+0x6f8>
ffffffffc0203adc:	00001617          	auipc	a2,0x1
ffffffffc0203ae0:	08c60613          	addi	a2,a2,140 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203ae4:	0c700593          	li	a1,199
ffffffffc0203ae8:	00002517          	auipc	a0,0x2
ffffffffc0203aec:	ee050513          	addi	a0,a0,-288 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203af0:	885fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203af4:	00002697          	auipc	a3,0x2
ffffffffc0203af8:	08468693          	addi	a3,a3,132 # ffffffffc0205b78 <default_pmm_manager+0xc60>
ffffffffc0203afc:	00001617          	auipc	a2,0x1
ffffffffc0203b00:	06c60613          	addi	a2,a2,108 # ffffffffc0204b68 <commands+0x738>
ffffffffc0203b04:	0fb00593          	li	a1,251
ffffffffc0203b08:	00002517          	auipc	a0,0x2
ffffffffc0203b0c:	ec050513          	addi	a0,a0,-320 # ffffffffc02059c8 <default_pmm_manager+0xab0>
ffffffffc0203b10:	865fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b14 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b14:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b16:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b18:	e822                	sd	s0,16(sp)
ffffffffc0203b1a:	e426                	sd	s1,8(sp)
ffffffffc0203b1c:	ec06                	sd	ra,24(sp)
ffffffffc0203b1e:	e04a                	sd	s2,0(sp)
ffffffffc0203b20:	8432                	mv	s0,a2
ffffffffc0203b22:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b24:	8d3ff0ef          	jal	ra,ffffffffc02033f6 <find_vma>

    pgfault_num++;
ffffffffc0203b28:	0000d797          	auipc	a5,0xd
ffffffffc0203b2c:	a287a783          	lw	a5,-1496(a5) # ffffffffc0210550 <pgfault_num>
ffffffffc0203b30:	2785                	addiw	a5,a5,1
ffffffffc0203b32:	0000d717          	auipc	a4,0xd
ffffffffc0203b36:	a0f72f23          	sw	a5,-1506(a4) # ffffffffc0210550 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b3a:	c929                	beqz	a0,ffffffffc0203b8c <do_pgfault+0x78>
ffffffffc0203b3c:	651c                	ld	a5,8(a0)
ffffffffc0203b3e:	04f46763          	bltu	s0,a5,ffffffffc0203b8c <do_pgfault+0x78>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b42:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203b44:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b46:	8b89                	andi	a5,a5,2
ffffffffc0203b48:	e395                	bnez	a5,ffffffffc0203b6c <do_pgfault+0x58>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b4a:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b4c:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b4e:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b50:	85a2                	mv	a1,s0
ffffffffc0203b52:	4605                	li	a2,1
ffffffffc0203b54:	b49fd0ef          	jal	ra,ffffffffc020169c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203b58:	610c                	ld	a1,0(a0)
ffffffffc0203b5a:	c999                	beqz	a1,ffffffffc0203b70 <do_pgfault+0x5c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203b5c:	0000d797          	auipc	a5,0xd
ffffffffc0203b60:	9e47a783          	lw	a5,-1564(a5) # ffffffffc0210540 <swap_init_ok>
ffffffffc0203b64:	cf8d                	beqz	a5,ffffffffc0203b9e <do_pgfault+0x8a>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0203b66:	04003023          	sd	zero,64(zero) # 40 <kern_entry-0xffffffffc01fffc0>
ffffffffc0203b6a:	9002                	ebreak
        perm |= (PTE_R | PTE_W);
ffffffffc0203b6c:	4959                	li	s2,22
ffffffffc0203b6e:	bff1                	j	ffffffffc0203b4a <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203b70:	6c88                	ld	a0,24(s1)
ffffffffc0203b72:	864a                	mv	a2,s2
ffffffffc0203b74:	85a2                	mv	a1,s0
ffffffffc0203b76:	b1bfe0ef          	jal	ra,ffffffffc0202690 <pgdir_alloc_page>
ffffffffc0203b7a:	87aa                	mv	a5,a0
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203b7c:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203b7e:	cb85                	beqz	a5,ffffffffc0203bae <do_pgfault+0x9a>
failed:
    return ret;
}
ffffffffc0203b80:	60e2                	ld	ra,24(sp)
ffffffffc0203b82:	6442                	ld	s0,16(sp)
ffffffffc0203b84:	64a2                	ld	s1,8(sp)
ffffffffc0203b86:	6902                	ld	s2,0(sp)
ffffffffc0203b88:	6105                	addi	sp,sp,32
ffffffffc0203b8a:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203b8c:	85a2                	mv	a1,s0
ffffffffc0203b8e:	00002517          	auipc	a0,0x2
ffffffffc0203b92:	0b250513          	addi	a0,a0,178 # ffffffffc0205c40 <default_pmm_manager+0xd28>
ffffffffc0203b96:	d24fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203b9a:	5575                	li	a0,-3
        goto failed;
ffffffffc0203b9c:	b7d5                	j	ffffffffc0203b80 <do_pgfault+0x6c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203b9e:	00002517          	auipc	a0,0x2
ffffffffc0203ba2:	0fa50513          	addi	a0,a0,250 # ffffffffc0205c98 <default_pmm_manager+0xd80>
ffffffffc0203ba6:	d14fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203baa:	5571                	li	a0,-4
            goto failed;
ffffffffc0203bac:	bfd1                	j	ffffffffc0203b80 <do_pgfault+0x6c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203bae:	00002517          	auipc	a0,0x2
ffffffffc0203bb2:	0c250513          	addi	a0,a0,194 # ffffffffc0205c70 <default_pmm_manager+0xd58>
ffffffffc0203bb6:	d04fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203bba:	5571                	li	a0,-4
            goto failed;
ffffffffc0203bbc:	b7d1                	j	ffffffffc0203b80 <do_pgfault+0x6c>

ffffffffc0203bbe <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203bbe:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bc0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203bc2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bc4:	8d1fc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203bc8:	cd01                	beqz	a0,ffffffffc0203be0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203bca:	4505                	li	a0,1
ffffffffc0203bcc:	8cffc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203bd0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203bd2:	810d                	srli	a0,a0,0x3
ffffffffc0203bd4:	0000d797          	auipc	a5,0xd
ffffffffc0203bd8:	94a7be23          	sd	a0,-1700(a5) # ffffffffc0210530 <max_swap_offset>
}
ffffffffc0203bdc:	0141                	addi	sp,sp,16
ffffffffc0203bde:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203be0:	00002617          	auipc	a2,0x2
ffffffffc0203be4:	0e060613          	addi	a2,a2,224 # ffffffffc0205cc0 <default_pmm_manager+0xda8>
ffffffffc0203be8:	45b5                	li	a1,13
ffffffffc0203bea:	00002517          	auipc	a0,0x2
ffffffffc0203bee:	0f650513          	addi	a0,a0,246 # ffffffffc0205ce0 <default_pmm_manager+0xdc8>
ffffffffc0203bf2:	f82fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203bf6 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203bf6:	1141                	addi	sp,sp,-16
ffffffffc0203bf8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203bfa:	00855793          	srli	a5,a0,0x8
ffffffffc0203bfe:	c3a5                	beqz	a5,ffffffffc0203c5e <swapfs_write+0x68>
ffffffffc0203c00:	0000d717          	auipc	a4,0xd
ffffffffc0203c04:	93073703          	ld	a4,-1744(a4) # ffffffffc0210530 <max_swap_offset>
ffffffffc0203c08:	04e7fb63          	bgeu	a5,a4,ffffffffc0203c5e <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c0c:	0000d617          	auipc	a2,0xd
ffffffffc0203c10:	90c63603          	ld	a2,-1780(a2) # ffffffffc0210518 <pages>
ffffffffc0203c14:	8d91                	sub	a1,a1,a2
ffffffffc0203c16:	4035d613          	srai	a2,a1,0x3
ffffffffc0203c1a:	00002597          	auipc	a1,0x2
ffffffffc0203c1e:	3465b583          	ld	a1,838(a1) # ffffffffc0205f60 <error_string+0x38>
ffffffffc0203c22:	02b60633          	mul	a2,a2,a1
ffffffffc0203c26:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203c2a:	00002797          	auipc	a5,0x2
ffffffffc0203c2e:	33e7b783          	ld	a5,830(a5) # ffffffffc0205f68 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c32:	0000d717          	auipc	a4,0xd
ffffffffc0203c36:	8de73703          	ld	a4,-1826(a4) # ffffffffc0210510 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c3a:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c3c:	00c61793          	slli	a5,a2,0xc
ffffffffc0203c40:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c42:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c44:	02e7f963          	bgeu	a5,a4,ffffffffc0203c76 <swapfs_write+0x80>
}
ffffffffc0203c48:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c4a:	0000d797          	auipc	a5,0xd
ffffffffc0203c4e:	8de7b783          	ld	a5,-1826(a5) # ffffffffc0210528 <va_pa_offset>
ffffffffc0203c52:	46a1                	li	a3,8
ffffffffc0203c54:	963e                	add	a2,a2,a5
ffffffffc0203c56:	4505                	li	a0,1
}
ffffffffc0203c58:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c5a:	847fc06f          	j	ffffffffc02004a0 <ide_write_secs>
ffffffffc0203c5e:	86aa                	mv	a3,a0
ffffffffc0203c60:	00002617          	auipc	a2,0x2
ffffffffc0203c64:	09860613          	addi	a2,a2,152 # ffffffffc0205cf8 <default_pmm_manager+0xde0>
ffffffffc0203c68:	45e5                	li	a1,25
ffffffffc0203c6a:	00002517          	auipc	a0,0x2
ffffffffc0203c6e:	07650513          	addi	a0,a0,118 # ffffffffc0205ce0 <default_pmm_manager+0xdc8>
ffffffffc0203c72:	f02fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203c76:	86b2                	mv	a3,a2
ffffffffc0203c78:	06a00593          	li	a1,106
ffffffffc0203c7c:	00001617          	auipc	a2,0x1
ffffffffc0203c80:	32c60613          	addi	a2,a2,812 # ffffffffc0204fa8 <default_pmm_manager+0x90>
ffffffffc0203c84:	00001517          	auipc	a0,0x1
ffffffffc0203c88:	2ec50513          	addi	a0,a0,748 # ffffffffc0204f70 <default_pmm_manager+0x58>
ffffffffc0203c8c:	ee8fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c90 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203c90:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203c94:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203c96:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203c9a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203c9c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ca0:	f022                	sd	s0,32(sp)
ffffffffc0203ca2:	ec26                	sd	s1,24(sp)
ffffffffc0203ca4:	e84a                	sd	s2,16(sp)
ffffffffc0203ca6:	f406                	sd	ra,40(sp)
ffffffffc0203ca8:	e44e                	sd	s3,8(sp)
ffffffffc0203caa:	84aa                	mv	s1,a0
ffffffffc0203cac:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203cae:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203cb2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203cb4:	03067e63          	bgeu	a2,a6,ffffffffc0203cf0 <printnum+0x60>
ffffffffc0203cb8:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203cba:	00805763          	blez	s0,ffffffffc0203cc8 <printnum+0x38>
ffffffffc0203cbe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203cc0:	85ca                	mv	a1,s2
ffffffffc0203cc2:	854e                	mv	a0,s3
ffffffffc0203cc4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203cc6:	fc65                	bnez	s0,ffffffffc0203cbe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203cc8:	1a02                	slli	s4,s4,0x20
ffffffffc0203cca:	00002797          	auipc	a5,0x2
ffffffffc0203cce:	04e78793          	addi	a5,a5,78 # ffffffffc0205d18 <default_pmm_manager+0xe00>
ffffffffc0203cd2:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203cd6:	9a3e                	add	s4,s4,a5
}
ffffffffc0203cd8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203cda:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203cde:	70a2                	ld	ra,40(sp)
ffffffffc0203ce0:	69a2                	ld	s3,8(sp)
ffffffffc0203ce2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ce4:	85ca                	mv	a1,s2
ffffffffc0203ce6:	87a6                	mv	a5,s1
}
ffffffffc0203ce8:	6942                	ld	s2,16(sp)
ffffffffc0203cea:	64e2                	ld	s1,24(sp)
ffffffffc0203cec:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203cee:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203cf0:	03065633          	divu	a2,a2,a6
ffffffffc0203cf4:	8722                	mv	a4,s0
ffffffffc0203cf6:	f9bff0ef          	jal	ra,ffffffffc0203c90 <printnum>
ffffffffc0203cfa:	b7f9                	j	ffffffffc0203cc8 <printnum+0x38>

ffffffffc0203cfc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203cfc:	7119                	addi	sp,sp,-128
ffffffffc0203cfe:	f4a6                	sd	s1,104(sp)
ffffffffc0203d00:	f0ca                	sd	s2,96(sp)
ffffffffc0203d02:	ecce                	sd	s3,88(sp)
ffffffffc0203d04:	e8d2                	sd	s4,80(sp)
ffffffffc0203d06:	e4d6                	sd	s5,72(sp)
ffffffffc0203d08:	e0da                	sd	s6,64(sp)
ffffffffc0203d0a:	fc5e                	sd	s7,56(sp)
ffffffffc0203d0c:	f06a                	sd	s10,32(sp)
ffffffffc0203d0e:	fc86                	sd	ra,120(sp)
ffffffffc0203d10:	f8a2                	sd	s0,112(sp)
ffffffffc0203d12:	f862                	sd	s8,48(sp)
ffffffffc0203d14:	f466                	sd	s9,40(sp)
ffffffffc0203d16:	ec6e                	sd	s11,24(sp)
ffffffffc0203d18:	892a                	mv	s2,a0
ffffffffc0203d1a:	84ae                	mv	s1,a1
ffffffffc0203d1c:	8d32                	mv	s10,a2
ffffffffc0203d1e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203d20:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203d24:	5b7d                	li	s6,-1
ffffffffc0203d26:	00002a97          	auipc	s5,0x2
ffffffffc0203d2a:	026a8a93          	addi	s5,s5,38 # ffffffffc0205d4c <default_pmm_manager+0xe34>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203d2e:	00002b97          	auipc	s7,0x2
ffffffffc0203d32:	1fab8b93          	addi	s7,s7,506 # ffffffffc0205f28 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203d36:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203d3a:	001d0413          	addi	s0,s10,1
ffffffffc0203d3e:	01350a63          	beq	a0,s3,ffffffffc0203d52 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203d42:	c121                	beqz	a0,ffffffffc0203d82 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203d44:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203d46:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203d48:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203d4a:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203d4e:	ff351ae3          	bne	a0,s3,ffffffffc0203d42 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d52:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203d56:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203d5a:	4c81                	li	s9,0
ffffffffc0203d5c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203d5e:	5c7d                	li	s8,-1
ffffffffc0203d60:	5dfd                	li	s11,-1
ffffffffc0203d62:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203d66:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d68:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203d6c:	0ff5f593          	zext.b	a1,a1
ffffffffc0203d70:	00140d13          	addi	s10,s0,1
ffffffffc0203d74:	04b56263          	bltu	a0,a1,ffffffffc0203db8 <vprintfmt+0xbc>
ffffffffc0203d78:	058a                	slli	a1,a1,0x2
ffffffffc0203d7a:	95d6                	add	a1,a1,s5
ffffffffc0203d7c:	4194                	lw	a3,0(a1)
ffffffffc0203d7e:	96d6                	add	a3,a3,s5
ffffffffc0203d80:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203d82:	70e6                	ld	ra,120(sp)
ffffffffc0203d84:	7446                	ld	s0,112(sp)
ffffffffc0203d86:	74a6                	ld	s1,104(sp)
ffffffffc0203d88:	7906                	ld	s2,96(sp)
ffffffffc0203d8a:	69e6                	ld	s3,88(sp)
ffffffffc0203d8c:	6a46                	ld	s4,80(sp)
ffffffffc0203d8e:	6aa6                	ld	s5,72(sp)
ffffffffc0203d90:	6b06                	ld	s6,64(sp)
ffffffffc0203d92:	7be2                	ld	s7,56(sp)
ffffffffc0203d94:	7c42                	ld	s8,48(sp)
ffffffffc0203d96:	7ca2                	ld	s9,40(sp)
ffffffffc0203d98:	7d02                	ld	s10,32(sp)
ffffffffc0203d9a:	6de2                	ld	s11,24(sp)
ffffffffc0203d9c:	6109                	addi	sp,sp,128
ffffffffc0203d9e:	8082                	ret
            padc = '0';
ffffffffc0203da0:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203da2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203da6:	846a                	mv	s0,s10
ffffffffc0203da8:	00140d13          	addi	s10,s0,1
ffffffffc0203dac:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203db0:	0ff5f593          	zext.b	a1,a1
ffffffffc0203db4:	fcb572e3          	bgeu	a0,a1,ffffffffc0203d78 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203db8:	85a6                	mv	a1,s1
ffffffffc0203dba:	02500513          	li	a0,37
ffffffffc0203dbe:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203dc0:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203dc4:	8d22                	mv	s10,s0
ffffffffc0203dc6:	f73788e3          	beq	a5,s3,ffffffffc0203d36 <vprintfmt+0x3a>
ffffffffc0203dca:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203dce:	1d7d                	addi	s10,s10,-1
ffffffffc0203dd0:	ff379de3          	bne	a5,s3,ffffffffc0203dca <vprintfmt+0xce>
ffffffffc0203dd4:	b78d                	j	ffffffffc0203d36 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203dd6:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203dda:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203dde:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203de0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203de4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203de8:	02d86463          	bltu	a6,a3,ffffffffc0203e10 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203dec:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203df0:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203df4:	0186873b          	addw	a4,a3,s8
ffffffffc0203df8:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203dfc:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203dfe:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203e02:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203e04:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203e08:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203e0c:	fed870e3          	bgeu	a6,a3,ffffffffc0203dec <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0203e10:	f40ddce3          	bgez	s11,ffffffffc0203d68 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0203e14:	8de2                	mv	s11,s8
ffffffffc0203e16:	5c7d                	li	s8,-1
ffffffffc0203e18:	bf81                	j	ffffffffc0203d68 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0203e1a:	fffdc693          	not	a3,s11
ffffffffc0203e1e:	96fd                	srai	a3,a3,0x3f
ffffffffc0203e20:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e24:	00144603          	lbu	a2,1(s0)
ffffffffc0203e28:	2d81                	sext.w	s11,s11
ffffffffc0203e2a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203e2c:	bf35                	j	ffffffffc0203d68 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0203e2e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e32:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203e36:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e38:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0203e3a:	bfd9                	j	ffffffffc0203e10 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0203e3c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203e3e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203e42:	01174463          	blt	a4,a7,ffffffffc0203e4a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0203e46:	1a088e63          	beqz	a7,ffffffffc0204002 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0203e4a:	000a3603          	ld	a2,0(s4)
ffffffffc0203e4e:	46c1                	li	a3,16
ffffffffc0203e50:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203e52:	2781                	sext.w	a5,a5
ffffffffc0203e54:	876e                	mv	a4,s11
ffffffffc0203e56:	85a6                	mv	a1,s1
ffffffffc0203e58:	854a                	mv	a0,s2
ffffffffc0203e5a:	e37ff0ef          	jal	ra,ffffffffc0203c90 <printnum>
            break;
ffffffffc0203e5e:	bde1                	j	ffffffffc0203d36 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0203e60:	000a2503          	lw	a0,0(s4)
ffffffffc0203e64:	85a6                	mv	a1,s1
ffffffffc0203e66:	0a21                	addi	s4,s4,8
ffffffffc0203e68:	9902                	jalr	s2
            break;
ffffffffc0203e6a:	b5f1                	j	ffffffffc0203d36 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203e6c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203e6e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203e72:	01174463          	blt	a4,a7,ffffffffc0203e7a <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0203e76:	18088163          	beqz	a7,ffffffffc0203ff8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0203e7a:	000a3603          	ld	a2,0(s4)
ffffffffc0203e7e:	46a9                	li	a3,10
ffffffffc0203e80:	8a2e                	mv	s4,a1
ffffffffc0203e82:	bfc1                	j	ffffffffc0203e52 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e84:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203e88:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e8a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203e8c:	bdf1                	j	ffffffffc0203d68 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0203e8e:	85a6                	mv	a1,s1
ffffffffc0203e90:	02500513          	li	a0,37
ffffffffc0203e94:	9902                	jalr	s2
            break;
ffffffffc0203e96:	b545                	j	ffffffffc0203d36 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e98:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0203e9c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e9e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ea0:	b5e1                	j	ffffffffc0203d68 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0203ea2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203ea4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203ea8:	01174463          	blt	a4,a7,ffffffffc0203eb0 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0203eac:	14088163          	beqz	a7,ffffffffc0203fee <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0203eb0:	000a3603          	ld	a2,0(s4)
ffffffffc0203eb4:	46a1                	li	a3,8
ffffffffc0203eb6:	8a2e                	mv	s4,a1
ffffffffc0203eb8:	bf69                	j	ffffffffc0203e52 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0203eba:	03000513          	li	a0,48
ffffffffc0203ebe:	85a6                	mv	a1,s1
ffffffffc0203ec0:	e03e                	sd	a5,0(sp)
ffffffffc0203ec2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203ec4:	85a6                	mv	a1,s1
ffffffffc0203ec6:	07800513          	li	a0,120
ffffffffc0203eca:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203ecc:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203ece:	6782                	ld	a5,0(sp)
ffffffffc0203ed0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203ed2:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0203ed6:	bfb5                	j	ffffffffc0203e52 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203ed8:	000a3403          	ld	s0,0(s4)
ffffffffc0203edc:	008a0713          	addi	a4,s4,8
ffffffffc0203ee0:	e03a                	sd	a4,0(sp)
ffffffffc0203ee2:	14040263          	beqz	s0,ffffffffc0204026 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0203ee6:	0fb05763          	blez	s11,ffffffffc0203fd4 <vprintfmt+0x2d8>
ffffffffc0203eea:	02d00693          	li	a3,45
ffffffffc0203eee:	0cd79163          	bne	a5,a3,ffffffffc0203fb0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203ef2:	00044783          	lbu	a5,0(s0)
ffffffffc0203ef6:	0007851b          	sext.w	a0,a5
ffffffffc0203efa:	cf85                	beqz	a5,ffffffffc0203f32 <vprintfmt+0x236>
ffffffffc0203efc:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203f00:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f04:	000c4563          	bltz	s8,ffffffffc0203f0e <vprintfmt+0x212>
ffffffffc0203f08:	3c7d                	addiw	s8,s8,-1
ffffffffc0203f0a:	036c0263          	beq	s8,s6,ffffffffc0203f2e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0203f0e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203f10:	0e0c8e63          	beqz	s9,ffffffffc020400c <vprintfmt+0x310>
ffffffffc0203f14:	3781                	addiw	a5,a5,-32
ffffffffc0203f16:	0ef47b63          	bgeu	s0,a5,ffffffffc020400c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0203f1a:	03f00513          	li	a0,63
ffffffffc0203f1e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f20:	000a4783          	lbu	a5,0(s4)
ffffffffc0203f24:	3dfd                	addiw	s11,s11,-1
ffffffffc0203f26:	0a05                	addi	s4,s4,1
ffffffffc0203f28:	0007851b          	sext.w	a0,a5
ffffffffc0203f2c:	ffe1                	bnez	a5,ffffffffc0203f04 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0203f2e:	01b05963          	blez	s11,ffffffffc0203f40 <vprintfmt+0x244>
ffffffffc0203f32:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203f34:	85a6                	mv	a1,s1
ffffffffc0203f36:	02000513          	li	a0,32
ffffffffc0203f3a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203f3c:	fe0d9be3          	bnez	s11,ffffffffc0203f32 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203f40:	6a02                	ld	s4,0(sp)
ffffffffc0203f42:	bbd5                	j	ffffffffc0203d36 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f44:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203f46:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0203f4a:	01174463          	blt	a4,a7,ffffffffc0203f52 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0203f4e:	08088d63          	beqz	a7,ffffffffc0203fe8 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0203f52:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203f56:	0a044d63          	bltz	s0,ffffffffc0204010 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0203f5a:	8622                	mv	a2,s0
ffffffffc0203f5c:	8a66                	mv	s4,s9
ffffffffc0203f5e:	46a9                	li	a3,10
ffffffffc0203f60:	bdcd                	j	ffffffffc0203e52 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0203f62:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f66:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f68:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203f6a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f6e:	8fb5                	xor	a5,a5,a3
ffffffffc0203f70:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f74:	02d74163          	blt	a4,a3,ffffffffc0203f96 <vprintfmt+0x29a>
ffffffffc0203f78:	00369793          	slli	a5,a3,0x3
ffffffffc0203f7c:	97de                	add	a5,a5,s7
ffffffffc0203f7e:	639c                	ld	a5,0(a5)
ffffffffc0203f80:	cb99                	beqz	a5,ffffffffc0203f96 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f82:	86be                	mv	a3,a5
ffffffffc0203f84:	00002617          	auipc	a2,0x2
ffffffffc0203f88:	dc460613          	addi	a2,a2,-572 # ffffffffc0205d48 <default_pmm_manager+0xe30>
ffffffffc0203f8c:	85a6                	mv	a1,s1
ffffffffc0203f8e:	854a                	mv	a0,s2
ffffffffc0203f90:	0ce000ef          	jal	ra,ffffffffc020405e <printfmt>
ffffffffc0203f94:	b34d                	j	ffffffffc0203d36 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203f96:	00002617          	auipc	a2,0x2
ffffffffc0203f9a:	da260613          	addi	a2,a2,-606 # ffffffffc0205d38 <default_pmm_manager+0xe20>
ffffffffc0203f9e:	85a6                	mv	a1,s1
ffffffffc0203fa0:	854a                	mv	a0,s2
ffffffffc0203fa2:	0bc000ef          	jal	ra,ffffffffc020405e <printfmt>
ffffffffc0203fa6:	bb41                	j	ffffffffc0203d36 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203fa8:	00002417          	auipc	s0,0x2
ffffffffc0203fac:	d8840413          	addi	s0,s0,-632 # ffffffffc0205d30 <default_pmm_manager+0xe18>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203fb0:	85e2                	mv	a1,s8
ffffffffc0203fb2:	8522                	mv	a0,s0
ffffffffc0203fb4:	e43e                	sd	a5,8(sp)
ffffffffc0203fb6:	196000ef          	jal	ra,ffffffffc020414c <strnlen>
ffffffffc0203fba:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203fbe:	01b05b63          	blez	s11,ffffffffc0203fd4 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0203fc2:	67a2                	ld	a5,8(sp)
ffffffffc0203fc4:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203fc8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203fca:	85a6                	mv	a1,s1
ffffffffc0203fcc:	8552                	mv	a0,s4
ffffffffc0203fce:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203fd0:	fe0d9ce3          	bnez	s11,ffffffffc0203fc8 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fd4:	00044783          	lbu	a5,0(s0)
ffffffffc0203fd8:	00140a13          	addi	s4,s0,1
ffffffffc0203fdc:	0007851b          	sext.w	a0,a5
ffffffffc0203fe0:	d3a5                	beqz	a5,ffffffffc0203f40 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203fe2:	05e00413          	li	s0,94
ffffffffc0203fe6:	bf39                	j	ffffffffc0203f04 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0203fe8:	000a2403          	lw	s0,0(s4)
ffffffffc0203fec:	b7ad                	j	ffffffffc0203f56 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0203fee:	000a6603          	lwu	a2,0(s4)
ffffffffc0203ff2:	46a1                	li	a3,8
ffffffffc0203ff4:	8a2e                	mv	s4,a1
ffffffffc0203ff6:	bdb1                	j	ffffffffc0203e52 <vprintfmt+0x156>
ffffffffc0203ff8:	000a6603          	lwu	a2,0(s4)
ffffffffc0203ffc:	46a9                	li	a3,10
ffffffffc0203ffe:	8a2e                	mv	s4,a1
ffffffffc0204000:	bd89                	j	ffffffffc0203e52 <vprintfmt+0x156>
ffffffffc0204002:	000a6603          	lwu	a2,0(s4)
ffffffffc0204006:	46c1                	li	a3,16
ffffffffc0204008:	8a2e                	mv	s4,a1
ffffffffc020400a:	b5a1                	j	ffffffffc0203e52 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020400c:	9902                	jalr	s2
ffffffffc020400e:	bf09                	j	ffffffffc0203f20 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204010:	85a6                	mv	a1,s1
ffffffffc0204012:	02d00513          	li	a0,45
ffffffffc0204016:	e03e                	sd	a5,0(sp)
ffffffffc0204018:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020401a:	6782                	ld	a5,0(sp)
ffffffffc020401c:	8a66                	mv	s4,s9
ffffffffc020401e:	40800633          	neg	a2,s0
ffffffffc0204022:	46a9                	li	a3,10
ffffffffc0204024:	b53d                	j	ffffffffc0203e52 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204026:	03b05163          	blez	s11,ffffffffc0204048 <vprintfmt+0x34c>
ffffffffc020402a:	02d00693          	li	a3,45
ffffffffc020402e:	f6d79de3          	bne	a5,a3,ffffffffc0203fa8 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204032:	00002417          	auipc	s0,0x2
ffffffffc0204036:	cfe40413          	addi	s0,s0,-770 # ffffffffc0205d30 <default_pmm_manager+0xe18>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020403a:	02800793          	li	a5,40
ffffffffc020403e:	02800513          	li	a0,40
ffffffffc0204042:	00140a13          	addi	s4,s0,1
ffffffffc0204046:	bd6d                	j	ffffffffc0203f00 <vprintfmt+0x204>
ffffffffc0204048:	00002a17          	auipc	s4,0x2
ffffffffc020404c:	ce9a0a13          	addi	s4,s4,-791 # ffffffffc0205d31 <default_pmm_manager+0xe19>
ffffffffc0204050:	02800513          	li	a0,40
ffffffffc0204054:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204058:	05e00413          	li	s0,94
ffffffffc020405c:	b565                	j	ffffffffc0203f04 <vprintfmt+0x208>

ffffffffc020405e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020405e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204060:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204064:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204066:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204068:	ec06                	sd	ra,24(sp)
ffffffffc020406a:	f83a                	sd	a4,48(sp)
ffffffffc020406c:	fc3e                	sd	a5,56(sp)
ffffffffc020406e:	e0c2                	sd	a6,64(sp)
ffffffffc0204070:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204072:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204074:	c89ff0ef          	jal	ra,ffffffffc0203cfc <vprintfmt>
}
ffffffffc0204078:	60e2                	ld	ra,24(sp)
ffffffffc020407a:	6161                	addi	sp,sp,80
ffffffffc020407c:	8082                	ret

ffffffffc020407e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020407e:	715d                	addi	sp,sp,-80
ffffffffc0204080:	e486                	sd	ra,72(sp)
ffffffffc0204082:	e0a6                	sd	s1,64(sp)
ffffffffc0204084:	fc4a                	sd	s2,56(sp)
ffffffffc0204086:	f84e                	sd	s3,48(sp)
ffffffffc0204088:	f452                	sd	s4,40(sp)
ffffffffc020408a:	f056                	sd	s5,32(sp)
ffffffffc020408c:	ec5a                	sd	s6,24(sp)
ffffffffc020408e:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204090:	c901                	beqz	a0,ffffffffc02040a0 <readline+0x22>
ffffffffc0204092:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204094:	00002517          	auipc	a0,0x2
ffffffffc0204098:	cb450513          	addi	a0,a0,-844 # ffffffffc0205d48 <default_pmm_manager+0xe30>
ffffffffc020409c:	81efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02040a0:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02040a2:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02040a4:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02040a6:	4aa9                	li	s5,10
ffffffffc02040a8:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02040aa:	0000cb97          	auipc	s7,0xc
ffffffffc02040ae:	03eb8b93          	addi	s7,s7,62 # ffffffffc02100e8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02040b2:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02040b6:	83cfc0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02040ba:	00054a63          	bltz	a0,ffffffffc02040ce <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02040be:	00a95a63          	bge	s2,a0,ffffffffc02040d2 <readline+0x54>
ffffffffc02040c2:	029a5263          	bge	s4,s1,ffffffffc02040e6 <readline+0x68>
        c = getchar();
ffffffffc02040c6:	82cfc0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02040ca:	fe055ae3          	bgez	a0,ffffffffc02040be <readline+0x40>
            return NULL;
ffffffffc02040ce:	4501                	li	a0,0
ffffffffc02040d0:	a091                	j	ffffffffc0204114 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02040d2:	03351463          	bne	a0,s3,ffffffffc02040fa <readline+0x7c>
ffffffffc02040d6:	e8a9                	bnez	s1,ffffffffc0204128 <readline+0xaa>
        c = getchar();
ffffffffc02040d8:	81afc0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02040dc:	fe0549e3          	bltz	a0,ffffffffc02040ce <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02040e0:	fea959e3          	bge	s2,a0,ffffffffc02040d2 <readline+0x54>
ffffffffc02040e4:	4481                	li	s1,0
            cputchar(c);
ffffffffc02040e6:	e42a                	sd	a0,8(sp)
ffffffffc02040e8:	808fc0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02040ec:	6522                	ld	a0,8(sp)
ffffffffc02040ee:	009b87b3          	add	a5,s7,s1
ffffffffc02040f2:	2485                	addiw	s1,s1,1
ffffffffc02040f4:	00a78023          	sb	a0,0(a5)
ffffffffc02040f8:	bf7d                	j	ffffffffc02040b6 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02040fa:	01550463          	beq	a0,s5,ffffffffc0204102 <readline+0x84>
ffffffffc02040fe:	fb651ce3          	bne	a0,s6,ffffffffc02040b6 <readline+0x38>
            cputchar(c);
ffffffffc0204102:	feffb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204106:	0000c517          	auipc	a0,0xc
ffffffffc020410a:	fe250513          	addi	a0,a0,-30 # ffffffffc02100e8 <buf>
ffffffffc020410e:	94aa                	add	s1,s1,a0
ffffffffc0204110:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204114:	60a6                	ld	ra,72(sp)
ffffffffc0204116:	6486                	ld	s1,64(sp)
ffffffffc0204118:	7962                	ld	s2,56(sp)
ffffffffc020411a:	79c2                	ld	s3,48(sp)
ffffffffc020411c:	7a22                	ld	s4,40(sp)
ffffffffc020411e:	7a82                	ld	s5,32(sp)
ffffffffc0204120:	6b62                	ld	s6,24(sp)
ffffffffc0204122:	6bc2                	ld	s7,16(sp)
ffffffffc0204124:	6161                	addi	sp,sp,80
ffffffffc0204126:	8082                	ret
            cputchar(c);
ffffffffc0204128:	4521                	li	a0,8
ffffffffc020412a:	fc7fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc020412e:	34fd                	addiw	s1,s1,-1
ffffffffc0204130:	b759                	j	ffffffffc02040b6 <readline+0x38>

ffffffffc0204132 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204132:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204136:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204138:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020413a:	cb81                	beqz	a5,ffffffffc020414a <strlen+0x18>
        cnt ++;
ffffffffc020413c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020413e:	00a707b3          	add	a5,a4,a0
ffffffffc0204142:	0007c783          	lbu	a5,0(a5)
ffffffffc0204146:	fbfd                	bnez	a5,ffffffffc020413c <strlen+0xa>
ffffffffc0204148:	8082                	ret
    }
    return cnt;
}
ffffffffc020414a:	8082                	ret

ffffffffc020414c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020414c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020414e:	e589                	bnez	a1,ffffffffc0204158 <strnlen+0xc>
ffffffffc0204150:	a811                	j	ffffffffc0204164 <strnlen+0x18>
        cnt ++;
ffffffffc0204152:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204154:	00f58863          	beq	a1,a5,ffffffffc0204164 <strnlen+0x18>
ffffffffc0204158:	00f50733          	add	a4,a0,a5
ffffffffc020415c:	00074703          	lbu	a4,0(a4)
ffffffffc0204160:	fb6d                	bnez	a4,ffffffffc0204152 <strnlen+0x6>
ffffffffc0204162:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204164:	852e                	mv	a0,a1
ffffffffc0204166:	8082                	ret

ffffffffc0204168 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204168:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020416a:	0005c703          	lbu	a4,0(a1)
ffffffffc020416e:	0785                	addi	a5,a5,1
ffffffffc0204170:	0585                	addi	a1,a1,1
ffffffffc0204172:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204176:	fb75                	bnez	a4,ffffffffc020416a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204178:	8082                	ret

ffffffffc020417a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020417a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020417e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204182:	cb89                	beqz	a5,ffffffffc0204194 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204184:	0505                	addi	a0,a0,1
ffffffffc0204186:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204188:	fee789e3          	beq	a5,a4,ffffffffc020417a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020418c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204190:	9d19                	subw	a0,a0,a4
ffffffffc0204192:	8082                	ret
ffffffffc0204194:	4501                	li	a0,0
ffffffffc0204196:	bfed                	j	ffffffffc0204190 <strcmp+0x16>

ffffffffc0204198 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204198:	00054783          	lbu	a5,0(a0)
ffffffffc020419c:	c799                	beqz	a5,ffffffffc02041aa <strchr+0x12>
        if (*s == c) {
ffffffffc020419e:	00f58763          	beq	a1,a5,ffffffffc02041ac <strchr+0x14>
    while (*s != '\0') {
ffffffffc02041a2:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02041a6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02041a8:	fbfd                	bnez	a5,ffffffffc020419e <strchr+0x6>
    }
    return NULL;
ffffffffc02041aa:	4501                	li	a0,0
}
ffffffffc02041ac:	8082                	ret

ffffffffc02041ae <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02041ae:	ca01                	beqz	a2,ffffffffc02041be <memset+0x10>
ffffffffc02041b0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02041b2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02041b4:	0785                	addi	a5,a5,1
ffffffffc02041b6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02041ba:	fec79de3          	bne	a5,a2,ffffffffc02041b4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02041be:	8082                	ret

ffffffffc02041c0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02041c0:	ca19                	beqz	a2,ffffffffc02041d6 <memcpy+0x16>
ffffffffc02041c2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02041c4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02041c6:	0005c703          	lbu	a4,0(a1)
ffffffffc02041ca:	0585                	addi	a1,a1,1
ffffffffc02041cc:	0785                	addi	a5,a5,1
ffffffffc02041ce:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02041d2:	fec59ae3          	bne	a1,a2,ffffffffc02041c6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02041d6:	8082                	ret
