//synchronous fifo

module syn_fifo #(parameter DEP=4, parameter WID=16)
  (
  input wire clk,
  input wire rst,
  input wire wr_i,
  input wire rd_i,
  input wire[WID-1:0] wdata,
  output wire[WID-1:0] rdata,
  output wire overflow_o,
  output wire empty_o
);
  
  typedef enum logic [1:0] {
    WR=2'b01, RD=2'b10, BOTH=2'b11
  } fifo_st;
  
  logic         rd_q;
  logic         wr_q;
  logic [DEP:0] wrptr,wrptr_q;
  logic [DEP:0] rdptr,rdptr_q;
  logic [DEP-1:0][WID-1:0] fifo_mem;
  
  
  assign empty_o=(wrptr==rdptr);
  assign overflow_o=(wrptr[DEP]!=rdptr[DEP]) && (wrptr[DEP-1:0]==rdptr[DEP-1:0]);
  assign rd_q=rd_i && ~empty_o;
  assign wr_q=wr_i && ~overflow_o;
  assign rdata=rd_q?fifo_mem[rdptr]:0;
    
  
  always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
      wrptr<=0;
      rdptr<=0;
     end else begin
      wrptr<=wrptr_q;
      rdptr<=rdptr_q;
     end
  end
  
 always_comb begin
   wrptr_q=wrptr;
   rdptr_q=rdptr;
   case({rd_q, wr_q}) 
     WR  : wrptr_q++;
     RD  : rdptr_q++;
     BOTH: begin wrptr_q++; rdptr_q++; end
   endcase
 end

  always_ff @(posedge clk or negedge rst) begin
    if(!rst)
      fifo_mem<=0;
    else if(wr_q)
      fifo_mem[wrptr]<=wdata;
  end

endmodule  
