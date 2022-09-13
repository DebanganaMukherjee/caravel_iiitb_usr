// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

 

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,



    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire reset;
	wire [1:0] ctrl;
	wire [3:0] d;
	wire [3:0] q;
    wire [12:0] in1;
    wire [12:0] in2;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    assign io_oeb=0;
    assign {in1,clk,reset,ctrl[1:0],d[3:0],in2}=io_in[`MPRJ_IO_PADS-2:0];
    assign [3:0] io_out=q;

    
    
usr usr1(clk,reset,ctrl,d,q);
endmodule



module usr(
input wire clk, reset,
	input wire [1:0] ctrl,
	input wire [3:0] d,
	output wire [3:0] q
);

reg[3:0] r_reg, r_next;
always @(posedge clk, posedge reset)
	if (reset)
		r_reg<=0;
	else
		r_reg<=r_next;

always @*
	case(ctrl)
		2'b00: r_next=r_reg;
		2'b10: r_next={r_reg[2:0],r_reg[3]};
		2'b01: r_next={r_reg[0],r_reg[3:1]};
		default: r_next=d;
	endcase
assign q=r_reg;
endmodule

`default_nettype wire

