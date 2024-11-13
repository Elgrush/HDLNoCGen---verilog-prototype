`timescale 1ns/1ns
`include "router.sv"

module tb_router;

    reg clk = 0;

    reg[0:`PL-1] data_in[0:`REN-1];
    wire[0:`PL-1] data_out[0:`REN-1];

    reg availability_signals[0:`REN-1];
    wire availability_signals_out[0:`REN-1];

    reg[`CS-1:0] router_X = 1;
    reg[`CS-1:0] router_Y = 1;

    wire data_output_flags[0:`REN-1];

    reg[`RMS-1:0] dv;

    assign data_output_flags[0] = data_out[0][0];
    assign data_output_flags[1] = data_out[1][0];
    assign data_output_flags[2] = data_out[2][0];
    assign data_output_flags[3] = data_out[3][0];
    assign data_output_flags[4] = data_out[4][0];

    localparam CLK_PERIOD = 20;
    always #(CLK_PERIOD/2) clk=~clk;

    router router(
        .clk(clk),
        .inputs(data_in),
        .outputs(data_out),
        .availability_signals_in(availability_signals),
        .router_X(router_X),
        .router_Y(router_Y),
        .availability_signals_out(availability_signals_out)
        );

    initial begin
        for (dv = 0; dv<`REN; dv = dv + 1) begin
            availability_signals[dv] <= 1;
        end
    end

    initial begin
        $dumpfile("tb_router.vcd");
        $dumpvars;

        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            $dumpvars(0, router.XY.outputs[dv]);
            $dumpvars(0, router.XY.shift_signals[dv]);
            $dumpvars(0, router.XY.availability_signals_in[dv]);
        end

        $dumpvars(0, router.XY.from_arbiter);

        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            data_in[dv] <= {1'b1, dv, 3'b000};
        end
        #20
        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            data_in[dv] <= {1'b1, dv+3'b101, 3'b001};
        end
        #20
        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            data_in[dv] <= {1'b1, dv+3'b100, 3'b010};
        end
        #20
        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            data_in[dv] <= {1'b1, dv+3'b010, 3'b011};
        end
        #20
        for (dv = 0; dv < `REN; dv = dv + 1)
        begin
            data_in[dv] <= 0;
        end
        #1000
        data_in[0] <= {1'b1, 4'b1010, 3'b100};
        #20
        data_in[0] <= 0;
        #300
        data_in[0] <= {1'b1, 4'b1010, 3'b101};
        #300
        $finish;
    end

    initial begin
        #250
        if ( router.queues_initialiser[4].queue_i.data_out == 8'hC9) begin
            $error("Queue failed to delete the package.");
        end
    end

    wire[0:7] output_checker;
    assign output_checker = router.XY.outputs[0] | router.XY.outputs[1] | router.XY.outputs[2] | router.XY.outputs[3] | router.XY.outputs[4];

    reg passed = 1;

    initial begin
        #55
        if ( output_checker != 8'h90) begin
            $error("Package failed to apear. ", output_checker, " != " , 8'h90);
            passed = 0;
        end
        #20
        if ( output_checker != 8'h00) begin
            $error("Package failed to apear. ", output_checker, " != " , 8'h00);
            passed = 0;
        end
        #20
        if ( output_checker != 8'hA0) begin
            $error("Package failed to apear. ", output_checker, " != " , 8'hA0);
            passed = 0;
        end
        #60
        if ( output_checker != 8'hB9) begin
            $error("Package failed to apear. ", output_checker, " != " , 8'hB9);
            passed = 0;
        end

        if(passed) begin
            $display("Test complete");
        end

    end

endmodule
