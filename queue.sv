`include "queue.svh"

module queue (

    input clk,
    input[0:`PL-1] data_in,
    input shift_signal,
    output wire[0:`PL-1] data_out,
    output wire availability_signal,
    output wire[0:`EN+1] selector,
    output reg[0:`PL-1] queue_buffers[0:`EN-1]

);

    assign selector[`EN] = shift_signal;
    assign selector[`EN+1] = data_in[0];

    assign availability_signal = !queue_buffers[`EN-1][0];

    assign data_out = queue_buffers[0];

    genvar j;
    generate
        for (j = 0; j < `EN; j = j + 1)
        begin : queue_selector_generator
            assign selector[j] = queue_buffers[j][0];
        end
    endgenerate

    initial
    begin
        int i;
        for (i = 0; i < `EN; i = i + 1) // initialize queue at 0
        begin
            queue_buffers[i] = 0;
        end
    end

    always @(negedge clk)
    begin
        
        
        casex (selector) // find queue entry

            'b0xxxx1: 
            begin
                queue_buffers[0] <= data_in;
            end
            'b10xx11: 
            begin
                queue_buffers[0] <= data_in;
            end
            'b10xx01: 
            begin
                queue_buffers[1] <= data_in;
            end
            'b110x11: 
            begin
                queue_buffers[0] <= queue_buffers[1];
                queue_buffers[1] <= data_in;
            end
            'b110x01: 
            begin
                queue_buffers[2] <= data_in;
            end
            'b111011:
            begin
                queue_buffers[0] <= queue_buffers[1];
                queue_buffers[1] <= queue_buffers[2];
                queue_buffers[2] <= data_in;
            end
            'b111001: 
            begin
                queue_buffers[3] <= data_in;
            end
            'b111111: 
            begin
                queue_buffers[0] <= queue_buffers[1];
                queue_buffers[1] <= queue_buffers[2];
                queue_buffers[2] <= queue_buffers[3];
                queue_buffers[3] <= data_in;
            end

            'b10xx10: 
            begin
                queue_buffers[0] <= 0;
            end
            'b110x10: 
            begin
                queue_buffers[0] <= queue_buffers[1];
                queue_buffers[1] <= 0;
            end
            'b111010: 
            begin
                queue_buffers[0] <= queue_buffers[1];
                queue_buffers[1] <= queue_buffers[2];
                queue_buffers[2] <= 0;
            end
            'b111110: 
            begin
                queue_buffers[0] <= queue_buffers[1];
                queue_buffers[1] <= queue_buffers[2];
                queue_buffers[2] <= queue_buffers[3];
                queue_buffers[3] <= 0;
            end

            default: 
            begin
            end
        endcase

    end

endmodule