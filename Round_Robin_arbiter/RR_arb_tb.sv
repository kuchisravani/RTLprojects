// Parameterized Round Robin arbiter TB.

module RR_arb_tb();
 
  localparam RWID=4;
  logic clk;
  logic reset;
  logic [RWID-1:0] req_i;
  logic [RWID-1:0] gnt_o;
  
  RR_arb #(RWID) dut(.*);
  
  always begin
    clk=1'b1;
    #5;
    clk=1'b0;
    #5;
  end
  
  initial begin
    reset<=1'b1;
    req_i<='h0;
    @(posedge clk);
    reset<=1'b0;
    for(int i=0; i<32; i++) begin
      req_i<=$urandom_range(0,{RWID{'hF}});
      @(posedge clk);
    end
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,RR_tb);
  end
  
endmodule
