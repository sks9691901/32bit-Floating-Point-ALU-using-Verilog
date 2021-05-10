`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:36:54 05/10/2021
// Design Name:   ALU
// Module Name:   /home/ise/ALU_32bit_IEEE/ALU_tb.v
// Project Name:  ALU_32bit_IEEE
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ALU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ALU_tb;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] operation;

	// Outputs
	wire Exception;
	wire Overflow;
	wire Underflow;
	wire [31:0] Result;

	// Instantiate the Unit Under Test (UUT)
	ALU uut (
		.A(A), 
		.B(B), 
		.operation(operation), 
		.Exception(Exception), 
		.Overflow(Overflow), 
		.Underflow(Underflow), 
		.Result(Result)
	);

	initial begin
		// Initialize Inputs
		A = 32'b01000001000111001100110011001101; //9.8
		B = 32'b01000000100010011001100110011010; //4.3
		operation = 3'b000; // Addition

		// Wait 100 ns for global reset to finish
		#100;
        
		A = 32'b01000001000111001100110011001101; //9.8
		B = 32'b01000000100010011001100110011010; //4.3
		operation = 3'b001; // Subtraction

		// Wait 100 ns for global reset to finish
		#100;
		
		A = 32'b01000001000111001100110011001101; //9.8
		B = 32'b01000000100010011001100110011010; //4.3
		operation = 3'b010; // Multiplication

		// Wait 100 ns for global reset to finish
		#100;
		
		A = 32'b01000001000111001100110011001101; //9.8
		B = 32'b01000000100010011001100110011010; //4.3
		operation = 3'b011; // Division

		// Wait 100 ns for global reset to finish
		#100;

	end
      
endmodule

