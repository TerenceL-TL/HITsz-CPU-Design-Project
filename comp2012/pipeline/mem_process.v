`timescale 1ns / 1ps

`include "defines.vh"

module mem_process (
    input wire [1:0]   wb_op,      // write back operator
    input wire [1:0]   word_sel,   // Selection for hex or bytes in word
    input wire [31:0]  word_data,  // word read from dram
    input wire [31:0]  write_data, // write data, maybe hex or byte or word
    output reg [31:0]  write_word
);

    wire [7:0] data_byte = write_data[7:0];
    wire [15:0] data_hex = write_data[15:0];

    always@(*) begin 
        case(wb_op)
            `WB_BYTE: write_word = (word_sel == 2'b00) ? {word_data[31:8], data_byte}                   :
                                   (word_sel == 2'b01) ? {word_data[31:16], data_byte, word_data[7:0]}  :
                                   (word_sel == 2'b10) ? {word_data[31:24], data_byte, word_data[15:0]} :
                                                         {data_byte, word_data[23:0]};
            `WB_HEX:  write_word = (word_sel == 2'b00) ? {word_data[31:16], data_hex} :
                                   (word_sel == 2'b01) ? {word_data[31:24], data_hex, word_data[7:0]} : 
                                                         {data_hex, word_data[15:0]};
            `WB_WORD: write_word = write_data;  // write entire word
        endcase  
    end

endmodule
