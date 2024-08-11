`timescale 1ns / 1ps

`include "defines.vh"

module memory (
    input wire  [1:0]   wb_op,      // write back operator
    input wire  [2:0]   lext_op,    // Extension operation for load data
    input wire  [1:0]   rf_wsel,    // Write Data
    input wire  [1:0]   word_sel,   // Selection for hex or bytes in word
    input wire  [31:0]  aluc,       // res of alu
    input wire  [31:0]  pc4,        // npc: pc+4
    input wire  [31:0]  ext,        // Output as 32 bits data
    input wire  [31:0]  word_data,  // word read from dram
    input wire  [31:0]  write_data, // write data, maybe hex or byte or word
    output wire [31:0]  write_dram, // to dram
    output reg  [31:0]  write_reg   // to reg
);
    wire [31:0] drdo;

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
        .dout(drdo)
    );

    always@(*) begin 
        case(rf_wsel)
            `RFW_ALUC: write_reg = aluc;
            `RFW_DRAM: write_reg = drdo;
            `RFW_SEXT: write_reg = ext;
            `RFW_NPC:  write_reg = pc4;
            default:   write_reg = 32'h0;
        endcase
    end

endmodule
