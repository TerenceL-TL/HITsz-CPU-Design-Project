`timescale 1ns / 1ps

`include "defines.vh"

module forwarding_unit (
    input wire [4:0] id_ex_rs1,
    input wire [4:0] id_ex_rs2,
    input wire [4:0] ex_mem_rd,
    input wire       ex_mem_regwrite,
    input wire [4:0] mem_wb_rd,
    input wire       mem_wb_regwrite,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @(*) begin
        // Default forwarding controls
        forward_a = 2'b00;
        forward_b = 2'b00;

        // EX hazard
        if (ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10;
        end
        if (ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end

        // MEM hazard
        if (mem_wb_regwrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs1) && 
            !(ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1))) begin
            forward_a = 2'b01;
        end
        if (mem_wb_regwrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs2) && 
            !(ex_mem_regwrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2))) begin
            forward_b = 2'b01;
        end
    end
endmodule
