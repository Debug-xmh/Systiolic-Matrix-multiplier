/*Instruction:
Module Name:FIFO_SYNC 
Function: support read and wirte in the meantime
parameter:
port:
*/
module fifo_sync  #(
    parameter   WIDTH     =   16  ,
    parameter   DEEP      =   128 ,
    parameter   PTR_SIZE  =   10
)(
    input   wire   clk,
    input   wire   rst,
    input   wire   write_en,
    input   wire   [WIDTH-1:0]    write_data,

    input   reg    read_en,
    output  reg    [WIDTH-1:0]    read_data,

    output  reg    full,
    output  reg    empty
);

reg     [WIDTH-1:0] FIFO_BUFF   [0:DEEP-1];
reg     [PTR_SIZE-1:0]  read_ptr  = 0;
reg     [PTR_SIZE-1:0]  write_ptr = 0;
reg     [PTR_SIZE-1:0]  cnt       = 0;      //signal to make write first(when the module read_ptr==read_ptr   cause write data error  )

//support read and wirte in the meantime
always@(posedge  clk)begin
    //reset
    if(!rst)begin
        cnt        <= 0; 
        write_ptr  <= 0;
        full       <= 1'd0;
    end
    //write
    else if(write_en)  begin
        if(write_ptr==read_ptr&&cnt==DEEP)begin    //write full
            full <= 1'd1;
        end
        else begin                      //write normal
            FIFO_BUFF[write_ptr] <= write_data;
            full <= 1'd0;
            cnt  <= cnt + 1;
            if(write_ptr==DEEP-1)
                write_ptr <= 1'd0;
            else
                write_ptr <= write_ptr + 1;
        end
    end
    //idle
    else begin
        write_ptr <= write_ptr;
        full <= 1'd0;
    end
end


always@(posedge  clk)begin
    //reset
    if(!rst)begin
        read_ptr  <= 0;
        read_data <= 0;
        empty     <= 1'd0;
    end
    //read
    else if(read_en)  begin
        if(read_ptr==write_ptr&&cnt==0)begin //read empty
            empty     <= 1'd1;
        end
        else begin                  //read normal
            cnt  <= cnt - 1;
            read_data <= FIFO_BUFF[read_ptr];
            empty     <= 1'd0;
            if(read_ptr==DEEP-1)
                read_ptr <= 0;
            else
                read_ptr <= read_ptr + 1;
        end
    end
    //idle
    else begin
        read_ptr  <= read_ptr;
        read_data <= read_data;
        empty     <= 1'd0;
    end
end

endmodule