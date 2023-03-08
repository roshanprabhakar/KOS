#ifndef MINI_UART_H
#define MINI_UART_H

#include "devices/devices.h"

// read byte 1: read from receive fifo, write byte 1: 
// write to transmit fifo.
#define AUX_MU_IO_REG (MMIO_BASE + 0x00215040)	

// [2,3] = 1 to enable interrupts, [1] = 1 interrupt generated
// when transmit fifo is empty. [0] = 1 interrupt generated if the
// receive fifo holds at least 1 byte.
#define AUX_MU_IER_REG (MMIO_BASE + 0x00215044)

// [7,6] indicates fifo enabled. Always 1, as fifo always enabled.
// [2,1] read
// 	= 00: no interrupts
// 	= 01: transmit register empty
// 	= 10: receiver holds valid byte
// 	= 11: not possible
// [2,1] write [1] clears the receive fifo,
// write [2] clears the transmit fifo.
// [0] = 0 whenever an interrupt is pending.
#define AUX_MU_IIR_REG (MMIO_BASE + 0x00215048)

// [1,0] 
// 	= 0,0: uart in 7-bit mode
// 	= 1,1: uart in 8-bit mode
#define AUX_MU_LCR_REG (MMIO_BASE + 0x0021504C)

// probably unnecessary
#define AUX_MU_MCR_REG (MMIO_BASE + 0x00215050)

// [6] transmitter fifo empty and transmitter idle
// [5] transmitter fifo can accept a byte
// [1] receiver overrun, cleared on each read
// [0] receiver fifo ready, contains a symbol
#define AUX_MU_LSR_REG (MMIO_BASE + 0x00215054)

// probably unnecessary
#define AUX_MU_MSR_REG (MMIO_BASE + 0x00215058)

// probably unnecessary
#define AUX_MU_SCRATCH (MMIO_BASE + 0x0021505C)

// [1] transmitter enabled, ![1] transmitter disabled
// [0] receiver enabled, ![0] receiver disabled
#define AUX_MU_CNTL_REG (MMIO_BASE + 0x00215060)

// [27..24] num symbols stored in the transmit fifo (max 8)
// [19..16] num symbols stored in the receive fifo (max 8)
// [9] transmitter idle and transmitter fifo empty
// [8] transmitter fifo is empty
//
// [7] CTS status (1 -> receiver ready to be invoked)
// [6] RTS status (1 -> transmitter ready to be invoked)
//
// [5] transmit fifo is full
// [4] receiver overrun occurred. overrun characters are
// 		 discarded.
// [3] transmitter is idle
// [2] receiver is idle
// [1] transmitter fifo may accept another symbol
// [0] receiver contains at least one symbol
#define AUX_MU_STAT_REG (MMIO_BASE + 0x00215064)

// [15..0] mini uart baud rate counter
#define AUX_MU_BAUD (MMIO_BASE + 0x00215068)

#define DEFAULT_BAUD 115200

void mini_uart_enable (void);
void mini_uart_putc (char);

#endif // MINI_UART_H
