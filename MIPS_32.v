`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2022 12:27:52 PM
// Design Name: 
// Module Name: MIPS_32
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


// risc 32 bit pilpeline


module risc32_pipe(clk1, clk2);
    input clk1, clk2;
    reg[31:0] pc, if_id_ir, if_id_npc;
    reg[31:0] id_ex_ir, id_ex_npc, id_ex_a, id_ex_b, id_ex_imm;
    reg[2:0] id_ex_type, ex_mem_type, mem_wb_type;
    reg[31:0] ex_mem_ir, ex_mem_aluout, ex_mem_b;
    reg ex_mem_cond;
    reg[31:0] mem_wb_ir, mem_wb_aluout, mem_wb_lmd;
    reg[31:0] regb [0:31];
    reg[31:0] mem [0:31];
    parameter add = 6'b000000, sub = 6'b000001, andr = 6'b000010, orr = 6'b000011, slt = 6'b000100, mul = 6'b000101, hlt = 6'b111111, lw = 6'b001000, sw = 6'b001001, addi = 6'b001010, subi = 6'b001011, slti = 6'b001100, bneqz = 6'b001101, beqz = 6'b001110;
    parameter rr_alu = 3'b000, rm_alu = 3'b001, load = 3'b010, store = 3'b011, branch = 3'b100, halt = 3'b101;
    reg halted, taken_branch;
   
    //Instruction Fetch stage
    always @(posedge clk1)
    begin
        if(halted == 0)
        begin
            if(((ex_mem_ir[31:26] == beqz) && (ex_mem_cond == 1)) || ((ex_mem_ir[31:26] == bneqz) && (ex_mem_cond == 0)))
            begin
                if_id_ir <= #2 mem[ex_mem_aluout];
                taken_branch <= #2 1'b1;
                if_id_npc <= #2 ex_mem_aluout + 1;
                pc <= #2 ex_mem_aluout + 1;
            end
            else
            begin
                if_id_ir <= #2 mem[pc];
                if_id_npc <= #2 pc + 1;
                pc <= #2 pc + 1;
            end
        end
    end
   
    //Instruction Decode Stage
    always @(posedge clk2)
    begin
        if(halted == 0)
        begin
            if(if_id_ir[25:21] == 0) id_ex_a <= 0;
            else id_ex_a <= #2 regb[if_id_ir[25:21]];
            if(if_id_ir[20:16] == 0) id_ex_b <= 0;
            else id_ex_b <= #2 regb[if_id_ir[20:16]];
            id_ex_npc <= #2 if_id_npc;
            id_ex_ir <= #2 if_id_ir;
            id_ex_imm <= {{16{if_id_ir[15]}},{if_id_ir[15:0]}};
            case (if_id_ir[31:26])
                add: id_ex_type <= #2 rr_alu;
                sub: id_ex_type <= #2 rr_alu;
                andr: id_ex_type <= #2 rr_alu;
                orr: id_ex_type <= #2 rr_alu;
                slt: id_ex_type <= #2 rr_alu;
                mul: id_ex_type <= #2 rr_alu;
                addi: id_ex_type <= #2 rm_alu;
                subi: id_ex_type <= #2 rm_alu;
                slti: id_ex_type <= #2 rm_alu;
                lw: id_ex_type <= #2 store;
                beqz: id_ex_type <= #2 branch;
                bneqz: id_ex_type <= #2 branch;
                hlt: id_ex_type <= #2 halt;
                default: id_ex_type <= halt;
            endcase
        end
    end
   
    //Execution Stage
    always @(posedge clk1)
    if(halted == 0)
    begin
        ex_mem_type <= #2 id_ex_type;
        ex_mem_ir <= #2 id_ex_ir;
        taken_branch <= #2 0;
        case (id_ex_type)
        rr_alu: begin
                    case (id_ex_ir)
                        add: ex_mem_aluout <= #2 id_ex_a + id_ex_b;
                        sub: ex_mem_aluout <= #2 id_ex_a - id_ex_b;
                        andr: ex_mem_aluout <= #2 id_ex_a & id_ex_b;
                        orr: ex_mem_aluout <= #2 id_ex_a | id_ex_b;
                        slt: ex_mem_aluout <= #2 id_ex_a < id_ex_b;
                        mul: ex_mem_aluout <= #2 id_ex_a * id_ex_b;
                        default: ex_mem_aluout <= #2 32'hxxxxxxxx;
                    endcase
                end
        rm_alu: begin
                    case (id_ex_ir[31:26])
                        addi: ex_mem_aluout <= #2 id_ex_a + id_ex_imm;
                        subi: ex_mem_aluout <= #2 id_ex_a - id_ex_imm;
                        slti: ex_mem_aluout <= #2 id_ex_a < id_ex_imm;
                        default: ex_mem_aluout <= #2 32'hxxxxxxxx;
                    endcase
                end
        load: begin
                         ex_mem_aluout <= #2 id_ex_npc + id_ex_imm;
                         ex_mem_cond <= #2 (id_ex_a);
                     end
        store: begin
                         ex_mem_aluout <= #2 id_ex_npc + id_ex_imm;
                         ex_mem_cond <= #2 (id_ex_a);
                     end
        branch: begin
                    ex_mem_aluout <= #2 id_ex_npc + id_ex_imm;
                    ex_mem_cond <= #2 (id_ex_a);
                end        
        endcase
    end
   
    //Memory stage
    always @(posedge clk2)
    begin
        if(halted == 0)
        begin
            mem_wb_type <= #2 ex_mem_type;
            mem_wb_ir <= #2 ex_mem_ir;
            case (ex_mem_type)
                rr_alu: mem_wb_aluout <= #2 ex_mem_aluout;
                rm_alu: mem_wb_aluout <= #2 ex_mem_aluout;
                load: mem_wb_lmd <= #2 mem[ex_mem_aluout];
                store: if(taken_branch == 0) mem[ex_mem_aluout] <= #2 ex_mem_b;
            endcase
        end
    end
   
    //Write Back Stage
    always @(posedge clk1)
    begin
        if(taken_branch == 0)
        case (mem_wb_type)
            rr_alu: regb[mem_wb_ir[15:11]] <= #2 mem_wb_aluout;
            rm_alu: regb[mem_wb_ir[15:11]] <= #2 mem_wb_aluout;
            load: regb[mem_wb_ir[20:16]] <= #2 mem_wb_lmd;
            halt: halted <= #2 1'b1;
        endcase
    end
    endmodule

