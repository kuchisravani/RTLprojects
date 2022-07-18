// APB Master reading from address DEAD_CAFE at every posedge clock, writing to the same address the value of previous read + 1.


  module APBM(
  input  wire[1:0]  req_i,     /// req_i[1] indicates read/write 
  input  wire 		  pclk_i,
  input  wire  		  prst_n,
  input  wire[31:0] prdata_i,
  input  wire       pready_i,
  output wire 		  psel_o,
  output wire 		  penable_o,
  output wire[31:0] paddr_o,
  output wire		    pwrite_o,
  output wire[31:0] pwdata_o
  
);
    
  logic [31:0] rddata_q;
  logic [31:0] wrdata_q;
  typedef enum logic [1:0] {ST_IDLE=2'b00, ST_SETUP=2'b01, ST_ACC=2'b10} apb_state_t;
                     
apb_state_t state_q;
apb_state_t nxt_st;
 
  always_ff @(posedge pclk_i or negedge prst_n) begin
    if(!prst_n)
      state_q<=ST_IDLE;
    else
      state_q<=nxt_st;
  end
  
  always_comb begin
    nxt_st=state_q;
  case(state_q) 
    ST_IDLE : if(|req_i) nxt_st=ST_SETUP; else nxt_st=ST_IDLE;
    ST_SETUP: nxt_st=ST_ACC;
    ST_ACC  : if(|req_i && pready_i) nxt_st=ST_SETUP; else if(pready_i) nxt_st=ST_IDLE; else nxt_st=ST_ACC;
    default : nxt_st=ST_IDLE;
  endcase
  end
  
  assign psel_o   = (state_q==ST_SETUP) | (state_q==ST_ACC);  
  assign penable_o= (state_q==ST_ACC);
  assign pwrite_o = req_i[1];
  assign paddr_o  = 32'hDEAD_CAFE;
  assign pwdata_o = rddata_q + 32'h1;                            // stored read data + 1   
  assign wrdata_q = (penable_o && pwrite_o) ? pwdata_o : 32'h0;  // wrdata_q is wire to check whether write data is happening properly or not.

    always_ff @(posedge pclk_i or negedge prst_n) begin
      if(!prst_n)
        rddata_q<=0;
      else if( ~pwrite_o & penable_o)
        rddata_q<=prdata_i;                                    // store the read data for later use write data.   
    end
    
endmodule    
