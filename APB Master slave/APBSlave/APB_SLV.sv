/*
APB is Arm based low performance protocol used for data transfer.
APB State Machine has 3 states which depends upon 3 signals.
psel_o: indicates of slave selection, 
penable_o: indicates slave is ready for transfer, 
pready_i: indicates transfer is done.
IDLE State  : psel_o=0, penable_o=0
SETUP State : psel_o=1, penable_o=0 
ACCESS State: psel_o=1, penable_o=1
In ACCESS state once transfer is done pready_i is high, if next valid requests it will goto SETUP state otherwise will goto IDLE state.
  
Below APB Slave has memory interface. APB slave writes and reads data to and from memory interface.
*/

`default_nettype none
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

//////////////////////////////// Memory interface module ///////////////////////////////
///memory interface module, used lfsr and edge detector to read and write into memory///

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
  
  //edge detector instantion//
  raise_fall rf_inst (.clk(clk), 
                 .rst(rst), 
                 .req_i(req_i),         
                 .raise_o(req_rise_edge), 
                 .fall_o(/*notneeded*/)
                );
  
  //lfsr instantiation//
  lfsr lfsr_inst (.clk(clk), .rst(rst), .lfsr_o(lfsr_q));
  
  assign nxt_count=req_rise_edge?lfsr_q:count+3'h1; // if req signal raises assign lfsr value otherwise increase count value upto 4 bits of count is 0000.
  assign count=count_q;                       //count is used to add some random delays for transaction to complete and assert pready_o signal high
  
  always_comb begin
    if(~(|count) & memwr)
      mem[addr_i]=wdata_i;                    //write when count is zero
  end
  
  assign rdata_o = mem[addr_i] & {32{memrd}}; //read directly when read request happened
  
  assign ready_o=~|count;                     // slave sends ready output when count is zero.  
  
endmodule


////////////// edge detector module /////////////
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

////////////// lfsr module /////////////
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
