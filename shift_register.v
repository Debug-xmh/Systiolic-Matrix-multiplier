/*Instruction:

Module Name:FIFO_SYNC 
Function: support read and wirte in the meantime
parameter:
port:

*/
module shift_register  #(
    parameter   WIDTH_in  = 16,
    parameter   WIDTH_out  = 16,
    parameter   DEEP      =   128 ,
    parameter   PTR_SIZE  =   10
)(
    input   wire   clk,
    input   wire   rst,
    input   wire   shift_en,
    input   wire   [WIDTH_in-1:0]    shift_in,
    output  wire   [WIDTH_out-1:0]    shift_out
);

reg     [WIDTH_in-1:0] SHIFT_BUFF   [0:DEEP-1]; //how to initate the value? method1:for loop  (waste hardware resource) method 2:control output
reg     [PTR_SIZE-1:0]  cnt = 0;      //signal to make write first(when the module read_ptr==read_ptr   cause write data error  )

integer  i;
assign shift_out = (cnt==DEEP)?{{(WIDTH_out-WIDTH_in){1'd0}},SHIFT_BUFF[DEEP-1]}:0;

//support read and wirte in the meantime
always@(posedge  clk)begin
    //reset
    if(!rst)begin
        cnt <= 0; 
    end

    //write
    else  begin
        for(i=0;i<DEEP-1;i=i+1)begin
            SHIFT_BUFF[i+1] <= SHIFT_BUFF[i];
        end
        
        if(cnt==DEEP)begin
            cnt <= cnt;
        end
        else begin
            cnt <= cnt + 1;
        end

        if(shift_en)
            SHIFT_BUFF[0] <= shift_in;
        else
            SHIFT_BUFF[0] <= 0;

    end

end


endmodule