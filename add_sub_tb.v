`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:34:58 05/08/2021
// Design Name:   add_sub
// Module Name:   /home/ise/Documents/as/add_sub_tb.v
// Project Name:  as
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: add_sub
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module add_sub_tb;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg sign;

	// Outputs
	wire Exception;
	wire [31:0] Result;
	wire zero;

	// Instantiate the Unit Under Test (UUT)
	add_sub uut (
		.A(A), 
		.B(B), 
		.sign(sign), 
		.Exception(Exception), 
		.Result(Result),
		.zero(zero)
	);

	initial begin
		// Initialize Inputs
		A = 32'b01000000010100000000000000000000; // 3.25
		B = 32'b11000000000010000000000000000000; // -2.125
		sign = 1'b1;

		// Wait 100 ns for global reset to finish
		#100;
		
		A = 32'b01000000101100000000000000000000; //5.5
		B = 32'b11000000101100000000000000000000; //-5.5
		sign = 1'b0;
		// Wait 100 ns for global reset to finish
		#100;	
		
		A = 32'b11000000010100001010001111010111; // 3.26
		B = 32'b00111111101000111101011100001010; // 1.28
		sign = 1'b0;
		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here

	end
      
endmodule

