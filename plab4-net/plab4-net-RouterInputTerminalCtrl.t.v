//========================================================================
// Router Input Terminal Ctrl Unit Tests
//========================================================================

`include "plab4-net-RouterInputTerminalCtrl.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab4-net-RouterInputTerminalCtrl" )

  //----------------------------------------------------------------------
  // Test input control with greedy routing
  //----------------------------------------------------------------------

  reg  [2:0]  t1_dest;
  reg         t1_in_val;
  wire        t1_in_rdy;
  reg  [1:0]  t1_num_free_west;
  reg  [1:0]  t1_num_free_east;
  wire [2:0]  t1_reqs;
  reg  [2:0]  t1_grants;

  plab4_net_RouterInputTerminalCtrl
  #(
    .p_router_id      (2),
    .p_num_routers    (8),
    .p_num_free_nbits (2)
  )
  t1_input_term_ctrl
  (
    .dest       (t1_dest  ),
    .in_val     (t1_in_val),
    .in_rdy     (t1_in_rdy),
    .num_free_west  (t1_num_free_west),
    .num_free_east  (t1_num_free_east),
    .reqs       (t1_reqs  ),
    .grants     (t1_grants)
  );

  // Helper task

  task t1
  (
    input [2:0]  dest,
    input        in_val,
    input        in_rdy,
    input [1:0]  num_free_west,
    input [1:0]  num_free_east,
    input [2:0]  reqs,
    input [2:0]  grants
  );
  begin
    t1_dest          = dest;
    t1_in_val        = in_val;
    t1_num_free_west = num_free_west;
    t1_num_free_east = num_free_east;
    t1_grants        = grants;
    #1;
    `VC_TEST_NOTE_INPUTS_3( in_val, dest, grants );
    `VC_TEST_NOTE_INPUTS_2( num_free_west, num_free_east );
    `VC_TEST_NET( t1_in_rdy,  in_rdy );
    `VC_TEST_NET( t1_reqs, reqs );

  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "num_free = 2" )
  begin

    //  dest  val   rdy   fr_w  fr_e  reqs    grants
    t1( 3'hx, 1'b0, 1'b0, 2'h2, 2'h2, 3'b000, 3'bxxx );
    t1( 3'h1, 1'b1, 1'b0, 2'h2, 2'h2, 3'b001, 3'bxx0 );
    t1( 3'h1, 1'b1, 1'b1, 2'h2, 2'h2, 3'b001, 3'bxx1 );
    t1( 3'h3, 1'b1, 1'b1, 2'h2, 2'h2, 3'b100, 3'b1xx );
    t1( 3'h5, 1'b1, 1'b0, 2'h2, 2'h2, 3'b100, 3'b0xx );
    t1( 3'h2, 1'b0, 1'b0, 2'h2, 2'h2, 3'b000, 3'bx1x );
    t1( 3'h2, 1'b1, 1'b1, 2'h2, 2'h2, 3'b010, 3'bx1x );
    t1( 3'h2, 1'b1, 1'b0, 2'h2, 2'h2, 3'b010, 3'bx0x );
    t1( 3'h7, 1'b1, 1'b1, 2'h2, 2'h2, 3'b001, 3'bxx1 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN( 2, "num_free < 2" )
  begin

    //  dest  val   rdy   fr_w  fr_e  reqs    grants
    t1( 3'hx, 1'b0, 1'b0, 2'h2, 2'h2, 3'b000, 3'bxxx );
    t1( 3'h1, 1'b1, 1'b0, 2'h0, 2'h2, 3'b001, 3'bxx0 );
    t1( 3'h1, 1'b1, 1'b1, 2'h0, 2'h2, 3'b001, 3'bxx1 );
    t1( 3'h3, 1'b1, 1'b0, 2'h1, 2'h2, 3'b000, 3'bxxx );
    t1( 3'h5, 1'b1, 1'b0, 2'h0, 2'h2, 3'b000, 3'bxxx );
    t1( 3'h2, 1'b0, 1'b0, 2'h0, 2'h0, 3'b000, 3'bx1x );
    t1( 3'h2, 1'b1, 1'b1, 2'h0, 2'h0, 3'b010, 3'bx1x );
    t1( 3'h2, 1'b1, 1'b0, 2'h0, 2'h0, 3'b010, 3'bx0x );
    t1( 3'h7, 1'b1, 1'b0, 2'h2, 2'h1, 3'b000, 3'bxxx );
    t1( 3'h1, 1'b1, 1'b0, 2'h2, 2'h1, 3'b000, 3'bxxx );
    t1( 3'h1, 1'b1, 1'b0, 2'h2, 2'h0, 3'b000, 3'bxxx );

  end
  `VC_TEST_CASE_END


  `VC_TEST_SUITE_END
endmodule


