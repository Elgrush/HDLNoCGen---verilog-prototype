`include "noc.svh"
`include "router.sv"
`timescale 1ns/1ns

module noc;

reg clk = 0;
always #(`CLK_PERIOD/2) clk=~clk;

wire [0:`PL-1] inputs[0:`Y-1][0:`X-1][0:`REN-1];
wire [0:`PL-1] core_inputs[0:`Y-1][0:`X-1];

wire written_signals[0:`Y-1][0:`X-1][0:`REN-1];
wire core_written_signals[0:`Y-1][0:`X-1];

generate
    genvar router_Y_iterator, router_X_iterator;
    for (router_Y_iterator = 0; router_Y_iterator < `Y; router_Y_iterator = router_Y_iterator + 1)
    begin  : routers_Y
        for (router_X_iterator = 0; router_X_iterator < `X; router_X_iterator = router_X_iterator + 1)
        begin  : routers_X
            if (router_Y_iterator == `Y-1) begin
                localparam lower = 0;
            end
            else begin
                localparam lower = router_Y_iterator + 1;
            end

            if (router_X_iterator == `X-1) begin
                localparam right = 0;
            end
            else begin
                localparam right = router_X_iterator + 1;
            end

            if (router_Y_iterator == 0) begin
                localparam upper = `Y-1;
            end
            else begin
                localparam upper = router_Y_iterator - 1;
            end

            if (router_X_iterator == 0) begin
                localparam left = `X-1;
            end
            else begin
                localparam left = router_X_iterator - 1;
            end

            router router(
                .clk(clk),
                .inputs(inputs[router_Y_iterator][router_X_iterator]), .outputs(
                    '{ 
                        core_inputs[router_Y_iterator][router_X_iterator],
                        inputs[upper][router_X_iterator][3],
                        inputs[lower][router_X_iterator][1],
                        inputs[router_Y_iterator][right][4],
                        inputs[router_Y_iterator][left][2]
                    }),
                .purge_signals(written_signals[router_Y_iterator][router_X_iterator]), .written_signals(
                    '{
                        core_written_signals[router_Y_iterator][router_X_iterator],
                        written_signals[upper][router_X_iterator][3],
                        written_signals[lower][router_X_iterator][1],
                        written_signals[router_Y_iterator][right][4],
                        written_signals[router_Y_iterator][left][2]
                    }),
                .router_Y(router_Y_iterator), .router_X(router_X_iterator)
            );
        end
    end
endgenerate

always @(posedge clk)
    begin
    end

endmodule
