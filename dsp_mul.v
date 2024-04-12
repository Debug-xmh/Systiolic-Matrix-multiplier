module dsp_mul  #(
    parameter   WIDTH_a     =   16,
    parameter   WIDTH_b     =   16
)(
    input   clk,
    input   rst,
    input   valid,
    input   wire  [WIDTH_a-1:0]    multiplicand,
    input   wire  [WIDTH_b-1:0]    multiplier,
    output  wire  [WIDTH_a+WIDTH_b-1:0]    product
);

assign product = valid?multiplicand*multiplier:0;



endmodule