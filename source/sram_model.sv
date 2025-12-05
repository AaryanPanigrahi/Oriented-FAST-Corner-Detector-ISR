/*
name: sram_tb_model
Description: 
- Single port ram model for TB
- No implementation of multi-cycle access
- Seperate wires for input and ouput
- By default synchronous
- Dead simple, no timing, no banks :(

Author: Spencer Bowles
Adapted: Aaryan Panigrahi
Date: 11/18/2025
*/

`timescale 1ns / 10ps

module sram_model #(
    parameter ADDR_WIDTH = 18,
    parameter DATA_WIDTH = 32,
    parameter RAM_IS_SYNCHRONOUS = 1
)(
    input logic ramclk,                     // Acts as en/dis (if async) - no reset
    input logic [ADDR_WIDTH-1:0] addr,
    input logic wen, ren,
    input logic [DATA_WIDTH-1:0] wdat,
    output logic [DATA_WIDTH-1:0] rdat
);

bit [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH]; 

////    ////    ////    ////    ////    ////    ////    ////    ////    //// 
// WRITE
always_ff @(posedge ramclk) begin : WRITE
    if (wen) ram[addr] <= wdat;
end

// READ
generate
    if (RAM_IS_SYNCHRONOUS) begin : READ_SYNC
        always_ff @(posedge ramclk) begin : READ_SYNC_FF
            rdat <= (ren) ? ram[addr] : 'x;
        end
    end
    else begin : READ_ASYNC
        assign rdat = (ren) ? ram[addr] : 'x;
    end
endgenerate
////    ////    ////    ////    ////    ////    ////    ////    ////    ////   

////    ////    ////    ////    ////    ////    ////    ////    ////    ////    
// Helper Funtions
function rmh(input string fname);
    $readmemh(fname, ram);    
endfunction
////    ////    ////    ////    ////    ////    ////    ////    ////    ////    

endmodule
