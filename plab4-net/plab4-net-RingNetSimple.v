//========================================================================
// plab4-net-RingNetSimple
//========================================================================
// This is a wrapper around the functional test network in the vc library

`ifndef PLAB4_NET_RING_NET_SIMPLE
`define PLAB4_NET_RING_NET_SIMPLE

`include "vc-TestNet.v"
`include "vc-net-msgs.v"
`include "vc-param-utils.v"

module plab4_net_RingNetSimple
#(
  parameter p_payload_nbits  = 32,
  parameter p_opaque_nbits   = 3,
  parameter p_srcdest_nbits  = 3,

  // Shorter names, not to be set from outside the module
  parameter p = p_payload_nbits,
  parameter o = p_opaque_nbits,
  parameter s = p_srcdest_nbits,

  parameter c_num_ports = 8,
  parameter c_net_msg_nbits = `VC_NET_MSG_NBITS(p,o,s)
)
(
  input clk,
  input reset,

  input  [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0]               in_val,
  output [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0]               in_rdy,
  input  [`VC_PORT_PICK_NBITS(c_net_msg_nbits,c_num_ports)-1:0] in_msg,


  output [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0]               out_val,
  input  [`VC_PORT_PICK_NBITS(1,c_num_ports)-1:0]               out_rdy,
  output [`VC_PORT_PICK_NBITS(c_net_msg_nbits,c_num_ports)-1:0] out_msg
);

  vc_TestNet
  #(
    .p_num_ports      (c_num_ports    ),
    .p_queue_num_msgs (2              ),
    .p_payload_nbits  (p_payload_nbits),
    .p_opaque_nbits   (p_opaque_nbits ),
    .p_srcdest_nbits  (p_srcdest_nbits)
  )
  test_net
  (
    .clk      (clk     ),
    .reset    (reset   ),

    .in_val   (in_val  ),
    .in_rdy   (in_rdy  ),
    .in_msg   (in_msg  ),

    .out_val  (out_val ),
    .out_rdy  (out_rdy ),
    .out_msg  (out_msg )
  );

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    test_net.trace_module( trace );
  end
  endtask

endmodule

`endif /* PLAB4_NET_RING_NET_SIMPLE */
