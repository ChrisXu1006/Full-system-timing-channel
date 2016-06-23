//=========================================================================
// Simple Cache Control
//=========================================================================

`ifndef PLAB3_MEM_BLOCKING_CACHE_SIMPLE_CTRL_V
`define PLAB3_MEM_BLOCKING_CACHE_SIMPLE_CTRL_V

`include "vc-mem-msgs.v"

module plab3_mem_BlockingCacheSimpleCtrl
#(
  parameter size    = 256,            // Cache size in bytes

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw      // Number of blocks in the cache
)
(
  input                                         clk,
  input                                         reset,

  // Cache Request

  input                                         cachereq_val,
  output                                        cachereq_rdy,

  // Cache Response

  output                                        cacheresp_val,
  input                                         cacheresp_rdy,

  // Memory Request

  output                                        memreq_val,
  input                                         memreq_rdy,

  // Memory Response

  input                                         memresp_val,
  output                                        memresp_rdy
);

  // pass through the request and response signals in the null cache

  assign memreq_val    = cachereq_val;
  assign cachereq_rdy  = memreq_rdy;

  assign cacheresp_val = memresp_val;
  assign memresp_rdy   = cacheresp_rdy;

endmodule

`endif
