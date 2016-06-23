//========================================================================
// Cache Simulator Harness
//========================================================================
// This harness is meant to be instatiated for a specific implementation
// of a memory system module and optionally a cache implementation using
// the special IMPL defines like this:
//
// `define PLAB3_CACHE_IMPL     plab3_mem_BlockingCacheBase
// `define PLAB3_MEM_IMPL_STR  "plab3-mem-BlockingCacheBase"
//
// `include "plab3-mem-BlockingCacheBase.v"
// `include "plab3-mem-test-harness.v"

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-TestDelay.v"
`include "vc-test.v"
`include "vc-mem-msgs.v"

`include "vc-TestRandDelayMem_1port.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
(
  input         clk,
  input         reset,
  input         mem_clear,
  input  [31:0] src_max_delay,
  input  [31:0] mem_max_delay,
  input  [31:0] mem_fixed_delay,
  input  [31:0] sink_max_delay,
  output [31:0] num_failed,
  output        done
);

  // Local parameters

  localparam c_cache_nbytes       = 256;
  localparam c_cache_opaque_nbits = 8;
  localparam c_cache_addr_nbits   = 32;
  localparam c_cache_data_nbits   = 32;

  localparam c_mem_nbytes       = 1<<16;
  localparam c_mem_opaque_nbits = 8;
  localparam c_mem_addr_nbits   = 32;
  localparam c_mem_data_nbits   = 128;

  localparam c_cache_req_nbits  = `VC_MEM_REQ_MSG_NBITS(c_cache_opaque_nbits,c_cache_addr_nbits,c_cache_data_nbits);
  localparam c_cache_resp_nbits = `VC_MEM_RESP_MSG_NBITS(c_cache_opaque_nbits,c_cache_data_nbits);

  localparam c_mem_req_nbits  = `VC_MEM_REQ_MSG_NBITS(c_mem_opaque_nbits,c_mem_addr_nbits,c_mem_data_nbits);
  localparam c_mem_resp_nbits = `VC_MEM_RESP_MSG_NBITS(c_mem_opaque_nbits,c_mem_data_nbits);

  // Test source
  wire                         src_val;
  wire                         src_rdy;
  wire [c_cache_req_nbits-1:0] src_msg;
  wire                         src_done;

  vc_TestRandDelaySource#(c_cache_req_nbits) src
  (
    .clk       (clk),
    .reset     (reset),
    .max_delay (src_max_delay),
    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),
    .done      (src_done)
  );

  // Cache under test

  wire                          sink_val;
  wire                          sink_rdy;
  wire [c_cache_resp_nbits-1:0] sink_msg;

  wire                          memreq_val;
  wire                          memreq_rdy;
  wire [c_mem_req_nbits-1:0]    memreq_msg;
  wire                          memresp_val;
  wire                          memresp_rdy;
  wire [c_mem_resp_nbits-1:0]   memresp_msg;

  // to be able to determine if we have a refill or evict, we snoop the
  // memory message to see what type it is
  localparam c_mem_req_type_nbits  = `VC_MEM_REQ_MSG_TYPE_NBITS(
                    c_mem_opaque_nbits,c_mem_addr_nbits,c_mem_data_nbits);

  wire [c_mem_req_type_nbits-1:0] memreq_type;
  assign memreq_type = memreq_msg[ `VC_MEM_REQ_MSG_TYPE_FIELD(
                  c_mem_opaque_nbits,c_mem_addr_nbits,c_mem_data_nbits) ];

  `PLAB3_CACHE_IMPL
  #(
    .p_mem_nbytes   (c_cache_nbytes)
  )
  cache
  (
    .clk           (clk),
    .reset         (reset),

    .cachereq_val  (src_val),
    .cachereq_rdy  (src_rdy),
    .cachereq_msg  (src_msg),

    .cacheresp_val (sink_val),
    .cacheresp_rdy (sink_rdy),
    .cacheresp_msg (sink_msg),

    .memreq_val  (memreq_val),
    .memreq_rdy  (memreq_rdy),
    .memreq_msg  (memreq_msg),

    .memresp_val (memresp_val),
    .memresp_rdy (memresp_rdy),
    .memresp_msg (memresp_msg)
  );

  //----------------------------------------------------------------------
  // Initialize the delay unit to force fixed delay in the memory
  //----------------------------------------------------------------------

  wire                          memreq_delay_val;
  wire                          memreq_delay_rdy;
  wire [c_mem_req_nbits-1:0]    memreq_delay_msg;

  vc_TestDelay#(c_mem_req_nbits) memreq_delay
  (
    .clk       (clk),
    .reset     (reset),

    .delay_amt (mem_fixed_delay),

    .in_val    (memreq_val),
    .in_rdy    (memreq_rdy),
    .in_msg    (memreq_msg),

    .out_val   (memreq_delay_val),
    .out_rdy   (memreq_delay_rdy),
    .out_msg   (memreq_delay_msg)
  );

  //----------------------------------------------------------------------
  // Initialize the test memory
  //----------------------------------------------------------------------

  vc_TestRandDelayMem_1port
  #(
    .p_mem_nbytes   (c_mem_nbytes),
    .p_opaque_nbits (c_mem_opaque_nbits),
    .p_addr_nbits   (c_mem_addr_nbits),
    .p_data_nbits   (c_mem_data_nbits)
  )
  test_mem
  (
    .clk          (clk),
    .reset        (reset),
    // we reset memory on reset
    .mem_clear    (reset),

    .max_delay    (mem_max_delay),

    .memreq_val   (memreq_delay_val),
    .memreq_rdy   (memreq_delay_rdy),
    .memreq_msg   (memreq_delay_msg),

    .memresp_val  (memresp_val),
    .memresp_rdy  (memresp_rdy),
    .memresp_msg  (memresp_msg)
  );

  // Test sink

  wire [31:0] sink_num_failed;
  wire        sink_done;

  vc_TestRandDelaySink#(c_cache_resp_nbits) sink
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink_val),
    .rdy        (sink_rdy),
    .msg        (sink_msg),
    .num_failed (sink_num_failed),
    .done       (sink_done)
  );

  // Done when both source and sink are done for both ports

  assign done = src_done & sink_done;

  // Num failed is sum from both sinks

  assign num_failed = sink_num_failed;

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  vc_MemReqMsgTrace#(c_cache_opaque_nbits, c_cache_addr_nbits, c_cache_data_nbits) cachereq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (src_val),
    .rdy   (src_rdy),
    .msg   (src_msg)
  );

  vc_MemRespMsgTrace#(c_cache_opaque_nbits, c_cache_data_nbits) cacheresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (sink_val),
    .rdy   (sink_rdy),
    .msg   (sink_msg)
  );

  vc_MemReqMsgTrace#(c_mem_opaque_nbits, c_mem_addr_nbits, c_mem_data_nbits) memreq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (memreq_val),
    .rdy   (memreq_rdy),
    .msg   (memreq_msg)
  );

  vc_MemRespMsgTrace#(c_mem_opaque_nbits, c_mem_data_nbits) memresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (memresp_val),
    .rdy   (memresp_rdy),
    .msg   (memresp_msg)
  );

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    cachereq_trace.trace_module( trace );

    vc_trace_str( trace, " > " );

    cache.trace_module( trace );

    vc_trace_str( trace, " " );

    memreq_trace.trace_module( trace );

    vc_trace_str( trace, " | " );

    memresp_trace.trace_module( trace );

    vc_trace_str( trace, " > " );

    cacheresp_trace.trace_module( trace );

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
      max_cycles = 10000;
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
      $display( " plab3-mem-sim [options]" );
      $display( "" );
      $display( "   +help                 : this message" );
      $display( "   +input=<dataset>      : {random,ustride,stride2,stride4," );
      $display( "                            shared,ustride-shared,loop-2d," );
      $display( "                            loop-3d}" );
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

  reg         th_reset = 1;
  reg         th_mem_clear;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_mem_max_delay;
  reg  [31:0] th_mem_fixed_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .mem_max_delay  (th_mem_max_delay),
    .mem_fixed_delay(th_mem_fixed_delay),
    .sink_max_delay (th_sink_max_delay),
    .num_failed     (th_num_failed),
    .done           (th_done)
  );

  //------------------------------------------------------------------------
  // Helper task to initialize source/sink delays
  //------------------------------------------------------------------------

  task init_delays
  (
    input [31:0] src_max_delay,
    input [31:0] mem_max_delay,
    input [31:0] mem_fixed_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_mem_max_delay  = mem_max_delay;
    th_mem_fixed_delay= mem_fixed_delay;
    th_sink_max_delay = sink_max_delay;
    // reset the index for test source/sink
    th_index = 0;

    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;
  end
  endtask

  //----------------------------------------------------------------------
  // task to load to test memory
  //----------------------------------------------------------------------

  task load_mem
  (
    input [31:0]  addr,
    input [127:0] data
  );
  begin
    th.test_mem.mem.m[ addr >> 4 ] = data;
  end
  endtask

  //------------------------------------------------------------------------
  // Helper task to initalize source/sink
  //------------------------------------------------------------------------

  reg [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] th_port_memreq;
  reg [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   th_port_memresp;
  // index into the next test src/sink index
  reg [31:0] th_index = 0;

  task init_port
  (
    //input [1023:0] index,

    input [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   memreq_type,
    input [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] memreq_opaque,
    input [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   memreq_addr,
    input [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    memreq_len,
    input [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   memreq_data,

    input [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]     memresp_type,
    input [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0]   memresp_opaque,
    input [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]      memresp_len,
    input [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]     memresp_data
  );
  begin
    th_port_memreq[`VC_MEM_REQ_MSG_TYPE_FIELD(8,32,32)]   = memreq_type;
    th_port_memreq[`VC_MEM_REQ_MSG_OPAQUE_FIELD(8,32,32)] = memreq_opaque;
    th_port_memreq[`VC_MEM_REQ_MSG_ADDR_FIELD(8,32,32)]   = memreq_addr;
    th_port_memreq[`VC_MEM_REQ_MSG_LEN_FIELD(8,32,32)]    = memreq_len;
    th_port_memreq[`VC_MEM_REQ_MSG_DATA_FIELD(8,32,32)]   = memreq_data;

    th_port_memresp[`VC_MEM_RESP_MSG_TYPE_FIELD(8,32)]    = memresp_type;
    th_port_memresp[`VC_MEM_RESP_MSG_OPAQUE_FIELD(8,32)]  = memresp_opaque;
    th_port_memresp[`VC_MEM_RESP_MSG_LEN_FIELD(8,32)]     = memresp_len;
    th_port_memresp[`VC_MEM_RESP_MSG_DATA_FIELD(8,32)]    = memresp_data;

    th.src.src.m[th_index]   = th_port_memreq;
    th.sink.sink.m[th_index] = th_port_memresp;

    // increment the index for the next call to init_port
    th_index = th_index + 1;

    // the following is to prevent previous test cases to "leak" into the
    // next cases
    th.src.src.m[th_index]   = 'hx;
    th.sink.sink.m[th_index] = 'hx;
  end
  endtask

  // Helper local params

  localparam c_req_rd  = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam c_req_wr  = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam c_req_wn  = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;

  localparam c_resp_rd = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam c_resp_wr = `VC_MEM_RESP_MSG_TYPE_WRITE;
  localparam c_resp_wn = `VC_MEM_RESP_MSG_TYPE_WRITE_INIT;

  //----------------------------------------------------------------------
  // Include Python-generated input datasets
  //----------------------------------------------------------------------

  `include "plab3-mem-input-gen_random.py.v"

  `include "plab3-mem-input-gen_ustride.py.v"

  `include "plab3-mem-input-gen_stride2.py.v"

  `include "plab3-mem-input-gen_stride4.py.v"

  `include "plab3-mem-input-gen_shared.py.v"

  `include "plab3-mem-input-gen_ustride-shared.py.v"

  `include "plab3-mem-input-gen_loop-2d.py.v"

  `include "plab3-mem-input-gen_loop-3d.py.v"

  //----------------------------------------------------------------------
  // Drive the simulation
  //----------------------------------------------------------------------

  // number of cache accesses
  integer num_cache_acc = 0;
  // number of misses and hits in the cache
  integer num_misses    = 0;
  integer num_hits      = 0;
  integer num_evicts    = 0;
  integer num_refills   = 0;
  integer num_mem_acc   = 0;

  // mark if this current transaction is a miss
  integer xaction_miss = 0;

  initial begin

    #1;

    // we use a fixed delay of 10 cycles in the memory
    init_delays( 0, 0, 9, 0 );

    if          ( input_dataset == "random"   ) begin
      init_random;
    end else if ( input_dataset == "ustride"   ) begin
      init_ustride;
    end else if ( input_dataset == "stride2"   ) begin
      init_stride2;
    end else if ( input_dataset == "stride4"   ) begin
      init_stride4;
    end else if ( input_dataset == "shared"   ) begin
      init_shared;
    end else if ( input_dataset == "ustride-shared"   ) begin
      init_ustride_shared;
    end else if ( input_dataset == "loop-2d"   ) begin
      init_loop_2d;
    end else if ( input_dataset == "loop-3d"   ) begin
      init_loop_3d;
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
      // if the source could be sent, this is a valid cache access
      if ( th.src_val && th.src_rdy ) begin
        num_cache_acc = num_cache_acc + 1;
        // initially mark this transaction as a hit
        xaction_miss = 0;
      end

      if ( th.memreq_val && th.memreq_rdy ) begin
        // if we go to the main memory, then this transaction is a miss
        xaction_miss = 1;
        // snoop the memory request message and increment the refill/evict
        // counter accordingly
        num_mem_acc = num_mem_acc + 1;
        if ( th.memreq_type == `VC_MEM_REQ_MSG_TYPE_READ )
          num_refills = num_refills + 1;
        else
          num_evicts = num_evicts + 1;
      end

      if ( th.sink_val && th.sink_rdy ) begin
        // we increment the counters accordingly
        if ( xaction_miss )
          num_misses = num_misses + 1;
        else
          num_hits   = num_hits   + 1;
      end

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
      $display( "num_cache_accesses      = %0d", num_cache_acc   );
      $display( "num_hits                = %0d", num_hits        );
      $display( "num_misses              = %0d", num_misses      );
      $display( "miss_rate               = %f%%",
                                    100.0*num_misses/num_cache_acc );
      $display( "num_mem_accesses        = %0d", num_mem_acc     );
      $display( "num_refills             = %0d", num_refills     );
      $display( "num_evicts              = %0d", num_evicts      );
      $display( "amal                    = %f",
                                  1.0*th.trace_cycles/num_cache_acc );

      //$display( "avg_num_cycles_per_inst = %f",
      //                            th.trace_cycles/(1.0*num_insts) );
    end

    // Finish simulation

    $finish;

  end

endmodule
