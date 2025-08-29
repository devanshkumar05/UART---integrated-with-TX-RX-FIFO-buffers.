module uart_rx_fifo (
    input  wire clk,
    input  wire reset,
    input  wire baud_tick,
    input  wire rx,
    
    output wire [7:0] rx_data_out,
    input  wire rx_read,
    output wire rx_empty
);
    wire [7:0] rx_data_internal;
    wire rx_data_ready;

    // RX core
    uart_receiver rx_core (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .baud_tick(baud_tick),
        .data_out(rx_data_internal),
        .data_ready(rx_data_ready)
    );

    // RX FIFO
    fifo #(.DATA_WIDTH(8), .DEPTH(16)) rx_fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(rx_data_ready),
        .wr_data(rx_data_internal),
        .rd_en(rx_read),
        .rd_data(rx_data_out),
        .empty(rx_empty),
        .full() // ignored
    );
endmodule
