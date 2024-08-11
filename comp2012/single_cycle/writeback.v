`timescale 1ns / 1ps

`include "defines.vh"

module writeback (
    input wire [31:0] inst,
    // 4 inputs
    input wire [31:0]  aluc,      // res of alu
    input wire [31:0]  pc4,       // npc: pc+4
    input wire [31:0]  drdo,      // read data from dram
    input wire [31:0]  ext,       // Output as 32 bits data
    input wire         rf_wrsel,  // whether it is jal
    input wire [1:0]   rf_wsel,   // Write Data
    output reg [4:0]   wR,
    output reg [31:0]  wD         // for reg RF
);

    always@(*) begin 
        case(rf_wsel)
            `RFW_ALUC: wD = aluc;
            `RFW_DRAM: wD = drdo;
            `RFW_SEXT: wD = ext;
            `RFW_NPC:  wD = pc4;
            default:   wD = 32'h0;
        endcase
        wR  = (rf_wrsel == `RFWR_N) ? inst[4:0] : 5'b00001;
    end

endmodule