`timescale 1ns / 10ps

module sram_image #(
    PIXEL_DEPTH = 8,
    X_MAX = 5,
    Y_MAX = 5
) (
    input logic ramclk, 
    input logic [$clog2(X_MAX) - 1:0] x_addr,
    input logic [$clog2(Y_MAX) - 1:0] y_addr,
    input logic wen, ren,
    input logic [PIXEL_DEPTH-1:0] wdat,
    output logic [PIXEL_DEPTH-1:0] rdat
);

    localparam ADDR_WIDTH = $clog2(X_MAX * Y_MAX);
    localparam WORD_WIDTH = 32;                                   // SRAM word size
    localparam IMG_PX_PER_LINE = WORD_WIDTH / PIXEL_DEPTH;        // Pixels per 32 bit word

    logic [$clog2(X_MAX) - 1:0] x_max_eff;
    assign x_max_eff = X_MAX - 1;
    logic [$clog2(Y_MAX) - 1:0] y_max_eff;
    assign y_max_eff = Y_MAX - 1;

    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////
    // Map 1D SRAM as 2D SRAM
    logic [$clog2(X_MAX) * $clog2(Y_MAX) - 1:0] corr_addr;
    assign corr_addr = x_addr + (y_addr * X_MAX);
    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////

    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////
    // If addr out of bounds, ret 0 - else sram_rdat
    logic [PIXEL_DEPTH-1:0] sram_rdat;
    assign rdat = ((x_addr > (x_max_eff)) || (y_addr > (y_max_eff))) ? '0 : sram_rdat;

    
    sram_model #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(PIXEL_DEPTH), .RAM_IS_SYNCHRONOUS(1)) IMAGE_DUT (
        .ramclk(ramclk), .addr(corr_addr), .wen(wen), .ren(ren), 
        .wdat(wdat), 
        .rdat(sram_rdat)
    );
    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////    ////

    ////    ////    ////    ////    ////    ////    ////    ////    ////    //// 
    // Inside sram_image
    function automatic void load_img(input string fname,
                                    input int xdim,
                                    input int ydim);
        automatic bit [PIXEL_DEPTH-1:0] temp_img []; 
        automatic int total_pixels;
        automatic int px_idx;
        automatic int image_idx;
        
        total_pixels = xdim * ydim;

        temp_img = new[total_pixels];

        $readmemh(fname, temp_img);

        // 2) Clear entire underlying SRAM
        for (int i = 0; i < (1 << ADDR_WIDTH); i++) begin
            IMAGE_DUT.ram[i] = '0;
        end

        for (int y = 0; y < ydim; y++) begin
            for (int x = 0; x < xdim; x++) begin
                px_idx = x + (y * X_MAX); 
                image_idx = x + (y * xdim);
                if (px_idx < total_pixels)
                    IMAGE_DUT.ram[px_idx] = temp_img[image_idx];
            end
        end
    endfunction

endmodule
