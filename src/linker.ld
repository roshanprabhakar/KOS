ENTRY(_start)

kernel_start = 0x80000;

SECTIONS
{
	. = kernel_start;
	.text : { KEEP(*(.text.boot)) *(.text .text.*) }
	.rodata : { *(.rodata .rodata.*) }
	PROVIDE (data_section = .);
	.data : { *(.data .data.* ) }
	.bss (NOLOAD) : {
		. = ALIGN(16);
		__bss_start = .;
		*(.bss)
		*(.bss.*)
		. = ALIGN(8);
		*(COMMON)
		__bss_end = .;
	}
	end = .;
}
__bss_size = __bss_end - __bss_start;

