`timescale 1ns/1ns
`include "arbiter.sv" 

module tb_arbiter; 

    reg clk;
    reg [0:`PL-1] input_[0:`REN-1];
    reg delete_data_flag;
    
    wire [0:`PL-1] output_data;
    wire [3:0] shift;

    reg[5:0] dv;

    arbiter uut (
        .clk(clk),
        .input_(input_),
        .output_data(output_data),
        .shift(shift)
    );

    
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    reg[3:0] del_shift;


    initial begin
        input_[0] = 8'hFF; // 255
        input_[1] = 8'h00; // 0
        input_[2] = 8'hAA; // 170
        input_[3] = 8'h00; // 0
        input_[4] = 8'h00; // 0

        delete_data_flag = 0;

        #10 if (output_data != 8'hFF)
        begin
            $error("Arbiter failed to output ", output_data, " != " , 8'hFF);
        end
        
        #10
        input_[0] <= 0;

        if (output_data != 8'hAA)
        begin
            $error("Arbiter failed to output ", output_data, " != " , 8'hAA);
        end

        #10
        input_[2] <= 0;
        
        #10 if (output_data == 8'hFF)
        begin
            $error("Phantom package detected ", output_data, " != " , 0);
        end

        #10 input_[0] = 8'h10; // 16
            input_[1] = 8'h20; // 32
            input_[2] = 8'h80; // 128
            input_[3] = 8'h40; // 64
            input_[4] = 8'h50; // 80

        #10 
        if (output_data != 8'h80)
        begin
            $error("Arbiter failed to output ", output_data, " != " , 8'h80);
        end

        #10
        input_[2] <= 0;

        #10
        input_[0] = 8'h00; // 0
        input_[1] = 8'h00; // 0
        input_[2] = 8'h00; // 0
        input_[3] = 8'hFF; // 255
        input_[4] = 8'h00; // 0

        #50 $finish;
    end

    initial begin
        $dumpfile("tb_arbiter.vcd");
        $dumpvars(0, tb_arbiter);
        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            $dumpvars(0, input_[dv]);
        end
    end

endmodule
