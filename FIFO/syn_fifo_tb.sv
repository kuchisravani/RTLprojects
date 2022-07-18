//synchronous fifo test bench

module syn_fifo_tb();
  
  localparam DEP=8;
  localparam WID=32;
  
  logic clk;
  logic rst;
  logic wr_i;
  logic rd_i;
  logic [WID-1:0] wdata;
  logic [WID-1:0] rdata;
  logic overflow_o;
  logic empty_o;
  
  syn_fifo #(DEP, WID) dut (.*);
  
  always begin
    clk=1'b1;
    #5 clk=1'b0;
    #5;
  end
  
  initial begin
    rst<=1'b0;
    wr_i<=0;
    rd_i<=0;
    wdata<=0;
    @(posedge clk);
    rst<=1'b1;
    @(posedge clk);
    for(int i=0;i<32; i++) begin
      wr_i<=$urandom_range(0,1);
      rd_i<=$urandom_range(0,1);
      if(wr_i)                    /// write data in next cycle if wr_i signal is high, dont write if wr_i is not enabled.
        wdata<=$urandom_range(0,{WID{1'b1}});
      @(posedge clk);
    end
    $finish;
  end
initial begin
  #40 rst=1'b0;
  #10 rst=1'b1;
end
  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
