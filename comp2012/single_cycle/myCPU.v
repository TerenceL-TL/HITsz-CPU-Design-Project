`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr,
`else
    output wire [13:0]  inst_addr,
`endif
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_we,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // Internal signals for ifetch
    wire br;
    wire [31:0] npc_pc4;

    wire [2:0] npc_op;   

    // Internal signals for idecode
    wire [31:0] rD1;
    wire [31:0] rD2;
    wire [31:0] wD;
    wire [4:0]  wR;
    wire [31:0] ext;
    wire [31:0] alu_c;

    wire [1:0] rf_wsel;
    wire rf_we; 
    wire rf2_sel;
    wire rf_wrsel; 
    wire [2:0] sext_op;  

    // LEXT
    wire [2:0] lext_op;
    wire [31:0] loadData2reg;

    // Internal signals for execute
    wire [3:0] alu_op;
    wire alua_sel;
    wire alub_sel;

    // Internal signals for writeback
    wire [1:0] wb_op;

    // Instantiate ifetch module
    ifetch IF (
        .clk(cpu_clk),
        .rst(cpu_rst),
        .offset(ext),
        .jal_npc(alu_c),
        .br(alu_f),
        .npc_op(npc_op),
        .pc4(npc_pc4),
        .inst_addr(inst_addr)
    );

    // Instantiate idecode module
    idecode ID (
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst(inst),
        .sext_op(sext_op),
        .rf2_sel(rf2_sel),
        .we(rf_we),
        .wD(wD),
        .wR(wR),
        .rD1(rD1),
        .rD2(rD2),
        .ext(ext)
    );

    // Instantiate execute module
    execute EX (
        .rf_rD1(rD1),
        .pc({inst_addr, 2'b0}),
        .rf_rD2(rD2),
        .ext(ext),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .alu_op(alu_op),
        .alu_c(alu_c),
        .alu_f(alu_f)
    );

    // Instantiate controller module
    controller CONTROL (
        .inst(inst),
        .npc_op(npc_op),
        .rf_wsel(rf_wsel),
        .rf_wrsel(rf_wrsel),
        .rf_we(rf_we),
        .rf2_sel(rf2_sel),
        .sext_op(sext_op),
        .lext_op(lext_op),
        .alu_op(alu_op),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .ram_we(Bus_we),
        .wb_op(wb_op)
    );

    memory MEM (
        .wb_op(wb_op),
        .lext_op(lext_op),
        .word_sel(Bus_addr[1:0]),
        .word_data(Bus_rdata),
        .write_data(rD2),
        .write_dram(Bus_wdata),
        .write_reg(loadData2reg)
    );

    writeback WB (
        .inst(inst),
        .aluc(alu_c),
        .pc4(npc_pc4),
        .drdo(loadData2reg),
        .ext(ext),
        .rf_wrsel(rf_wrsel),
        .rf_wsel(rf_wsel),
        .wR(wR),
        .wD(wD)
    );

    assign Bus_addr = alu_c;

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = ~cpu_rst;
    assign debug_wb_pc        = {inst_addr, 2'b0};
    assign debug_wb_ena       = rf_we;
    assign debug_wb_reg       = (rf_wrsel == `RFWR_N)  ? inst[4:0] : 5'b00001;
    assign debug_wb_value     = wD;
`endif

endmodule
