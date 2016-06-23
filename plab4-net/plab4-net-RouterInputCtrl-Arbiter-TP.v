//========================================================================
// Router Input Ctrl Arbiter With Timing Channel Protection
//========================================================================

`ifndef PLAB4_NET_ROUTER_INPUT_CTRL_ARBITER_TP_V
`define	PLAB4_NET_ROUTER_INPUT_CTRL_ARBITER_TP_V

`include "plab4-net-RouterInputCtrl-TP.v"

module plab4_net_RouterInputCtrl_Arbiter_TP
#(
	parameter p_router_id			= 0,
	parameter p_num_routers			= 8,

	// indicates the reqs signal to pass through a message
	parameter p_default_reqs		= 3'b001,

	// parameter not meant to be set outside this module
	
	parameter c_dest_nbits			= $clog2 ( p_num_routers )
)
(
	input	[c_dest_nbits-1:0]		dest_d0,
	input	[c_dest_nbits-1:0]		dest_d1,

	input							in_val_d0,
	input							in_val_d1,
	output							in_rdy_d0,
	output							in_rdy_d1,

	output	[2:0]					reqs,
	input	[2:0]					grants,

	input							domain0,
	input							domain1
);

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------
	wire	[2:0]					reqs_d0;
	wire	[2:0]					reqs_d1;
	reg		[2:0]					reqs;
	//wire	[2:0]					grants_d0;
	//wire	[2:0]					grants_d1;

	plab4_net_RouterInputCtrl_TP
	#(
		.p_router_id				(p_router_id),
		.p_num_routers				(p_num_routers),
		.p_default_reqs				(p_default_reqs),
		.domain						(1'b0)
	)
	in_d0_ctrl
	(
		.dest						(dest_d0),
		.in_val						(in_val_d0),
		.in_rdy						(in_rdy_d0),
		.reqs						(reqs_d0),
		.grants						(grants),
		.domain0					(domain0),
		.domain1					(domain1)
	);

	plab4_net_RouterInputCtrl_TP
	#(
		.p_router_id				(p_router_id),
		.p_num_routers				(p_num_routers),
		.p_default_reqs				(p_default_reqs),
		.domain						(1'b1)
	)
	in_d1_ctrl
	(
		.dest						(dest_d1),
		.in_val						(in_val_d1),
		.in_rdy						(in_rdy_d1),
		.reqs						(reqs_d1),
		.grants						(grants),
		.domain0					(domain0),
		.domain1					(domain1)
	);

	always @(*) begin
		if ( domain0 == 1'b1 )
			reqs = reqs_d0;
		else if ( domain1 == 1'b1 )
			reqs = reqs_d1;
		else
			reqs = 3'b000;
	end

endmodule

`endif /* PLAB4_NET_ROUTER_INPUT_CTRL_ARBITER_V */
		
