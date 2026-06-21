`timescale 1ns/1ps

module tb_riscv;

reg clk;
reg rst_n;

RISC_V DUT(
    .clk(clk),
    .rst_n(rst_n)
);

/////////////////////////////////////////////////
// CLOCK
/////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

/////////////////////////////////////////////////
// RESET
/////////////////////////////////////////////////

initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
end

/////////////////////////////////////////////////
// PROGRAM MEMORY
/////////////////////////////////////////////////

initial begin

// addi x1,x0,5
DUT.FETCH.mem[0] = 32'h00500093;

// addi x2,x0,10
DUT.FETCH.mem[1] = 32'h00A00113;

// add x3,x1,x2
DUT.FETCH.mem[2] = 32'h002081B3;

// add x4,x3,x1
DUT.FETCH.mem[3] = 32'h00118233;

// lw x5,0(x0)
DUT.FETCH.mem[4] = 32'h00002283;

// add x6,x5,x1
DUT.FETCH.mem[5] = 32'h00128333;

// beq x1,x1,+12
DUT.FETCH.mem[6] = 32'h00108663;

// should flush
DUT.FETCH.mem[7] = 32'h06F00393;

// should flush
DUT.FETCH.mem[8] = 32'h0DE00413;

// LABEL:
// addi x9,x0,99
DUT.FETCH.mem[9] = 32'h06300493;

// jal x10,+12
DUT.FETCH.mem[10] = 32'h00C0056F;

// should flush
DUT.FETCH.mem[11] = 32'h07B00593;

// should flush
DUT.FETCH.mem[12] = 32'h0EA00613;

// TARGET:
// addi x13,x0,77
DUT.FETCH.mem[13] = 32'h04D00693;

/////////////////////////////////////////////////
// DATA MEMORY
/////////////////////////////////////////////////

DUT.MEMORY.mem[0] = 32'd100;

end

/////////////////////////////////////////////////
// WAVEFORM
/////////////////////////////////////////////////

initial begin
    $dumpfile("riscv.vcd");
    $dumpvars(0,tb_riscv);
end

/////////////////////////////////////////////////
// MONITOR HAZARDS
/////////////////////////////////////////////////

always @(posedge clk)
begin
    $display(
    "T=%0t PC=%h StallF=%b StallD=%b FlushD=%b FlushE=%b PCSrcE=%b",
    $time,
    DUT.FETCH.PCF,
    DUT.StallF,
    DUT.StallD,
    DUT.FlushD,
    DUT.FlushE,
    DUT.PCSrcE
    );
end

/////////////////////////////////////////////////
// CHECK RESULTS
/////////////////////////////////////////////////

initial begin

#500;

$display("\n===== REGISTER VALUES =====");

$display("x1  = %0d", DUT.DECODE.M1.REG[1]);
$display("x2  = %0d", DUT.DECODE.M1.REG[2]);
$display("x3  = %0d", DUT.DECODE.M1.REG[3]);
$display("x4  = %0d", DUT.DECODE.M1.REG[4]);
$display("x5  = %0d", DUT.DECODE.M1.REG[5]);
$display("x6  = %0d", DUT.DECODE.M1.REG[6]);

$display("x7  = %0d", DUT.DECODE.M1.REG[7]);
$display("x8  = %0d", DUT.DECODE.M1.REG[8]);

$display("x9  = %0d", DUT.DECODE.M1.REG[9]);

$display("x10 = %0d", DUT.DECODE.M1.REG[10]);

$display("x11 = %0d", DUT.DECODE.M1.REG[11]);
$display("x12 = %0d", DUT.DECODE.M1.REG[12]);

$display("x13 = %0d", DUT.DECODE.M1.REG[13]);

$finish;

end

endmodule
