`timescale 1ns / 1ps

`include "defines.vh"

module memory (
    input wire  [2:0]   wb_op,      // write back operator
    input wire  [2:0]   lext_op,    // Extension operation for load data
    input wire  [1:0]   word_sel,   // Selection for hex or bytes in word
    input wire  [31:0]  word_data,  // word read from dram
    input wire  [31:0]  write_data, // write data, maybe hex or byte or word
    output wire [31:0]  write_dram, // to dram
    output wire [31:0]  write_reg   // to reg
);

    mem_process MEM_process (
        .wb_op(wb_op),
        .word_sel(word_sel),
        .word_data(word_data),
        .write_data(write_data),
        .write_word(write_dram)
    );

    LEXT LOAD_EXT (
        .din(word_data),
        .ext_op(lext_op),
        .word_sel(word_sel),
        .dout(write_reg)
    );

endmodule
