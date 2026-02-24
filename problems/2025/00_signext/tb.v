`timescale 1ns/1ps

module tb_sign_ext;

localparam M = 32;

localparam N12 = 12;
reg  [N12-1:0] in12;
wire [M-1:0]   out12_b;
wire [M-1:0]   out12_s;
reg  [M-1:0]   correct12;

sign_ext_behav  #(N12, M) sign_ext_12_b (.i_x(in12), .o_y(out12_b));
sign_ext_struct #(N12, M) sign_ext_12_s (.i_x(in12), .o_y(out12_s));

localparam N20 = 20;
reg  [N20-1:0] in20;
wire [M-1:0]   out20_b;
wire [M-1:0]   out20_s;
reg  [M-1:0]   correct20;

sign_ext_behav  #(N20, M) sign_ext_20_b (.i_x(in20), .o_y(out20_b));
sign_ext_struct #(N20, M) sign_ext_20_s (.i_x(in20), .o_y(out20_s));

always  begin
    #1
    in12 = $random;
    correct12 = {{(M - N12){in12[N12 - 1]}}, in12};
    #1
    if (out12_b == correct12)
        $display("[%0t]. Correct beh N=12. in = %b. out = %b",
                $realtime, in12, out12_b);
    else
        $display("[%0t]. Incorrect beh N=12. in = %b. out = %b. correct = %b",
                $realtime, in12, out12_b, correct12);

    if (out12_s == correct12)
        $display("[%0t]. Correct struct N=12. in = %b. out = %b",
                $realtime, in12, out12_s);
    else
        $display("[%0t]. Incorrect struct N=12. in = %b. out = %b. correct = %b",
                $realtime, in12, out12_s, correct12);

    #1
    in20 = $random;
    correct20 = {{(M - N20){in20[N20 - 1]}}, in20};
    #1
    if (out20_b == correct20)
        $display("[%0t]. Correct beh N=20. in = %b. out = %b",
                $realtime, in20, out20_b);
    else
        $display("[%0t]. Incorrect beh N=20. in = %b. out = %b. correct = %b",
                $realtime, in20, out20_b, correct20);

    if (out20_s == correct20)
        $display("[%0t]. Correct struct N=20. in = %b. out = %b",
                $realtime, in20, out20_s);
    else
        $display("[%0t]. Incorrect struct N=20. in = %b. out = %b. correct = %b",
                $realtime, in20, out20_s, correct20);
end

initial begin
    $dumpvars;
    $display("[%0t] Start", $realtime);
    #100 $finish;
end

endmodule