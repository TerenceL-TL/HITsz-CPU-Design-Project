`timescale 1ns / 1ps

`include "defines.vh"

module idecode (
    input wire         clk,
    input wire         rst,
    input wire [31:0]  inst,      // instruction got from ifetch
    input wire [2:0]   sext_op,   // For sext module
    input wire         rf2_sel,   // RF2_RK means using inst[14:10] as rR2, RF2_RD means using inst[4:0] as rR2
    input wire         rf_wrsel,  // whether it is jal
    input wire         we,        // Write Enable
    input wire  [4:0]  wb_wR,        // reg to write
    input wire  [31:0] wb_wD,        // data to write
    output wire [4:0]  rR1,
    output wire [4:0]  rR2,
    output wire [4:0]  wR_out,
    output wire [31:0] rD1_out,       // Read Register 1 Data
    output wire [31:0] rD2_out,       // Read Register 2 Data
    output wire [31:0] ext        // Output as 32 bits data
);

    wire [31:0] rD1;
    wire [31:0] rD2;

    assign rR1 = inst[9:5];                                            // rj
    assign rR2 = (rf2_sel == `RF2_RK) ? inst[14:10] : inst[4:0];       // rk or rd
    assign wR_out = (rf_wrsel == `RFWR_N) ? inst[4:0] : 5'b00001;

    assign rD1_out = (wb_wR == rR1 & wb_wR != 5'b0) ? wb_wD : rD1;
    assign rD2_out = (wb_wR == rR2 & wb_wR != 5'b0) ? wb_wD : rD2;

    // Instantiate RF module
    RF rf_inst (
        .clk(clk),
        .rst(rst),
        .rR1(rR1),
        .rR2(rR2),
        .wR(wb_wR),
        .we(we),
        .wD(wb_wD),
        .rD1(rD1),
        .rD2(rD2)
    );

    // Instantiate SEXT module
    SEXT sext_inst (
        .din(inst[25:0]),
        .sext_op(sext_op),
        .ext(ext)
    );

endmodule
