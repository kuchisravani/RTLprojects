module APB_SLV_tb();
  logic pclk_i;
  logic prst_n;
  logic psel_i;
  logic penable_i;
  logic pwrite_i;
  logic[7:0] paddr_i;
  logic[31:0]pwdata_i;
  logic[31:0]prdata_o;
  logic pready_o;
  
  logic [7:0]addr[9:0];
  APB_SLV dut(.*);
  
 always begin
   pclk_i=1'b1;
   #5 pclk_i=1'b0;
   #5;
 end
 
 initial begin
   prst_n<=1'b1;
   psel_i<=1'b0;
   penable_i<=1'b0;
   pwrite_i<=1'b0;
   paddr_i<=8'b0;
   @(posedge pclk_i);
   prst_n<=1'b0;
   
   //// write to address ////
   for(int i=0; i<10; i++) begin
     pwrite_i<=1'b1;
     psel_i<=1;
     penable_i<=1'b1;
     paddr_i<=$urandom_range(0,8'hFF);
     addr[i]<=paddr_i;
     pwdata_i<=$urandom_range(0,32'hFFFFFFFF);
     wait(psel_i & penable_i & pready_o) @(posedge pclk_i);  //wait untill pready_o is high in access state
     psel_i<=1'b0;
     penable_i<=1'b0;
     @(posedge pclk_i);
  end
   
   //// read from written address ////
   for(int i=0;i<10;i++)begin
     pwrite_i<=1'b0;
     psel_i<=1;
     penable_i<=1'b1;
     paddr_i<=addr[i];
     wait(psel_i & penable_i & pready_o) @(posedge pclk_i);  //wait untill pready_o is high in access state
     psel_i<=1'b0;
     penable_i<=1'b0;
     @(posedge pclk_i);
   end
   
   $finish;
 end

  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars(0,APB_SLV_tb.dut);
  end

endmodule
