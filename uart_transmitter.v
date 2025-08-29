module uart_transmitter (
    input wire clk,
    input wire reset,
    input wire tx_start,             // Signal to start transmission
    input wire [7:0] tx_data,        // Data byte to transmit
    input wire baud_tick,            // Tick from baud rate generator (16× baud rate)

    output reg tx,                   // UART TX line
    output reg tx_busy,              // HIGH when transmitting
    output reg tx_done               // HIGH when done (1 clk cycle)
);

    // State encoding
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;
    localparam DONE  = 3'b100;

    reg [2:0] state = IDLE;

    reg [3:0] tick_counter = 0;      // Counts up to 15 (16 ticks per bit)
    reg [2:0] bit_index = 0;         // 0 to 7 for 8 bits

    reg [7:0] shift_reg = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            tx           <= 1'b1;   // TX line idle is HIGH
            tx_busy      <= 0;
            tx_done      <= 0;
            tick_counter <= 0;
            bit_index    <= 0;
        end else if (baud_tick) begin
            case (state)
                IDLE: begin
                    tx_done <= 0;
                    if (tx_start) begin
                        tx_busy      <= 1;
                        shift_reg    <= tx_data;
                        tick_counter <= 0;
                        state        <= START;
                        tx           <= 0; // Start bit
                    end
                end

                START: begin
                    if (tick_counter == 15) begin
                        tick_counter <= 0;
                        bit_index <= 0;
                        state <= DATA;
                        tx <= shift_reg[0]; // First data bit
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end

                DATA: begin
                    if (tick_counter == 15) begin
                        tick_counter <= 0;
                        bit_index <= bit_index + 1;
                        if (bit_index == 7) begin
                            state <= STOP;
                            tx <= 1; // Stop bit
                        end else begin
                            shift_reg <= shift_reg >> 1;
                            tx <= shift_reg[1]; // Next data bit
                        end
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end

                STOP: begin
                    if (tick_counter == 15) begin
                        state <= DONE;
                        tick_counter <= 0;
                        tx_done <= 1;
                        tx_busy <= 0;
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end

                DONE: begin
                    state <= IDLE;
                    tx_done <= 0;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
