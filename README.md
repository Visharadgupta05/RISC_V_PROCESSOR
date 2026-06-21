
WHAT I IMPLEMENTED :- 
1. Designed and implemented a 32-bit pipelined RISC-V processor in Verilog.
2. Developed a 5-stage pipeline consisting of Fetch, Decode, Execute, Memory, and Writeback stages.
3. Implemented support for R-type, I-type, Load, Store, Branch, Jump, and LUI instructions.
4. Designed ALU, Register File, Control Unit, Immediate Generator, and Data Memory modules

5. I also tried to debug some common hazards in risc-v processor - data hazard, load hazard and jump hazard;

DATA HAZARDS

A data hazard occurs when an instruction depends on the result of a previous instruction that has not yet completed execution.

For example:

add x5, x1, x2
sub x6, x5, x3

The sub instruction requires the value of x5, but the add instruction has not yet written the result back to the register file. Without any hazard handling, sub would use an incorrect value.

To solve this problem, the processor uses data forwarding. Instead of waiting for the result to be written back, the result is directly forwarded from later pipeline stages to the ALU inputs of the dependent instruction. This allows dependent arithmetic instructions to execute without introducing pipeline stalls.

It directly uses value from EX/MEM or MEM/WB pipelined register of the preceeding instruction and uses it in its EXECUTE section.

LOAD-USE HAZARDS

A load-use hazard is a special type of data hazard that occurs when an instruction immediately uses data loaded from memory.

For example:

lw  x5, 0(x1)
add x6, x5, x2

The add instruction needs the value of x5, but the data being loaded by the lw instruction is not available until the Memory stage. Unlike arithmetic instructions, forwarding alone cannot solve this hazard because the required data has not yet been fetched from memory.

To handle this situation, the hazard unit detects the dependency and inserts a one-cycle stall. During the stall:

The Program Counter is frozen.
The Fetch stage is frozen.
The Decode stage is frozen.
A bubble (NOP) is inserted into the Execute stage.

After one clock cycle, the loaded data becomes available and execution continues normally.






<img width="2141" height="1314" alt="image" src="https://github.com/user-attachments/assets/7bae9d14-cecb-454d-9d21-1fbb8da3508d" />
This was the final output 
