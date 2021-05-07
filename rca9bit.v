`timescale 1ns / 1ps

`include"rca8bit.v"
module rca9bit(
    input [8:0] A,
    input [8:0] B,
    input cin,
    output [8:0] ans,
    output cout
    );
	 wire Cout;
rca8bit adder0(A[7:0],  B[7:0], cin,  ans[7:0],  Cout);
FA fa0(.a(A[8]),  .b(B[8]),  .ci(Cout),  .sum(ans[8]),  .Carry(cout));

endmodule

module FA(
	 input a,
	 input b,
	 input cin,
	 output sum,
	 output Carry
	 );
	 wire w1,w2,w3;
HA (.a(a),    .b(b),    .sum(w1),   .Carry(w2));
HA (.a(w1),   .b(cin),  .sum(sum),  .Carry(w3));
or(Carry,w2,w3);

endmodule

module HA(
	 input a,
	 input b,
	 output sum,
	 output Carry
	 );
xor(sum,a,b);
and(Carry,a,b);

endmodule
