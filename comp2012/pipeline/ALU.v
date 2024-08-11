`timescale 1ns / 1ps

`include "defines.vh"

module ALU(
    input wire [31:0]  alu_a,    // number 1
    input wire [31:0]  alu_b,    // number 2
    input wire [3:0]   alu_op,   // operator
    output reg [31:0] alu_c,    // result
    output reg        alu_f     // signature
    );

    /*
        alu_op has different values:
        ALU_ADD:  alu_c = alu_a + alu_b
        ALU_SUB:  alu_c = alu_a - alu_b
        ALU_AND:  alu_c = alu_a & alu_b
        ALU_OR:   alu_c = alu_a | alu_b
        ALU_XOR:  alu_c = alu_a ^ alu_b
        ALU_SLL:  alu_c = alu_a << alu_b (logical shift left)
        ALU_SRL:  alu_c = alu_a >> alu_b (logical shift right)
        ALU_SRA:  alu_c = alu_a >>> alu_b (arthithmatical shift right)
        ALU_SLT:  alu_c = (alu_a < alu_b)  signed comparison
        SLU_SLTU: alu_c = (alu_a < alu_b)  unsigned comparison
    */

    /*
        Note that alu_f follows alu_c[0] while comparing two numbers.
    */

    wire signed [31:0] signed_a = alu_a;
    wire signed [31:0] signed_b = alu_b;

    always @(*) begin
        case (alu_op)
            `ALU_ADD:  alu_c = alu_a + alu_b;
            `ALU_SUB:  alu_c = alu_a - alu_b;
            `ALU_AND:  alu_c = alu_a & alu_b;
            `ALU_OR:   alu_c = alu_a | alu_b;
            `ALU_XOR:  alu_c = alu_a ^ alu_b;
            `ALU_SLL:  alu_c = alu_a << alu_b[4:0];
            `ALU_SRL:  alu_c = alu_a >> alu_b[4:0];
            `ALU_SRA:  alu_c = signed_a >>> alu_b[4:0];
            `ALU_SLT:  alu_c = (signed_a[31] & ~signed_b[31]) | 
                               ((signed_a - signed_b) >> 31 & ~(~signed_a[31] & signed_b[31])); // Signed comparison
            `ALU_SLTU: alu_c = (~alu_a[31] & alu_b[31]) | 
                               ((alu_a - alu_b) >> 31 & ~(alu_a[31] & ~alu_b[31]));       // Unsigned comparison
            default:   alu_c = 32'd0;
        endcase

        // Signature flag
        if (alu_op == `ALU_SLT | alu_op == `ALU_SLTU) alu_f = alu_c[0];
        else alu_f = (alu_c == 32'd0);
    end

endmodule
