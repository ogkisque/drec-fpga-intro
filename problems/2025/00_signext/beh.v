`timescale 1ns/1ps

module sign_ext_behav #(parameter N = 12,
                        parameter M = 32
)(
    input  wire [N-1:0] i_x,
    output wire [M-1:0] o_y
);

    assign o_y = {{(M - N){i_x[N - 1]}}, i_x};

endmodule