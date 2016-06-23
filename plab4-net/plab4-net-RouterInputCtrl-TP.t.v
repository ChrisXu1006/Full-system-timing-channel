//========================================================================
// Router Input Ctrl With Timing Protection Unit Tests
//========================================================================

`include "plab4-net-RouterInputCtrl-TP.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab4-net-RouterInputCtrl-TP" )

  //----------------------------------------------------------------------
  // Test input control with pass through routing
  //----------------------------------------------------------------------

  reg  [2:0]			t1_dest;
  reg					t1_in_val;
  wire					t1_in_rdy;
  wire [2:0]			t1_reqs;
  reg  [2:0]			t1_grants;
  reg					t1_domain0;
  reg					t1_domain1;

  plab4_net_RouterInputCtrl_TP
  #(
    .p_router_id		(2),
	//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++
    .p_default_reqs		(3'b001),
    //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++
    .p_num_routers		(8),
	.domain				(0)
  )
  t1_input_ctrl_TP
  (
	.dest				(t1_dest),
	.in_val				(t1_in_val),
	.in_rdy				(t1_in_rdy),
	.reqs				(t1_reqs),
	.grants				(t1_grants),
	.domain0			(t1_domain0),
	.domain1			(t1_domain1)
  );

  // Helper task

  task t1
  (
	input [2:0]			dest,
	input				in_val,
	input				in_rdy,
	input [2:0]			reqs,
	input [2:0]			grants,
	input				domain0,
	input				domain1
  );
  begin
	t1_dest		= dest;
	t1_in_val	= in_val;
	t1_grants	= grants;
	t1_domain0	= domain0;
	t1_domain1	= domain1;
	#1;
	`VC_TEST_NOTE_INPUTS_3( in_val, dest, grants );
	`VC_TEST_NOTE_INPUTS_2( domain0, domain1 );
	`VC_TEST_NET( t1_in_rdy, in_rdy );
	`VC_TEST_NET( t1_reqs, reqs );

  end
  endtask

  // Test case
  //
  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++ 

  `VC_TEST_CASE_BEGIN( 1, "pass through routing" )
  begin

	//  dest	val		rdy		reqs	grants	domain0	domain1
	t1( 3'hx,	1'b0,	1'b0,	3'b000,	3'bxxx, 1'bx,	1'bx	);
	t1( 3'h1,	1'b1,	1'b0,	3'b001,	3'bxx0, 1'b1,	1'b0	);
	t1( 3'h1,	1'b1,	1'b1,	3'b001, 3'bxx1,	1'b1,	1'b0	);
	t1(	3'h1,	1'b1,	1'b0,	3'b001,	3'bxx1,	1'b0,	1'b1	);
	t1(	3'h3,	1'b1,	1'b1,	3'b001, 3'bxx1, 1'b1,	1'b0	);
	t1(	3'h3,	1'b1,	1'b0,	3'b001, 3'bxx1, 1'b0,	1'b1	);
	t1( 3'h5,	1'b1,	1'b0,	3'b001,	3'bxx0,	1'b1,	1'b0	);
	t1(	3'h2,	1'b0,	1'b0,	3'b000,	3'bx1x,	1'b1,	1'b0	);
	t1(	3'h2,	1'b1,	1'b1,	3'b010,	3'bx1x,	1'b1,	1'b0	);
	t1(	3'h2,	1'b1,	1'b0,	3'b010,	3'bx0x,	1'b1,	1'b0	);
	t1( 3'h2,	1'b1,	1'b0,	3'b010,	3'bx1x, 1'b0,	1'b1	);
	t1(	3'h7,	1'b1,	1'b1,	3'b001,	3'bxx1,	1'b1,	1'b0	);
	t1( 3'h7,	1'b1,	1'b0,	3'b001,	3'bxx1,	1'b0,	1'b1	);

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule
