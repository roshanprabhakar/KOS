#include "devices/auxilaries.h"
#include "devices/mini-uart.h"
#include "printf.h"

void
mini_uart_putc (char c)
{
	for (; !(REG_GET (AUX_MU_STAT_REG, uint32_t) & 2) ;);
	REG_SET (AUX_MU_IO_REG, uint32_t, (uint32_t) c);
}

void
mini_uart_enable (void)
{
	// enable uart
	REG_BIS (AUXENB, uint32_t, 0);

	// enable transmitter and receiver
	REG_BIS (AUX_MU_CNTL_REG, uint32_t, 0);
	REG_BIS (AUX_MU_CNTL_REG, uint32_t, 1);

	// disable mini uart interrupts
	REG_BIC (AUX_MU_IER_REG, uint32_t, 2);
	REG_BIC (AUX_MU_IER_REG, uint32_t, 3);

	// verify AUX_MU_IER[0,1] = 0,0

	// put uart in 8-bit mode
	REG_BIS (AUX_MU_LCR_REG, uint32_t, 0);
	REG_BIS (AUX_MU_LCR_REG, uint32_t, 1);

	// verify AUX_MU_CNTL_REG[0,1] = 1,1

	// set baud rate to qemu's default
	REG_SET (AUX_MU_BAUD, uint32_t, (uint32_t) DEFAULT_BAUD);

	// send init message
	printf ("mini uart initialized\n");
}
