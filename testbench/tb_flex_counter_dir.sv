`timescale 1ns/10ps

module tb_flex_counter_dir;

    localparam SIZE = 4;

    // DUT signals
    logic                 clk;
    logic                 n_rst;
    logic                 clear;
    logic                 count_enable;
    logic [SIZE-1:0]      wrap_val;
    logic [1:0]           mode;
    logic [SIZE-1:0]      count_out;
    logic                 rollover_flag;
    logic                 wrap_flag;

    // Instantiate DUT
    flex_counter_dir #(
        .SIZE(SIZE)
    ) dut (
        .clk           (clk),
        .n_rst         (n_rst),
        .clear         (clear),
        .count_enable  (count_enable),
        .wrap_val      (wrap_val),
        .mode          (mode),
        .count_out     (count_out),
        .rollover_flag (rollover_flag),
        .wrap_flag     (wrap_flag)
    );


    typedef enum bit [1:0] { 
        COUNT_UP, COUNT_DOWN, UP_DOWN, HOLD
    } mode_t;

    mode_t MODE_TYPE = HOLD;

    always @(negedge clk) begin
        case (mode)
            0:     MODE_TYPE = COUNT_UP;
            1:     MODE_TYPE = COUNT_DOWN;
            2:     MODE_TYPE = UP_DOWN;
            default: MODE_TYPE = HOLD;
        endcase 
    end

    // Clk Gen
    initial clk = 0;
    always #5 clk = ~clk;

    // Utility
    task wait_time(
        input int wait_t
        );
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

    task wait_sample;
    begin
        repeat(25) @(negedge clk);
    end
    endtask

    // Reset Module
    task reset_dut;
        begin
            n_rst = 1;
            @(negedge clk);
            n_rst = 0;
            @(negedge clk);

            n_rst = 1;
        end
    endtask

    // Init
    task init;
        begin
            clear           = 0;
            count_enable    = 0;
            wrap_val        = 0;
            mode            = 0;

            reset_dut();
        end
    endtask

    initial begin
        init;

        wait_ten;

        // Mode 0
        mode = 0;

        // Count Up test
        clear = 1;
        count_enable = 0;
        wait_time(1);
        clear = 0;

        wrap_val = 7;
        count_enable = 1;

        wait_time(8);

        // Mode 0
        mode = 1;

        // Count Down Test
        clear = 1;
        count_enable = 0;
        wait_time(1);
        clear = 0;

        wrap_val = 7;
        count_enable = 1;

        wait_time(8);

        // Mode 0
        mode = 2;

        // Count Up-Down Test
        clear = 1;
        count_enable = 0;
        wait_time(1);
        clear = 0;

        wrap_val = 7;
        count_enable = 1;

        wait_time(7 + 7 + 1);

        // End
        wait_fifty;
        $finish;
    end
endmodule
