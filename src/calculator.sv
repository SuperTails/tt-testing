`default_nettype none

module tt_um_calculator (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    calculator_chip calc(
        .NumOut(uo_out) .NumIn(uo_in), .OpIn({ 1'b1, uio_in[6:0] }), .Enter(uio_in[7]),
        .Reset(rst_n),
        .clock(clk));

    assign uio_oe = 8'b0000_0000;

endmodule : tt_um_calculator

module calculator_chip (
    output logic [7:0] NumOut,
    input logic [7:0] NumIn,
    input logic [1:0] OpIn,
    input logic Enter,
    input logic Reset,
    input logic clock);

    logic [7:0] state, next_state;

    assign NumOut = state;

    always_comb begin
        next_state = 8'b0;

        case (OpIn)
            2'b00: next_state = state + NumIn;
            2'b01: next_state = state - NumIn;
            2'b10: next_state = state | NumIn;
            2'b11: next_state = (state == NumIn) ? 8'b1 : 8'b0;
        endcase
    end

    always_ff @(posedge clock, negedge Reset) begin
        if (~Reset)
            state <= 8'b0;
        else
            state <= next_state;
    end

endmodule : calculator_chip