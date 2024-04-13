module pulse_arrays  #(
    parameter   WIDTH_left     =   8,
    parameter   WIDTH_up       =   8,
    parameter   WIDTH_out      =   8,
    parameter   Mritx_M   =   3,//output row
    parameter   Mritx_N   =   3,//
    parameter   Mritx_L   =   3,//output col
    parameter   Mritx_LOG2_size  =   10 //counter's width
)(
    input   clk,
    input   rst,

    input   wire    valid_left,
    input   wire    valid_up,
    input   wire  [Mritx_M*WIDTH_left-1:0]   left,
    input   wire  [Mritx_L*WIDTH_up-1:0]     up,

    output  reg     ready,                          //ready for input
    output  wire  [WIDTH_out*Mritx_M-1:0]    product 
);
    localparam  idl      = 4'd0;
    localparam  state_in = 4'd1;
    localparam  state_out= 4'd2;
    // state register
    reg [3:0] state;


    wire    [WIDTH_out-1:0]          left_temp [Mritx_M*Mritx_L-1:0];   //x_unite_wire
    wire    [WIDTH_up-1:0]           up_temp   [Mritx_M*Mritx_L-1:0];   //y_unite_wire

//enable  signal

    // reg     [Mritx_M-1:0]           left_shift_en;
    // reg     [Mritx_L-1:0]           up_shift_en;
    reg     star=0,export=0,finish=0;//flag
    reg     [Mritx_LOG2_size-1:0]      cnt_flow1;
    reg     [Mritx_LOG2_size-1:0]      cnt_flow2;

    reg     [2*Mritx_L-1:0]      mode_control=0;// 行同步控制 初始赋值0 大量变1易串扰不稳定
//output 
    wire    [WIDTH_out-1:0] out_data[Mritx_M*Mritx_L-1:0];  


assign left_temp[0] = valid_left?{{(WIDTH_out-WIDTH_left){1'd0}},left[WIDTH_left-1:0]}:0;
assign up_temp[0]   = valid_up?up[WIDTH_up-1:0]:0;

always @(posedge clk ) begin
    if(!rst)begin
        state <= idl;
        star  <= 0;
        export<= 0;
        ready <= 0;
        finish<= 0;
        cnt_flow1 <= 0;
        cnt_flow2 <= 0;
        mode_control   <= 0;
    end

    else begin
        case (state)
        idl :begin
            ready     <= 1;
            star      <= 0;
            export    <= 0;
            finish    <= 0;
            cnt_flow1 <= 0;
            cnt_flow2 <= 0;
            mode_control <= 0;
            if(valid_left&valid_up)
                state <= state_in;
            else
                state <= idl;
        end 
        state_in :begin
            ready     <= 0;
            star      <= 1;
            export    <= 0;
            finish    <= 0;
            cnt_flow1 <= cnt_flow1 + 1;
            cnt_flow2 <= 0;
            if(cnt_flow1==Mritx_M+Mritx_N+Mritx_L-2+WIDTH_up-1)begin
                state <= state_out;
                mode_control <= {Mritx_L{2'd2}};
            end
            else
                state <= state_in;
        end 
        state_out:begin
            ready     <= 0;
            star      <= 0;
            cnt_flow1 <= 0;
            cnt_flow2 <= cnt_flow2 + 1;
            if(cnt_flow2==0)
                mode_control <= {Mritx_L{2'd1}}<<2;
            else
                mode_control <= mode_control<<2;
            if(cnt_flow2==Mritx_L) begin
                state <= idl;
                finish<= 1;
                export<= 0;
            end
            else begin
                state <= state_out;
                finish<= 0;
                export<= 1;
            end
        end 

        default: begin
            ready     <= 0;
            star      <= 0;
            export    <= 0;
            finish    <= 0;
            cnt_flow1 <= 0;
            cnt_flow2 <= 0;
            mode_control <= 0;
            state <= idl;
        end
        endcase
    end
end

generate 
    genvar  i,j;
    for(i=0;i<=Mritx_M-1;i=i+1)begin
        for(j=0;j<=Mritx_L-1;j=j+1)begin:pulse_arrays_pex
            if(i==0&&j==0)begin
                pulse_arrays_pe #(
                    .WIDTH_left (WIDTH_left),
                    .WIDTH_up   (WIDTH_up),
                    .WIDTH_out  (WIDTH_out)
                )pulse_arrays_pex(
                    .clk        (clk),
                    .rst        (rst),
                    .mode       (mode_control[(j+1)*2-1:j*2]),
                    .left       (left_temp[0]),
                    .up         (up_temp[0]),
                    .right      (left_temp[i*Mritx_L+j+1]),
                    .down       (up_temp[(i+1)*Mritx_L+j]),
                    .out_data   (out_data[i*Mritx_L+j])
                );
            end
            
            else if(i==Mritx_M-1&&j==Mritx_L-1)begin
                pulse_arrays_pe #(
                    .WIDTH_left (WIDTH_left),
                    .WIDTH_up   (WIDTH_up),
                    .WIDTH_out  (WIDTH_out)
                )pulse_arrays_pex(
                    .clk        (clk),
                    .rst        (rst),
                    .mode       (mode_control[(j+1)*2-1:j*2]),
                    .left       (left_temp[i*Mritx_L+j]),
                    .up         (up_temp[i*Mritx_L+j]),
                    .right      (product[WIDTH_out*(i+1)-1:WIDTH_out*i]),
                    .down       (),
                    .out_data   (out_data[i*Mritx_L+j])
                );
            end
            else if(i==Mritx_M-1)begin
                pulse_arrays_pe #(
                    .WIDTH_left (WIDTH_left),
                    .WIDTH_up   (WIDTH_up),
                    .WIDTH_out  (WIDTH_out)
                )pulse_arrays_pex(
                    .clk        (clk),
                    .rst        (rst),
                    .mode       (mode_control[(j+1)*2-1:j*2]),
                    .left       (left_temp[i*Mritx_L+j]),
                    .up         (up_temp[i*Mritx_L+j]),
                    .right      (left_temp[i*Mritx_L+j+1]),
                    .down       (),
                    .out_data   (out_data[i*Mritx_L+j])
                );
            end
            else if(j==Mritx_L-1)begin
                pulse_arrays_pe #(
                    .WIDTH_left (WIDTH_left),
                    .WIDTH_up   (WIDTH_up),
                    .WIDTH_out  (WIDTH_out)
                )pulse_arrays_pex(
                    .clk        (clk),
                    .rst        (rst),
                    .mode       (mode_control[(j+1)*2-1:j*2]),
                    .left       (left_temp[i*Mritx_L+j]),
                    .up         (up_temp[i*Mritx_L+j]),
                    .right      (product[WIDTH_out*(i+1)-1:WIDTH_out*i]),
                    .down       (up_temp[(i+1)*Mritx_L+j]),
                    .out_data   (out_data[i*Mritx_L+j])
                );
            end
            else begin
                pulse_arrays_pe #(
                    .WIDTH_left (WIDTH_left),
                    .WIDTH_up   (WIDTH_up),
                    .WIDTH_out  (WIDTH_out)
                )pulse_arrays_pex(
                    .clk        (clk),
                    .rst        (rst),
                    .mode       (mode_control[(j+1)*2-1:j*2]),
                    .left       (left_temp[i*Mritx_L+j]),
                    .up         (up_temp[i*Mritx_L+j]),
                    .right      (left_temp[i*Mritx_L+j+1]),
                    .down       (up_temp[(i+1)*Mritx_L+j]),
                    .out_data   (out_data[i*Mritx_L+j])
                );
            end
        end
    end
endgenerate

generate
    genvar m,n;
        for(m=1;m<Mritx_M;m=m+1)begin:shift_register_left
            shift_register #(
                .WIDTH_in(WIDTH_left),
                .WIDTH_out(WIDTH_out),
                .DEEP(m),
                .PTR_SIZE(Mritx_LOG2_size)
            )shift_register_left(
                .clk(clk),
                .rst(rst),
                .shift_en(valid_left),
                .shift_in(left[(m+1)*WIDTH_left-1:(m)*WIDTH_left]),
                .shift_out(left_temp[m*Mritx_L])
            );
        end

        for(n=1;n<Mritx_L;n=n+1)begin:shift_register_up
            shift_register #(
                .WIDTH_in(WIDTH_up),
                .WIDTH_out(WIDTH_up),
                .DEEP(n),
                .PTR_SIZE(Mritx_LOG2_size)
            )shift_register_up(
                .clk(clk),
                .rst(rst),
                .shift_en(valid_up),
                .shift_in(up[(n+1)*WIDTH_up-1:n*WIDTH_up]),
                .shift_out(up_temp[n])
            );
        end
endgenerate

endmodule