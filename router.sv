`include "queue.sv"
`include "arbiter.sv"
`include "algorithm.sv"

module router (
    input clk,
    input[0:`PL-1] inputs[0:`REN-1], output[0:`PL-1] outputs[0:`REN-1],
    input availability_signals_in[0:`REN-1], output availability_signals_out[0:`REN-1],
    input[`CS-1:0] router_X, input[`CS-1:0] router_Y
);

    wire[0:`PL-1] queue_to_arbiter[0:`REN-1];
    wire[0:`PL-1] arbiter_to_algorithm;
    wire shift_signals[0:`REN-1];
    wire[3:0] shift;
    wire send_data_flag;

    generate
        genvar i;
        for (i=0; i<`REN; i=i+1) begin : queues_initialiser
            queue queue_i (.clk(clk),
            .data_in(inputs[i]), .data_out(queue_to_arbiter[i]),
            .availability_signal(availability_signals_out[i]), .shift_signal(shift_signals[i]));
        end
    endgenerate

    arbiter round_robin(.clk(clk),
    .input_(queue_to_arbiter), .output_data(arbiter_to_algorithm),
    .shift(shift)
    );

    algorithm XY(.clk(clk),
    .from_arbiter(arbiter_to_algorithm), .shift(shift), .outputs(outputs),
    .router_X(router_X), .router_Y(router_Y),
    .availability_signals_in(availability_signals_in), .shift_signals(shift_signals));

    
endmodule
