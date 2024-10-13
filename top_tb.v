`timescale 1ns/1ps
module top_tb;
    reg     clk         ;
    reg     rst_n       ;
    wire    led         ;      
    wire    scl         ;
    wire    sda         ;
    
    
    e2prom_top e2prom_top1(
    clk     ,
    rst_n   ,
    led     ,      
    scl     ,
    sda    
);
/*--------------------clk-------------------*/
 initial begin
     clk = 0;
 end
 always #10 clk = ~clk;
/*-------------------rst_n--------------------*/
 initial begin
     rst_n = 1'b0;
     #201 rst_n = 1'b1;
     #256_000;
     $stop;
 end
endmodule