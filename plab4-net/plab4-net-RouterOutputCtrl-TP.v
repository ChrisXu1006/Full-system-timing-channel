//========================================================================
// Router Output Ctrl With Timing Channel Protection
//========================================================================

`ifndef PLAB4_NET_ROUTER_OUTPUT_CTRL_TP_V
`define	PLAB4_NET_ROUTER_OUTPUT_CTRL_TP_V

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "vc-arbiters.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

module plab4_net_RouterOutputCtrl_TP
#(
  // indicate which domain it belongs to
  parameter	domain		= 0
)
(
  input					clk,
  input					reset,

  input  [2:0]			reqs,
  output [2:0]			grants,

  output				out_val,
  input					out_rdy,
  output [2:0]			xbar_sel
);

  wire  [2:0]			arb_reqs;

  //----------------------------------------------------------------------
  // Round robin arbiter
  //----------------------------------------------------------------------

  vc_RoundRobinArb
  #(
    .p_num_reqs			(3)
  )
  arbiter
  (
	.clk				(clk),
	.reset				(reset),

	.reqs				(arb_reqs),
	.grants				(grants)
  );

  
  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  assign out_val = | grants;

  // we use reqs only if out_rdy is high

  assign arb_reqs = ( out_rdy ? reqs : 3'h0 );

  reg [2:0] xbar_sel;

  always @(*) begin
	if ( grants == 3'b001 ) begin
	  if ( domain == 1'b0 )
        xbar_sel = 3'h0;
	  else
		xbar_sel = 3'h3;
    end
	else if ( grants == 3'b010 ) begin
	  if ( domain == 1'b0 )
        xbar_sel = 3'h1;
      else
		xbar_sel = 3'h4;
	end
	else begin
	  if ( domain == 1'b0 )
        xbar_sel = 3'h2;
	  else
		xbar_sel = 3'h5;
	end
  end

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif /* PLAB4_NET_ROUTER_OUTPUT_CTRL_V */ 
