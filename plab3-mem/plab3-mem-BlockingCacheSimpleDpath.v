//=========================================================================
// Simple Cache Datapath
//=========================================================================

`ifndef PLAB3_MEM_BLOCKING_CACHE_SIMPLE_DPATH_V
`define PLAB3_MEM_BLOCKING_CACHE_SIMPLE_DPATH_V

`include "vc-mem-msgs.v"

module plab3_mem_BlockingCacheSimpleDpath
#(
  parameter size    = 256,            // Cache size in bytes

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw,     // Number of blocks in the cache
  parameter idw     = $clog2(nblocks) // Short name for index width
)
(
  input                                         clk,
  input                                         reset,

  // Cache Request

  input [`VC_MEM_REQ_MSG_NBITS(8,abw,dbw)-1:0]  cachereq_msg,

  // Cache Response

  output [`VC_MEM_RESP_MSG_NBITS(8,dbw)-1:0]    cacheresp_msg,

  // Memory Request

  output [`VC_MEM_REQ_MSG_NBITS(8,abw,clw)-1:0] memreq_msg,

  // Memory Response

  input [`VC_MEM_RESP_MSG_NBITS(8,clw)-1:0]     memresp_msg

);

  //----------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------

  // cache request

  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(8,abw,dbw)-1:0]   cachereq_type;
  wire [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,abw,dbw)-1:0] cachereq_opaque;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(8,abw,dbw)-1:0]   cachereq_addr;
  wire [`VC_MEM_REQ_MSG_LEN_NBITS(8,abw,dbw)-1:0]    cachereq_len;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(8,abw,dbw)-1:0]   cachereq_data;

  // memory response

  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(8,clw)-1:0]      memresp_type;
  wire [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,clw)-1:0]    memresp_opaque;
  wire [`VC_MEM_RESP_MSG_LEN_NBITS(8,clw)-1:0]       memresp_len;
  wire [`VC_MEM_RESP_MSG_DATA_NBITS(8,clw)-1:0]      memresp_data;

  // memory request

  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(8,abw,clw)-1:0]   memreq_type;
  wire [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,abw,clw)-1:0] memreq_opaque;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(8,abw,clw)-1:0]   memreq_addr;
  wire [`VC_MEM_REQ_MSG_LEN_NBITS(8,abw,clw)-1:0]    memreq_len;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(8,abw,clw)-1:0]   memreq_data;

  // cache response

  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(8,dbw)-1:0]      cacheresp_type;
  wire [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,dbw)-1:0]    cacheresp_opaque;
  wire [`VC_MEM_RESP_MSG_LEN_NBITS(8,dbw)-1:0]       cacheresp_len;
  wire [`VC_MEM_RESP_MSG_DATA_NBITS(8,dbw)-1:0]      cacheresp_data;

  //----------------------------------------------------------------------
  // Unpack
  //----------------------------------------------------------------------

  // Unpack cache request

  vc_MemReqMsgUnpack#(8,abw,dbw) cachereq_msg_unpack
  (
    // input

    .msg    (cachereq_msg),

    // outputs

    .type   (cachereq_type),
    .opaque (cachereq_opaque),
    .addr   (cachereq_addr),
    .len    (cachereq_len),
    .data   (cachereq_data)
  );

  // Unpack memory response

  vc_MemRespMsgUnpack#(8,clw) memresp_msg_unpack
  (
    // input

    .msg    (memresp_msg),

    // outputs

    .type   (memresp_type),
    .opaque (memresp_opaque),
    .len    (memresp_len),
    .data   (memresp_data)
  );

  //----------------------------------------------------------------------
  // Datapath logic
  //----------------------------------------------------------------------

  // null cache behavior: pass the transaction to the main memory

  assign memreq_type      = cachereq_type;
  assign memreq_opaque    = cachereq_opaque;
  assign memreq_addr      = cachereq_addr;
  assign memreq_len       = cachereq_len == 0 ? 3'b100 : cachereq_len;
  assign memreq_data      = cachereq_data;

  assign cacheresp_type   = memresp_type;
  assign cacheresp_opaque = memresp_opaque;
  assign cacheresp_len    = memresp_len;
  assign cacheresp_data   = memresp_data;

  //----------------------------------------------------------------------
  // Unpack
  //----------------------------------------------------------------------

  // Pack cache response

  vc_MemRespMsgPack#(8,dbw) cacheresp_msg_pack
  (
    // inputs

    .type   (cacheresp_type),
    .opaque (cacheresp_opaque),
    .len    (cacheresp_len),
    .data   (cacheresp_data),

    // output

    .msg    (cacheresp_msg)
  );

  // Pack memory request

  vc_MemReqMsgPack#(8,abw,clw) memreq_msg_pack
  (
    // inputs

    .type   (memreq_type),
    .opaque (memreq_opaque),
    .addr   (memreq_addr),
    .len    (memreq_len),
    .data   (memreq_data),

    // output

    .msg    (memreq_msg)
  );

endmodule

`endif
