`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:24:20 05/06/2021 
// Design Name:    Multiplication Logic for ALU
// Module Name:    mul 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Gate Level Implementation
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//
// module 1
module mul(
		input [31:0] a_operand,
		input [31:0] b_operand,
		output Exception,Overflow,Underflow,
		output [31:0] result
		);
wire [8:0] exponent,temp_expo,comp_expo,sum_exponent;
wire [22:0] product_mantissa;
wire [23:0] operand_a,operand_b;
wire [47:0] product,product_normalised;
wire bitandA,bitandB,bitorA,bitorB,pro_man_bitand;
wire [8:0]temp;
wire sign,product_round,normalised,zero,carry,sign_carry,not_sign,not_zero,w1;
wire [31:0]ripple_result_1,ripple_result_2,ripple_result_3;

xor (sign,a_operand[31],b_operand[31]);
bitand C1(.bitandin(a_operand[30:23]),.bitandout(bitandA));
bitand C2(.bitandin(b_operand[30:23]),.bitandout(bitandB));
or(Exception,bitandA,bitandB);
bitor  C3(.bitorin(a_operand[30:23]),.bitorout(bitorA));
bitor  C4(.bitorin(b_operand[30:23]),.bitorout(bitorB));
assign product = {bitorA,a_operand[22:0]} * {bitorB,b_operand[22:0]};
bitor2 C5(.in(product[22:0]),.out(product_round));	
and(normalised,product[47],1'b1);
assign product_normalised = normalised ? product : product << 1;
assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & product_round);
bitand2 C6(.in(product_mantissa[22:0]),.out(pro_man_bitand));
mux C7(.fi(pro_man_bitand),.si(1'b0),.SL(Exception),.Y(zero));
rca8bit  C8(.A(a_operand[30:23]),.B(b_operand[30:23]),.Cin(1'b0),.Sum(sum_exponent[7:0]),.Cout(sum_exponent[8]));
rca9bit  C10( .A(sum_exponent[8:0]), .B(9'b110000001), .Cin(normalised),       .Sum(exponent[8:0]), .Cout(sign_carry));
wire not_zero,w1;
not(Underflow,sign_carry);
and(Overflow,sign_carry,exponent[8]);
mux_multi C13( .A({sign,exponent[7:0],product_mantissa}), .B(32'b00000000000000000000000000000000),       .SL(Exception),    .O(ripple_result_1[31:0]));
mux_multi C14( .A(ripple_result_1[31:0]),                 .B({sign,31'b0000000000000000000000000000000}), .SL(zero),         .O(ripple_result_2[31:0]));
mux_multi C15( .A(ripple_result_2[31:0]),                 .B({sign,31'b1111111100000000000000000000000}), .SL(Overflow),     .O(ripple_result_3[31:0]));
mux_multi C16( .A(ripple_result_3[31:0]),                 .B({sign,31'b0000000000000000000000000000000}), .SL(Underflow),    .O(result[31:0])         );
endmodule

// module 2
module bitand(
	 input [7:0]bitandin,
	 output bitandout
	 );
and(bitandout,bitandin[7],bitandin[6],bitandin[5],bitandin[4],bitandin[3],bitandin[2],bitandin[1],bitandin[0]);
endmodule

// module 3
module bitor(
	 input [7:0]bitorin,
	 output bitorout
	 );
or(bitorout,bitorin[7],bitorin[6],bitorin[5],bitorin[4],bitorin[3],bitorin[2],bitorin[1],bitorin[0]);
endmodule

// module 4
module bitor2(
	 input [22:0]in,
	 output out
	 );
or(out,in[22],in[21],in[20],in[19],in[18],in[17],in[16],in[15],in[14],in[13],in[12],in[11],in[10],in[9],in[8],in[7],in[6],in[5],in[4],in[3],in[2],in[1],in[0]);
endmodule

// module 5
module bitand2(
	 input [22:0]in,
	 output out
	 );
and(out,in[22],in[21],in[20],in[19],in[18],in[17],in[16],in[15],in[14],in[13],in[12],in[11],in[10],in[9],in[8],in[7],in[6],in[5],in[4],in[3],in[2],in[1],in[0]);
endmodule

// module 6
module mux(
	 input fi,
	 input si,
	 input SL,
	 output Y
	 );
wire invSL,and1,and2,or1;
and(and1,SL,si);
not(invSL,SL);
and(and2,invSL,fi);
or(Y,and1,and2);
endmodule

// module 7
module rca9bit(
    input [8:0] A,
    input [8:0] B,
    input Cin,
    output [8:0] Sum,
    output Cout
    );
rca8bit adder0(.A(A[7:0]),  .B(B[7:0]), .Cin(Cin),  .Sum(Sum[7:0]),  .Cout(ripple));
adder_full fa0(.a(A[8]),  .b(B[8]),  .cin(ripple),  .sum(Sum[8]),  .carry(Cout));
endmodule

// module 8
module rca8bit(
    input [7:0] A,
    input [7:0] B,
	 input Cin,
	 output [7:0] Sum,
	 output Cout
    );
adder4 F0( .a(A[3:0]),  .b(B[3:0]),  .cin(Cin),      .sum(Sum[3:0]),  .carry(ripple));
adder4 F1( .a(A[7:4]),  .b(B[7:4]),  .cin(ripple),   .sum(Sum[7:4]),  .carry(Cout));
endmodule

// module 9
module adder4(
	 input [3:0]a,
	 input [3:0]b,
	 input cin,
	 output [3:0]sum,
	 output carry
	 );
wire w1,w2,w3;
adder_full G0(.a(a[0]),  .b(b[0]),  .cin(cin),  .sum(sum[0]),  .carry(w1));
adder_full G1(.a(a[1]),  .b(b[1]),  .cin(w1),   .sum(sum[1]),  .carry(w2));
adder_full G2(.a(a[2]),  .b(b[2]),  .cin(w2),   .sum(sum[2]),  .carry(w3));
adder_full G3(.a(a[3]),  .b(b[3]),  .cin(w3),   .sum(sum[3]),  .carry(carry));
endmodule

// module 10
module adder_full(
	 input a,
	 input b,
	 input cin,
	 output sum,
	 output carry
	 );
wire w1,w2,w3;
adder_half H0(.a(a),    .b(b),    .sum(w1),   .carry(w2));
adder_half H1(.a(w1),   .b(cin),  .sum(sum),  .carry(w3));
or(carry,w2,w3);
endmodule

// module 11
module adder_half(
	 input a,
	 input b,
	 output sum,
	 output carry
	 );
xor(sum,a,b);
and(carry,a,b);
endmodule

// module 12
module mux_multi(
	 input [31:0]A,
	 input [31:0]B,
	 input SL,
	 output [31:0]O
	 );
mux M01 (.fi(A[31]),.si(B[31]),.SL(SL),.Y(O[31]));
mux M02 (.fi(A[30]),.si(B[30]),.SL(SL),.Y(O[30]));
mux M03 (.fi(A[29]),.si(B[29]),.SL(SL),.Y(O[29]));
mux M04 (.fi(A[28]),.si(B[28]),.SL(SL),.Y(O[28]));
mux M05 (.fi(A[27]),.si(B[27]),.SL(SL),.Y(O[27]));
mux M06 (.fi(A[26]),.si(B[26]),.SL(SL),.Y(O[26]));
mux M07 (.fi(A[25]),.si(B[25]),.SL(SL),.Y(O[25]));
mux M08 (.fi(A[24]),.si(B[24]),.SL(SL),.Y(O[24]));
mux M09 (.fi(A[23]),.si(B[23]),.SL(SL),.Y(O[23]));
mux M10 (.fi(A[22]),.si(B[22]),.SL(SL),.Y(O[22]));
mux M11 (.fi(A[21]),.si(B[21]),.SL(SL),.Y(O[21]));
mux M12 (.fi(A[20]),.si(B[20]),.SL(SL),.Y(O[20]));
mux M13 (.fi(A[19]),.si(B[19]),.SL(SL),.Y(O[19]));
mux M14 (.fi(A[18]),.si(B[18]),.SL(SL),.Y(O[18]));
mux M15 (.fi(A[17]),.si(B[17]),.SL(SL),.Y(O[17]));
mux M16 (.fi(A[16]),.si(B[16]),.SL(SL),.Y(O[16]));
mux M17 (.fi(A[15]),.si(B[15]),.SL(SL),.Y(O[15]));
mux M18 (.fi(A[14]),.si(B[14]),.SL(SL),.Y(O[14]));
mux M19 (.fi(A[13]),.si(B[13]),.SL(SL),.Y(O[13]));
mux M20 (.fi(A[12]),.si(B[12]),.SL(SL),.Y(O[12]));
mux M21 (.fi(A[11]),.si(B[11]),.SL(SL),.Y(O[11]));
mux M22 (.fi(A[10]),.si(B[10]),.SL(SL),.Y(O[10]));
mux M23 (.fi(A[9]) ,.si(B[9]) ,.SL(SL),.Y(O[9]) );
mux M24 (.fi(A[8]) ,.si(B[8]) ,.SL(SL),.Y(O[8]) );
mux M25 (.fi(A[7]) ,.si(B[7]) ,.SL(SL),.Y(O[7]) );
mux M26 (.fi(A[6]) ,.si(B[6]) ,.SL(SL),.Y(O[6]) );
mux M27 (.fi(A[5]) ,.si(B[5]) ,.SL(SL),.Y(O[5]) );
mux M28 (.fi(A[4]) ,.si(B[4]) ,.SL(SL),.Y(O[4]) );
mux M29 (.fi(A[3]) ,.si(B[3]) ,.SL(SL),.Y(O[3]) );
mux M30 (.fi(A[2]) ,.si(B[2]) ,.SL(SL),.Y(O[2]) );
mux M31 (.fi(A[1]) ,.si(B[1]) ,.SL(SL),.Y(O[1]) );
mux M32 (.fi(A[0]) ,.si(B[0]) ,.SL(SL),.Y(O[0]) );
	 
endmodule
