module uart_receiver (
    input wire clk,             // System clock
    input wire reset,           // Active high reset
    input wire rx,              // UART RX line
    input wire baud_tick,       // Tick from baud rate generator (16× baud rate)

    output reg [7:0] data_out,  // Received byte
    output reg data_ready       // Goes high when byte is received
);

    // State encoding
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;
    localparam DONE  = 3'b100;

    reg [2:0] state = IDLE;

    reg [3:0] tick_counter = 0;  // Counts 0 to 15
    reg [2:0] bit_index = 0;     // Counts 0 to 7 for 8 bits

    reg [7:0] shift_reg = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            data_ready   <= 0;
            tick_counter <= 0;
            bit_index    <= 0;
            shift_reg    <= 0;
        end else if (baud_tick) begin
            case (state)
                // Wait for falling edge (start bit)
                IDLE: begin
                    data_ready <= 0;
                    if (~rx) begin  // Start bit detected (rx is LOW)
                        tick_counter <= 0;
                        state <= START;
                    end
                end

                // Wait for middle of start bit (tick 8)
                START: begin
                    if (tick_counter == 7) begin
                        if (~rx) begin  // Confirm it's still low
                            tick_counter <= 0;
                            bit_index <= 0;
                            state <= DATA;
                        end else begin
                            state <= IDLE;  // False start bit
                        end
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end

                // Receive 8 data bits
                DATA: begin
                    if (tick_counter == 15) begin
                        tick_counter <= 0;
                        shift_reg <= {rx, shift_reg[7:1]};  // Shift in LSB first
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end

                // Check stop bit
                STOP: begin
                    if (tick_counter == 15) begin
                        data_out <= shift_reg;
                        data_ready <= rx;  // Only assert if stop bit is HIGH
                        state <= IDLE;
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
