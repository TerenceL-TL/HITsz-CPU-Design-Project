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
    wire [31:0] npc_pc4;
    wire [2:0] npc_op;  
    wire       jump_en; 

    // Internal signals for idecode
    wire [4:0]  rR1;
    wire [4:0]  rR2;
    wire [4:0]  wR_out;
    wire [31:0] rD1;
    wire [31:0] rD2;
    wire [31:0] wb_wD;
    wire [4:0]  wb_wR;
    wire [31:0] ext;
    wire [31:0] alu_c;
    wire [31:0] alu_src1;
    wire [31:0] alu_src2;

    wire [2:0]  ctrl_npc_op_out;
    wire [1:0]  ctrl_rf_wsel_out;
    wire        ctrl_rf_wrsel_out;  
    wire        ctrl_rf_we_out;
    wire        ctrl_rf2_sel_out;
    wire [2:0]  ctrl_sext_op_out;
    wire [2:0]  ctrl_lext_op_out;
    wire [3:0]  ctrl_alu_op_out;
    wire        ctrl_alua_sel_out;
    wire        ctrl_alub_sel_out;
    wire        ctrl_ram_we_out;
    wire [1:0]  ctrl_wb_op_out; 

    // MEM
    wire [31:0] loadData2reg;

    // forwarding 
    wire [1:0] forward_a;
    wire [1:0] forward_b;

    // reg logic rst
    wire if_id_rst;
    wire id_ex_rst;
    wire ex_mem_rst;
    wire mem_wb_rst;

    /*** IF_ID reg ***/ 
    // data
    reg [31:0] if_id_pc;
    reg [31:0] if_id_pc4;
    reg [31:0] if_id_inst;

    // module wire
    wire [31:0] if_pc_out;  
    wire [31:0] if_pc4_out; // for if
    
    /*** ID_EX reg ***/ 
    // control signal from controller
    reg [1:0] id_ex_rf_wsel;
    reg       id_ex_rf_we; 
    reg       id_ex_rf2_sel;
    reg       id_ex_rf_wrsel;

    reg [2:0] id_ex_sext_op; 
    reg [2:0] id_ex_lext_op;
    reg [3:0] id_ex_alu_op;
    reg [2:0] id_ex_npc_op;
    reg [1:0] id_ex_wb_op;

    reg       id_ex_alua_sel;
    reg       id_ex_alub_sel;
    reg       id_ex_ram_we;
    
    // data
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_pc4;
    reg [31:0] id_ex_inst;
    reg [31:0] id_ex_rD1;
    reg [31:0] id_ex_rD2;
    reg [31:0] id_ex_ext;

    reg [4:0]  id_ex_rR1;
    reg [4:0]  id_ex_rR2;
    reg [4:0]  id_ex_wR;

    /*** EX_MEM reg ***/ 
    // control signal from controller
    reg [1:0] ex_mem_rf_wsel;
    reg       ex_mem_rf_we; 
    reg       ex_mem_rf2_sel;
    reg       ex_mem_rf_wrsel;

    reg [2:0] ex_mem_sext_op; 
    reg [2:0] ex_mem_lext_op;
    reg [3:0] ex_mem_alu_op;
    reg [2:0] ex_mem_npc_op;
    reg [1:0] ex_mem_wb_op;

    reg       ex_mem_alua_sel;
    reg       ex_mem_alub_sel;
    reg       ex_mem_ram_we;
    
    // data
    reg [31:0] ex_mem_pc;
    reg [31:0] ex_mem_pc4;
    reg [31:0] ex_mem_inst;
    reg [31:0] ex_mem_alu_c;
    reg [31:0] ex_mem_alu_f;
    reg [31:0] ex_mem_ext;
    reg [31:0] ex_mem_rD2;

    reg [4:0]  ex_mem_rR1;
    reg [4:0]  ex_mem_rR2;
    reg [4:0]  ex_mem_wR;

    /*** MEM_WB reg ***/ 
    // control signal from controller
    reg [1:0] mem_wb_rf_wsel;
    reg       mem_wb_rf_we; 
    reg       mem_wb_rf2_sel;
    reg       mem_wb_rf_wrsel;

    reg [2:0] mem_wb_sext_op; 
    reg [2:0] mem_wb_lext_op;
    reg [3:0] mem_wb_alu_op;
    reg [2:0] mem_wb_npc_op;
    reg [1:0] mem_wb_wb_op;

    reg       mem_wb_alua_sel;
    reg       mem_wb_alub_sel;
    reg       mem_wb_ram_we;

    // data
    reg [31:0] mem_wb_pc;
    reg [31:0] mem_wb_pc4;
    reg [31:0] mem_wb_inst;
    reg [31:0] mem_wb_alu_c;
    reg [31:0] mem_wb_alu_f;
    reg [31:0] mem_wb_ext;
    reg [31:0] mem_wb_loadData2reg;

    reg [4:0]  mem_wb_rR1;
    reg [4:0]  mem_wb_rR2;
    reg [4:0]  mem_wb_wR;
    reg [31:0] mem_wb_wD;

    // Instantiate ifetch module
    ifetch IF (
        .clk(cpu_clk),
        .rst(cpu_rst),
        .offset(mem_wb_ext),
        .jal_npc(mem_wb_alu_c),
        .wb_pc(mem_wb_pc),
        .br(mem_wb_alu_f),
        .npc_op(mem_wb_npc_op),
        .pc4(if_pc4_out),
        .pc(if_pc_out),
        .jump_en(jump_en),
        .inst_addr(inst_addr)
    );

    // IF/ID pipeline register logic
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst | jump_en) begin
            if_id_inst <= 32'b0;
            if_id_pc4 <= 32'b0;
            if_id_pc <= 32'b0;
        end else begin
            if_id_inst <= inst;
            if_id_pc4 <= if_pc4_out;
            if_id_pc <= if_pc_out;
        end
    end

    // Instantiate idecode module
    idecode ID (
        .clk(cpu_clk),
        .rst(cpu_rst),
        .inst(if_id_inst),
        .sext_op(ctrl_sext_op_out),
        .rf2_sel(ctrl_rf2_sel_out),
        .rf_wrsel(ctrl_rf_wrsel_out),
        .we(mem_wb_rf_we),
        .wb_wD(wb_wD),
        .wb_wR(mem_wb_wR),
        .rR1(rR1),
        .rR2(rR2),
        .wR_out(wR_out),
        .rD1_out(rD1),
        .rD2_out(rD2),
        .ext(ext)
    );

    // Instantiate controller module
    controller CONTROL (
        .inst(if_id_inst),
        .npc_op(ctrl_npc_op_out),
        .rf_wsel(ctrl_rf_wsel_out),
        .rf_wrsel(ctrl_rf_wrsel_out),
        .rf_we(ctrl_rf_we_out),
        .rf2_sel(ctrl_rf2_sel_out),
        .sext_op(ctrl_sext_op_out),
        .lext_op(ctrl_lext_op_out),
        .alu_op(ctrl_alu_op_out),
        .alua_sel(ctrl_alua_sel_out),
        .alub_sel(ctrl_alub_sel_out),
        .ram_we(ctrl_ram_we_out),
        .wb_op(ctrl_wb_op_out)
    );

    // ID/EX pipeline register logic
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst | jump_en) begin
            id_ex_npc_op <= 3'b0;
            id_ex_rf_wsel <= 2'b0;
            id_ex_rf_we <= 1'b0;
            id_ex_rf2_sel <= 1'b0;
            id_ex_rf_wrsel <= 1'b0;
            id_ex_lext_op <= 3'b0;
            id_ex_alu_op <= 4'b0;
            id_ex_wb_op <= 2'b0;
            id_ex_alua_sel <= 1'b0;
            id_ex_alub_sel <= 1'b0;
            id_ex_ram_we <= 1'b0;
            id_ex_pc <= 32'b0;
            id_ex_pc4 <= 32'b0;
            id_ex_inst <= 32'b0;
            id_ex_rD1 <= 32'b0;
            id_ex_rD2 <= 32'b0;
            id_ex_ext <= 32'b0;
            id_ex_rR1 <= 5'b0;
            id_ex_rR2 <= 5'b0;
            id_ex_wR  <= 5'b0;
        end else begin
            id_ex_npc_op <= ctrl_npc_op_out;
            id_ex_rf_wsel <= ctrl_rf_wsel_out;
            id_ex_rf_we <= ctrl_rf_we_out;
            id_ex_rf2_sel <= ctrl_rf2_sel_out;
            id_ex_rf_wrsel <= ctrl_rf_wrsel_out;
            id_ex_lext_op <= ctrl_lext_op_out;
            id_ex_alu_op <= ctrl_alu_op_out;
            id_ex_wb_op <= ctrl_wb_op_out;
            id_ex_alua_sel <= ctrl_alua_sel_out;
            id_ex_alub_sel <= ctrl_alub_sel_out;
            id_ex_ram_we <= ctrl_ram_we_out;
            id_ex_pc <= if_id_pc;
            id_ex_pc4 <= if_id_pc4;
            id_ex_inst <= if_id_inst;
            id_ex_rD1 <= rD1;
            id_ex_rD2 <= rD2;
            id_ex_ext <= ext;
            id_ex_rR1 <= rR1;
            id_ex_rR2 <= rR2;
            id_ex_wR  <= wR_out;
        end
    end

    // Instantiate execute module
    execute EX (
        .rf_rD1(id_ex_rD1),
        .pc(id_ex_pc),
        .rf_rD2(id_ex_rD2),
        .ext(id_ex_ext),
        .alua_sel(id_ex_alua_sel),
        .alub_sel(id_ex_alub_sel),
        .alu_op(id_ex_alu_op),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .mem_wD(loadData2reg),
        .wb_wD(wb_wD),
        .alu_c(alu_c),
        .alu_f(alu_f),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2)
    );

    // EX/MEM pipeline register logic
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst | jump_en) begin
            ex_mem_npc_op <= 3'b0;
            ex_mem_rf_wsel <= 2'b0;
            ex_mem_rf_we <= 1'b0;
            ex_mem_rf_wrsel <= 1'b0;
            ex_mem_lext_op <= 3'b0;
            ex_mem_wb_op <= 2'b0;
            ex_mem_ram_we <= 1'b0;
            ex_mem_pc4 <= 32'b0;
            ex_mem_pc <= 32'b0;
            ex_mem_inst <= 32'b0;
            ex_mem_alu_c <= 32'b0;
            ex_mem_alu_f <= 32'b0;
            ex_mem_ext <= 32'b0;
            ex_mem_rD2 <= 32'b0;
            ex_mem_rR1 <= 5'b0;
            ex_mem_rR2 <= 5'b0;
            ex_mem_wR  <= 5'b0;
        end else begin
            ex_mem_npc_op <= id_ex_npc_op;
            ex_mem_rf_wsel <= id_ex_rf_wsel;
            ex_mem_rf_we <= id_ex_rf_we;
            ex_mem_rf_wrsel <= id_ex_rf_wrsel;
            ex_mem_lext_op <= id_ex_lext_op;
            ex_mem_wb_op <= id_ex_wb_op;
            ex_mem_ram_we <= id_ex_ram_we;
            ex_mem_pc <= id_ex_pc;
            ex_mem_pc4 <= id_ex_pc4;
            ex_mem_inst <= id_ex_inst;
            ex_mem_alu_c <= alu_c;
            ex_mem_alu_f <= alu_f;
            ex_mem_ext <= id_ex_ext;
            ex_mem_rD2 <= alu_src2;
            ex_mem_rR1 <= id_ex_rR1;
            ex_mem_rR2 <= id_ex_rR1;
            ex_mem_wR  <= id_ex_wR;
        end
    end

    memory MEM (
        .wb_op(ex_mem_wb_op),
        .lext_op(ex_mem_lext_op),
        .rf_wsel(ex_mem_rf_wsel),
        .word_sel(Bus_addr[1:0]),
        .aluc(ex_mem_alu_c),
        .pc4(ex_mem_pc4),
        .ext(ex_mem_ext),
        .word_data(Bus_rdata),
        .write_data(ex_mem_rD2),
        .write_dram(Bus_wdata),
        .write_reg(loadData2reg)
    );

    // MEM/WB pipeline register logic
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst | jump_en) begin
            mem_wb_npc_op <= 3'b0;
            mem_wb_rf_wsel <= 2'b0;
            mem_wb_rf_we <= 1'b0;
            mem_wb_rf_wrsel <= 1'b0;
            mem_wb_pc <= 32'b0;
            mem_wb_pc4 <= 32'b0;
            mem_wb_inst <= 32'b0;
            mem_wb_ext <= 32'b0;
            mem_wb_alu_c <= 32'b0;
            mem_wb_alu_f <= 32'b0;
            mem_wb_loadData2reg <= 32'b0;
            mem_wb_rR1 <= 5'b0;
            mem_wb_rR2 <= 5'b0;
            mem_wb_wR  <= 5'b0;
        end else begin
            mem_wb_npc_op <= ex_mem_npc_op;
            mem_wb_rf_wsel <= ex_mem_rf_wsel;
            mem_wb_rf_we <= ex_mem_rf_we;
            mem_wb_rf_wrsel <= ex_mem_rf_wrsel;
            mem_wb_pc <= ex_mem_pc;
            mem_wb_pc4 <= ex_mem_pc4;
            mem_wb_inst <= ex_mem_inst;
            mem_wb_alu_c <= ex_mem_alu_c;
            mem_wb_alu_f <= ex_mem_alu_f;
            mem_wb_ext <= ex_mem_ext;
            mem_wb_loadData2reg <= loadData2reg;
            mem_wb_rR1 <= ex_mem_rR1;
            mem_wb_rR2 <= ex_mem_rR2;
            mem_wb_wR  <= ex_mem_wR;
        end
    end

    writeback WB (
        .inst(mem_wb_inst),
        .aluc(mem_wb_alu_c),
        .pc4(mem_wb_pc4),
        .drdo(mem_wb_loadData2reg),
        .ext(mem_wb_ext),
        .rf_wrsel(mem_wb_rf_wrsel),
        .rf_wsel(mem_wb_rf_wsel),
        .wR(wb_wR),
        .wD(wb_wD)
    );

    // Forwarding unit instantiation
    forwarding_unit FU (
        .id_ex_rs1(id_ex_rR1),  // Source register 1
        .id_ex_rs2(id_ex_rR2),  // Source register 2
        .ex_mem_rd(ex_mem_wR),  // Destination register in EX/MEM stage
        .ex_mem_regwrite(ex_mem_rf_we), // RegWrite signal in EX/MEM stage
        .mem_wb_rd(mem_wb_wR),  // Destination register in MEM/WB stage
        .mem_wb_regwrite(mem_wb_rf_we), // RegWrite signal in MEM/WB stage
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    assign Bus_addr = ex_mem_alu_c;
    assign Bus_we = ex_mem_ram_we;

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = |mem_wb_inst;
    assign debug_wb_pc        = mem_wb_pc[17:0];
    assign debug_wb_ena       = mem_wb_rf_we;
    assign debug_wb_reg       = wb_wR;
    assign debug_wb_value     = wb_wD;
`endif

endmodule
