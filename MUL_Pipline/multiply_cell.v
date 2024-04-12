module  multiply_cell#(
    parameter WIDTH_multiplicand = 16,
    parameter WIDTH_multiplier = 16
)
(
    input   clk,
    input   rst,
    input   valid,

    input   [WIDTH_multiplicand + WIDTH_multiplier-1:0]       multiplicand,
    input   [WIDTH_multiplier-1:0]                          multiplier,
    input   [WIDTH_multiplicand + WIDTH_multiplier-1:0]       product_in,

    output  reg ready,
    output  reg [WIDTH_multiplicand + WIDTH_multiplier-1:0]   multiplicand_shift,
    output  reg [WIDTH_multiplier-1:0]                      multiplier_shift,

    output  reg [WIDTH_multiplicand + WIDTH_multiplier-1:0]   product_out   
);

always @(posedge clk)begin
    if(!rst)begin
        ready <= 0;
        multiplicand_shift  <= {(WIDTH_multiplicand + WIDTH_multiplier){1'd0}};
        multiplier_shift <= {WIDTH_multiplier{1'd0}};
        product_out <=  {(WIDTH_multiplicand + WIDTH_multiplier){1'd0}};
    end


    else if(valid)begin

        ready <= 1;
        multiplicand_shift <= (multiplicand<<1);
        multiplier_shift <= (multiplier>>1);

        if(multiplier[0])begin
            product_out <= product_in  + multiplicand;
        end
        else begin
            product_out <= product_in;
        end
    end

    else begin
        ready <= 0;
        multiplicand_shift  <= {(WIDTH_multiplicand + WIDTH_multiplier){1'd0}};
        multiplier_shift <= {WIDTH_multiplier{1'd0}};
        product_out <=  {(WIDTH_multiplicand + WIDTH_multiplier){1'd0}};
    end



end



endmodule