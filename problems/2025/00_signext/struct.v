`timescale 1ns/1ps

module copy #(parameter N = 12,
                  parameter M = 32
)(
    input  wire i_x,
    output wire o_y
);
    assign o_y = i_x;

endmodule

module sign_ext_struct #(parameter N = 12,
                         parameter M = 32
)(
    input  wire [N-1:0] i_x,
    output wire [M-1:0] o_y
);
    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin : gen_lo
            copy low(.i_x(i_x[i]), .o_y(o_y[i]));
        end
    endgenerate

    generate
        for (i = N; i < M; i = i + 1) begin : gen_hi
            copy low(.i_x(i_x[N - 1]), .o_y(o_y[i]));
        end
    endgenerate

endmodule
