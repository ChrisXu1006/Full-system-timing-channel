//========================================================================
// Router Output Ctrl With Timing Channel Protection Unit Tests
//========================================================================

`include "plab4-net-RouterOutputCtrl-TP.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab4-net-RouterOutputCtrl-TP" )
  
  //----------------------------------------------------------------------
  // Test output control with round robin arbitration
  //----------------------------------------------------------------------

  reg			t1_reset;
  reg  [2:0]	t1_reqs;
  wire [2:0]	t1_grants;

  wire			t1_out_val;
  reg			t1_out_rdy;
  wire [2:0]	t1_xbar_sel;

  plab4_net_RouterOutputCtrl_TP
  #(
    .domain		(0)
  )
  t1_output_ctrl
  (
	.clk		(clk),
	.reset		(t1_reset),

	.reqs		(t1_reqs),
	.grants		(t1_grants),

	.out_val	(t1_out_val),
	.out_rdy	(t1_out_rdy),
	.xbar_sel	(t1_xbar_sel)
  );

  //Helper task
  
  task t1
  (
	input [2:0]	reqs,
	input [2:0]	grants,

	input		out_val,
	input		out_rdy,
	input [2:0]	xbar_sel
  );
  begin
	t1_reqs		= reqs;
	t1_out_rdy	= out_rdy;
	#1;
	`VC_TEST_NOTE_INPUTS_2( reqs, out_rdy );
	`VC_TEST_NET( t1_grants, grants );
	`VC_TEST_NET( t1_out_val, out_val );
	`VC_TEST_NET( t1_xbar_sel, xbar_sel );
	#9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "basic test" )
  begin

	#1;		t1_reset = 1'b1;
	#20;	t1_reset = 1'b0;

	//  reqs    grants  val   rdy   sel
    t1( 3'b000, 3'b000, 1'b0, 1'b0, 3'h? );
    t1( 3'b100, 3'b000, 1'b?, 1'b0, 3'h? );
    t1( 3'b100, 3'b100, 1'b1, 1'b1, 3'h2 );
    t1( 3'b010, 3'b010, 1'b1, 1'b1, 3'h1 );
    t1( 3'b001, 3'b001, 1'b1, 1'b1, 3'h0 );
    t1( 3'b011, 3'b0??, 1'b1, 1'b1, 3'b0?);
    t1( 3'b011, 3'b0??, 1'b1, 1'b1, 3'b0?);
    t1( 3'b111, 3'b???, 1'b1, 1'b1, 3'h? );
    t1( 3'b101, 3'b000, 1'b?, 1'b0, 3'h? );
    t1( 3'b000, 3'b000, 1'b0, 1'b1, 3'h? );

	// this used for testing the situation
	// where the domain is 1
	/*//  reqs    grants  val   rdy   sel
    t1( 3'b000, 3'b000, 1'b0, 1'b0, 3'h? );
    t1( 3'b100, 3'b000, 1'b?, 1'b0, 3'h? );
    t1( 3'b100, 3'b100, 1'b1, 1'b1, 3'h5 );
    t1( 3'b010, 3'b010, 1'b1, 1'b1, 3'h4 );
    t1( 3'b001, 3'b001, 1'b1, 1'b1, 3'h3 );
    t1( 3'b011, 3'b0??, 1'b1, 1'b1, 3'b0?);
    t1( 3'b011, 3'b0??, 1'b1, 1'b1, 3'b0?);
    t1( 3'b111, 3'b???, 1'b1, 1'b1, 3'h? );
    t1( 3'b101, 3'b000, 1'b?, 1'b0, 3'h? );
    t1( 3'b000, 3'b000, 1'b0, 1'b1, 3'h? );*/

  end
  `VC_TEST_CASE_END


  `VC_TEST_SUITE_END
endmodule

