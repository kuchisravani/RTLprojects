
module APBM_tb();
  
  logic[1:0]  req_i;
  logic 	    pclk_i;
  logic       prst_n;
  logic[31:0] prdata_i;
  logic       pready_i;
  logic       psel_o;
  logic       penable_o;
  logic[31:0] paddr_o;
  logic       pwrite_o;
  logic[31:0] pwdata_o;
  
  APBM dut(.*);
  
  always begin 
    pclk_i=1;
    #5;
    pclk_i=0;
    #5;
  end
  
  int wait_cycles;
  always begin
    pready_i=1'b0;
    wait_cycles=$urandom_range(1, 10);
    while(wait_cycles) begin
      @(posedge pclk_i);
      wait_cycles--;
    end
    pready_i=1'b1;
    @(posedge pclk_i);
  end
  
  initial begin
    prst_n<=0;
    prdata_i<=0;
    @(posedge pclk_i);
    prst_n<=1;
    @(posedge pclk_i);
    for(int i=0; i<32; i++) begin
      prdata_i<=$urandom_range(0, 32'hFFFF);
      while(~pready_i | ~psel_o ) @(posedge pclk_i); // send next prdata only when it completes reading previous data and also it should be  
      @(posedge pclk_i);
     end
    $finish;
  end
  // Generates request signal //
  initial begin
    req_i<=2'b0;
    for(int i=0; i<32; i++) begin
      req_i<=$urandom_range(0,3);
      while(~pready_i) @(posedge pclk_i);      // wait for pready_i signal for next request to generate.
      @(posedge pclk_i);
     end
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,APBM_tb.dut);
  end
  
endmodule
