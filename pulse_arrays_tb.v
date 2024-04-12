`timescale 1ns / 1ps
module pulse_arrays_tb();
    parameter   WIDTH_left   =   4;
    parameter   WIDTH_up     =   4;
    parameter   WIDTH_out    =   8;
    parameter   Mritx_M   =   3;//row
    parameter   Mritx_N   =   4;//row
    parameter   Mritx_L   =   3;  //col
    parameter   Mritx_LOG2_size =  10;

    reg clk;
    reg rst;
    reg valid;

    reg  [Mritx_M*WIDTH_left-1:0] left;
    reg  [Mritx_L*WIDTH_up-1:0]   up;

    reg   [WIDTH_left-1:0] left_mtrix[0:Mritx_M*Mritx_N-1];
    reg   [WIDTH_up-1:0] up_mtrix[0:Mritx_N*Mritx_L-1];

    wire   [WIDTH_left+WIDTH_up-1:0]   out[Mritx_M*Mritx_L-1:0];

    reg [Mritx_LOG2_size-1:0] m;
    reg [Mritx_LOG2_size-1:0] n;
    integer i,j;

    integer file1,file2 ,file_out,code;

    initial begin
        clk=0;
        rst=0;
        left=0;
        up=0;
        valid=0;
        m=0;
        n=0;
        #10;
        rst=1;
        
        // 
        file1 = $fopen("input_data_left.txt", "r");
        file2 = $fopen("input_data_up.txt", "r");
        file_out =$fopen("output_data.txt", "w");
        for (i = 1; i <= Mritx_M; i = i + 1) begin
            for(j = 1; j <= Mritx_N; j = j + 1) begin
                if(j==Mritx_N)
                    code = $fscanf(file1, "%d\n", left_mtrix[(i-1)*Mritx_N+j-1]);  // 
                else
                    code = $fscanf(file1, "%d,", left_mtrix[(i-1)*Mritx_N+j-1]);  // 

                if (code != 1) begin
                    $display("Error or end of file reached prematurely at row %d col %d", i,j);
                end
            end
        end
        for (i = 1; i <= Mritx_N; i = i + 1) begin
            for(j = 1; j <= Mritx_L; j = j + 1) begin
                if(j==Mritx_N)
                    code = $fscanf(file2, "%d\n", up_mtrix[(i-1)*Mritx_L+j-1]);  // 
                else
                    code = $fscanf(file2, "%d,", up_mtrix[(i-1)*Mritx_L+j-1]);  // 

                if (code != 1) begin
                    $display("Error or end of file reached prematurely at row %d col %d", i,j);
                end
            end
        end

        #20;
        rst=1;
        #10;
        left= {left_mtrix[Mritx_M*Mritx_N-m-1],left_mtrix[(Mritx_M-1)*Mritx_N-m-1],left_mtrix[(Mritx_M-2)*Mritx_N-m-1]};
        up= {up_mtrix[(Mritx_N-n)*Mritx_L-n-1],up_mtrix[(Mritx_N-n)*Mritx_L-1-1],up_mtrix[(Mritx_N-n)*Mritx_L-1-2]};
        m=1;
        n=1;
        valid=1;
        #10;
        #1000;
        $stop;
        end

    always #5  clk=~clk;

always @(posedge clk ) begin
    if(valid)begin

        if(m<Mritx_N)begin
            left= {left_mtrix[Mritx_M*Mritx_N-m-1],left_mtrix[(Mritx_M-1)*Mritx_N-m-1],left_mtrix[(Mritx_M-2)*Mritx_N-m-1]};
        end

        if(n<Mritx_N)begin
            up= {up_mtrix[(Mritx_N-n)*Mritx_L-1],up_mtrix[(Mritx_N-n)*Mritx_L-1-1],up_mtrix[(Mritx_N-n)*Mritx_L-1-2]};
        end
        if(m==Mritx_N&&n==Mritx_N)
            valid=0;
        m=m+1;
        n=n+1;
    end
    
end



// 实例化 pulse_arrays 模块
pulse_arrays #(
    .WIDTH_left(WIDTH_left),
    .WIDTH_up(WIDTH_up),
    .WIDTH_out(WIDTH_out),
    .Mritx_M(Mritx_M),
    .Mritx_N(Mritx_N),
    .Mritx_L(Mritx_L),
    .Mritx_LOG2_size(Mritx_LOG2_size)
) pulse_arrays_inst (
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .left(left),
    .up(up),
    .ready(),
    .product()
);



endmodule
