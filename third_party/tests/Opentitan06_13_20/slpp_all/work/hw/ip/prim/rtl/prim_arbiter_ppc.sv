// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// N:1 arbiter module
//
// Verilog parameter
//   N:    Number of request ports
//   DW:   Data width
//
// This is the original implementation of the arbiter which relies on parallel prefix
// computing optimization to optimize the request / arbiter tree. Not all synthesis tools
// may support this.
//
// Note that the currently winning request is held if the data sink is not ready.
// This behavior is required by some interconnect protocols (AXI, TL). Note that
// this implies that an asserted request must stay asserted
// until it has been granted. Note that for PPC, this option cannot
// be disabled.
//
// See also: prim_arbiter_tree

// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Macros and helper code for using assertions.
//  - Provides default clk and rst options to simplify code
//  - Provides boiler plate template for common assertions












































































































































module prim_arbiter_ppc #(
  parameter int unsigned N  = 4,
  parameter int unsigned DW = 32,

  // Configurations
  // EnDataPort: {0, 1}, if 0, input data will be ignored
  parameter int EnDataPort = 1,

  // Derived parameters
  localparam int unsigned IdxW = $clog2(N)
) (
  input clk_i,
  input rst_ni,

  input        [ N-1:0]        req_i,
  input        [DW-1:0]        data_i [N],
  output logic [ N-1:0]        gnt_o,
  output logic [IdxW-1:0]      idx_o,

  output logic          valid_o,
  output logic [DW-1:0] data_o,
  input                 ready_i
);

  

  // this case is basically just a bypass
  if (N == 1) begin : gen_degenerate_case

    assign valid_o  = req_i[0];
    assign data_o   = data_i[0];
    assign gnt_o[0] = valid_o & ready_i;
    assign idx_o    = '0;

  end else begin : gen_normal_case

    logic [N-1:0] masked_req;
    logic [N-1:0] ppc_out;
    logic [N-1:0] arb_req;
    logic [N-1:0] mask, mask_next;
    logic [N-1:0] winner;

    assign masked_req = mask & req_i;
    assign arb_req = (|masked_req) ? masked_req : req_i;

    // PPC
    //   Even below code looks O(n) but DC optimizes it to O(log(N))
    //   Using Parallel Prefix Computation
    always_comb begin
      ppc_out[0] = arb_req[0];
      for (int i = 1 ; i < N ; i++) begin
        ppc_out[i] = ppc_out[i-1] | arb_req[i];
      end
    end

    // Grant Generation: Leading-One detector
    assign winner = ppc_out ^ {ppc_out[N-2:0], 1'b0};
    assign gnt_o    = (ready_i) ? winner : '0;

    assign valid_o = |req_i;
    // Mask Generation
    assign mask_next = {ppc_out[N-2:0], 1'b0};
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        mask <= '0;
      end else if (valid_o && ready_i) begin
        // Latch only when requests accepted
        mask <= mask_next;
      end else if (valid_o && !ready_i) begin
        // Downstream isn't yet ready so, keep current request alive. (First come first serve)
        mask <= ppc_out;
      end
    end

    if (EnDataPort == 1) begin: gen_datapath
      always_comb begin
        data_o = '0;
        for (int i = 0 ; i < N ; i++) begin
          if (winner[i]) begin
            data_o = data_i[i];
          end
        end
      end
    end else begin: gen_nodatapath
      assign data_o = '1;
      // TODO: waive data_i from NOT_READ error
    end

    always_comb begin
      idx_o = '0;
      for (int i = 0 ; i < N ; i++) begin
        if (winner[i]) begin
          idx_o = i[IdxW-1:0];
        end
      end
    end

    ////////////////
    // assertions //
    ////////////////
    // grant shall be higher index than prev. unless no higher requests exist
    

  end

  ////////////////
  // assertions //
  ////////////////

  // we can only grant one requestor at a time
  
  // A grant implies that the sink is ready
  
  // A grant implies that the arbiter asserts valid as well
  
  // A request and a sink that is ready imply a grant
  
  // A request and a sink that is ready imply a grant
  
  // Both conditions above combined and reversed
  
  // Both conditions above combined and reversed
  
  // check index / grant correspond
  
  // data flow
  
  // KNOWN assertions on outputs, except for data as that may be partially X in simulation
  // e.g. when used on a BUS
  
  
  











endmodule
