module uart_tx_fifo (
    input  wire clk,
    input  wire reset,
    input  wire baud_tick,
    input  wire [7:0] tx_data_in,
    input  wire tx_write,
    output wire tx_full,

    output wire tx,
    output wire tx_busy
);
    wire fifo_empty;
    wire [7:0] fifo_data_out;
    reg tx_start = 0;
    wire tx_done;

    // FIFO for TX buffer
    fifo #(.DATA_WIDTH(8), .DEPTH(16)) tx_fifo (
        .clk(clk),
        .reset(reset),
        .wr_en(tx_write),
        .wr_data(tx_data_in),
        .rd_en(tx_done),
        .rd_data(fifo_data_out),
        .empty(fifo_empty),
        .full(tx_full)
    );

    // Transmitter logic
    uart_transmitter tx_core (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(fifo_data_out),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    // Start TX if not busy and FIFO is not empty
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_start <= 0;
        end else begin
            tx_start <= (~fifo_empty && ~tx_busy);
        end
    end
endmodule
