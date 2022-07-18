//Parameterized priority arbiter with a define for LSB high priority or MSB high priority.

`define LSB_HPRI 0
module pri_arbiter2 #(parameter WID=4)
  (
    input logic [WID-1:0] req_i,
    output logic [WID-1:0] gnt_o
  );
  
  wire [WID-1:0] mask;
  
  `if LSB_HPRI
  
  assign mask[0]=1'b0;
  assign mask[WID-1:1]=mask[WID-2:0] | req_i[WID-2:0];
  assign gnt_o[WID-1:0]=req_i & ~mask;
  
  `else
  
  assign mask[WID-1]=1'b0;
  assign mask[WID-2:0]=mask[WID-1:1] | req_i[WID-1:1];
  assign gnt_o = req_i & ~mask;
   
  `endif
  
endmodule
