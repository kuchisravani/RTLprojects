//Parameterized Round Robin aribter with priority arbiter as an instantion.

module RR_arb #(parameter RR_WID=4)
  input logic clk,
  input logic reset,
  input logic [RR_WID-1:0] req_i,
  output logic [RR_WID-1:0] gnt_o
);
  
  logic [RR_WID-1:0] mask_q;
  logic [RR_WID-1:0] nxt_msk;
  
  always_ff @(posedge clk or posedge reset) begin
    if(reset)
      mask_q<=0;
    else
      mask_q<=nxt_msk;
  end

 always_comb begin
    nxt_msk=mask_q;
    genvar i;
    for(i=0; i<RR_WID; i++) begin
      if(gnt_o[i]) nxt_msk={RR_WID{1'b1}} << i+1;
    end
  end

  logic [RR_WID-1:0] mask_req;
  logic [RR_WID-1:0] mask_gnt;
  assign mask_req=req_i & mask_q;
  
  pri_arbiter #(RR_WID) maskedgnt (.req_i(mask_req), .gnt_po(mask_gnt));
  pri_arbiter #(RR_WID) rawgnt (.req_i(req_i), .gnt_po(raw_gnt));
  
  logic [RR_WID-1:0] raw_gnt;
  assign gnt_o= |mask_req ? mask_gnt : raw_gnt;
  
endmodule

///priority arbiter////

module pri_arbiter #(parameter WID=4)
 (
   input logic [WID-1:0] req_i,
   output logic [WID-1:0] gnt_po
);
  
  assign gnt_po[0]=req_i[0];
  
  genvar i;
  for(i=1;i<WID;i=i+1) begin
    assign gnt_po[i]=req_i[i] & ~(|gnt_po[i-1:0]);
  end
  
endmodule

