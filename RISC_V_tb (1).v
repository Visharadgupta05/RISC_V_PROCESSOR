`timescale 1ns / 1ps

module RISC_V_tb;

reg clk;
reg rst_n;

////////////////////////////////////////////////////////////
// DUT
////////////////////////////////////////////////////////////

RISC_V dut(
    .clk(clk),
    .rst_n(rst_n)
);

////////////////////////////////////////////////////////////
// CLOCK
////////////////////////////////////////////////////////////

initial
begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

////////////////////////////////////////////////////////////
// RESET
////////////////////////////////////////////////////////////

initial
begin
    rst_n = 1'b0;

    #20;
    rst_n = 1'b1;
end

////////////////////////////////////////////////////////////
// PROGRAM LOAD
////////////////////////////////////////////////////////////

initial
begin

// addi x1,x0,10
dut.FETCH.mem[0] = 32'h00A00093;

// addi x2,x0,20
dut.FETCH.mem[1] = 32'h01400113;

// add x3,x1,x2
dut.FETCH.mem[2] = 32'h002081B3;

// sub x4,x2,x1
dut.FETCH.mem[3] = 32'h40110233;

// and x5,x1,x2
dut.FETCH.mem[4] = 32'h0020F2B3;

// or x6,x1,x2
dut.FETCH.mem[5] = 32'h0020E333;

// sw x3,0(x0)
dut.FETCH.mem[6] = 32'h00302023;

// lw x7,0(x0)
dut.FETCH.mem[7] = 32'h00002383;

end

////////////////////////////////////////////////////////////
// MONITOR
////////////////////////////////////////////////////////////

initial
begin

$monitor(
"TIME=%0t | PC=%h | INSTR=%h | x1=%0d | x2=%0d | x3=%0d | x4=%0d | x5=%0d | x6=%0d | x7=%0d",
$time,
dut.FETCH.PCF,
dut.FETCH.InstrF,
dut.DECODE.M1.REG[1],
dut.DECODE.M1.REG[2],
dut.DECODE.M1.REG[3],
dut.DECODE.M1.REG[4],
dut.DECODE.M1.REG[5],
dut.DECODE.M1.REG[6],
dut.DECODE.M1.REG[7]
);

end

////////////////////////////////////////////////////////////
// FINAL VALUES
////////////////////////////////////////////////////////////

initial
begin

#300;

$display("\n====================================");
$display("FINAL REGISTER VALUES");
$display("====================================");

$display("x1 = %0d", dut.DECODE.M1.REG[1]);
$display("x2 = %0d", dut.DECODE.M1.REG[2]);
$display("x3 = %0d", dut.DECODE.M1.REG[3]);
$display("x4 = %0d", dut.DECODE.M1.REG[4]);
$display("x5 = %0d", dut.DECODE.M1.REG[5]);
$display("x6 = %0d", dut.DECODE.M1.REG[6]);
$display("x7 = %0d", dut.DECODE.M1.REG[7]);

$display("\n====================================");
$display("DATA MEMORY");
$display("====================================");

$display("MEM[0] = %0d", dut.MEMORY.mem[0]);

$finish;

end

////////////////////////////////////////////////////////////
// WAVES
////////////////////////////////////////////////////////////

initial
begin
    $dumpfile("RISC_V.vcd");
    $dumpvars(0, RISC_V_tb);
end

endmodule
