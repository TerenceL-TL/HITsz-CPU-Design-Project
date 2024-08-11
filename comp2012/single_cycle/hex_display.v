`timescale 1ns / 1ps

`include "defines.vh"

module hex_display (
    input wire [31:0] din,
    input wire        dig_we,
    output wire [7:0] dig_en,
    output wire DN_A,
    output wire DN_B,
    output wire DN_C,
    output wire DN_D,
    output wire DN_E,
    output wire DN_F,
    output wire DN_G,
    output wire DN_DP,
    input wire clk,
    input wire rst
);

    reg [31:0] din_reg; // Register to store din when dig_we is active
    reg [3:0] hex_digit;
    reg [2:0] current_digit; // 3-bit counter to cycle through 8 digits
    reg [19:0] cycle_counter; // 5-bit counter for counting to 20

    // Internal registers for the outputs
    reg [7:0] dig_en_reg;
    reg DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg, DN_DP_reg;

    // Update din_reg when dig_we is active
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            din_reg <= 32'b0;
        end else if (dig_we) begin
            din_reg <= din;
        end else begin 
            din_reg <= din_reg;
        end
    end

    // Extract 4-bit segments from din_reg
    wire [3:0] hex_digit0 = din_reg[3:0];
    wire [3:0] hex_digit1 = din_reg[7:4];
    wire [3:0] hex_digit2 = din_reg[11:8];
    wire [3:0] hex_digit3 = din_reg[15:12];
    wire [3:0] hex_digit4 = din_reg[19:16];
    wire [3:0] hex_digit5 = din_reg[23:20];
    wire [3:0] hex_digit6 = din_reg[27:24];
    wire [3:0] hex_digit7 = din_reg[31:28];

    // Select current digit
    always @(*) begin
        case (current_digit)
            3'b000: hex_digit = hex_digit0;
            3'b001: hex_digit = hex_digit1;
            3'b010: hex_digit = hex_digit2;
            3'b011: hex_digit = hex_digit3;
            3'b100: hex_digit = hex_digit4;
            3'b101: hex_digit = hex_digit5;
            3'b110: hex_digit = hex_digit6;
            3'b111: hex_digit = hex_digit7;
            default: hex_digit = 4'b0000;
        endcase
    end

    // Seven-segment display encoding with reversed logic
    always @(*) begin
        case (hex_digit)
            4'h0: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0000001;
            4'h1: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b1001111;
            4'h2: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0010010;
            4'h3: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0000110;
            4'h4: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b1001100;
            4'h5: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0100100;
            4'h6: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0100000;
            4'h7: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0001111;
            4'h8: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0000000;
            4'h9: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0000100;
            4'hA: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0001000;
            4'hB: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b1100000;
            4'hC: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0110001;
            4'hD: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b1000010;
            4'hE: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0110000;
            4'hF: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b0111000;
            default: {DN_A_reg, DN_B_reg, DN_C_reg, DN_D_reg, DN_E_reg, DN_F_reg, DN_G_reg} = 7'b1111111;
        endcase
        DN_DP_reg = 1'b1; // Decimal point off (reversed logic, so 1 means off)
    end

    // Digit enable control with reversed logic
    always @(*) begin
        dig_en_reg = 8'b11111111; // Disable all digits by default (reversed logic, so 1 means disabled)
        case (current_digit)
            3'b000: dig_en_reg = 8'b11111110;
            3'b001: dig_en_reg = 8'b11111101;
            3'b010: dig_en_reg = 8'b11111011;
            3'b011: dig_en_reg = 8'b11110111;
            3'b100: dig_en_reg = 8'b11101111;
            3'b101: dig_en_reg = 8'b11011111;
            3'b110: dig_en_reg = 8'b10111111;
            3'b111: dig_en_reg = 8'b01111111;
        endcase
    end

    // State machine to cycle through digits with a counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_counter <= 0;
            current_digit <= 0;
        end else begin
            if (cycle_counter == 20'd25000) begin
                cycle_counter <= 0;
                current_digit <= current_digit + 1;
            end else begin
                cycle_counter <= cycle_counter + 1;
            end
        end
    end

    // Assign internal registers to outputs
    assign dig_en = dig_en_reg;
    assign DN_A = DN_A_reg;
    assign DN_B = DN_B_reg;
    assign DN_C = DN_C_reg;
    assign DN_D = DN_D_reg;
    assign DN_E = DN_E_reg;
    assign DN_F = DN_F_reg;
    assign DN_G = DN_G_reg;
    assign DN_DP = DN_DP_reg;

endmodule

