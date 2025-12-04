`timescale 1ns / 10ps

module tb_pixel_pos;
    parameter X_MAX = 7;
    parameter Y_MAX = 8;

    logic clk, n_rst;
    logic update_pos, new_trans;
    logic [$clog2(X_MAX) - 1:0] max_x;
    logic [$clog2(Y_MAX) - 1:0] max_y;
    logic end_pos, next_dir;
    logic [$clog2(X_MAX) - 1:0] curr_x;
    logic [$clog2(Y_MAX) - 1:0] curr_y;

    // Instantiate DUT
    pixel_pos #(.X_MAX(X_MAX), .Y_MAX(Y_MAX)) dut (
        .clk(clk),
        .n_rst(n_rst),
        .update_pos(update_pos),
        .new_trans(new_trans),
        .max_x(max_x),
        .max_y(max_y),
        .end_pos(end_pos),
        .next_dir(next_dir),
        .curr_x(curr_x),
        .curr_y(curr_y)
    );

    // Clk Gen
    initial clk = 0;
    always #5 clk = ~clk;

    // Aux
    task wait_time(input int wait_t);
        begin
            repeat(wait_t) @(negedge clk);
        end
    endtask

    task wait_ten;
        begin
            repeat(10) @(negedge clk);
        end
    endtask

    task wait_fifty;
        begin
            repeat(50) @(negedge clk);
        end
    endtask

    task reset_dut;
        begin
            n_rst = 1;
            @(negedge clk);
            n_rst = 0;
            @(negedge clk);
            n_rst = 1;
        end
    endtask

    task init;
        begin
            new_trans   = 0;
            update_pos  = 0;
            max_x       = 0;
            max_y       = 0;
            reset_dut();
        end
    endtask

    // Main test
    initial begin
        init();

        // Test 1
        max_x = 5;
        max_y = 5;
        new_trans = 1;
        update_pos = 1;
        @(negedge clk);
        new_trans = 0;

        wait_time(5 * 5 + 5);
        update_pos = 0;

        wait_ten;

        // Test 2
        max_x = 240;
        max_y = 240;
        new_trans = 1;
        update_pos = 1;
        @(negedge clk);
        new_trans = 0;

        wait_time(240 * 240 + 5);
        update_pos = 0;

        // Finish
        wait_ten;
        $finish();
    end

endmodule
