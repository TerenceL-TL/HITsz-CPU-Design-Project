`timescale 1ns / 1ps

`include "defines.vh"

module led_display (
    input wire led_clk,
    input wire led_rst,
    input wire led_we,
    input wire [31:0] led_wdata,
    output reg [23:0] led
);

    always @(posedge led_clk or posedge led_rst)
    begin
        if (led_rst) begin
            led <= 24'hffffff; // Initialize LEDs to be all off 
        end else begin
            if (led_we) begin
                led <= led_wdata[23:0]; // Write data to LEDs
            end else begin
                led <= led; // Hold the current state
            end
        end
    end

endmodule
