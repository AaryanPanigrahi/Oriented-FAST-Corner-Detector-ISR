`timescale 1ns / 10ps

module FlexCounter #(
    parameter SIZE = 4 // Number of bits available to store the count
) (
    input logic clk, // Maximum operating frequency = 100 MHz
    input logic n_rst, // asynchronous, active-low system reset
    input logic clear, // synchronous, active-high sinal to clear count value back to 0
    input logic count_enable, // active-high enable signal to allow the counter to increment
    input logic [SIZE-1:0] rollover_val, // Determines when to roll over
    output logic [SIZE-1:0] count_out, // The current count value stored in the counter
    output logic rollover_flag // active-high flag, asserted when the counter is at the rollover value
);
    const logic [SIZE-2:0] zeros = '0;
    // always_comb begin 
    //     if (count_out >= rollover_val) rollover_flag = 1'b1;
    //     else rollover_flag = 1'b0;
    // end

    always_ff @(posedge clk, negedge n_rst) begin
        if (~n_rst) begin 
            count_out <= '0; // Async counter reset
            rollover_flag <= 1'b0; // Async flag reset
        end
        else if (clear) begin
            count_out <= '0; // Synchronous clear
            rollover_flag <= 1'b0; end
        else if (count_enable) begin
            if ((count_out + 1'b1) == rollover_val) begin 
                rollover_flag <= 1'b1;  
                count_out <= count_out + 1'b1; // Counter increment
            end
            else if (count_out >= rollover_val) begin
                count_out <= '0; // Rollover state
                //rollover_flag <= 1'b1;
                rollover_flag <= 1'b0;
            end 
            else begin 
                rollover_flag <= 1'b0;
                count_out <= count_out + 1'b1; // Counter increment
            end
        end
    end
endmodule

