// Parameterised Priority arbiter with LSB has highest priority

module pri_arbiter #(parameter WID=4)
 (
   input logic [WID-1:0] req_i,
   output logic [WID-1:0] gnt_o
);
  
  assign gnt_o[0]=req_i[0];
  
  genvar i;
  for(i=1;i<WID;i=i+1) begin
    assign gnt_o[i]=req_i[i] & ~(|gnt_o[i-1:0]);
  end
  
endmodule
