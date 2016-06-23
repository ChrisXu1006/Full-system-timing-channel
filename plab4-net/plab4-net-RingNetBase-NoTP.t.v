//=========================================================================
// Baseline Ring Network Unit Tests without Timing Channel Protection
//=========================================================================

`define PLAB4_NET_IMPL_TP			plab4_net_RingNetBase_NOTP
`define PLAB4_NET_IMPL_TP_STR		"plab4_net_RingNetBase_NOTP"

`include "plab4-net-RingNetBase-NoTP.v"
`include "plab4-net-test-harness-TP.v"
