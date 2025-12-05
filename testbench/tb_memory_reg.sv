`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_memory_reg ();
    logic clk, n_rst;
    localparam CLK_PERIOD = 2.5ns;

    logic load_enable;
    logic [7:0] parallel_in;
    logic [7:0] parallel_out;

    memory_reg #(.SIZE(8), .RESET(2)) DUT (.clk(clk), .n_rst(n_rst),
            .load_enable(load_enable), .parallel_in(parallel_in),
            .parallel_out(parallel_out));

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task reset_dut;
    begin
        n_rst = 0;
        @(negedge clk);
        @(negedge clk);

        n_rst = 1;
        @(negedge clk);
        @(negedge clk);
    end
    endtask

    task init;
    begin
        load_enable = 1'b0;
        parallel_in = 8'd0;

        reset_dut;
    end
    endtask

    task wait_ten;
    begin
        repeat (10) @(negedge clk);
    end
    endtask

    task wait_five;
    begin
        repeat (5) @(negedge clk);
    end
    endtask

    initial begin
        init;
        
        // Test 1
        load_enable = 1;
        parallel_in = 8'b10101010;
        wait_five;
        load_enable = 0;

        // Test 2
        load_enable = 0;
        parallel_in = 8'b01010101;
        wait_five;

        wait_ten;

        $finish;
    end
endmodule

/* verilator coverage_on */

