`timescale 1ns/1ps

module tb_sram_model;

    localparam ADDR_WIDTH = 8;
    localparam DATA_WIDTH = 32;

    // Signals
    logic                   clk;
    logic [ADDR_WIDTH-1:0]  addr;
    logic [DATA_WIDTH-1:0]  wdat;
    logic                   wen, ren;
    logic [DATA_WIDTH-1:0]  rdat;

    // DUT
    sram_model #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .RAM_IS_SYNCHRONOUS(1)
    ) DUT (
        .ramclk (clk),
        .addr   (addr),
        .wdat   (wdat),
        .wen    (wen),
        .ren    (ren),
        .rdat   (rdat)
    );

    // Clk Gen - 100 Mhz
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Simple tasks
    task automatic do_write(input logic [ADDR_WIDTH-1:0] a,
                            input logic [DATA_WIDTH-1:0] d);
        @(posedge clk);
        addr <= a;
        wdat <= d;
        wen  <= 1;
        ren  <= 0;
        @(posedge clk);
        wen  <= 0;
    endtask

    task automatic do_read(input  logic [ADDR_WIDTH-1:0] a,
                           output logic [DATA_WIDTH-1:0] q);
        @(posedge clk);
        addr <= a;
        wen  <= 0;
        ren  <= 1;
        @(posedge clk);            // sync read: data valid after this edge
        q = rdat;
        ren <= 0;
    endtask

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

    // Custom Vars
    logic [DATA_WIDTH-1:0] q;               // Read Var

    task init;
    begin
        // Preload Mem
        DUT.rmh("image/init_mem.hex");

        addr = '0; 
        wdat = '0; 
        wen = 0; 
        ren = 0;

        // Custom
        q = '0;         
    end
    endtask

    // Test sequence
    initial begin
        init();

        // Write Check
        for (int i = 0; i < 16; i++) begin
            do_write(i, i*4);
        end

        // Read Check
        for (int i = 0; i < 16; i++) begin
            do_read(i, q);
        end

        // RAW Checker
        do_write(8'h10, 32'hDEADBEEF);
        do_read (8'h10, q);

        // Image dump       -- Doesn't work, will make work  soon
        //DUT.memdump_img("image/init_mem.hex", 2, 2);  

        // End
        wait_ten;
        $finish;
    end

endmodule
