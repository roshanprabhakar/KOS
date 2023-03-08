#include <stdint.h>
#include "devices/mini-uart.h"
#include "printf.h"

unsigned long undcl_long1;
unsigned long undcl_long2;
unsigned int undcl_int1;

int kernel_main (void);
void validate_bss (uint8_t*, uint8_t*);

/* KERNEL ENTRY POINT 
 * kernel mode addresses: 0xC0000000 to 0xEFFFFFFF (dma)
 * 												0x00000000 to 0x2FFFFFFF (physical)	
 * peripherals exist at: 	0x3F000000 to 0x3FFFFFFF (physical)
 *												0x7E000000 to 0x7EFFFFFF (bus)
 * MMU and Caches currently disabled upon entry, so PE in
 * physical addressing mode.
 */
int
kernel_main (void)
{
	mini_uart_enable ();
	for (;;);
}

/* Simple loop to ensure that the bss was in
	 fact zero'd out as expected. Takes as arguments
 	 __bss_start (p1) and __bss_end (p2). */
void
validate_bss(uint8_t* p1, uint8_t* p2)
{
	for (; p1 != p2; ++p1)
	{
		if (*p1 != 0)
		{
			asm volatile ("ldr x10, =0xBAD" ::: );
			break;	
		}
	}
}
