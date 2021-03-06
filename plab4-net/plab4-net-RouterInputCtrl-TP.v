//========================================================================
// Router Input Ctrl
//========================================================================

`ifndef PLAB4_NET_ROUTER_INPUT_CTRL_TP_V
`define PLAB4_NET_ROUTER_INPUT_CTRL_TP_V

module plab4_net_RouterInputCtrl_TP
#(
  parameter	p_router_id		= 0,
  parameter p_num_routers	= 8,

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  // indicates the reqs signal to pass through a message
  parameter	p_default_reqs	= 3'b001,

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  // parameter not meant to be set outside this module

  parameter c_dest_nbits	= $clog2( p_num_routers ),

  // indicates the domain belongs to
  parameter domain			= 0

)
(
  input  [c_dest_nbits-1:0]				dest,

  input									in_val,
  output								in_rdy,

  output [2:0]							reqs,
  input	 [2:0]							grants,

  input									domain0,
  input									domain1
);

 //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
// 
//   // add logic here
// 
//   assign in_rdy = 0;
//   assign reqs = 0;
// 
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  // rdy is just a reductive OR of the AND of reqs and grants
  
  reg [2:0]				reqs;
  reg					in_rdy_me;
  reg					in_rdy;

  always @(*) begin
    if (in_val && ( ( domain == 1'b0 && domain0 == 1'b1)|| ( domain == 1'b1 && domain1 == 1'b1) )) begin

      // if the packet is for this port, redirect it to the terminal
      if ( dest == p_router_id )
        reqs = 3'b010;

      // otherwise, we just pass through it
      else
        reqs = p_default_reqs;

    end else begin
      // if !val, we don't request any output ports
      reqs = 3'b000;
    end
  end

  always @(*) begin
    
	// if the control unit belongs to domain 0
	if ( domain == 1'b0 ) begin
	  in_rdy_me = | (reqs & grants);
	  in_rdy = in_rdy_me & domain0;
	end
	else begin
	  in_rdy_me = | (reqs & grants);
	  in_rdy = in_rdy_me & domain1;
	end
  end
 
  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif  /* PLAB4_NET_ROUTER_INPUT_CTRL_TP_V */





