//synchronous fifo test bench
module syn_fifo_tb();
  
  localparam DEP=4;
  localparam WID=8;
  
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
    
    //both read and write
    for(int i=0;i<10; i++) begin
      wr_i<=1;
      rd_i<=1;             
      wdata<=$urandom_range(0,{WID{1'b1}});
      @(posedge clk);
    end
    rd_i<=0;

    //only write
    for(int i=0;i<10; i++) begin
      wr_i<=1'b1;
      wdata<=$urandom_range(0,{WID{1'b1}});
      @(posedge clk);
    end
    wr_i<=0;

    //only read
    for(int i=0;i<10; i++) begin
      rd_i<=1'b1;
      @(posedge clk);
    end
    
    $finish;
  end

  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
