//========================================================================
// Simulator for Integer Multiplier
//========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define  PLAB1_IMUL_IMPL plab1-imul_Impl
//  `include "plab1-imul-Impl.v"
//  `include "plab1-imul-sim-harness.v"
//

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
(
  input  clk,
  input  reset,
  output done
);

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0] src_msg;
  wire                                        src_val;
  wire                                        src_rdy;
  wire                                        src_done;

  wire [31:0]                                 sink_msg;
  wire                                        sink_val;
  wire                                        sink_rdy;
  wire                                        sink_done;

  vc_TestSource
  #(
    .p_msg_nbits (`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS),
    .p_num_msgs  (1024)
  )
  src
  (
    .clk       (clk),
    .reset     (reset),

    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),

    .done      (src_done)
  );

  `PLAB1_IMUL_IMPL imul
  (
    .clk       (clk),
    .reset     (reset),

    .in_msg    (src_msg),
    .in_val    (src_val),
    .in_rdy    (src_rdy),

    .out_msg   (sink_msg),
    .out_val   (sink_val),
    .out_rdy   (sink_rdy)
  );

  vc_TestSink
  #(
    .p_msg_nbits (32),
    .p_num_msgs  (1024),
    .p_sim_mode  (1)
  )
  sink
  (
    .clk       (clk),
    .reset     (reset),

    .val       (sink_val),
    .rdy       (sink_rdy),
    .msg       (sink_msg),

    .done      (sink_done)
  );

  assign done = src_done && sink_done;

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    src.trace_module( trace );
    vc_trace_str( trace, " > " );
    imul.trace_module( trace );
    vc_trace_str( trace, " > " );
    sink.trace_module( trace );
  end
  endtask

endmodule

//------------------------------------------------------------------------
// Simulation driver
//------------------------------------------------------------------------

module top;

  //----------------------------------------------------------------------
  // Process command line flags
  //----------------------------------------------------------------------

  reg [(512<<3)-1:0] input_dataset;
  reg [(512<<3)-1:0] vcd_dump_file_name;
  integer            stats_en = 0;
  integer            max_cycles;

  initial begin

    // Input dataset

    if ( !$value$plusargs( "input=%s", input_dataset ) ) begin
      input_dataset = "directed";
    end

    // Maximum cycles

    if ( !$value$plusargs( "max-cycles=%d", max_cycles ) ) begin
      max_cycles = 5000;
    end

    // VCD dumping

    if ( $value$plusargs( "dump-vcd=%s", vcd_dump_file_name ) ) begin
      $dumpfile(vcd_dump_file_name);
      $dumpvars;
    end

    // Output stats

    if ( $test$plusargs( "stats" ) ) begin
      stats_en = 1;
    end

    // Usage message

    if ( $test$plusargs( "help" ) ) begin
      $display( "" );
      $display( " pex-gcd-sim [options]" );
      $display( "" );
      $display( "   +help                 : this message" );
      $display( "   +input=<dataset>      : {small,large,lomask,himask,lohimask,sparse}" );
      $display( "   +max-cycles=<int>     : max cycles to wait until done" );
      $display( "   +trace=<int>          : 1 turns on line tracing" );
      $display( "   +dump-vcd=<file-name> : dump VCD to given file name" );
      $display( "   +stats                : display statistics" );
      $display( "" );
      $finish;
    end

  end

  //----------------------------------------------------------------------
  // Generate clock
  //----------------------------------------------------------------------

  reg clk = 1;
  always #5 clk = ~clk;

  //----------------------------------------------------------------------
  // Instantiate the harness
  //----------------------------------------------------------------------

  reg  th_reset = 1'b1;
  wire th_done;

  TestHarness th
  (
    .clk   (clk),
    .reset (th_reset),
    .done  (th_done)
  );

  //----------------------------------------------------------------------
  // Helper task to initialize sorce sink
  //----------------------------------------------------------------------

  task init
  (
    input [ 9:0] i,
    input [31:0] a,
    input [31:0] b,
    input [31:0] result
  );
  begin
    th.src.m[i]  = { `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_MUL, a, b };
    th.sink.m[i] = result;
  end
  endtask

  //----------------------------------------------------------------------
  // Drive the simulation
  //----------------------------------------------------------------------

  integer num_inputs = 0;

  initial begin

    #1;

    if ( input_dataset == "small" ) begin
      `include "plab1-imul-input-gen_small.py.v"
    end
    else if ( input_dataset == "large" ) begin
      `include "plab1-imul-input-gen_large.py.v"
    end
    else if ( input_dataset == "lomask" ) begin
      `include "plab1-imul-input-gen_lomask.py.v"
    end
    else if ( input_dataset == "himask" ) begin
      `include "plab1-imul-input-gen_himask.py.v"
    end
    else if ( input_dataset == "lohimask" ) begin
      `include "plab1-imul-input-gen_lohimask.py.v"
    end
    else if ( input_dataset == "sparse" ) begin
      `include "plab1-imul-input-gen_sparse.py.v"
    end
    else begin
      $display( "" );
      $display( " ERROR: Unrecognized input dataset specified with +input!" );
      $display( "" );
      $finish_and_return(1);
    end

    // Reset signal

         th_reset = 1'b1;
    #20; th_reset = 1'b0;

    // Run the simulation

    while ( !th_done && (th.trace_cycles < max_cycles) ) begin
      th.trace_display();
      #10;
    end

    // Check that the simulation actually finished

    if ( !th_done ) begin
      $display( "" );
      $display( " ERROR: Simulation did not finish in time. Maybe increase" );
      $display( " the simulation time limit using the +max-cycles=<int>" );
      $display( " command line parameter?" );
      $display( "" );
      $finish_and_return(1);
    end

    // Output stats

    if ( stats_en ) begin
      $display( "num_cycles              = %0d", th.trace_cycles );
      $display( "avg_num_cycles_per_imul = %f",  th.trace_cycles/(1.0*num_inputs) );
    end

    // Finish simulation

    $finish;

  end

endmodule

