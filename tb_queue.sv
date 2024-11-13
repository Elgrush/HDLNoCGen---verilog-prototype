`timescale 1ns/1ns
`include "queue.sv"


module tb_queue;

    reg clk = 1'b0;
    reg[0:`PL-1] data_in;
    wire[0:`PL-1] data_out;
    wire sent_to_queue;
    wire[0:`PL-1] tb_queue_buffers[0:`EN-1];
    reg taken_from_queue = 1'b0;

    integer i;

    queue queue1
    (
        .clk(clk),
        .data_in(data_in),
        .shift_signal(taken_from_queue),
        .data_out(data_out),
        .availability_signal(sent_to_queue),
        .queue_buffers(tb_queue_buffers)
    );

    always #10 clk = ~clk;

    always @(posedge sent_to_queue)
    begin
        data_in = 0;
    end

    initial
    begin
        $dumpfile("tb_queue.vcd");
        $dumpvars;

        for (i = 0; i < `EN; i = i + 1)
        begin
            $dumpvars(0, tb_queue_buffers[i]);
        end

        for (i = 0; i < 4; i = i + 1)
        begin
            taken_from_queue = 1'b0;
            data_in = 8'b10000000 + i;
            #20;
            // Assert non reaction
            if (tb_queue_buffers[i] != 8'b10000000 + i)
            begin
                $error("Queue failed to store ", tb_queue_buffers[i], " !=" , 8'b10000000 + i);
            end
        end
        #10
        taken_from_queue = 1'b1;
        for (i = 0; i < 4; i = i + 1)
        begin
            // Assert reaction
            if (data_out != 8'b10000000 + i)
            begin
                $error("Queue failed to react ", data_out, " !=" , 8'b10000000 + i);
            end
            #20;
        end
        #30
        data_in = 8'b10000000 + 4;
        #20
        if (data_out != 8'b10000000 + 4)
            begin
                $error("Queue failed to clear itself ", data_out, " !=" , 8'b10000000 + 4);
            end
        #90
        taken_from_queue = 1'b0;
        for (i = 5; i < 10; i = i + 1)
        begin
            data_in = 8'b10000000 + i;
            #20;
            if (tb_queue_buffers[i]  !=  8'b10000000 + i)
                begin
                    $error("Queue failed to react ", tb_queue_buffers[i], " !=" , 8'b10000000 + i);
                end
        end
        #10
        data_in = 0;
        taken_from_queue = 1'b1;
        for (i = 5; i < 9; i = i + 1)
        begin
            // Assert reaction
            if (data_out != 8'b10000000 + i)
            begin
                $error("Queue failed to react ", data_out, " !=" , 8'b10000000 + i);
            end
            #20;
        end
        taken_from_queue = 1'b0;
        if (data_out != 0)
            begin
                $error("Queue failed to clean itself ", data_out, " !=" , 0);
            end
        $finish;
    end

endmodule