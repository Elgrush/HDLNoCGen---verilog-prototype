`timescale 1ns/1ns
`include "algorithm.sv"
`include "router.svh"
`define CS 2 // size of single coordinate part
`define RMS 4 // router marker size

module tb_algorithm;

    reg clk = 0;
    reg[0:`PL-1] from_arbiter;
    wire[`CS-1:0] router_X = 1;
    wire[`CS-1:0] router_Y = 1;
    reg[0:`REN-1] written_signals = 0;
    wire[0:`PL-1] outputs[0:`REN-1];
    wire send_data_flag;

    wire availability_signals_array[0:`REN-1];

    assign availability_signals_array[0] = written_signals[0];
    assign availability_signals_array[1] = written_signals[1];
    assign availability_signals_array[2] = written_signals[2];
    assign availability_signals_array[3] = written_signals[3];
    assign availability_signals_array[4] = written_signals[4];

    reg[`CS-1:0] i;
    reg[`CS-1:0] j;

    reg[`RMS-1:0] dv;

    algorithm XY
    (
        .clk(clk),
        .from_arbiter(from_arbiter),
        .router_X(router_X),
        .router_Y(router_Y),
        .availability_signals_in(availability_signals_array),
        .outputs(outputs)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk=~clk;

    initial
    begin
        $dumpfile("tb_algorithm.vcd");
        $dumpvars;

        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            $dumpvars(0, outputs[dv]);
        end

        from_arbiter = 0;
        written_signals = `REN'b11111;
        for (i = 0; i < 3; i = i + 1)
        begin
            for (j = 0; j < 3; j = j + 1)
            begin
                from_arbiter = {1'b1, i, j, 3'b101};
                #10;
            end
        end
        $finish;
    end

endmodule