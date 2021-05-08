`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:29:59 05/06/2021
// Design Name:   mul
// Module Name:   /home/ise/Documents/m/mul_tb.v
// Project Name:  m
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mul
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mul_tb;

	// Inputs
	reg [31:0] a_operand;
	reg [31:0] b_operand;

	// Outputs
	wire Exception;
	wire Overflow;
	wire Underflow;
	wire [31:0] result;

	// Instantiate the Unit Under Test (UUT)
	mul uut (
		.a_operand(a_operand), 
		.b_operand(b_operand), 
		.Exception(Exception), 
		.Overflow(Overflow), 
		.Underflow(Underflow), 
		.result(result)
	);

	initial begin
		// Initialize Inputs
		a_operand = 32'b01111111100110111000010100011111;
		b_operand = 32'b11000000010011101011100001010010;

		// Wait 100 ns for global reset to finish
		#100;
        
		a_operand = 32'b01000000010100000000000000000000; // 3.25
		b_operand = 32'b11000000000010000000000000000000; // 2.125

		// Wait 100 ns for global reset to finish
		#100;
		
		a_operand = 32'b01000000101100000000000000000000; //5.5
		b_operand = 32'b11000000101100000000000000000000; //-5.5

		// Wait 100 ns for global reset to finish
		#100;	
		
		a_operand = 32'b00100000101100010001011010111000; // 0.0000125
		b_operand = 32'b00010000000110000001111000111010; // 0.00005

		// Wait 100 ns for global reset to finish
		#100;
        
		a_operand = 32'b01000010000011000000000000000000; // 35
		b_operand = 32'b01000001010101000000000000000000; // 13.25
		// Add stimulus here

	end
      
endmodule

