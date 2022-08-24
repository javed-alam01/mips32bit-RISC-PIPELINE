`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2022 12:34:04 PM
// Design Name: 
// Module Name: mips_32_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// testbench 
module test_risc_32();
    reg clk1,clk2;
    integer k;
    risc32_pipe mips(clk1,clk2);
   
    initial
        begin
            clk1=0;
            clk2=0;
        end
    always
    begin
        #5 clk1 = 1; #5 clk1 = 0;
        #5 clk2 = 1; #5 clk2 = 0;
    end
   
    initial
    begin
      $dumpfile("mips.vcd");
  $dumpvars(0, test_risc_32);
    for (k=0; k<31; k = k+1) mips.regb[k] = k;
    mips.mem[0] = 32'h28010001;
    mips.mem[1] = 32'h28020010;
    mips.mem[2] = 32'h28030011;
    mips.mem[3] = 32'h0ce77800; //dummy
    mips.mem[4] = 32'h0ce77800; //dummy
    mips.mem[5] = 32'h00222000;
    mips.mem[6] = 32'h0ce77800; //dummy
    mips.mem[7] = 32'h00822800;
    mips.mem[8] = 32'hfc000000;
    mips.halted = 0;
    mips.pc <= 0;
    mips.taken_branch <= 0;
    $display("r0 - %d",mips.regb[0]);
    $display("r1 - %d",mips.regb[1]);
    $display("r2 - %d",mips.regb[2]);
    $display("r3 - %d",mips.regb[3]);
    $display("r4 - %d",mips.regb[4]);
    $display("r5 - %d",mips.regb[5]);
    #500 $finish;
    end
   
endmodule


