//========================================================================
// 1-Core Processor-Cache-Network
//========================================================================

`ifndef PLAB5_MCORE_PROC_CACHE_NET_BASE_V
`define PLAB5_MCORE_PROC_CACHE_NET_BASE_V

`include "vc-mem-msgs.v"
`include "plab2-proc-PipelinedProcBypass.v"
`include "plab3-mem-BlockingCacheAlt.v"

module plab5_mcore_ProcCacheNetBase
#(
  parameter p_icache_nbytes = 256,
  parameter p_dcache_nbytes = 256,

  // local params not meant to be set from outside

  parameter c_opaque_nbits = 8,
  parameter c_addr_nbits = 32,
  parameter c_data_nbits = 32,
  parameter c_cacheline_nbits = 128,

  parameter o = c_opaque_nbits,
  parameter a = c_addr_nbits,
  parameter d = c_data_nbits,
  parameter l = c_cacheline_nbits,

  parameter c_memreq_nbits  = `VC_MEM_REQ_MSG_NBITS(o,a,l),
  parameter c_memresp_nbits = `VC_MEM_RESP_MSG_NBITS(o,l)
)
(
  input clk,
  input reset,

  // proc0 manager ports

  input  [31:0] proc0_from_mngr_msg,
  input         proc0_from_mngr_val,
  output        proc0_from_mngr_rdy,

  output [31:0] proc0_to_mngr_msg,
  output        proc0_to_mngr_val,
  input         proc0_to_mngr_rdy,

  output  [c_memreq_nbits-1:0] memreq0_msg,
  output                       memreq0_val,
  input                        memreq0_rdy,

  input  [c_memresp_nbits-1:0] memresp0_msg,
  input                        memresp0_val,
  output                       memresp0_rdy,

  output  [c_memreq_nbits-1:0] memreq1_msg,
  output                       memreq1_val,
  input                        memreq1_rdy,

  input  [c_memresp_nbits-1:0] memresp1_msg,
  input                        memresp1_val,
  output                       memresp1_rdy,

  output                       stats_en
);

  //+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++
// 
//   // placeholder assignments, add processor-cache composition here
// 
//   assign proc0_from_mngr_rdy = 0;
//   assign proc0_to_mngr_msg   = 0;
//   assign proc0_to_mngr_val   = 0;
// 
//   assign memreq0_msg  = 0;
//   assign memreq0_val  = 0;
//   assign memresp0_rdy = 0;
// 
//   assign memreq1_msg  = 0;
//   assign memreq1_val  = 0;
//   assign memresp1_rdy = 0;
// 
//   assign stats_en     = 0;
// 
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  localparam c_cachereq_nbits  = `VC_MEM_REQ_MSG_NBITS(o,a,d);
  localparam c_cacheresp_nbits = `VC_MEM_RESP_MSG_NBITS(o,d);

  wire [c_cachereq_nbits-1:0]  icache0_req_msg;
  wire                         icache0_req_val;
  wire                         icache0_req_rdy;

  wire [c_cacheresp_nbits-1:0] icache0_resp_msg;
  wire                         icache0_resp_val;
  wire                         icache0_resp_rdy;

  wire [c_cachereq_nbits-1:0]  dcache0_req_msg;
  wire                         dcache0_req_val;
  wire                         dcache0_req_rdy;

  wire [c_cacheresp_nbits-1:0] dcache0_resp_msg;
  wire                         dcache0_resp_val;
  wire                         dcache0_resp_rdy;

  // processor

  plab2_proc_PipelinedProcBypass proc0
  (
    .clk           (clk),
    .reset         (reset),

    .imemreq_msg   (icache0_req_msg),
    .imemreq_val   (icache0_req_val),
    .imemreq_rdy   (icache0_req_rdy),

    .imemresp_msg  (icache0_resp_msg),
    .imemresp_val  (icache0_resp_val),
    .imemresp_rdy  (icache0_resp_rdy),

    .dmemreq_msg   (dcache0_req_msg),
    .dmemreq_val   (dcache0_req_val),
    .dmemreq_rdy   (dcache0_req_rdy),

    .dmemresp_msg  (dcache0_resp_msg),
    .dmemresp_val  (dcache0_resp_val),
    .dmemresp_rdy  (dcache0_resp_rdy),

    .from_mngr_msg (proc0_from_mngr_msg),
    .from_mngr_val (proc0_from_mngr_val),
    .from_mngr_rdy (proc0_from_mngr_rdy),

    .to_mngr_msg   (proc0_to_mngr_msg),
    .to_mngr_val   (proc0_to_mngr_val),
    .to_mngr_rdy   (proc0_to_mngr_rdy),

    .stats_en      (stats_en)
  );

  // instruction cache

  plab3_mem_BlockingCacheAlt
  #(
    .p_mem_nbytes   (p_icache_nbytes)
  )
  icache0
  (
    .clk           (clk),
    .reset         (reset),

    .cachereq_msg  (icache0_req_msg),
    .cachereq_val  (icache0_req_val),
    .cachereq_rdy  (icache0_req_rdy),

    .cacheresp_msg (icache0_resp_msg),
    .cacheresp_val (icache0_resp_val),
    .cacheresp_rdy (icache0_resp_rdy),

    .memreq_msg    (memreq0_msg),
    .memreq_val    (memreq0_val),
    .memreq_rdy    (memreq0_rdy),

    .memresp_msg   (memresp0_msg),
    .memresp_val   (memresp0_val),
    .memresp_rdy   (memresp0_rdy)

  );

  // data cache

  plab3_mem_BlockingCacheAlt
  #(
    .p_mem_nbytes   (p_dcache_nbytes)
  )
  dcache0
  (
    .clk           (clk),
    .reset         (reset),

    .cachereq_msg  (dcache0_req_msg),
    .cachereq_val  (dcache0_req_val),
    .cachereq_rdy  (dcache0_req_rdy),

    .cacheresp_msg (dcache0_resp_msg),
    .cacheresp_val (dcache0_resp_val),
    .cacheresp_rdy (dcache0_resp_rdy),

    .memreq_msg    (memreq1_msg),
    .memreq_val    (memreq1_val),
    .memreq_rdy    (memreq1_rdy),

    .memresp_msg   (memresp1_msg),
    .memresp_val   (memresp1_val),
    .memresp_rdy   (memresp1_rdy)

  );


  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    proc0.trace_module( trace );
    vc_trace_str( trace, "|" );
    icache0.trace_module( trace );
    dcache0.trace_module( trace );
  end
  endtask

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
// 
//   `include "vc-trace-tasks.v"
// 
//   task trace_module( inout [vc_trace_nbits-1:0] trace );
//   begin
//     // uncomment following for line tracing
// 
//     // proc0.trace_module( trace );
//     // vc_trace_str( trace, "|" );
//     // icache0.trace_module( trace );
//     // dcache0.trace_module( trace );
//   end
//   endtask
// 
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

endmodule

`endif /* PLAB5_MCORE_PROC_CACHE_NET_BASE_V */
