`timescale 1ns / 10ps

module KernelAccumulator #(
    parameter [3:0] SIZE = 4'd3
)(
    input logic clk, n_rst,
    input logic [SIZE-1:0][SIZE-1:0][7:0] in, kernel,
    input logic en_strobe, 
    input logic [3:0] cur_x, cur_y,
    input logic clear, start,
    output logic ready,
    output logic [7:0] sum
);
logic [7:0] kernel_v, pixel_v;
logic [2:0] op;
logic [3:0] src1, src2, dest;
logic [16:0] tempSum;
assign sum = tempSum[15:8]; // Takes the 8 LSBs of the sum
// This is done to account for the mulitplication by decimal
// Stores the value stored at the kernel/pixel indexed

MatrixIndex #(.SIZE(SIZE)) get_index (
    .clk(clk),
    .n_rst(n_rst),
    .cur_x(cur_x),
    .cur_y(cur_y),
    .kernel(kernel),
    .in(in),
    .en_strobe(en_strobe),
    .kernel_v(kernel_v),
    .pixel_v(pixel_v));

AccumulatorControl controller (
    .clk(clk),
    .n_rst(n_rst),
    .clear(clear),
    .start(start),
    .op(op),
    .src1(src1),
    .src2(src2),
    .dest(dest),
    .ready(ready)
    .product(product));

datapath accumulator_datapath (
    .clk(clk),
    .n_reset(n_rst),
    .op(op),
    .src1(src1),
    .src2(src2),
    .dest(dest),
    .ext_data1({8'b0, pixel_v}),
    .ext_data2({8'b0, kernel_v}),
    .outreg_data(tempSum),
    .overflow());

endmodule
