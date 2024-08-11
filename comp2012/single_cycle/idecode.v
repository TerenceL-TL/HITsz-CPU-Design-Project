`timescale 1ns / 1ps

`include "defines.vh"

module idecode (
    input wire         clk,
    input wire         rst,
    input wire [31:0]  inst,      // instruction got from ifetch
    input wire [2:0]   sext_op,   // For sext module
    input wire         rf2_sel,   // RF2_RK means using inst[14:10] as rR2, RF2_RD means using inst[4:0] as rR2
    input wire         we,        // Write Enable
    input wire  [4:0]  wR,        // reg to write
    input wire  [31:0] wD,        // data to write
    output wire [31:0] rD1,       // Read Register 1 Data
    output wire [31:0] rD2,       // Read Register 2 Data
    output wire [31:0] ext        // Output as 32 bits data
);

    wire [4:0] rR1;               // Read Register 1
    wire [4:0] rR2;               // Read Register 2

    assign rR1 = inst[9:5];                                            // rj
    assign rR2 = (rf2_sel == `RF2_RK) ? inst[14:10] : inst[4:0];       // rk or rd

    // Instantiate RF module
    RF rf_inst (
        .clk(clk),
        .rst(rst),
        .rR1(rR1),
        .rR2(rR2),
        .wR(wR),
        .we(we),
        .wD(wD),
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
