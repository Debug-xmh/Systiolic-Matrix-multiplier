

module FIX_unsigned_pipline_MUL #(
    parameter WIDTH_multiplicand = 16,
    parameter WIDTH_multiplier = 16
)
(
    input   clk,
    input   rst,
    input   valid,
    input   [WIDTH_multiplicand-1:0]       multiplicand,
    input   [WIDTH_multiplier-1:0]         multiplier,

    output  wire ready,
    output  wire [WIDTH_multiplicand + WIDTH_multiplier-1:0] product                      
);




wire     [WIDTH_multiplicand + WIDTH_multiplier-1:0]     multiplicand_shift [WIDTH_multiplier-1:0];
wire     [WIDTH_multiplier-1:0]                          multiplier_shift   [WIDTH_multiplier-1:0];

wire     [WIDTH_multiplier-1:0]                          valid_array;//
wire     [WIDTH_multiplicand + WIDTH_multiplier-1:0]     product_array[WIDTH_multiplier-1:0];


assign  ready = valid_array[WIDTH_multiplier-1];
assign  product = product_array[WIDTH_multiplier-1];

    multiply_cell # (
        .WIDTH_multiplicand         (WIDTH_multiplicand),
        .WIDTH_multiplier           (WIDTH_multiplier)
    ) multiply_cell0(
        .clk                        (clk),
        .rst                        (rst),
        .valid                      (valid),
        .multiplicand               ({{WIDTH_multiplier{1'd0}},multiplicand}),
        .multiplier                 (multiplier),
        .product_in                 ({(WIDTH_multiplicand + WIDTH_multiplier){1'd0}}),


        .ready                      (valid_array[0]),
        .multiplicand_shift         (multiplicand_shift[0]),
        .multiplier_shift           (multiplier_shift[0]),
        .product_out                (product_array[0])
    );

generate
    genvar i;
    for(i=1;i<WIDTH_multiplier;i=i+1)begin:multiply_cellx
        multiply_cell # (
            .WIDTH_multiplicand             (WIDTH_multiplicand),
            .WIDTH_multiplier               (WIDTH_multiplier)
        ) multiply_cellx(
            .clk                            (clk),
            .rst                            (rst),
            .valid                          (valid_array[i-1]),
            .multiplicand                   (multiplicand_shift[i-1]),
            .multiplier                     (multiplier_shift[i-1]),
            .product_in                     (product_array[i-1]),

            .ready                          (valid_array[i]),
            .multiplicand_shift             (multiplicand_shift[i]),
            .multiplier_shift               (multiplier_shift[i]),
            .product_out                    (product_array[i])
        );

    end
    endgenerate









endmodule