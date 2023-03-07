.section ".text.boot"

.global _start
.global _stop
.global kernel_main
.global validate_bss

.global enable_sfi
.global disable_sfi

// boot into el3, stack uninitialized
_start:
	mov x0, #0
	mrs x0, mpidr_el1
	and x0, x0, #3
	cbnz x0, _stop
 _boot_cpu:
	 ldr x0, =__bss_start
	 ldr w1, =__bss_size
/* Clear bss before entering C. */
1: cbz w1, 2f
	 str xzr, [x0], #8
	 sub w1, w1, #8 // linker guarantees bss length is multiple of 8
	 b 1b

 // checks that the bss was properly zerod, not called
check_bss_zeroed:
	ldr x0, =__bss_start
	ldr x1, =__bss_end
	bl validate_bss

/* Prepare the interrupt tables. */
2:
	ldr x0, =vtable_el2
	msr vbar_el2, x0

	ldr x0, =vtable_el1
	msr vbar_el1, x0

/* Set exception routing, finalize HCR */
3:
	ldr x0, #0
	orr x0, x0, #(1 << 30) 	// [31] = 0 -> el1 executes in aarch64
													// [5] = 0 -> serror in el0 not taken to el2
													// [4] = 0 -> irq in el0 not taken to el2
													// [3] = 0 -> fiq in el0 not taken to el2
	msr hcr_el2, x0	

/* Explicitly enable interrupts. */
4:bl enable_sfi

/* Configure EL2 and EL1 system state (pertaining to sctlr_eln) */
// TODO make sure this literal makes sense. It was taken from the
// baremetal boot code reference. least few significant bits make sense.
5:
	ldr x0, =0x70c50838
	msr sctlr_el2, x0 // [31] -> el1 in aarch64
	msr sctlr_el1, x0

/* Initialize the el2 stack pointer. */
	mov x0, #1
	msr spsel, x0 // dedicated sp per el

/* Set sp_el2 to 1KiB from 0x0. */
	ldr x0, #4096
	mov sp, x0

// TODO setup the MMU, clean/invalidate caches

/* Change exception level to el2. */
// initialize scr_el3
	mrs x0, scr_el3
	// orr x0, x0, #(1 << 18) // [18] el2 runs in secure state
	// orr x0, x0, #(1 << 8) // [8] -> enables hvc calls at el2,el1
	orr x0, x0, #(1 << 10) // [10] -> el2 controls if el1 is aarch32 or 64
	orr x0, x0, #1 // el0,1,2 not in secure state
	msr scr_el3, x0

// prepare for eret to el2
	mov x0, #9 // 1001 --> daif = 0
	msr spsr_el3, x0 
	adr x0, el2_entry
	msr elr_el3, x0
	eret

el2_entry:	
/* Change exception level to el1. */
// Initialize sctlr_el1
	msr sctlr_el1, xzr

/* Initialize el1 processor state. */
/* Upon entry, hcr_el2 contains 0x58000000 = 1011(27 0's)
	 [28] -> trap DC ZVA ??
	 [27] -> trap all reads of vm controls, must clear when writing vm system 
 */
	mrs x0, hcr_el2
	// bic x0, x0, #(1 << 29) // [29] -> HVC undefined at el0,1,2
	bic x0, x0, #(1 << 27) // [27] -> trap all from el0 to el2
	orr x0, x0, #(1 << 31) // [31] -> el1 in aarch64
	msr hcr_el2, x0


// prepare for eret to el1
	mov x0, #5 // 101 --> daif = 0
	msr spsr_el2, x0
	adr x0, el1_entry // load el1_entry
	msr elr_el2, x0 // set eret to el1_entry

	mrs x0, CurrentEl

	eret

el1_entry:
/*
	mrs x0, CurrentEl
	wfe
*/

/******************************/
/*** entry into kernel_main ***/
/******************************/

/* General register initialization. */
init_general_purpose_regs:
	mov x0, xzr
	mov x1, xzr
	mov x2, xzr
	mov x3, xzr
	mov x4, xzr
	mov x5, xzr
	mov x6, xzr
	mov x7, xzr
	mov x8, xzr
	mov x9, xzr
	mov x10, xzr
	mov x11, xzr
	mov x12, xzr
	mov x13, xzr
	mov x14, xzr
	mov x15, xzr
	mov x16, xzr
	mov x17, xzr
	mov x18, xzr
	mov x19, xzr
	mov x20, xzr
	mov x21, xzr
	mov x22, xzr
	mov x23, xzr
	mov x24, xzr
	mov x25, xzr
	mov x26, xzr
	mov x27, xzr
	mov x28, xzr
	mov x29, xzr
	mov x30, xzr
	// Cannot do bl, as that relies on x30 as link reg.
	// Skip floating point reg init for now.
	
	bl kernel_main
_stop:
	wfe
	b _stop

/* sfi: [s]ync [f]iq [i]rq */
enable_sfi:
	msr daifclr, #7
	ret
disable_sfi:
	msr daifset, #7
	ret

