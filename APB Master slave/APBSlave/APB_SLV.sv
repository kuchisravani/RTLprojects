module APB_SLV(
  input wire pclk_i,
  input wire prst_n,
  input wire psel_i,
  input wire penable_i,
  input wire pwrite_i,
  input wire[7:0] paddr_i,
  input wire[31:0]pwdata_i,
  output wire[31:0]prdata_o,
  output wire pready_o
);
  
  logic req;
  assign req=psel_i &penable_i;
  mem_int mem_int_inst(
    .clk(pclk_i),
    .rst(prst_n),
    .req_i(req),
    .req_rnw_i(pwrite_i),
    .addr_i(paddr_i),
    .wdata_i(pwdata_i),
    .rdata_o(prdata_o),
    .ready_o(pready_o)
  );

endmodule

`default_nettype none
module mem_int(
  input wire clk,
  input wire rst,
  input wire req_i,
  input wire req_rnw_i,
  input wire[7:0] addr_i,
  input wire[31:0]wdata_i,
  output wire[31:0] rdata_o,
  output wire ready_o
);
  
  logic [31:0]mem[256:0];
  logic [2:0]lfsr_q;
  logic [2:0]count, count_q, nxt_count;
  logic req_rise_edge;
  logic memrd, memwr;
  
  assign memwr = req_i & req_rnw_i;
  assign memrd = req_i & ~req_rnw_i;
  
  always_ff @(posedge clk or rst) begin
    if(rst)
      count_q<=0;
    else
      count_q<=nxt_count;
  end
  
  raise_fall rf_inst (.clk(clk), 
                 .rst(rst), 
                 .req_i(req_i),         
                 .raise_o(req_rise_edge), 
                 .fall_o(/*notneeded*/)
                );
  
  lfsr lfsr_inst (.clk(clk), .rst(rst), .lfsr_o(lfsr_q));
  
  assign nxt_count=req_rise_edge?lfsr_q:count+3'h1;
  assign count=count_q;
  
  always_comb begin
    if(~(|count) & memwr)
      mem[addr_i]=wdata_i;
  end
  
  assign rdata_o = mem[addr_i] & {32{memrd}};
  
  assign ready_o=~|count;
  
endmodule

module raise_fall(
  input clk,
  input rst,
  input req_i,
  output raise_o,
  output fall_o
);
  
  logic req_ff;
  always @(posedge clk or posedge rst) begin
    if(rst)
      req_ff<=0;
    else
      req_ff<=req_i;
  end
  
  assign raise_o=~req_ff & req_i;
  assign fall_o =req_ff & ~req_i;
endmodule

module lfsr(
  input clk,
  input rst,
  output logic [2:0]lfsr_o
);
  
  logic [2:0]next_ff;
  logic [2:0]lfsr_ff;
  
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      lfsr_ff<=3'h4;
    else
      lfsr_ff[2:0]<=next_ff;
  end
 assign next_ff={lfsr_o[1:0],lfsr_o[2] ^ lfsr_o[0]};
 assign lfsr_o=lfsr_ff;
  endmodule
