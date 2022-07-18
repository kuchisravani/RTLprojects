// Test Bench for parameterized priority arbiter. It works for both the arbiter designs.

module pri_arbiter_tb();
  
  localparam WID=8;
  logic [WID-1:0] req_i;
  logic [WID-1:0] gnt_o;
  
  pri_arbiter #(WID) dut (.*);
  
  initial begin
    for (int i=0;i<16;i=i+1) begin
      req_i=$urandom_range(0,4'hF);
      #5;
    end
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb.dut);
  end
  
endmodule
