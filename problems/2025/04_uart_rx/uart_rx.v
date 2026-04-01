module uart_rx #(
    parameter FREQ = 50_000_000,
    parameter RATE = 2_000_000)
(
  input  wire       clk,
  input  wire       rst_n,

  input  wire       i_rx,
  output wire [7:0] o_data,
  output wire       o_vld
);

reg [3:0] state, next_state;

localparam [3:0] IDLE  = 4'd0,
                 START = 4'd1,
                 BIT0  = 4'd2,
                 BIT1  = 4'd3,
                 BIT2  = 4'd4,
                 BIT3  = 4'd5,
                 BIT4  = 4'd6,
                 BIT5  = 4'd7,
                 BIT6  = 4'd8,
                 BIT7  = 4'd9,
                 STOP  = 4'd10;

reg rx_d;
reg rx_fall;
reg load;
wire en;
reg shift_en;
reg [7:0] data;

assign o_data = data;
assign o_vld = i_rx && en && (state == STOP);

always @(posedge clk) begin
    rx_d <= i_rx;
end

always @(*) begin
    rx_fall = rx_d & !i_rx;
    load = rx_fall && (state == IDLE);
end

counter #(
    .CNT_WIDTH  ($clog2(FREQ / RATE)),
    .CNT_LOAD   (FREQ / RATE / 2),
    .CNT_MAX    (FREQ / RATE - 1)
) cnt (
    .clk    (clk    ),
    .rst_n  (rst_n  ),
    .i_load (load   ),
    .o_en   (en     )
);

always @(posedge clk or negedge rst_n)
   state <= !rst_n ? IDLE : next_state;

always @(*) begin
    case (state)
        IDLE, START, STOP:  shift_en = 0;
        default:            shift_en = en;
    endcase
end

always @(posedge clk) begin
    if (shift_en) begin
        data <= {i_rx, data[7:1]};
    end
end

always @(*) begin
    case (state)
        IDLE:  next_state = rx_fall ? START : state;
        START: next_state = en      ? (i_rx ? START : BIT0) : state;
        BIT0:  next_state = en      ? BIT1  : state;
        BIT1:  next_state = en      ? BIT2  : state;
        BIT2:  next_state = en      ? BIT3  : state;
        BIT3:  next_state = en      ? BIT4  : state;
        BIT4:  next_state = en      ? BIT5  : state;
        BIT5:  next_state = en      ? BIT6  : state;
        BIT6:  next_state = en      ? BIT7  : state;
        BIT7:  next_state = en      ? STOP  : state;
        STOP:  next_state = en      ? IDLE  : state;
        default: next_state = state;
    endcase
end

endmodule