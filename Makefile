TARGET = cortex-a53

CC = aarch64-linux-gnu-gcc
AS = aarch64-linux-gnu-gcc
OC = aarch64-linux-gnu-objcopy

INCLUDE 	:= -isystem src/include/
WARN 			:= -Wall -Wmissing-prototypes
OPS_C 		:= $(WARN) -nostdlib -nostartfiles -ffreestanding -mgeneral-regs-only -fno-stack-protector -mcpu=$(TARGET) $(INCLUDE) -g
OPS_ASM		:= -mcpu=$(TARGET) -g
OPS_LINK 	:= -ffreestanding -nostdlib -lgcc -g

LINK_FILE	:= src/linker.ld

SRC_C 		:= $(shell find src -name "*.c")
SRC_ASM 	:= $(shell find src -name "*.S")

OBJ_C 		:= $(patsubst src/%.c, build/%.o, $(SRC_C))
OBJ_ASM 	:= $(patsubst src/%.S, build/%.o, $(SRC_ASM))

# 
# https://www.gnu.org/software/make/manual/make.html#Static-Pattern
# 
all: $(OBJ_C) $(OBJ_ASM)
	$(CC) -T $(LINK_FILE) -o build/kernel.elf $(OPS_LINK) $(OBJ_ASM) $(OBJ_C)
	$(OC) build/kernel.elf -O binary build/kernel.img

$(OBJ_C): build/%.o: src/%.c
	mkdir -p ./build && $(CC) $(OPS_C) -c $< -o $@

$(OBJ_ASM): build/%.o: src/%.S
	mkdir -p ./build && $(AS) $(OPS_ASM) -c $< -o $@

clean:
	rm -rf ./build


