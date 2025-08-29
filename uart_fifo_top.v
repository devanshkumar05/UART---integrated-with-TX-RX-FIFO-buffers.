module uart_fifo_top (
    input  wire clk,
    input  wire reset,

    // TX interface
    input  wire [7:0] tx_data,
    input  wire tx_write,
    output wire tx_full,
    output wire tx,

    // RX interface
    input  wire rx,
    output wire [7:0] rx_data,
    input  wire rx_read,
    output wire rx_empty
);
    wire baud_tick;

    baud_gen #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(9600)
    ) baud_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    uart_tx_fifo tx_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx_data_in(tx_data),
        .tx_write(tx_write),
        .tx_full(tx_full),
        .tx(tx),
        .tx_busy()
    );

    uart_rx_fifo rx_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .rx(rx),
        .rx_data_out(rx_data),
        .rx_read(rx_read),
        .rx_empty(rx_empty)
    );
endmodule
