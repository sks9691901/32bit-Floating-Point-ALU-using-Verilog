`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   04:54:04 05/10/2021
// Design Name:   div
// Module Name:   /home/ise/Documents/div/div_tb.v
// Project Name:  div
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: div
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module div_tb;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;

	// Outputs
	wire Exception;
	wire [31:0] result;
	wire [47:0]div_quotient;
	wire [7:0]final_res_expo;

	// Instantiate the Unit Under Test (UUT)
	div uut (
		.A(A), 
		.B(B), 
		.Exception(Exception),  
		.result(result),
		.div_quotient(div_quotient),
		.final_res_expo(final_res_expo)
	);

	initial begin
		// Initialize Inputs
		A = 32'b01000000101100110011001100110011; //5.6
		B = 32'd00000000000000000000000000000000; //0

		// Wait 100 ns for global reset to finish
		#100;
        
		A = 32'b11000000101100110011001100110011; //-5.6
		B = 32'b01000000000100110011001100110011; //2.3

		// Wait 100 ns for global reset to finish
		#100;
		
		A = 32'b00000000000000000000000000000000; //0
		B = 32'b01000000101100110011001100110011; //5.6

		// Wait 100 ns for global reset to finish
		#100;
		
		A = 32'b00000000000000000000000000000000; //0
		B = 32'b01111111101100110011001100110011; //Inf

		// Wait 100 ns for global reset to finish
		#100;
		
		A = 32'b01111111101100110011001100110011; //Inf
		B = 32'b00000000000000000000000000000000; //0

		// Wait 100 ns for global reset to finish
		#100;
		
		A = 32'b00101100011101000000000000000000; //3.46744855E-12
		B = 32'b00101000011101000000000000000000; //1.35447209E-14

		// Wait 100 ns for global reset to finish
		#100;

	end
      
endmodule

