`timescale 1ns / 1ps

`include "defines.vh"

module RF (
    input wire         clk,       // Clock signal
    input wire         rst,       // Reset signal
    input wire [4:0]   rR1,       // Read Register 1
    input wire [4:0]   rR2,       // Read Register 2
    input wire [4:0]   wR,        // Write Register
    input wire         we,        // Write enable
    input wire [31:0]  wD,        // Write Data
    output reg [31:0]  rD1,       // Read Register 1 Data
    output reg [31:0]  rD2        // Read Register 2 Data
);

    reg [31:0] registers [31:0];  // Register file

    // Initialize register file to 0
    always @(posedge rst or posedge clk) begin
        if (rst == 1'b1) begin
            registers[0]  <= 32'h0;
            registers[1]  <= 32'h0;
            registers[2]  <= 32'h0;
            registers[3]  <= 32'h0;
            registers[4]  <= 32'h0;
            registers[5]  <= 32'h0;
            registers[6]  <= 32'h0;
            registers[7]  <= 32'h0;
            registers[8]  <= 32'h0;
            registers[9]  <= 32'h0;
            registers[10] <= 32'h0;
            registers[11] <= 32'h0;
            registers[12] <= 32'h0;
            registers[13] <= 32'h0;
            registers[14] <= 32'h0;
            registers[15] <= 32'h0;
            registers[16] <= 32'h0;
            registers[17] <= 32'h0;
            registers[18] <= 32'h0;
            registers[19] <= 32'h0;
            registers[20] <= 32'h0;
            registers[21] <= 32'h0;
            registers[22] <= 32'h0;
            registers[23] <= 32'h0;
            registers[24] <= 32'h0;
            registers[25] <= 32'h0;
            registers[26] <= 32'h0;
            registers[27] <= 32'h0;
            registers[28] <= 32'h0;
            registers[29] <= 32'h0;
            registers[30] <= 32'h0;
            registers[31] <= 32'h0;
        end else if (we && (wR != 5'b0)) begin
            registers[wR] <= wD;
        end
    end

    // Read from register file
    always @(*) begin
        rD1 = (rR1 == 5'b0) ? 32'h0 : registers[rR1];
        rD2 = (rR2 == 5'b0) ? 32'h0 : registers[rR2];
    end

endmodule
