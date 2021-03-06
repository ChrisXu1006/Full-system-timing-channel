//=========================================================================
// Processor Simulator Harness
//=========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define PLAB2_PROC_IMPL     plab2_proc_Impl
//  `define PLAB2_PROC_IMPL_STR "plab2-proc-Impl"
//
//  `include "plab2-proc-Impl.v"
//  `include "plab2-proc-sim-harness.v"
//

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-TestRandDelayMem_2ports.v"
`include "vc-test.v"
`include "pisa-inst.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_mem_nbytes  = 1 << 20, // size of physical memory in bytes
  parameter p_num_msgs    = 1024
)(
  input        clk,
  input        reset,
  input        mem_clear,
  input [31:0] src_max_delay,
  input [31:0] mem_max_delay,
  input [31:0] sink_max_delay,
  output       done
);

  // Local parameters

  localparam c_req_msg_nbits  = `VC_MEM_REQ_MSG_NBITS(8,32,32);
  localparam c_resp_msg_nbits = `VC_MEM_RESP_MSG_NBITS(8,32);
  localparam c_opaque_nbits   = 8;
  localparam c_data_nbits     = 32;   // size of mem message data in bits
  localparam c_addr_nbits     = 32;   // size of mem message address in bits

  // wires

  wire [`PLAB2_PROC_FROM_MNGR_MSG_NBITS-1:0]  src_msg;
  wire                                        src_val;
  wire                                        src_rdy;
  wire                                        src_done;

  wire [`PLAB2_PROC_TO_MNGR_MSG_NBITS-1:0]    sink_msg;
  wire                                        sink_val;
  wire                                        sink_rdy;
  wire                                        sink_done;

  // from mngr source

  vc_TestRandDelaySource
  #(
    .p_msg_nbits       (`PLAB2_PROC_FROM_MNGR_MSG_NBITS),
    .p_num_msgs        (p_num_msgs)
  )
  src
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (src_max_delay),

    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),

    .done      (src_done)
  );

  // memory

  wire                        imemreq_val;
  wire                        imemreq_rdy;
  wire [c_req_msg_nbits-1:0]  imemreq_msg;

  wire                        imemresp_val;
  wire                        imemresp_rdy;
  wire [c_resp_msg_nbits-1:0] imemresp_msg;

  wire                        dmemreq_val;
  wire                        dmemreq_rdy;
  wire [c_req_msg_nbits-1:0]  dmemreq_msg;

  wire                        dmemresp_val;
  wire                        dmemresp_rdy;
  wire [c_resp_msg_nbits-1:0] dmemresp_msg;

  vc_TestRandDelayMem_2ports
  #(p_mem_nbytes, c_opaque_nbits, c_addr_nbits, c_data_nbits) mem
  (
    .clk          (clk),
    .reset        (reset),
    .mem_clear    (mem_clear),

    .max_delay    (mem_max_delay),

    .memreq0_val  (imemreq_val),
    .memreq0_rdy  (imemreq_rdy),
    .memreq0_msg  (imemreq_msg),

    .memresp0_val (imemresp_val),
    .memresp0_rdy (imemresp_rdy),
    .memresp0_msg (imemresp_msg),

    .memreq1_val  (dmemreq_val),
    .memreq1_rdy  (dmemreq_rdy),
    .memreq1_msg  (dmemreq_msg),

    .memresp1_val (dmemresp_val),
    .memresp1_rdy (dmemresp_rdy),
    .memresp1_msg (dmemresp_msg)
  );

  // processor

  `PLAB2_PROC_IMPL proc
  (
    .clk           (clk),
    .reset         (reset),

    .imemreq_val   (imemreq_val),
    .imemreq_rdy   (imemreq_rdy),
    .imemreq_msg   (imemreq_msg),

    .imemresp_val  (imemresp_val),
    .imemresp_rdy  (imemresp_rdy),
    .imemresp_msg  (imemresp_msg),

    .dmemreq_val   (dmemreq_val),
    .dmemreq_rdy   (dmemreq_rdy),
    .dmemreq_msg   (dmemreq_msg),

    .dmemresp_val  (dmemresp_val),
    .dmemresp_rdy  (dmemresp_rdy),
    .dmemresp_msg  (dmemresp_msg),

    .from_mngr_msg (src_msg),
    .from_mngr_val (src_val),
    .from_mngr_rdy (src_rdy),

    .to_mngr_msg   (sink_msg),
    .to_mngr_val   (sink_val),
    .to_mngr_rdy   (sink_rdy)
  );

  // to mngr sink

  vc_TestRandDelaySink
  #(
    .p_msg_nbits       (`PLAB2_PROC_TO_MNGR_MSG_NBITS),
    .p_num_msgs        (p_num_msgs)
  )
  sink
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (sink_max_delay),

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
    proc.trace_module( trace );
    //vc_trace_str( trace, " > " );
    //mem.trace_module( trace );
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
  integer            verify_en = 0;
  integer            max_cycles;

  initial begin

    // Input dataset

    if ( !$value$plusargs( "input=%s", input_dataset ) ) begin
      // default dataset is none
      input_dataset = "";
    end

    // Maximum cycles

    if ( !$value$plusargs( "max-cycles=%d", max_cycles ) ) begin
      max_cycles = 7500;
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

    // Enable verify

    if ( $test$plusargs( "verify" ) ) begin
      verify_en = 1;
    end

    // Usage message

    if ( $test$plusargs( "help" ) ) begin
      $display( "" );
      $display( " plab2-proc-sim [options]" );
      $display( "" );
      $display( "   +help                 : this message" );
      $display( "   +input=<dataset>      : {vvadd-unopt,vvadd-opt,cmplx-mult,bin-search,masked-filter}" );
      $display( "   +max-cycles=<int>     : max cycles to wait until done" );
      $display( "   +trace=<int>          : 1 turns on line tracing" );
      $display( "   +dump-vcd=<file-name> : dump VCD to given file name" );
      $display( "   +stats                : display statistics" );
      $display( "   +verify               : verify output" );
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

  pisa_InstTasks pisa();

  // the reset vector (the PC that the processor will start fetching from
  // after a reset)
  localparam c_reset_vector = 32'h1000;

  reg         th_reset = 1;
  reg         th_mem_clear;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_mem_max_delay;
  reg  [31:0] th_sink_max_delay;
  reg  [31:0] th_inst_asm_str;
  reg  [31:0] th_addr;
  reg  [31:0] th_src_idx;
  reg  [31:0] th_sink_idx;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .mem_max_delay  (th_mem_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  //----------------------------------------------------------------------
  // load_mem: helper task to load one word into memory
  //----------------------------------------------------------------------

  task load_mem
  (
    input [31:0] addr,
    input [31:0] data
  );
  begin
    th.mem.mem.m[ addr >> 2 ] = data;
  end
  endtask

  //----------------------------------------------------------------------
  // load_from_mngr: helper task to load an entry into the from_mngr source
  //----------------------------------------------------------------------

  task load_from_mngr
  (
    input [ 9:0]                                i,
    input [`PLAB2_PROC_FROM_MNGR_MSG_NBITS-1:0] msg
  );
  begin
    th.src.src.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // load_to_mngr: helper task to load an entry into the to_mngr sink
  //----------------------------------------------------------------------

  task load_to_mngr
  (
    input [ 9:0]                                i,
    input [`PLAB2_PROC_TO_MNGR_MSG_NBITS-1:0]   msg
  );
  begin
    th.sink.sink.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // clear_mem: clear the contents of memory and test sources and sinks
  //----------------------------------------------------------------------

  task clear_mem;
  begin
    #1;   th_mem_clear = 1'b1;
    #20;  th_mem_clear = 1'b0;
    th_src_idx = 0;
    th_sink_idx = 0;
    // in case there are no srcs/sinks, we set the first elements of them
    // to xs
    load_from_mngr( 0, 32'hxxxxxxxx );
    load_to_mngr(   0, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // init_src: add a data to the test src
  //----------------------------------------------------------------------

  task init_src
  (
    input [31:0] data
  );
  begin
    load_from_mngr( th_src_idx, data );
    th_src_idx = th_src_idx + 1;
    // we set the next address with x's so that src/sink stops here if
    // there isn't another call to init_src/sink
    load_from_mngr( th_src_idx, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // init_sink: add a data to the test sink
  //----------------------------------------------------------------------

  task init_sink
  (
    input [31:0] data
  );
  begin
    load_to_mngr( th_sink_idx, data );
    th_sink_idx = th_sink_idx + 1;
    // we set the next address with x's so that src/sink stops here if
    // there isn't another call to init_src/sink
    load_to_mngr( th_sink_idx, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // inst: assemble and put instruction to next addr
  //----------------------------------------------------------------------

  task inst
  (
    input [25*8-1:0] asm_str
  );
  begin
    th_inst_asm_str = pisa.asm( th_addr, asm_str );
    load_mem( th_addr, th_inst_asm_str );
    // increment pc
    th_addr = th_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // data: put data_in to next addr, useful for mem ops
  //----------------------------------------------------------------------

  task data
  (
    input [31:0] data_in
  );
  begin
    load_mem( th_addr, data_in );
    // increment pc
    th_addr = th_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // address: each consecutive call to inst and data would be put after
  // this address
  //----------------------------------------------------------------------

  task address
  (
    input [31:0] addr
  );
  begin
    th_addr = addr;
  end
  endtask

  localparam c_ref_arr_size = 256;

  // reference and ubmark-related regs

  reg [31:0]  ref_addr;
  reg [ 8:0]  ref_arr_idx;
  reg [31:0]  ref_arr [ c_ref_arr_size-1:0 ];
  reg [13*8:0] ubmark_name;
  reg [ 8:0]  ubmark_dest_size;


  // expected and actual data

  reg [31:0] exp_data;
  reg [31:0] actual_data;

  //----------------------------------------------------------------------
  // verify: verify the outputs
  //----------------------------------------------------------------------

  task verify;
  begin
    // set the address to the beginning of the destination
    th_addr = ref_addr;
    for ( ref_arr_idx = 0; ref_arr_idx < ubmark_dest_size;
                        ref_arr_idx = ref_arr_idx + 1 ) begin
      exp_data    = ref_arr[ ref_arr_idx ];
      actual_data = th.mem.mem.m[ th_addr >> 2 ];

      // check if the expected and actual are the same
      if ( !( exp_data === actual_data ) ) begin
        $display( "  [ FAILED ] %s : dest[%d] != ref[%d] (%d != %d)",
                  ubmark_name, ref_arr_idx, ref_arr_idx,
                  actual_data, exp_data );
        // exit if we have a failure
        $finish_and_return(1);
      end

      // increment the address
      th_addr = th_addr + 4;
    end

    // if we didn't exit, we passed
    $display( "  [ passed ] %s", ubmark_name );
  end
  endtask

  //----------------------------------------------------------------------
  // ref_data: add a reference data to be checked in verify
  //----------------------------------------------------------------------

  task ref_data
  (
    input [31:0] data_in
  );
  begin
    ref_arr[ ref_arr_idx ] = data_in;
    ref_arr_idx = ref_arr_idx + 1;
  end
  endtask


  //----------------------------------------------------------------------
  // ref_address: register the destination address and reset ref_arr_idx
  //----------------------------------------------------------------------

  task ref_address
  (
    input [31:0] addr
  );
  begin
    ref_addr = addr;
    ref_arr_idx = 0;
  end
  endtask

  //----------------------------------------------------------------------
  // init_rand_delays: helper task to initialize random delay setup
  //----------------------------------------------------------------------

  task init_rand_delays
  (
    input [31:0] src_max_delay,
    input [31:0] mem_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_mem_max_delay  = mem_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask

  //----------------------------------------------------------------------
  // include the ubmarks
  //----------------------------------------------------------------------

  `include "plab2-proc-ubmark-vvadd.v"

  `include "plab2-proc-ubmark-cmplx-mult.v"

  `include "plab2-proc-ubmark-bin-search.v"

  `include "plab2-proc-ubmark-masked-filter.v"

  //----------------------------------------------------------------------
  // Drive the simulation
  //----------------------------------------------------------------------

  // number of instructions
  integer num_insts = 0;

  initial begin

    #1;

    // we don't have delays for simulation
    init_rand_delays( 0, 0, 0 );

    if          ( input_dataset == "vvadd-unopt"   ) begin
      init_vvadd_unopt;
    end else if ( input_dataset == "vvadd-opt"     ) begin
      init_vvadd_opt;
    end else if ( input_dataset == "cmplx-mult"    ) begin
      init_cmplx_mult;
    end else if ( input_dataset == "bin-search"    ) begin
      init_bin_search;
    end else if ( input_dataset == "masked-filter" ) begin
      init_masked_filter;
    end

    else begin
      $display( "" );
      $display( " ERROR: Unrecognized input dataset specified with +input! (%s)",
                            input_dataset );
      $display( "" );
      $finish_and_return(1);
    end

    // Reset signal

         th_reset = 1'b1;
    #20; th_reset = 1'b0;

    // Run the simulation

    while ( !th_done && (th.trace_cycles < max_cycles) ) begin
      th.trace_display();
      // we have a unique instruction when the pipe control in M has
      // next_val asserted
      if ( th.proc.ctrl.val_MW )
        num_insts = num_insts + 1;
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

    // Enable verify

    if ( verify_en ) begin
      verify;
    end

    // Output stats

    if ( stats_en ) begin
      $display( "num_cycles              = %0d", th.trace_cycles );
      $display( "num_insts               = %0d", num_insts );
      $display( "avg_num_cycles_per_inst = %f",
                                  th.trace_cycles/(1.0*num_insts) );
    end

    // Finish simulation

    $finish;

  end

endmodule


