`timescale 1ns / 10ps

module flex_counter_dir #(
    parameter SIZE = 4
) (
    input  logic                 clk,
    input  logic                 n_rst,
    input  logic                 clear,
    input  logic                 count_enable,  
    input  logic [SIZE-1:0]      wrap_val,
    input  logic [1:0]           mode,           
    output logic [SIZE-1:0]      count_out,
    output logic                 rollover_flag,  
    output logic                 wrap_flag       
);

    typedef enum logic {DIR_UP, DIR_DOWN} dir_e;
    dir_e dir_ff, dir_next;

    logic [SIZE-1:0] count_out_next;
    logic rollover_flag_next, wrap_flag_next;

    // Direction logic and FFs
    always_ff @(posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            count_out     <= '0;
            
            dir_ff        <= DIR_UP;

            rollover_flag <= 1'b0;
            wrap_flag     <= 1'b0;  
        end
        else begin
            count_out     <= count_out_next;

            dir_ff        <= dir_next;

            rollover_flag <= rollover_flag_next;
            wrap_flag     <= wrap_flag_next;
        end
    end

    // NS Logic based on mode
    always_comb begin
        count_out_next = count_out;
        dir_next       = dir_ff;

        if (clear) begin
            count_out_next = '0;
            dir_next       = DIR_UP;
        end else if (count_enable) begin
            unique case (mode)
                // 1 - wrap_val jump 1
                2'b00: begin 
                    if (count_out >= wrap_val)
                        count_out_next = {{(SIZE-1){1'b0}}, 1'b1};
                    else
                        count_out_next = count_out + 1;
                end

                // wrap_val - 1, jump wrap_val
                2'b01: begin 
                    if (count_out <= {{(SIZE-1){1'b0}}, 1'b1})
                        count_out_next = wrap_val;
                    else
                        count_out_next = count_out - 1;
                end

                // 0 - wrap_val - 0
                2'b10: begin 
                    unique case (dir_ff)
                        DIR_UP: begin
                            if (count_out >= wrap_val) begin
                                count_out_next = wrap_val - 1;
                                dir_next       = DIR_DOWN;
                            end else begin
                                count_out_next = count_out + 1;
                            end
                        end
                        DIR_DOWN: begin
                            if (count_out == '0) begin
                                count_out_next = 1;
                                dir_next       = DIR_UP;
                            end else begin
                                count_out_next = count_out - 1;
                            end
                        end
                    endcase
                end

                // 2'b11: hold
                default: begin 
                    count_out_next = count_out;
                end
            endcase
        end
    end

    // Output Flag
    always_comb begin
        wrap_flag_next     = (count_out_next == wrap_val);
        rollover_flag_next = (count_out_next == '0);
    end

endmodule
