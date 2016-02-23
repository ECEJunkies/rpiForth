###############################################################################
#	makefile
#	 by Alex Chadwick
#
#	A makefile script for generation of raspberry pi kernel images.
###############################################################################

# The toolchain to use. arm-none-eabi works, but there does exist 
# arm-bcm2708-linux-gnueabi.
ARMGNU ?= arm-none-eabi

# The name of the output file to generate.
TARGET = kernel.img

# The name of the assembler listing file to generate.
LIST = kernel.list

# The name of the map file to generate.
MAP = kernel.map

# The name of the linker script to use.
LINKER = kernel.ld

# The names of libraries to use.
LIBRARIES := csud

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
OBJECTS := $(patsubst %.s,%.o,$(wildcard *.s))

# Rule to make everything.
all: $(TARGET) $(LIST)

# Rule to remake everything. Does not include clean.
rebuild: all

# Rule to make the listing file.
$(LIST) : output.elf
	$(ARMGNU)-objdump -dDhslx output.elf > $(LIST)

# Rule to make the image file.
$(TARGET) : output.elf
	$(ARMGNU)-objcopy output.elf -O binary $(TARGET) 

# Rule to make the elf file.
output.elf : $(OBJECTS) $(LINKER)
	$(ARMGNU)-ld --no-undefined $(OBJECTS) -L. $(patsubst %,-l %,$(LIBRARIES)) -Map $(MAP) -o output.elf -T $(LINKER)

# Rule to make the object files.
%.o: %.s
	$(ARMGNU)-as $< -o $@

# Rule to clean files.
clean : 
	-rm -f *.o 
	-rm -f output.elf
	-rm -f $(TARGET)
	-rm -f $(LIST)
	-rm -f $(MAP)
