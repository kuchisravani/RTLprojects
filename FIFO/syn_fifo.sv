//synchronous fifo

module syn_fifo #(parameter DEP=4, parameter DWID=16)
  (
  input  wire           clk,
  input  wire           rst,
  input  wire           wr_i,
  input  wire           rd_i,
  input  wire[DWID-1:0] wdata,
  output wire[DWID-1:0] rdata,
  output wire           overflow_o,
  output wire           empty_o
);
  
  localparam PTR_WID=$clog2(DEP);
  typedef enum logic [1:0] {
    WR=2'b01, RD=2'b10, BOTH=2'b11
  } fifo_st;
  
  logic             rd_q;
  logic             wr_q;
  logic [DWID-1:0]  rdata_q;
  logic [PTR_WID:0] wrptr,wrptr_q;
  logic [PTR_WID:0]rdptr,rdptr_q;
  logic [DEP-1:0][WID-1:0] fifo_mem;
  
  
  assign empty_o   =(wrptr==rdptr);
  assign overflow_o=(wrptr[DEP]!=rdptr[DEP]) && (wrptr[DEP-1:0]==rdptr[DEP-1:0]);
  assign rd_q      =rd_i && ~empty_o;
  assign wr_q      =wr_i && ~overflow_o;
  assign rdata     =rdata_q;
    
  
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
   rdata_q=fifo_mem[rdptr[PTR_WID-1:0]];
   case({rd_q, wr_q}) 
     WR  : wrptr_q=wrptr + {PTR_WID{1'b1}};
     RD  : rdptr_q=rdptr + {PTR_WID{1'b1}};
     BOTH: begin 
           wrptr_q=wrptr + {PTR_WID{1'b1}}; 
           rdptr_q=rdptr + {PTR_WID{1'b1}};
           end
   endcase
 end

  always_ff @(posedge clk or negedge rst) begin
    if(!rst)
      fifo_mem<=0;
    else if(wr_q)
      fifo_mem[wrptr[PTR_WID-1:0]]<=wdata;
  end

endmodule  
  
