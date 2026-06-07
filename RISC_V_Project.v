`timescale 1ns / 1ps




module RISC_V(

input clk,
input rst_n

);

////////////////////////////////////////////////////////////
// FETCH ? DECODE
////////////////////////////////////////////////////////////

wire PCSrcE;
wire [31:0] PCTargetE;

wire [31:0] InstrD;
wire [31:0] PCD;
wire [31:0] PCPlus4D;

////////////////////////////////////////////////////////////
// DECODE ? EXECUTE
////////////////////////////////////////////////////////////

wire RegWriteE;
wire [1:0] ResultSrcE;
wire MemWriteE;
wire JumpE;
wire BranchE;

wire [3:0] ALUControlE;
wire ALUSrcE;
wire [2:0] FUNCT3E;

wire [31:0] DataRead1E;
wire [31:0] DataRead2E;
wire [31:0] PCE;
wire [4:0] RDE;
wire [31:0] ImmExtE;
wire [31:0] PCPlus4E;

////////////////////////////////////////////////////////////
// EXECUTE ? MEMORY
////////////////////////////////////////////////////////////

wire RegWriteM;
wire [1:0] ResultSrcM;
wire [2:0] FUNCT3M;

wire MemWriteM;

wire [31:0] ALUResultM;
wire [31:0] WriteDataM;

wire [4:0] RDM;

wire [31:0] PCPlus4M;

////////////////////////////////////////////////////////////
// MEMORY ? WRITEBACK
////////////////////////////////////////////////////////////

wire RegWriteW;
wire [1:0] ResultSrcW;

wire [31:0] ReadDataW;

wire [4:0] RDW;

wire [31:0] PCPlus4W;
wire [31:0] ALUResultW;

////////////////////////////////////////////////////////////
// WRITEBACK FEEDBACK
////////////////////////////////////////////////////////////

wire [31:0] ResultW;




// HAZARD WIRES
wire [4:0] Rs1E;
wire [4:0] Rs2E;

wire [1:0] ForwardAE;
wire [1:0] ForwardBE;

////////////////////////////////////////////////////////////
// FETCH STAGE
////////////////////////////////////////////////////////////

RISC_FETCH FETCH(

.PCSrcE(PCSrcE),
.PCTargetE(PCTargetE),
.clk(clk),
.rst_n(rst_n),

.InstrD(InstrD),
.PCD(PCD),
.PCPlus4D(PCPlus4D)

);

////////////////////////////////////////////////////////////
// DECODE STAGE
////////////////////////////////////////////////////////////

RISC_DECODE DECODE(

.clk(clk),
.rst_n(rst_n),

.RegWriteW(RegWriteW),
.RDW(RDW),

.PCPlus4D(PCPlus4D),
.InstrD(InstrD),
.PCD(PCD),

.ResultW(ResultW),

.DataRead1E(DataRead1E),
.DataRead2E(DataRead2E),
.PCE(PCE),
.RDE(RDE),
.ImmExtE(ImmExtE),
.PCPlus4E(PCPlus4E),
.Rs1E(Rs1E),
.Rs2E(Rs2E),
.RegWriteE(RegWriteE),
.ResultSrcE(ResultSrcE),
.MemWriteE(MemWriteE),
.JumpE(JumpE),
.BranchE(BranchE),
.ALUControlE(ALUControlE),
.ALUSrcE(ALUSrcE),
.FUNCT3E(FUNCT3E)

);

////////////////////////////////////////////////////////////
// EXECUTE STAGE
////////////////////////////////////////////////////////////

RISC_EXECUTE EXECUTE(

.clk(clk),
.rst_n(rst_n),

.RegWriteE(RegWriteE),
.ResultSrcE(ResultSrcE),
.MemWriteE(MemWriteE),
.JumpE(JumpE),
.BranchE(BranchE),

.FUNCT3E(FUNCT3E),

.ALUControlE(ALUControlE),

.ALUSrcE(ALUSrcE),

.DataRead1E(DataRead1E),
.DataRead2E(DataRead2E),

.PCE(PCE),

.RDE(RDE),

.ImmExtE(ImmExtE),

.PCPlus4E(PCPlus4E),

.PCSrcE(PCSrcE),

.PCTargetE(PCTargetE),

.RegWriteM(RegWriteM),

.ResultSrcM(ResultSrcM),

.FUNCT3M(FUNCT3M),

.MemWriteM(MemWriteM),

.ALUResultM(ALUResultM),

.WriteDataM(WriteDataM),

.RDM(RDM),

.PCPlus4M(PCPlus4M),

.Rs1E(Rs1E),
.Rs2E(Rs2E),
.ForwardAE(ForwardAE),
.ForwardBE(ForwardBE),
.ResultW(ResultW)

);

////////////////////////////////////////////////////////////
// MEMORY STAGE
////////////////////////////////////////////////////////////

RISC_MEMORY MEMORY(

.clk(clk),
.rst_n(rst_n),

.RegWriteM(RegWriteM),

.ResultSrcM(ResultSrcM),

.MemWriteM(MemWriteM),

.FUNCT3M(FUNCT3M),

.ALUResultM(ALUResultM),

.WriteDataM(WriteDataM),

.PCPlus4M(PCPlus4M),

.RDM(RDM),

.RegWriteW(RegWriteW),

.ResultSrcW(ResultSrcW),

.ReadDataW(ReadDataW),

.RDW(RDW),

.PCPlus4W(PCPlus4W),

.ALUResultW(ALUResultW)

);

////////////////////////////////////////////////////////////
// WRITEBACK STAGE
////////////////////////////////////////////////////////////

RISC_WB WRITEBACK(

.RegWriteW(RegWriteW),

.ResultSrcW(ResultSrcW),

.ReadDataW(ReadDataW),

.RDW(RDW),

.PCPlus4W(PCPlus4W),

.ALUResultW(ALUResultW),

.ResultW(ResultW)

);

// HAZARD
HAZARD_UNIT HAZARD(
    .rst_n(rst_n),
    .RDM(RDM),
    .RegWriteM(RegWriteM),
    .RDW(RDW),
    .RegWriteW(RegWriteW),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE)
);

endmodule




// FETCH

module RISC_FETCH(
input PCSrcE , input [31:0] PCTargetE, input clk, input rst_n , 

output reg [31:0]  InstrD , output reg [31:0] PCD, output reg [31:0] PCPlus4D
);

reg [31:0] mem [0:1023] ;
reg [31:0] PCF, PCF_bar , PCPlus4F;
wire [31:0] InstrF;
always @(PCSrcE , PCPlus4F , PCTargetE)
begin
case(PCSrcE)
1'b0 : PCF_bar = PCPlus4F;
1'b1 : PCF_bar = PCTargetE;
default : PCF_bar = PCPlus4F;
endcase
end

always @(posedge clk or negedge rst_n)
begin

if (!rst_n)
begin
PCF <= 32'h00000000;
PCPlus4D <= 32'h00000000;
InstrD <= 32'h00000000;
PCD <= 32'h00000000 ;

end

else
begin
PCF <= PCF_bar;
PCPlus4D <= PCPlus4F;
PCD <= PCF ;
InstrD <= InstrF;
end
end

always @(*)
begin
 PCPlus4F =  PCF  + 32'd4 ;
end


assign InstrF = mem[PCF[31:2]];


endmodule




//DECODE


module RISC_DECODE(
  input clk, input rst_n , input RegWriteW, input [4:0] RDW ,input [31:0] PCPlus4D , input [31:0] InstrD , 
  input [31:0] PCD ,
   input [31:0] ResultW, 
output reg [31:0]  DataRead1E , output reg [31:0] DataRead2E, output reg [31:0] PCE ,
output reg [4:0] Rs1E ,
output reg [4:0] Rs2E ,

 output reg [4:0] RDE , 
output reg [31:0] ImmExtE,
 output reg [31:0] PCPlus4E , 
output reg RegWriteE, output reg [1:0] ResultSrcE , output reg MemWriteE, output reg JumpE , 
output reg BranchE , output reg [3:0] ALUControlE , 
output reg ALUSrcE , output reg [2:0] FUNCT3E
);

wire [31:0] DATAREAD1 , DATAREAD2 ,IMM_EXTEND;
wire REGWRITE , MEMWRITE ,BRANCH, JUMP, ALUSRC ;
wire [1:0] RESULT_SRC ;
wire [2:0] IMM_SRC;
wire [3:0] ALUCONTROL;

Register_File M1(.clk(clk), .rst_n(rst_n) , .WriteEnable(RegWriteW),.sr1(InstrD[19:15]),.sr2(InstrD[24:20]) ,.dr(RDW) ,.dataWrite(ResultW),
 .dataRead1(DATAREAD1), .dataRead2(DATAREAD2) );
 
 
 Control_unit M3(.opcode(InstrD[6:0] ), .funct3(InstrD[14:12]) ,.funct7_5(InstrD[30]) ,.RegWrite(REGWRITE) ,.ResultSrc(RESULT_SRC),.MemWrite(MEMWRITE) , .Branch(BRANCH),
 .Jump(JUMP) , .ALUSrc(ALUSRC), .ImmSrc(IMM_SRC), .ALUCtrl(ALUCONTROL) );

SIGN_EXTENSION M2(.immSrc(IMM_SRC) ,.Instr(InstrD) ,.ImmExt(IMM_EXTEND));



always @(posedge clk or negedge rst_n)
begin

if (!rst_n)
begin

DataRead1E <= 32'h00000000;
DataRead2E <= 32'h00000000;
PCE        <= 32'h00000000;
Rs1E  <= 5'b00000;
 Rs2E <= 5'b00000;
RDE        <= 5'b00000;
ImmExtE    <= 32'h00000000;
PCPlus4E   <= 32'h00000000;


RegWriteE  <= 0;
ResultSrcE <= 2'b00;
MemWriteE  <= 0;
JumpE      <= 0;
BranchE    <= 0;
ALUControlE<= 4'b0000;
ALUSrcE    <= 0;
FUNCT3E <= 3'b000;
end


else 
begin

DataRead1E <= DATAREAD1;
DataRead2E <=  DATAREAD2;
PCE        <= PCD;
Rs1E      <= InstrD[19:15]; //hazard
Rs2E      <= InstrD[24:20]; //hazard
RDE       <= InstrD[11:7]; 
ImmExtE    <= IMM_EXTEND;
PCPlus4E   <= PCPlus4D;
           
           
RegWriteE  <= REGWRITE ;
ResultSrcE  <= RESULT_SRC;
MemWriteE  <=  MEMWRITE;
JumpE      <= JUMP;
BranchE   <= BRANCH; 
ALUControlE <=  ALUCONTROL;
ALUSrcE    <= ALUSRC;
FUNCT3E <= InstrD[14:12];

end

end


endmodule

// Instantiating modules for DECODE

module Control_unit 
( input [6:0] opcode , input [2:0] funct3 , input funct7_5 , output RegWrite , output  [1:0] ResultSrc , output  MemWrite , output Branch ,
  output Jump , output ALUSrc , output [2:0] ImmSrc , output [3:0] ALUCtrl  ); /* 1st */

wire [1:0] ALUOp;

Main_decoder md (
    .OPCODE(opcode),
    .regWrite(RegWrite),
    .resultSrc(ResultSrc),
    .memWrite(MemWrite),
    .branch(Branch),
    .jump(Jump),
    .ALUsrc(ALUSrc),
    .immSrc(ImmSrc),
    .ALUOp(ALUOp)
);

ALU_Decoder ad (
    .ALUOP(ALUOp),
    .opcode(opcode),
    .FUNCT3(funct3),
    .FUNCT7_5(funct7_5),
    .ALUCONTROL(ALUCtrl)
);




endmodule

module Main_decoder(
input [6:0] OPCODE , output reg regWrite , output reg [1:0] resultSrc , output reg memWrite , output reg branch ,
  output reg jump , output reg ALUsrc , output reg [2:0] immSrc , output reg [1:0] ALUOp  //2nd time
);

always @(*)
begin
case(OPCODE)
7'b0110011: {regWrite,resultSrc,memWrite, branch, jump, ALUsrc, immSrc, ALUOp} = 12'b1_00_0_0_0_0_xxx_10 ; //R type
7'b0010011: {regWrite,resultSrc,memWrite, branch, jump, ALUsrc, immSrc, ALUOp} = 12'b1_00_0_0_0_1_000_10 ; //I type ALU
7'b0000011: {regWrite,resultSrc,memWrite, branch, jump, ALUsrc, immSrc, ALUOp} = 12'b1_01_0_0_0_1_000_00 ;  // LOAD type
7'b0100011: {regWrite,resultSrc,memWrite, branch, jump, ALUsrc, immSrc, ALUOp} = 12'b0_xx_1_0_0_1_001_00 ; //STORE type
7'b1100011: {regWrite,resultSrc,memWrite, branch, jump, ALUsrc, immSrc, ALUOp} = 12'b0_xx_0_1_0_0_010_01 ;  //branch
7'b1101111: {regWrite,resultSrc,memWrite, branch, jump, ALUsrc, immSrc, ALUOp} = 12'b1_10_0_0_1_x_011_xx ;  //JAL
7'b0110111: {regWrite,resultSrc,memWrite, branch, jump, ALUsrc, immSrc, ALUOp} = 12'b1_00_0_0_0_1_100_11;  // LUI
default: {regWrite,resultSrc,memWrite,branch, jump,ALUsrc,immSrc,ALUOp} = 12'b0_00_0_0_0_0_000_00;
endcase
end
endmodule

module ALU_Decoder (
input [1:0] ALUOP ,input[6:0] opcode, input [2:0] FUNCT3 , input FUNCT7_5 , output reg [3:0] ALUCONTROL
);


always @(*)
begin

case(ALUOP)
2'b00: ALUCONTROL =  4'b0000; // LOAD , STORE
2'b01 : ALUCONTROL = 4'b0001; // BRANCH IF

2'b10:   //ARITHMATIC AND LOGICAL
begin

case(FUNCT3)

3'b000 : 
begin
if (FUNCT7_5 && opcode == 7'b0110011 )
begin

ALUCONTROL = 4'b0001; //SUBTRACTION
end

else
begin
ALUCONTROL = 4'b0000;  //ADDITION

end

end

3'b001 :   // shift left logical
ALUCONTROL = 4'b0110;

3'b010: // set less than signed
ALUCONTROL = 4'b0101;

3'b011 : //set less than unsigned
ALUCONTROL = 4'b1001;

3'b100 : ALUCONTROL = 4'b0100 ; //XOR or XORI

3'b101 : 
begin
if (FUNCT7_5)
begin
ALUCONTROL = 4'b1000;  //Shift right arithmatic

end

else
begin
ALUCONTROL = 4'b0111;  //shift right logical
end

end

3'b110:
ALUCONTROL = 4'b0011;  //OR or ORI


3'b111 : ALUCONTROL = 4'b0010; // AND or ANDI

default: ALUCONTROL = 4'b0000;

endcase

end

2'b11 : ALUCONTROL = 4'b1010 ;  // load upper immediate
default: ALUCONTROL = 4'b0000;
endcase
end
endmodule



module Register_File (
input clk, input rst_n, input WriteEnable, input [4:0] sr1 , input [4:0] sr2 , input [4:0] dr , input [31:0] dataWrite , output  [31:0] dataRead1 , output [31:0] dataRead2 
);

 reg [31:0] REG [0:31];
integer i;

always @(negedge clk or negedge rst_n)
begin
if(!rst_n)
begin
for (i = 0 ; i < 32 ; i = i + 1)
begin
REG[i] <= 0;

end
end

else if (WriteEnable && dr != 0)
begin

REG[dr] <= dataWrite;

end

end


assign dataRead1 = REG[sr1];
assign dataRead2 = REG[sr2];



endmodule

module SIGN_EXTENSION (
input [2:0] immSrc , input [31:0] Instr, output reg [31:0] ImmExt
);

always @(immSrc , Instr)
begin

case (immSrc)
3'b000 : ImmExt = {{20{Instr[31]}} , Instr[31:20]}; // I type 
3'b001 : ImmExt = {{20{Instr[31]}} , Instr[31:25] , Instr[11:7]}; // S type
3'b010 : ImmExt = {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0}; // B type
3'b011 : ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};  // Jump 
3'b100: ImmExt = {Instr[31:12], 12'b0};  // LUI
 default: ImmExt = 32'b0;
endcase
end
endmodule



///////////////////////
 //EXECUTE

`timescale 1ns / 1ps

 // EXECUTE
module RISC_EXECUTE(
input clk, input rst_n, input RegWriteE , input [1:0] ResultSrcE , input MemWriteE , input JumpE, input BranchE , 
input [2:0] FUNCT3E,
 input [3:0] ALUControlE,
input ALUSrcE , input [31:0] DataRead1E, input [31:0] DataRead2E , input [31:0] PCE, input [4:0] RDE ,
input [4:0] Rs1E, input [4:0] Rs2E, // data hazard
input [1:0] ForwardAE, input [1:0] ForwardBE,  // inputs from hazard unit
input [31:0] ImmExtE , input [31:0] PCPlus4E ,output reg PCSrcE, output [31:0] PCTargetE,
input [31:0] ResultW,
 output reg RegWriteM ,
 output reg [1:0] ResultSrcM , output reg [2:0]  FUNCT3M,
output reg MemWriteM , output reg [31:0] ALUResultM , output reg [31:0] WriteDataM , output reg [4:0] RDM , 
output reg [31:0] PCPlus4M
    );
    
    wire [31:0] Source_A;
    wire [31:0]  Source_B;
   
    wire [31:0] ALUResultE;
    wire [31:0] WriteDataE;
    wire [31:0] ALUResultM_wire = ALUResultM;
    
  
    wire [31:0] DataRead2E_mux;
assign Source_A = (ForwardAE == 2'b00) ? DataRead1E : (ForwardAE == 2'b01) ? ResultW : (ForwardAE == 2'b10) ? ALUResultM_wire :32'h00000000 ;
assign DataRead2E_mux = (ForwardBE == 2'b00) ? DataRead2E : (ForwardBE == 2'b01) ? ResultW : (ForwardBE == 2'b10) ? ALUResultM_wire :32'h00000000 ;  
    assign Source_B = ALUSrcE ? ImmExtE : DataRead2E_mux;
    
    assign WriteDataE = DataRead2E_mux;  // for store 
    
  
    assign PCTargetE = PCE + ImmExtE;
    
    
    // wires for different branch cases
    wire ZeroE  = (Source_A == DataRead2E_mux ); // beq , bne
    wire LessThanE = ($signed(Source_A) < $signed(DataRead2E_mux)); // blt , bge 
    wire LessThanUnsignedE = (Source_A < DataRead2E_mux);  //bltu , bgeu
    
   
  
    always @(*)
    begin
    
    case(FUNCT3E)
    3'b000 : PCSrcE = (BranchE & ZeroE) | JumpE;  //  beq    
    3'b001 : PCSrcE = (BranchE & ~ZeroE) | JumpE;  //  bne
    3'b100 : PCSrcE =  (BranchE & LessThanE) | JumpE; //blt
    3'b101 : PCSrcE =  (BranchE & ~LessThanE) | JumpE; //bge
    3'b110 : PCSrcE = (BranchE & LessThanUnsignedE ) | JumpE; //bltu
    3'b111 : PCSrcE = (BranchE & ~LessThanUnsignedE ) | JumpE; //bgeu
    default: PCSrcE = JumpE;
    endcase
    end
   
    
    ALU_OP uu1(.CONTROL(ALUControlE) ,.Src_A(Source_A), .Src_B( Source_B), .Result(ALUResultE));
    always @(posedge clk or negedge rst_n)
    begin
    if (!rst_n)
    begin
    RegWriteM  <= 0;
    ResultSrcM <= 2'b00;
    MemWriteM  <= 0;
    ALUResultM <= 32'h00000000;
    WriteDataM <= 32'h00000000;
    RDM        <= 5'b00000;
    PCPlus4M   <= 32'h00000000;
    FUNCT3M <= 3'b000;
   end 
    
    else
    begin
    
    RegWriteM  <= RegWriteE;
    ResultSrcM <= ResultSrcE;
    MemWriteM  <= MemWriteE;
    ALUResultM <= ALUResultE;
    WriteDataM <= WriteDataE;
    RDM        <=  RDE;
    PCPlus4M   <= PCPlus4E;
    FUNCT3M <= FUNCT3E;
    
    end
    end
    
endmodule


module ALU_OP(
input [3:0] CONTROL , input [31:0] Src_A , input [31:0] Src_B , 
 output reg [31:0] Result
);

always @(*)
begin
case(CONTROL)
4'b0000: Result = Src_A + Src_B;  // ADD OPERATION
4'b0001 :Result = Src_A - Src_B;  // SUB OPERATION
4'b0010 : Result = Src_A & Src_B; // AND OPERATION
4'b0011 : Result = Src_A | Src_B; // OR OPERATION
4'b0100 : Result =  Src_A ^ Src_B;  //XOR OPERATION
4'b0101 : Result = ($signed(Src_A) < $signed(Src_B)) ? 32'd1 : 32'd0; //Set less than signed
4'b0110 : Result = Src_A << Src_B[4:0];  // shift left logical
4'b0111 : Result = Src_A >> Src_B[4:0];  // shift right logical
4'b1000 : Result = $signed(Src_A) >>> Src_B[4:0];  // shift right arithmatic
4'b1001 : Result = (Src_A < Src_B) ? 32'd1 : 32'd0; // set less than unsigned
4'b1010 : Result = Src_B;  //LUI
default :  Result =  32'h00000000;
endcase

end



endmodule





////////////////////
// MEMORY

module RISC_MEMORY(
input clk , input rst_n, input RegWriteM, input [1:0] ResultSrcM, input MemWriteM,
input [2:0] FUNCT3M, 
input [31:0] ALUResultM, input [31:0] WriteDataM, input [31:0] PCPlus4M,
input [4:0] RDM, output reg RegWriteW, output reg [1:0] ResultSrcW, 
output reg [31:0] ReadDataW , output reg [4:0] RDW ,
output reg [31:0] PCPlus4W  , output reg [31:0] ALUResultW
    );
    
    reg [31:0] ReadDataW_reg;
    reg [31:0] mem[0:1023];
    
    wire [31:0] ReadData = mem[ALUResultM[31:2]];  //  ALUResultM[31:2] is word address
    
   // ALUResultM={Word Address, Byte Offset}
    // byte offset just tells which byte to be chosen from 32 bit ReadData
    
    
    always @(posedge clk or negedge rst_n)
    begin
    if (!rst_n)
    begin
    RegWriteW   <= 0;
    ResultSrcW  <= 2'b00;
    ReadDataW   <= 32'h00000000;
    RDW         <= 5'b00000;
    PCPlus4W    <= 32'h00000000;
    ALUResultW  <= 32'h00000000;
    
   end 
   
   else
   begin
   
    RegWriteW   <=  RegWriteM;
     ResultSrcW  <= ResultSrcM;
     ReadDataW   <= ReadDataW_reg;
     RDW         <=  RDM;
     PCPlus4W    <=  PCPlus4M;
     ALUResultW  <= ALUResultM;
   
   if(MemWriteM)
   begin
   case(FUNCT3M)
   3'b000 :  
   begin       // store only WriteDataM[7:0] byte into memory
   case (ALUResultM[1:0])
   2'b00 : mem[ALUResultM[31:2]][7:0] <= WriteDataM[7:0];
   2'b01 : mem[ALUResultM[31:2]][15:8] <= WriteDataM[7:0];
   2'b10 : mem[ALUResultM[31:2]][23:16] <= WriteDataM[7:0];
   2'b11 : mem[ALUResultM[31:2]][31:24] <= WriteDataM[7:0];
   
   
   endcase
   end
   
   3'b001: // store only WriteDataM[15:0] halfword into memory
   begin
   case(ALUResultM[1:0])
   
    2'b00 : mem[ALUResultM[31:2]][15:0] <= WriteDataM[15:0];
   2'b10 : mem[ALUResultM[31:2]][31:16] <= WriteDataM[15:0]; 
   default: ;
  
   endcase
   end
   
   3'b010:  // store word
   begin
    mem[ALUResultM[31:2]] <=  WriteDataM;
   end
 
   default  : ;
  endcase 
    
   end 
   
   
    end
  
   end 
   
   
   always @(*)
   begin
   case(FUNCT3M)
  3'b000: begin //LOAD BYTE SIGNED
  case(ALUResultM[1:0])
   2'b00 :  ReadDataW_reg = {{24{ReadData[7]} }, ReadData[7:0]}; // selects BYTE ReadData[7:0]
   2'b01 :  ReadDataW_reg = {{24{ReadData[15]}},  ReadData[15:8]}; // selects BYTE ReadData[15:8]
   2'b10 :  ReadDataW_reg = {{24{ReadData[23]}},  ReadData[23:16]}; // selects BYTE ReadData[23:16]
   2'b11 :  ReadDataW_reg = {{24{ReadData[31]}},  ReadData[31:24]}; // selects BYTE ReadData[31:24]
   default :  ReadDataW_reg = 32'h00000000;
  endcase
  end
   
 3'b001 :  // LOAD HALF WORD
 begin
  case(ALUResultM[1:0])
 2'b00 : ReadDataW_reg = {{16{ReadData[15]}}, ReadData[15:0]}; //selects half word ReadData[15:0]
 2'b10 : ReadDataW_reg = {{16{ReadData[31]}}, ReadData[31:16]}; //selects half word ReadData[31:16]
 default :  ReadDataW_reg = 32'h00000000;
  endcase
 end  
 
 3'b010 :  // Load WORD
 ReadDataW_reg = ReadData;
 
 3'b100 : 
 begin // load byte unsigned
 case(ALUResultM[1:0])
  2'b00 :  ReadDataW_reg = {24'b0, ReadData[7:0]}; // selects BYTE ReadData[7:0]
   2'b01 :  ReadDataW_reg = {24'b0,  ReadData[15:8]}; // selects BYTE ReadData[15:8]
   2'b10 :  ReadDataW_reg = {24'b0,  ReadData[23:16]}; // selects BYTE ReadData[23:16]
   2'b11 :  ReadDataW_reg = {24'b0,  ReadData[31:24]}; // selects BYTE ReadData[31:24]
   default :  ReadDataW_reg = 32'h00000000;
   endcase
   end
   
   3'b101:  // load half word unsigned
   begin
   case(ALUResultM[1:0])
 2'b00 : ReadDataW_reg = {16'b0, ReadData[15:0]}; //selects half word ReadData[15:0]
 2'b10 : ReadDataW_reg = {16'b0, ReadData[31:16]}; //selects half word ReadData[31:16]
 default :  ReadDataW_reg = 32'h00000000;
  
   endcase
   end
   
   
   default :  ReadDataW_reg = 32'h00000000;
   endcase
   end
   
endmodule


////WRITEBACK

module RISC_WB(
input RegWriteW,
input [1:0] ResultSrcW, 
input [31:0] ReadDataW ,input [4:0] RDW ,
input [31:0] PCPlus4W  ,input [31:0] ALUResultW,
output reg [31:0] ResultW
    );
    
    always @(*)
    begin
    case(ResultSrcW)
    2'b00 : ResultW = ALUResultW;
    2'b01 : ResultW = ReadDataW;
    2'b10 : ResultW = PCPlus4W;
    default : ResultW = 32'h00000000;

    
    endcase
    end
endmodule


//HAZARD 

module HAZARD_UNIT(
input rst_n, input [4:0] RDM, input RegWriteM, input [4:0] RDW, input RegWriteW, 
input [4:0] Rs1E, input [4:0] Rs2E , output [1:0] ForwardAE,  
output [1:0] ForwardBE
    );
    
  assign ForwardAE = (rst_n == 0) ? 2'b00 :( ( RegWriteM && ( RDM !=5'd0) &&  (RDM == Rs1E))? 2'b10 : 
  (RegWriteW && (RDW != 0) && (RDW == Rs1E)) ? 2'b01 : 2'b00) ;
  
   assign ForwardBE = (rst_n == 0) ? 2'b00 :( ( RegWriteM && ( RDM != 5'd0) &&  (RDM == Rs2E))? 2'b10 : 
  (RegWriteW && (RDW != 0) && (RDW == Rs2E)) ? 2'b01 : 2'b00) ;
  
endmodule












































































































