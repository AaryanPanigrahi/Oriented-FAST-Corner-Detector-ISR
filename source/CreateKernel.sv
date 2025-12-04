`timescale 1ns / 10ps

module CreateKernel #(
    parameter [3:0] SIZE = 4'd3
) (
    input logic clk, n_rst,
    input logic [2:0] sigma,
    input logic start,
    output logic [SIZE-1:0][SIZE-1:0][7:0] kernel,
    output logic err
);
logic ready;      // Ready signal for moving through rows/columns
logic end_row;    // Clear signal move column
logic end_column; // Signal for end of kernel operations
logic [3:0] cur_x, cur_y;
logic [SIZE-1:0][SIZE-1:0][7:0] nextKernel; 
logic [3:0] width;
logic [3:0] tempErr;
logic [3:0] distance;
assign width = (SIZE-1)/2;
assign tempErr = ((SIZE-1)%2);
assign err = tempErr[0];

flex_counter #(.SIZE(4)) rows (
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(ready),
    .rollover_val(SIZE),
    .clear(end_row),
    .rollover_flag(end_row),
    .count_out(cur_x));

flex_counter #(.SIZE(4)) columns (
    .clk(clk),
    .n_rst(n_rst),
    .count_enable(end_row),
    .rollover_val(SIZE),
    .clear(end_row),
    .rollover_flag(end_column),
    .count_out(cur_y));

always_ff @(posedge clk, negedge n_rst) begin
    if (~n_rst) kernel <= '0;
    else kernel <= nextKernel;
end
 
always_comb begin
    
end

// datapath kernel_datapath (
//     .clk(clk),
//     .n_reset(n_rst),
//     .op(op),
//     .src1(src1),
//     .src2(src2),
//     .dest(dest),
//     .ext_data1({8'b0, pixel_v}),
//     .ext_data2({8'b0, kernel_v}),
//     .outreg_data(tempSum),
//     .overflow());

endmodule

