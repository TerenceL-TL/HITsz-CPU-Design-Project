`timescale 1ns / 1ps

`include "defines.vh"

module LEXT (
    input wire [31:0] din,     // Data input
    input wire [2:0]  ext_op,  // Extension operation
    input wire [1:0]  word_sel, // select byte or hex in word
    output reg [31:0] dout    // Data output
);
    wire [7:0] din8 = (word_sel == 2'b00) ? din[7:0]   :
                      (word_sel == 2'b01) ? din[15:8]  :
                      (word_sel == 2'b10) ? din[23:16] :
                      din[31:24];

    wire [15:0] din16 = (word_sel == 2'b00) ? din[15:0]:
                        (word_sel == 2'b01) ? din[23:8]:
                        din[31:16];

    always @(*) begin
        case(ext_op)
            `LEXT_8U : dout = {{24{1'b0}}, din8};     // Zero extend 8-bit
            `LEXT_8  : dout = {{24{din8[7]}}, din8};   // Sign extend 8-bit
            `LEXT_16U: dout = {{16{1'b0}}, din16};    // Zero extend 16-bit
            `LEXT_16 : dout = {{16{din16[15]}}, din16}; // Sign extend 16-bit
            `LEXT_32 : dout = din;                        // Output 32-bit original data
            default: dout = din;
        endcase
    end

endmodule

