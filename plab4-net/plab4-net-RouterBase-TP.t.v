//========================================================================
// Test Harness for plab4-net-RouterBase-TP
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelayUnorderedSink.v"
`include "vc-test.v"
`include "vc-net-msgs.v"
`include "plab4-net-RouterBase-TP.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness_TP
#(
  parameter	p_payload_nbits		= 8,
  parameter p_opaque_nbits		= 8,
  parameter p_srcdest_nbits		= 2
)
(
  input							clk,
  input							reset,

  input	 [31:0]					src_max_delay,
  input	 [31:0]					sink_max_delay,
  output [31:0]					num_failed,
  output						done
);

  // Local parameters

  localparam c_num_routers		= 8;
  localparam c_router_id		= 2;
  localparam c_net_msg_nbits	= `VC_NET_MSG_NBITS(p,o,s);

  // shorter names

  localparam p					= p_payload_nbits;
  localparam o					= p_opaque_nbits;
  localparam s					= p_srcdest_nbits;

  //----------------------------------------------------------------------
  // Test sources
  //----------------------------------------------------------------------
 
  wire							src0_val_d0;
  wire							src0_rdy_d0;
  wire [c_net_msg_nbits-1:0]	src0_msg_d0;
  wire							src0_done_d0;

  wire							src_ter_val_d0;
  wire							src_ter_rdy_d0;
  wire [c_net_msg_nbits-1:0]	src_ter_msg_d0;
  wire							src_ter_done_d0;
  
  wire							src1_val_d0;
  wire							src1_rdy_d0;
  wire [c_net_msg_nbits-1:0]	src1_msg_d0;
  wire							src1_done_d0;

  wire							src0_val_d1;
  wire							src0_rdy_d1;
  wire [c_net_msg_nbits-1:0]	src0_msg_d1;
  wire							src0_done_d1;

  wire							src_ter_val_d1;
  wire							src_ter_rdy_d1;
  wire [c_net_msg_nbits-1:0]	src_ter_msg_d1;
  wire							src_ter_done_d1;

  wire							src1_val_d1;
  wire							src1_rdy_d1;
  wire [c_net_msg_nbits-1:0]	src1_msg_d1;
  wire							src1_done_d1;

  vc_TestRandDelaySource#(c_net_msg_nbits) src0_d0
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(src_max_delay),
	.val						(src0_val_d0),
	.rdy						(src0_rdy_d0),
	.msg						(src0_msg_d0),
	.done						(src0_done_d0)
  );

  vc_TestRandDelaySource#(c_net_msg_nbits) src_ter_d0
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(src_max_delay),
	.val						(src_ter_val_d0),
	.rdy						(src_ter_rdy_d0),
	.msg						(src_ter_msg_d0),
	.done						(src_ter_done_d0)
  );

  vc_TestRandDelaySource#(c_net_msg_nbits) src1_d0
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(src_max_delay),
	.val						(src1_val_d0),
	.rdy						(src1_rdy_d0),
	.msg						(src1_msg_d0),
	.done						(src1_done_d0)
  );

  vc_TestRandDelaySource#(c_net_msg_nbits) src0_d1
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(src_max_delay),
	.val						(src0_val_d1),
	.rdy						(src0_rdy_d1),
	.msg						(src0_msg_d1),
	.done						(src0_done_d1)
  );

  vc_TestRandDelaySource#(c_net_msg_nbits) src_ter_d1
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(src_max_delay),
	.val						(src_ter_val_d1),
	.rdy						(src_ter_rdy_d1),
	.msg						(src_ter_msg_d1),
	.done						(src_ter_done_d1)
  );

  vc_TestRandDelaySource#(c_net_msg_nbits) src1_d1
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(src_max_delay),
	.val						(src1_val_d1),
	.rdy						(src1_rdy_d1),
	.msg						(src1_msg_d1),
	.done						(src1_done_d1)
  );

  //----------------------------------------------------------------------
  // Router under test
  //----------------------------------------------------------------------

  wire							sink0_val;
  wire							sink0_rdy;
  wire [c_net_msg_nbits-1:0]	sink0_msg;

  wire							sink_ter_val;
  wire							sink_ter_rdy;
  wire [c_net_msg_nbits-1:0]	sink_ter_msg;

  wire							sink1_val;
  wire							sink1_rdy;
  wire [c_net_msg_nbits-1:0]	sink1_msg;

  reg							domain0;
  reg							domain1;

  plab4_net_RouterBase_TP
  #(
	.p_payload_nbits			(p_payload_nbits),
	.p_opaque_nbits				(p_opaque_nbits),
	.p_srcdest_nbits			(p_srcdest_nbits),

	.p_router_id				(c_router_id),
	.p_num_routers				(c_num_routers)
  )
  router_TP
  (
	.clk						(clk),
	.reset						(reset),

	.domain0					(domain0),
	.domain1					(domain1),

	.in0_val_d0					(src0_val_d0),
	.in0_rdy_d0					(src0_rdy_d0),
	.in0_msg_d0					(src0_msg_d0),

	.in_val_ter_d0				(src_ter_val_d0),
	.in_rdy_ter_d0				(src_ter_rdy_d0),
	.in_msg_ter_d0				(src_ter_msg_d0),

	.in1_val_d0					(src1_val_d0),
	.in1_rdy_d0					(src1_rdy_d0),
	.in1_msg_d0					(src1_msg_d0),

	.in0_val_d1					(src0_val_d1),
	.in0_rdy_d1					(src0_rdy_d1),
	.in0_msg_d1					(src0_msg_d1),

	.in_val_ter_d1				(src_ter_val_d1),
	.in_rdy_ter_d1				(src_ter_rdy_d1),
	.in_msg_ter_d1				(src_ter_msg_d1),

	.in1_val_d1					(src1_val_d1),
	.in1_rdy_d1					(src1_rdy_d1),
	.in1_msg_d1					(src1_msg_d1),

	.out0_val					(sink0_val),
	.out0_rdy					(sink0_rdy),
	.out0_msg					(sink0_msg),

	.out_val_ter				(sink_ter_val),
	.out_rdy_ter				(sink_ter_rdy),
	.out_msg_ter				(sink_ter_msg),
	
	.out1_val					(sink1_val),
	.out1_rdy					(sink1_rdy),
	.out1_msg					(sink1_msg)

  );

	
  //----------------------------------------------------------------------
  // Test sinks
  //----------------------------------------------------------------------

  wire	[31:0]					sink0_num_failed;
  wire	[31:0]					sink_ter_num_failed;
  wire	[31:0]					sink1_num_failed;

  wire							sink0_done;
  wire							sink_ter_done;
  wire							sink1_done;

  // We use unordered sinks because the message can come out of order
  
   vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink0
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(sink_max_delay),
	.val						(sink0_val),
	.rdy						(sink0_rdy),
	.msg						(sink0_msg),
	.num_failed					(sink0_num_failed),
	.done						(sink0_done)
  );

  vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink_ter
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(sink_max_delay),
	.val						(sink_ter_val),
	.rdy						(sink_ter_rdy),
	.msg						(sink_ter_msg),
	.num_failed					(sink_ter_num_failed),
	.done						(sink_ter_done)
  );

  vc_TestRandDelayUnorderedSink#(c_net_msg_nbits) sink1
  (
	.clk						(clk),
	.reset						(reset),
	.max_delay					(sink_max_delay),
	.val						(sink1_val),
	.rdy						(sink1_rdy),
	.msg						(sink1_msg),
	.num_failed					(sink1_num_failed),
	.done						(sink1_done)
  );

  // Done when all of sources and sinks are done

  assign done = src0_done_d0  && src_ter_done_d0  && src1_done_d0  &&
				src0_done_d1  && src_ter_done_d1  && src1_done_d1  &&
				sink0_done && sink_ter_done && sink1_done;
  // Num failed is the sum of all sinks

  assign num_failed = sink0_num_failed + sink_ter_num_failed + sink1_num_failed;

 
  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"
  reg [4*8-1:0]	src0_d0_str;
  reg [4*8-1:0]	src_ter_d0_str;
  reg [4*8-1:0]	src1_d0_str;
  reg [4*8-1:0] src0_d1_str;
  reg [4*8-1:0] src_ter_d1_str;
  reg [4*8-1:0]	src1_d1_str;
  
  reg [4*8-1:0]	sink0_str;
  reg [4*8-1:0]	sink_ter_str;
  reg [4*8-1:0]	sink1_str;

  task trace_module ( inout [vc_trace_nbits-1:0] trace );
  begin

	$sformat ( src0_d0_str, "%x>%x",
			   src0_msg_d0[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)],
			   src0_msg_d0[`VC_NET_MSG_DEST_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, src0_val_d0, src0_rdy_d0, src0_d0_str );

	vc_trace_str( trace, "|" );

	
	$sformat ( src_ter_d0_str, "%x>%x",
			   src_ter_msg_d0[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)],
			   src_ter_msg_d0[`VC_NET_MSG_DEST_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, src_ter_val_d0, src_ter_rdy_d0, src_ter_d0_str );

	vc_trace_str( trace, "|" );

	$sformat ( src1_d0_str, "%x>%x",
			   src1_msg_d0[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)],
			   src1_msg_d0[`VC_NET_MSG_DEST_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, src1_val_d0, src1_rdy_d0, src1_d0_str );

	vc_trace_str( trace, "|" );

	$sformat ( src0_d1_str, "%x>%x",
			   src0_msg_d1[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)],
			   src0_msg_d1[`VC_NET_MSG_DEST_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, src0_val_d1, src0_rdy_d1, src0_d1_str );

	vc_trace_str( trace, "|" );

	
	$sformat ( src_ter_d1_str, "%x>%x",
			   src_ter_msg_d1[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)],
			   src_ter_msg_d1[`VC_NET_MSG_DEST_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, src_ter_val_d1, src_ter_rdy_d1, src_ter_d1_str );

	vc_trace_str( trace, "|" );

	$sformat ( src1_d1_str, "%x>%x",
			   src1_msg_d1[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)],
			   src1_msg_d1[`VC_NET_MSG_DEST_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, src1_val_d1, src1_rdy_d1, src1_d1_str );

	vc_trace_str( trace, "|" );

	vc_trace_str( trace, " < " );

	vc_trace_str( trace, " > " );

	$sformat ( sink0_str, "%x>%x",
			   sink0_msg[`VC_NET_MSG_SRC_FIELD(p, o, s)],
			   sink0_msg[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, sink0_val, sink0_rdy, sink0_str );

	vc_trace_str( trace, "|" );

	$sformat ( sink_ter_str, "%x>%x",
			   sink_ter_msg[`VC_NET_MSG_SRC_FIELD(p, o, s)],
			   sink_ter_msg[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, sink_ter_val, sink_ter_rdy, sink_ter_str );

	vc_trace_str( trace, "|" );

	$sformat ( sink1_str, "%x>%x",
			   sink1_msg[`VC_NET_MSG_SRC_FIELD(p, o, s)],
			   sink1_msg[`VC_NET_MSG_OPAQUE_FIELD(p, o, s)] );
	vc_trace_str_val_rdy( trace, sink1_val, sink1_rdy, sink1_str );

	vc_trace_str( trace, "|" );

  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "plab4-net-RouterBase-TP" )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Local parameters

  localparam p_num_ports		= 8;

  localparam c_payload_nbits	= 8;
  localparam c_opaque_nbits		= 8;
  localparam c_srcdest_nbits	= 3;

  // shorter names
  
  localparam p = c_payload_nbits;
  localparam o = c_opaque_nbits;
  localparam s = c_srcdest_nbits;

  localparam c_net_msg_nbits	= `VC_NET_MSG_NBITS(p,o,s);

  reg		  th_reset			= 1;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire		  th_done;

  reg  [10:0] th_src_index		[5:0];
  reg  [10:0] th_sink_index		[2:0];

  TestHarness_TP
  #(
	.p_payload_nbits			(c_payload_nbits),
	.p_opaque_nbits				(c_opaque_nbits),
	.p_srcdest_nbits			(c_srcdest_nbits)
  )
  th
  (
	.clk						(clk),
	.reset						(th_reset),
	.src_max_delay				(th_src_max_delay),
	.sink_max_delay				(th_sink_max_delay),
	.num_failed					(th_num_failed),
	.done						(th_done)
  );

  // Helper task to initialize source/sink delays
  integer i;
  task init_rand_delays
  (
	input [31:0]				src_max_delay,
	input [31:0]				sink_max_delay
  );
  begin
    // we also reset the src/sink indexes
	th_src_index[0]				= 0;
	th_src_index[1]				= 0;
	th_src_index[2]				= 0;
	th_src_index[3]				= 0;
	th_src_index[4]				= 0;
	th_src_index[5]				= 0;

	th_sink_index[0]			= 0;
	th_sink_index[1]			= 0;
	th_sink_index[2]			= 0;

	th_src_max_delay			= src_max_delay;
	th_sink_max_delay			= sink_max_delay;
  end
  endtask

  task init_src
  (
	input [31:0]				port,

	input [c_net_msg_nbits-1:0]	msg
  );
  begin

	case ( port )
	  0: begin
		th.src0_d0.src.m[ th_src_index[port] ] = msg;
		
		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.src0_d0.src.m[ th_src_index[port] + 1] = 'hx;
	  end
	  1: begin
		th.src_ter_d0.src.m[ th_src_index[port] ] = msg;

		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.src_ter_d0.src.m[ th_src_index[port] + 1] = 'hx;
	  end
	  2: begin
		th.src1_d0.src.m[ th_src_index[port] ] = msg;

		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.src1_d0.src.m[ th_src_index[port] + 1] = 'hx;
	  end
	  3: begin
		th.src0_d1.src.m[ th_src_index[port] ] = msg;
		
		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.src0_d1.src.m[ th_src_index[port] + 1] = 'hx;
	  end
	  4: begin
		th.src_ter_d1.src.m[ th_src_index[port] ] = msg;

		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.src_ter_d1.src.m[ th_src_index[port] + 1] = 'hx;
	  end
	  5: begin
		th.src1_d1.src.m[ th_src_index[port] ] = msg;

		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.src1_d1.src.m[ th_src_index[port] + 1] = 'hx;
	  end

	endcase

	// increment the index
	th_src_index[port] = th_src_index[port] + 1;

  end
  endtask

  task init_sink
  (
	input [31:0]				port,

	input [c_net_msg_nbits-1:0]	msg
  );
  begin

	case ( port )
	  0: begin
		th.sink0.sink.m[ th_sink_index[port] ] = msg;
		
		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.sink0.sink.m[ th_sink_index[port] + 1] = 'hx;
	  end
	  1: begin
		th.sink_ter.sink.m[ th_sink_index[port] ] = msg;

		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.sink_ter.sink.m[ th_sink_index[port] + 1] = 'hx;
	  end
	  2: begin
		th.sink1.sink.m[ th_sink_index[port] ] = msg;

		// we load xs for the next address so that src/sink message don't
		// bleed to the next one

		th.sink1.sink.m[ th_sink_index[port] + 1] = 'hx;
	  end
	endcase

	// increment the index
	th_sink_index[port] = th_sink_index[port] + 1;

  end
  endtask

  
  reg [c_net_msg_nbits-1:0]							th_port_msg;

  task init_net_msg
  (
	input [2:0]										in_port,
	input [2:0]										out_port,

	input [`VC_NET_MSG_SRC_NBITS(p,o,s)-1:0]		src,
	input [`VC_NET_MSG_DEST_NBITS(p,o,s)-1:0]		dest,
	input [`VC_NET_MSG_OPAQUE_NBITS(p,o,s)-1:0]		opaque,
	input [`VC_NET_MSG_PAYLOAD_NBITS(p,o,s)-1:0]	payload
  );
  begin
	
    th_port_msg[`VC_NET_MSG_DEST_FIELD(p,o,s)]		= dest;
	th_port_msg[`VC_NET_MSG_SRC_FIELD(p,o,s)]		= src;
	th_port_msg[`VC_NET_MSG_PAYLOAD_FIELD(p,o,s)]	= payload;
	th_port_msg[`VC_NET_MSG_OPAQUE_FIELD(p,o,s)]	= opaque;

	init_src( in_port, th_port_msg );
	init_sink( out_port, th_port_msg );

  end
  endtask

  // Load the common dataset of domain 0

  task init_common_domain0;
  begin
    //            in    out   src   dest  opq    payload
    init_net_msg( 3'h0, 3'h2, 3'h1, 3'h3, 8'h00, 8'hce );
    init_net_msg( 3'h2, 3'h0, 3'h7, 3'h0, 8'h05, 8'hfe );
    init_net_msg( 3'h1, 3'h1, 3'h2, 3'h2, 8'h30, 8'h09 );
    init_net_msg( 3'h2, 3'h0, 3'h4, 3'h1, 8'h10, 8'hfe );
    init_net_msg( 3'h0, 3'h2, 3'h1, 3'h4, 8'h15, 8'h9f );
    init_net_msg( 3'h2, 3'h1, 3'h3, 3'h2, 8'h32, 8'hdf );
    init_net_msg( 3'h0, 3'h2, 3'h1, 3'h3, 8'h23, 8'hfe );
    init_net_msg( 3'h0, 3'h1, 3'h1, 3'h2, 8'h31, 8'hb0 );
    init_net_msg( 3'h1, 3'h0, 3'h2, 3'h1, 8'h70, 8'h89 );
	//th.domain0 = 1'b0;
	//th.domain1 = 1'b1;
  end
  endtask

  // Load the common dataset of domain 1
  task init_common_domain1;
  begin
    //            in    out   src   dest  opq    payload
    init_net_msg( 3'h3, 3'h2, 3'h1, 3'h3, 8'h00, 8'hab );
    init_net_msg( 3'h5, 3'h0, 3'h7, 3'h0, 8'h05, 8'hfe );
    init_net_msg( 3'h4, 3'h1, 3'h2, 3'h2, 8'h30, 8'h09 );
    init_net_msg( 3'h5, 3'h0, 3'h4, 3'h1, 8'h10, 8'hfe );
    init_net_msg( 3'h3, 3'h2, 3'h1, 3'h4, 8'h15, 8'haa );
    init_net_msg( 3'h5, 3'h1, 3'h3, 3'h2, 8'h32, 8'hdf );
    init_net_msg( 3'h3, 3'h2, 3'h1, 3'h3, 8'h23, 8'hcd );
    init_net_msg( 3'h3, 3'h1, 3'h1, 3'h2, 8'h31, 8'hb0 );
    init_net_msg( 3'h4, 3'h0, 3'h2, 3'h1, 8'h70, 8'h89 );
	//th.domain0 = 1'b1;
	//th.domain1 = 1'b0;
  end
  endtask
// Helper task to run test
  
  task run_test;
  begin
	th.domain0 = 1'b0;
	th.domain1 = 1'b1;

	//	th.domain0 = ~th.domain0;
	//	th.domain1 = ~th.domain1;

	#1;		th_reset = 1'b1;
	#20;	th_reset = 1'b0;


	while ( !th_done && (th.trace_cycles < 500) ) begin
	  th.trace_display();
	  th.domain0 = ~th.domain0;
	  th.domain1 = ~th.domain1;
	  #20;
	end

	`VC_TEST_INCREMENT_NUM_FAILED( th_num_failed );
	`VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // basic test, no delay
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "basic test, no delay" )
  begin
	init_rand_delays( 0, 0 );
	init_common_domain0;
	init_common_domain1;
	run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // basic test, src delay = 3, sink delay = 10
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "basic test, src delay = 3, sink delay = 10 " )
  begin
	init_rand_delays( 3, 10 );
	init_common_domain0;
	init_common_domain1;
	run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // basic test, src delay = 10, sink delay = 3
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "basic test, src delay = 10, sink delay = 3" )
  begin
	init_rand_delays( 10, 3 );
	init_common_domain0;
	init_common_domain1;
	run_test;
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule


