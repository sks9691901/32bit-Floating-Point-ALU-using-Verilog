`timescale 1ns / 1ps

module rca8bit(
    input [7:0] A,
    input [7:0] B,
	 input cin,
	 output [7:0] ans,
	 output cout
    );
wire Cout;
wire [7:0]sum;

adder4 F0(.a(A[3:0]),  .b(B[3:0]),  .cin(cin),      .sum(sum[3:0]),  .Carry(ripple));
adder4 F1(.a(A[7:4]),  .b(B[7:4]),  .cin(ripple),  .sum(sum[7:4]),  .Carry(Cout));

endmodule

module adder4(
	 input [3:0]a,
	 input [3:0]b,
	 input cin,
	 output [3:0]sum,
	 output Carry
	 );
    wire w1,w2,w3;
adder_full G0(.a(a[0]),  .b(b[0]),  .cin(cin),  .sum(sum[0]),  .Carry(w1));
adder_full G1(.a(a[1]),  .b(b[1]),  .cin(w1),   .sum(sum[1]),  .Carry(w2));
adder_full G2(.a(a[2]),  .b(b[2]),  .cin(w2),   .sum(sum[2]),  .Carry(w3));
adder_full G3(.a(a[3]),  .b(b[3]),  .cin(w3),   .sum(sum[3]),  .Carry(Carry));

endmodule

module adder_full(
	 input a,
	 input b,
	 input cin,
	 output sum,
	 output Carry
	 );
	 wire w1,w2,w3;
adder_half H0(.a(a),    .b(b),    .sum(w1),   .Carry(w2));
adder_half H1(.a(w1),   .b(cin),  .sum(sum),  .Carry(w3));
or(Carry,w2,w3);

endmodule

module adder_half(
	 input a,
	 input b,
	 output sum,
	 output Carry
	 );
xor(sum,a,b);
and(Carry,a,b);

endmodule
