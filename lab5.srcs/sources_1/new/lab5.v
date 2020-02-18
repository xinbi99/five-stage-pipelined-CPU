`timescale 1ns / 1ps

module lab5(clk, wwreg, wm2reg,rs, rt, wn, d);
    input clk;
    wire mwreg;
    wire mm2reg;
    wire[4:0]three;
    wire[31:0]mr;
    wire[31:0]do;
    output wire wwreg;
    output wire wm2reg;
    wire[31:0]wr;
    wire[31:0]wdo;
    output wire[4:0]rs;
    output wire[4:0]rt;
    output wire[4:0]wn;
    output wire[31:0]d;
    
    reg[31:0] pc;
    wire[31:0] inst_do;
    wire[5:0] op;
    wire[5:0] func;
    wire[4:0] rd;
    wire[15:0] imm;
    wire wreg;
    wire m2reg;
    wire wmem;
    wire[3:0]aluc;
    wire aluimm;
    wire regrt;
    wire[4:0]five;
    wire[31:0]qa;
    wire[31:0]qb;
    wire[31:0]extended;
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire[3:0]ealuc;
    wire ealuimm;
    wire [4:0]four;
    wire[31:0]eqa;
    wire[31:0]eqb;
    wire[31:0]eextended;
    wire[31:0]b;
    wire [31:0]r;
    wire mwmem;
    wire [31:0]di;
    initial begin
        pc = 100;
    end
    always @(posedge clk) begin
        pc <= pc + 32'd4;
    end
    instruction_memory instmem(pc, inst_do, clk);
    ifid ifid1(clk, inst_do, op, func, rd, rt, rs, imm);
    control_unit ctrl(op, func, wreg, m2reg, wmem, aluc, aluimm, regrt);
    multiplexer_short mux1(rd, rt, regrt, five);
    regfile reg1(clk, wwreg, rs, rt, wn, d, qa, qb);
    sign_extension extention(imm, extended);
    idexe idexe1(clk, wreg,m2reg,wmem, aluc, aluimm, five, qa, qb, extended, ewreg, em2reg, ewmem, ealuc, ealuimm, four, eqa, eqb, eextended);
    multiplexer_long mux2(eqb, eextended, ealuimm, b);
    ALU alu1(eqa, b, ealuc, r);
    exemem exemem1(clk, ewreg, em2reg, ewmem, four, r, eqb, mwreg, mm2reg, mwmem, three, mr, di);
    data_memory dm1(mwmem, mr, di, do);
    memwb memwb1(clk, mwreg, mm2reg, three, mr, do, wwreg, wm2reg, wn, wr, wdo);
    wmux mux3(wr, wdo , wm2reg, d);
endmodule



module instruction_memory(a, do, clk);
    input [31:0]a;
    input clk;
    output reg[31:0]do;
    reg[7:0] memory[0:255];
    initial begin
        memory[100] = 8'b10001100;
        memory[101] = 8'b00100010;
        memory[102] = 8'b00000000;
        memory[103] = 8'b00000000;
        
        memory[104] = 8'b10001100;
        memory[105] = 8'b00100011;
        memory[106] = 8'b00000000;
        memory[107] = 8'b00000100;
        
        memory[108] = 8'b10001100;
        memory[109] = 8'b00100100;
        memory[110] = 8'b00000000;
        memory[111] = 8'b00001000;
        
        memory[112] = 8'b10001100;
        memory[113] = 8'b00100101;
        memory[114] = 8'b00000000;
        memory[115] = 8'b00001100;
        
        memory[116] = 8'b00000000;
        memory[117] = 8'b01001010;
        memory[118] = 8'b00110000;
        memory[119] = 8'b00100000; 
    end
    always @(posedge clk) begin
        do = {memory[a], memory[a+1], memory[a+2], memory[a+3]};
    end
endmodule

module ifid(clk, do, op, func, rd, rt, rs, imm);
    input clk;
    input [31:0]do;
    output reg[5:0]op;
    output reg[5:0] func;
    output reg[4:0]rd;
    output reg[4:0]rt;
    output reg[4:0]rs;
    output reg[15:0]imm;
    always @(posedge clk) begin
        op <= do[31:26];
        rs <= do[25:21];
        rt <= do[20:16];
        rd <= do[15:11];
        imm <= do[15:0];
        func <= do[5:0];
    end
endmodule

module multiplexer_short(x, y, decide, z);
    input[4:0]x;
    input[4:0]y;
    input decide;
    output reg[4:0]z;
    always @(*)
        if (decide == 1'b0)
            z <= x;
        else
            z <= y;
endmodule

module sign_extension(in, extended);
    input[15:0] in;
    output reg [31:0] extended;
    always@(in) begin
        extended[31:0] <= { {16{in[15]}}, in[15:0] };
    end
endmodule

module control_unit(op, func, wreg, m2reg, wmem, aluc, aluimm, regrt);
    input [5:0] op;
    input [5:0] func;
    output reg wreg;
    output reg m2reg;
    output reg wmem;
    output reg[3:0] aluc;
    output reg aluimm;
    output reg regrt;
    always@(*) 
        case(op)
        6'b000000: begin
            wreg <= 1'b1;
            m2reg <= 1'b0;
            wmem <= 1'b0;
            aluc <= 4'b0010;
            aluimm <= 1'b0;
            regrt <= 1'b0;
        end
        6'b100011: begin
            wreg <= 1'b1;
            m2reg <= 1'b1;
            wmem <= 1'b0;
            aluc <= 4'b0010;
            aluimm <= 1'b1;
            regrt <= 1'b1;
        end
    endcase    
endmodule

module regfile(clk, we, rna, rnb, wn, d, qa, qb);
    input clk;
    input we;
    input [4:0]rna;
    input [4:0]rnb;
    input [4:0] wn;
    input [31:0]d;
    output reg[31:0]qa;
    output reg[31:0]qb;
    reg [31:0] registers [31:0];
    initial begin
        registers[0] <= 32'd0;
        registers[1] <= 32'd0;
        registers[2] <= 32'h10000011;
        registers[3] <= 32'h20000022;
        registers[4] <= 32'h30000033;
        registers[5] <= 32'h40000044;
        registers[6] <= 32'h50000055;
        registers[7] <= 32'h60000066;
        registers[8] <= 32'h70000077;
        registers[9] <= 32'h80000088;
        registers[10] <= 32'h90000099;
    end
    always @(*) begin
        if (we == 1) begin
            registers[wn] = d;
        end
        qa = registers[rna];
        qb = registers[rnb];
    end
endmodule

module idexe(clk, wreg,m2reg,wmem,aluc, aluimm, four, qa, qb, extend, ewreg, em2reg, ewmem, ealuc, ealuimm, ethree, eqa, eqb, eextend);
    input clk;
    input wreg;
    input m2reg;
    input wmem;
    input [3:0] aluc;
    input aluimm;
    input [4:0]four;
    input [31:0]qa;
    input [31:0]qb;
    input [31:0]extend;
    output reg ewreg;
    output reg em2reg;
    output reg ewmem;
    output reg[3:0]ealuc;
    output reg ealuimm;
    output reg[4:0]ethree;
    output reg[31:0] eqa;
    output reg[31:0] eqb;
    output reg[31:0] eextend;
    always @(posedge clk) begin
        ewreg <= wreg;
        em2reg <= m2reg;
        ewmem <= wmem;
        ealuc <= aluc;
        ealuimm <= aluimm;
        ethree <= four;
        eqa <= qa;
        eqb <= qb;
        eextend <= extend;
    end 
endmodule

module multiplexer_long(x, y, decide, z);
    input[31:0]x;
    input[31:0]y;
    input decide;
    output reg[31:0]z;
    always @(*)
        if (decide == 1'b0)
            z <= x;
        else
            z <= y;
endmodule

module ALU(a, b, aluc, r);
    input [31:0]a;
    input [31:0]b;
    input [3:0]aluc;
    output reg[31:0]r;
    always@(*) begin
        case(aluc)
            0: r <= b&a;
            1: r <= b|a;
            2: r <= b+a; 
            6: r <= a-b;
            7: r <= a < b ? 1:0;
            12: r <= ~(a|b);
            15: r <= a^b;
        endcase  
    end
endmodule

module exemem(clk, ewreg, em2reg, ewmem, ethree, r, eqb, mwreg, mm2reg, mwmem, mtwo, mr, di);
    input clk;
    input ewreg;
    input em2reg;
    input ewmem;
    input [4:0] ethree;
    input [31:0] r;
    input [31:0] eqb;
    output reg mwreg;
    output reg mm2reg;
    output reg mwmem;
    output reg[4:0]mtwo;
    output reg[31:0]mr;
    output reg[31:0]di;
    always @(posedge clk) begin
        mwreg <= ewreg;
        mm2reg <= em2reg;
        mwmem <= ewmem;
        mtwo <= ethree;
        mr <= r;
        di <= eqb;        
    end
endmodule

module data_memory(we, a, di, do);
    input we;
    input [31:0] a;
    input [31:0] di;
    output reg[31:0] do;
    reg[7:0]datamem[255:0];
    initial begin
        datamem[0] = 'hA00000AA;
        datamem[4] = 'h10000011;
        datamem[8] = 'h20000022;    
        datamem[12] = 'h30000033;
        datamem[16] = 'h40000044;
        datamem[20] = 'h50000055;
        datamem[24] = 'h60000066;
        datamem[28] = 'h70000077;
        datamem[32] = 'h80000088;
        datamem[36] = 'h90000099;
    end
    always @(*) begin
        if(we == 0)begin
            do = datamem[a];
        end
        if(we == 1)begin
            datamem[di] = datamem[a];
        end
    end
endmodule

module memwb(clk, mwreg, mm2reg, mtwo, mr, do, wwreg, wm2reg, wone, wr, wdo);
    input clk;
    input mwreg;
    input mm2reg;
    input [4:0]mtwo;
    input [31:0]mr;
    input [31:0]do;
    output reg wwreg;
    output reg wm2reg;
    output reg[4:0]wone;
    output reg[31:0]wr;
    output reg[31:0]wdo;
    always @(posedge clk) begin
        wwreg <= mwreg;
        wm2reg <= mm2reg;
        wone <= mtwo;
        wr <= mr;
        wdo <= do;
    end
endmodule

module wmux(x, y , decide, z);
    input[31:0]x;
    input[31:0]y;
    input decide;
    output reg[31:0]z;
    always @(*)
        if (decide == 1'b0)
            z <= x;
        else
            z <= y;
endmodule