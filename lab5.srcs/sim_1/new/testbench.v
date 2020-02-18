`timescale 1ns / 1ps

module testbench();
    reg clk;
    wire wwreg;
    wire wm2reg;
    wire[4:0]rna;
    wire[4:0]rnb;
    wire[4:0]wn;
    wire[31:0]d;
    initial begin
        clk = 0;
    end
    always #5 clk =~clk;
    lab5 final(clk, wwreg, wm2reg,rna, rnb, wn, d);
endmodule
