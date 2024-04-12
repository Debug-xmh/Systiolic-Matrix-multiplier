module pulse_arrays_pe  #(
    parameter   WIDTH_left     =   8,
    parameter   WIDTH_up       =   8,
    parameter   WIDTH_out      =   8
)(
    input   wire    clk,
    input   wire    rst,
    input   wire    [1:0]mode,           // mode=0 tpu_computer mode=1 shift out_data

    input   wire    [WIDTH_out-1:0]  left,
    input   wire    [WIDTH_up-1:0]  up,

    output  reg     [WIDTH_out-1:0]  right,
    output  reg     [WIDTH_up-1:0]  down,
    output  reg     [WIDTH_out-1:0]  out_data
);
//reg     [WIDTH_out-1:0]  out_data;
wire    [WIDTH_out-1:0]  temp_data;

always@(posedge  clk)begin
    if(!rst)begin
        right   <=  0;
        down   <=  0;
        out_data <=  0;
    end
    else begin
        if(mode==0)begin
            right<= left;//{{(WIDTH_out-WIDTH_left){1'd0}},left}
            down     <=  up;
            out_data <=  temp_data+out_data;
        end

        else if(mode==2)begin                  
            right    <=  out_data;
            out_data <=  0;
        end

        else
            right    <=  left;

    end
end

    //module instantiation
    FIX_unsigned_MUL  #(.WIDTH_multiplicand(WIDTH_left), .WIDTH_multiplier(WIDTH_up))
    uut
    (
        .clk               (clk),
        .rst               (rst),
        .valid             (1'd1),
        .multiplicand      (left[WIDTH_left-1:0]),
        .multiplier        (up),
        .ready             (),
        .product           (temp_data)
    );

endmodule