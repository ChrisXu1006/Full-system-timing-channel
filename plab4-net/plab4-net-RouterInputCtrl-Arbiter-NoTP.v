//========================================================================
// Router Input Ctrl Arbiter
//========================================================================

`ifndef PLAB4_NET_ROUTER_INPUT_CTRL_ARBITER_NOTP_V
`define	PLAB4_NET_ROUTER_INPUT_CTRL_ARBITER_NOTP_V

`include "plab4-net-RouterInputCtrl-NoTP.v"

module plab4_net_RouterInputCtrl_Arbiter_NOTP
#(
	parameter p_router_id			= 0,
	parameter p_num_routers			= 8,

	parameter p_default_reqs		= 3'b001,

	parameter c_dest_nbits			= $clog2(p_num_routers)
)
(
	input	[c_dest_nbits-1:0]		dest_d0,
	input	[c_dest_nbits-1:0]		dest_d1,

	input							in_val_d0,
	input							in_val_d1,
	output							in_rdy_d0,
	output							in_rdy_d1,

	output	[2:0]					reqs,
	input	[2:0]					grants

);

	wire	[2:0]					reqs_d0;
	wire	[2:0]					reqs_d1;
	reg		[2:0]					reqs;
	reg		[2:0]					grants_d0;
	reg		[2:0]					grants_d1;

	plab4_net_RouterInputCtrl_NOTP
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
		.grants						(grants_d0)
	);

	plab4_net_RouterInputCtrl_NOTP
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
		.grants						(grants_d1)
	);

	always @(*) begin
		if ( reqs_d0 != 3'b000 ) begin
			reqs = reqs_d0;
			grants_d0 = grants;
			grants_d1 = 3'b000;
		end
		else begin
			reqs = reqs_d1;
			grants_d0 = 3'b000;
			grants_d1 = grants;
		end
	end

endmodule

`endif /* PLAB4_NET_ROUTER_INPUT_CTRL_ARBITER_NOTP_V */
