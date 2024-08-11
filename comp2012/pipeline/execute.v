`timescale 1ns / 1ps

`include "defines.vh"

module execute(
    // ALU A
    input wire [31:0]  rf_rD1,
    input wire [31:0]  pc,

    // ALU B
    input wire [31:0]  rf_rD2,
    input wire [31:0]  ext,

    // selection
    input wire         alua_sel,
    input wire         alub_sel,

    input wire [3:0]   alu_op,

    input wire [1:0]   forward_a,
    input wire [1:0]   forward_b,
    input wire [31:0]  mem_wD,
    input wire [31:0]  wb_wD,
  
    output wire [31:0] alu_c,
    output wire        alu_f,
    output reg [31:0] alu_src1,
    output reg [31:0] alu_src2
    );

    wire [31:0] alu_a;    // ALU operand A
    wire [31:0] alu_b;    // ALU operand B

    

    /*
        alua_sel has two types:
        ALUA_RD1:  alu_a = rf_rD1
        ALUA_PC:   alu_a = pc

        alub_sel has two types:
        ALUB_RD2:  alu_a = rf_rD1
        ALUA_SEXT: alu_a = ext
    */

    // Selection logic for ALU A
    assign alu_a = (alua_sel == `ALUA_PC) ? pc : alu_src1;

    // Selection logic for ALU B
    assign alu_b = (alub_sel == `ALUB_SEXT) ? ext : alu_src2;

    always @(*) begin
    case (forward_a)
        2'b00: alu_src1 = rf_rD1;
        2'b10: alu_src1 = mem_wD;
        2'b01: alu_src1 = wb_wD;
        default: alu_src1 = rf_rD1;
    endcase

    case (forward_b)
        2'b00: alu_src2 = rf_rD2;
        2'b10: alu_src2 = mem_wD;
        2'b01: alu_src2 = wb_wD;
        default: alu_src2 = rf_rD2;
    endcase
end

    // Instantiate ALU module
    ALU alu_inst (
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_op(alu_op),
        .alu_c(alu_c),
        .alu_f(alu_f)
    );


endmodule
