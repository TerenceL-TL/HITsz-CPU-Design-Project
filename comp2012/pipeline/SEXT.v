`timescale 1ns / 1ps

`include "defines.vh"

module SEXT(
    input wire [25:0]  din,          // data in, as immediate numbers
    input wire [2:0]   sext_op,      // extension unit operation
    output reg [31:0]  ext           // Output as 32 bits data
    );

    /* 
        Five types of op: defined in defines.vh
        1. EXT_I5:   ui5 = din[14:10], and get ext = {27'b0, ui5}
        2. EXT_I12:  si12 = din[21:10], and get ext = sext(si12)
        3. EXT_I12U: zi12 = din[21:10], and get ext = zext(si12)
        4. EXT_I20:  si20 = din[24:5], and get ext = {si20, 12'b0}
        5. EXT_I16:  offs = din[25:10], and get ext = sext({offs, 2'b0})
        sext means signed extension, while zext means zero extension
    */
    
    always @(*) begin
        case (sext_op)
            `EXT_I5: begin
                // Unsigned 5-bit immediate
                ext = {27'b0, din[14:10]};
            end
            `EXT_I12: begin
                // Signed 12-bit immediate
                ext = {{20{din[21]}}, din[21:10]};
            end
            `EXT_I12U: begin
                // Zero extended 12-bit immediate
                ext = {20'b0, din[21:10]};
            end
            `EXT_I20: begin
                // Signed 20-bit immediate shifted left by 12 bits
                ext = {din[24:5], 12'b0};
            end
            `EXT_I16: begin
                // Signed 16-bit immediate shifted left by 2 bits
                ext = {{14{din[25]}}, din[25:10], 2'b0};
            end
            `EXT_I26: begin 
                ext = {{4{din[9]}}, din[9:0], din[25:10], 2'b0};
            end
            default: begin
                // Default case to handle unexpected sext_op values
                ext = 32'b0;
            end
        endcase
    end

endmodule
