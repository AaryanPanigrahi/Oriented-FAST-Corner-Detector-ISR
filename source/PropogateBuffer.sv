`timescale 1ns / 10ps

module PropogateBuffer #(
    parameter [3:0] SIZE = 4'd3
) (
    input logic clk, n_rst,
    input logic [SIZE:0][SIZE:0][7:0] input_buffer,
    input logic done, // indicates when to propogate again
    input logic [1:0] next_dir, // 00 = right, 01 = left, 10 = down  
    output logic [SIZE-1:0][SIZE-1:0][7:0] input_matrix
    output logic ready; // Ready signal to begin kernel comp
);
logic [SIZE-1:0][SIZE-1:0][7:0] next_matrix;
logic next_ready;

always_ff @(posedge clk, negedge n_rst) begin
    if (~n_rst) begin
        input_matrix <= '0;
        ready <= 0;
    end
    else begin
        input_matrix <= next_matrix;
        ready <= next_ready;
    end
end

always_comb begin : Shift_Logic
    next_matrix = input_matrix;
    next_ready = 0;
    if (done) begin
        if (next_dir == 2'b00) begin : Shift_Right
            next_matrix = input_buffer[SIZE:1][SIZE-1:0][15:0];
            next_ready = 1;
        end
        else if (next_dir == 2'b01) begin : Shift_Left
            next_matrix = input_buffer[SIZE-1:0][SIZE-1:0][15:0];
            next_ready = 1;
        end
        else if (next_dir == 2'b10) begin : Shift_Down
            next_matrix = input_buffer[SIZE-1:0][SIZE:1][15:0];
            next_ready = 1;
        end
        else begin
            next_matrix = input_matrix;
            next_ready = 0;
        end
    end
end

endmodule

