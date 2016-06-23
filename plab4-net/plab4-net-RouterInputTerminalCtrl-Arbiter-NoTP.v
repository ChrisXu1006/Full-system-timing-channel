//========================================================================
// Router Input Terminal Ctrl Arbiter Without Timing Channel Protection
//========================================================================

`ifndef PLAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_ARBITER_NOTP_V
`define	PLAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_ARBITER_NOTP_V

`include "plab4-net-RouterInputTerminalCtrl-NoTP.v"

module plab4_net_RouterInputTerminalCtrl_Aribter_NOTP
#(
	parameter p_router_id				= 0,
	parameter p_num_routers				= 8,
	parameter p_num_free_nbits			= 2,

	parameter c_dest_nbits				= $clog2(p_num_routers)
)
(
	input	[c_dest_nbits-1:0]		dest_d0,
	input	[c_dest_nbits-1:0]		dest_d1,

	input							in_val_d0,
	input							in_val_d1,
	output							in_rdy_d0,
	output							in_rdy_d1,

	input	[p_num_free_nbits-1:0]	num_free_west_d0,
	input	[p_num_free_nbits-1:0]	num_free_west_d1,
	input	[p_num_free_nbits-1:0]	num_free_east_d0,
	input	[p_num_free_nbits-1:0]	num_free_east_d1,

	output	[2:0]					reqs,
	input	[2:0]					grants
);

	wire	[2:0]					reqs_d0;
	wire	[2:0]					reqs_d1;
	reg		[2:0]					reqs;
	reg		[2:0]					grants_d0;
	reg		[2:0]					grants_d1;

plab4_net_RouterInputTerminalCtrl_NOTP
  #(
	.p_router_id					(p_router_id),
	.p_num_routers					(p_num_routers),
	.p_num_free_nbits				(p_num_free_nbits),
	.domain							(1'b0)
  )
  in_ter_ctrl_d0
  (
	.dest							(dest_d0),
	.in_val							(in_val_d0),
	.in_rdy							(in_rdy_d0),
	.num_free_west					(num_free_west_d0),
	.num_free_east					(num_free_east_d0),
	.reqs							(reqs_d0),
	.grants							(grants_d0)
  );

  plab4_net_RouterInputTerminalCtrl_NOTP
  #(
	.p_router_id					(p_router_id),
	.p_num_routers					(p_num_routers),
	.p_num_free_nbits				(p_num_free_nbits),
	.domain							(1'b1)
  )
  in_ter_ctrl_d1
  (
	.dest							(dest_d1),
	.in_val							(in_val_d1),
	.in_rdy							(in_rdy_d1),
	.num_free_west					(num_free_west_d1),
	.num_free_east					(num_free_east_d1),
	.reqs							(reqs_d1),
	.grants							(grants_d1)
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

`endif /* PLAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_NOTP_V */

