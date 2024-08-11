`timescale 1ns / 1ps

`include "defines.vh"

module PC(
    input wire clk,
    input wire rst,
    input wire [31:0] din,
    output reg [31:0] pc
);

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            pc <= 32'hfffffffc;
        end else begin
            pc <= din;
        end
    end

endmodule
