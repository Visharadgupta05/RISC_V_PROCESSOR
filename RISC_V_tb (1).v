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

integer i;

initial
begin

    // Initialize entire instruction memory to NOP
    for(i=0;i<1024;i=i+1)
        dut.FETCH.mem[i] = 32'h00000013;

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

    // add x8,x7,x1
    dut.FETCH.mem[8] = 32'h00138433;

end

////////////////////////////////////////////////////////////
// PIPELINE MONITOR
////////////////////////////////////////////////////////////

always @(posedge clk)
begin

$display(
"\nTIME=%0t  PC=%h  INSTR=%h",
$time,
dut.FETCH.PCF,
dut.FETCH.InstrF
);

$display(
"RDE=%0d Rs1E=%0d Rs2E=%0d RDM=%0d RDW=%0d",
dut.RDE,
dut.Rs1E,
dut.Rs2E,
dut.RDM,
dut.RDW
);

$display(
"ForwardAE=%b ForwardBE=%b",
dut.ForwardAE,
dut.ForwardBE
);

$display(
"StallF=%b StallD=%b FlushE=%b",
dut.StallF,
dut.StallD,
dut.FlushE
);

end

////////////////////////////////////////////////////////////
// LOAD HAZARD MONITOR
////////////////////////////////////////////////////////////

always @(posedge clk)
begin

if(dut.HAZARD.lwStall)
begin

$display("\n================================");
$display("LOAD HAZARD DETECTED");
$display("TIME=%0t", $time);

$display("InstrD      = %h", dut.InstrD);

$display("RDE         = %0d", dut.HAZARD.RDE);
$display("Rs1D        = %0d", dut.HAZARD.Rs1D);
$display("Rs2D        = %0d", dut.HAZARD.Rs2D);
$display("ResultSrcE  = %b", dut.HAZARD.ResultSrcE);

$display("================================");

end

end

////////////////////////////////////////////////////////////
// FINAL RESULTS
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
$display("x8 = %0d", dut.DECODE.M1.REG[8]);

$display("\n====================================");
$display("DATA MEMORY");
$display("====================================");

$display("MEM[0] = %0d", dut.MEMORY.mem[0]);

$display("\n====================================");
$display("PASS / FAIL REPORT");
$display("====================================");

if(dut.DECODE.M1.REG[1] == 10)
    $display("PASS : x1");
else
    $display("FAIL : x1 = %0d", dut.DECODE.M1.REG[1]);

if(dut.DECODE.M1.REG[2] == 20)
    $display("PASS : x2");
else
    $display("FAIL : x2 = %0d", dut.DECODE.M1.REG[2]);

if(dut.DECODE.M1.REG[3] == 30)
    $display("PASS : x3");
else
    $display("FAIL : x3 = %0d", dut.DECODE.M1.REG[3]);

if(dut.DECODE.M1.REG[4] == 10)
    $display("PASS : x4");
else
    $display("FAIL : x4 = %0d", dut.DECODE.M1.REG[4]);

if(dut.DECODE.M1.REG[5] == 0)
    $display("PASS : x5");
else
    $display("FAIL : x5 = %0d", dut.DECODE.M1.REG[5]);

if(dut.DECODE.M1.REG[6] == 30)
    $display("PASS : x6");
else
    $display("FAIL : x6 = %0d", dut.DECODE.M1.REG[6]);

if(dut.DECODE.M1.REG[7] == 30)
    $display("PASS : x7");
else
    $display("FAIL : x7 = %0d", dut.DECODE.M1.REG[7]);

if(dut.DECODE.M1.REG[8] == 40)
    $display("PASS : x8 (Load Hazard Test)");
else
    $display("FAIL : x8 = %0d", dut.DECODE.M1.REG[8]);

if(dut.MEMORY.mem[0] == 30)
    $display("PASS : MEM[0]");
else
    $display("FAIL : MEM[0] = %0d", dut.MEMORY.mem[0]);

$display("====================================");

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
