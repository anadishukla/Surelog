// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SRAM interface to TL-UL converter
//      Current version only supports if TL-UL width and SRAM width are same
//      If SRAM interface requests more than MaxOutstanding cap, it generates
//      error in simulation but not in Silicon.

// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Macros and helper code for using assertions.
//  - Provides default clk and rst options to simplify code
//  - Provides boiler plate template for common assertions












































































































































module sram2tlul #(
  parameter int                        SramAw = 12,
  parameter int                        SramDw = 32,
  parameter logic [top_pkg::TL_AW-1:0] TlBaseAddr = 'h0 // Base address of SRAM request
) (
  input clk_i,
  input rst_ni,

  output tlul_pkg::tl_h2d_t tl_o,
  input  tlul_pkg::tl_d2h_t tl_i,

  // SRAM
  input                     mem_req,
  input                     mem_write,
  input        [SramAw-1:0] mem_addr,
  input        [SramDw-1:0] mem_wdata,
  output logic              mem_rvalid,
  output logic [SramDw-1:0] mem_rdata,
  output logic        [1:0] mem_error
);

  import tlul_pkg::*;

  

  localparam int unsigned SRAM_DWB = $clog2(SramDw/8);

  assign tl_o.a_valid   = mem_req;
  assign tl_o.a_opcode  = (mem_write) ? PutFullData : Get;
  assign tl_o.a_param   = '0;
  assign tl_o.a_size    = top_pkg::TL_SZW'(SRAM_DWB); // Max Size always
  assign tl_o.a_source  = '0;
  assign tl_o.a_address = TlBaseAddr |
                          {{(top_pkg::TL_AW-SramAw-SRAM_DWB){1'b0}},mem_addr,{(SRAM_DWB){1'b0}}};
  assign tl_o.a_mask    = '1;
  assign tl_o.a_data    = mem_wdata;
  assign tl_o.a_user    = '0;

  assign tl_o.d_ready   = 1'b1;

  assign mem_rvalid     = tl_i.d_valid && (tl_i.d_opcode == AccessAckData);
  assign mem_rdata      = tl_i.d_data;
  assign mem_error      = {2{tl_i.d_error}};

  // below assertion fails when TL-UL doesn't accept request in a cycle,
  // which is currently not supported by sram2tlul
  

endmodule
