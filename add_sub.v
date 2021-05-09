`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:00:10 05/08/2021 
// Design Name: 
// Module Name:    add_sub 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module add_sub(
     input [31:0]A,
     input  [31:0]B,
     input  sign,
     output Exception,
	  output zero,
     output [31:0]Result
);
wire [7:0]comp_B,diff,comp_diff,expo_diff,comp_dec_expo,temp_expo,comp_temp_expo,final_res_expo,final_res_expo1;
wire expo_sign,expo_sign_comp,real_sign,result_sign,bitorA,bitorB,bitandA,bitandB,bitor_mantissa,bitor_expo_diff,mantissa_carry;
wire a_sign_comp,and1,and2,or1,xor1,xnor1,comp_mantissa_carry,comp_real_sign,temp_bit1,temp_bit2,w1,nw1;
wire [31:0]operand_a,operand_b,res_expo,temp_result1,temp_result2;
wire [23:0]mantissa_a,mantissa_b,mantissa_b_comp,mantissa_sum,comp_mantissa_sum,final_mantissa_sum,normalised,not_normalised,final_normalised;
wire [4:0]dec_expo;

bitand     C01(.bitandin(A[30:23]), .bitandout(bitandA));
bitand     C02(.bitandin(B[30:23]), .bitandout(bitandB));
or(Exception,bitandA,bitandB);

complement C03(.I(B[30:23]), .ctrl(1'b1), .O(comp_B[7:0]));
rca8bit    C04(.A(A[30:23]), .B(comp_B[7:0]), .Cin(1'b1), .Sum(diff[7:0]), .Cout(expo_sign));
// expo sign = 1 => no swap
// expo sign = 0 => swapping
mux_multi  C05(.A(A[31:0]), .B(B[31:0]), .SL(expo_sign), .O(operand_b[31:0]));
mux_multi  C06(.A(B[31:0]), .B(A[31:0]), .SL(expo_sign), .O(operand_a[31:0])); // swapping done, now (operand_a > operand_b) always
// set exponent of result equal to larger exponent
mux_multi  C07(.A({24'd0,B[30:23]}), .B({24'd0,A[30:23]}), .SL(expo_sign), .O(res_expo[31:0]));

not(expo_sign_comp,expo_sign);
complement C08(.I(diff[7:0]), .ctrl(expo_sign_comp), .O(comp_diff[7:0]));
rca8bit    C09(.A(comp_diff[7:0]), .B(8'd0), .Cin(expo_sign_comp), .Sum(expo_diff[7:0]), .Cout()); // get expo_difference 

not(a_sign_comp,operand_a[31]);
xnor(xnor1,sign,operand_b[31]);
xor(xor1,sign,operand_b[31]);
and(and1,xnor1,operand_a[31]);
and(and2,xor1,a_sign_comp);
or(real_sign,and1,and2);

and(result_sign,operand_a[31],1'b1); // final answer sign bit

bitor      C10(.bitorin(operand_a[30:23]), .bitorout(bitorA));
bitor      C11(.bitorin(operand_b[30:23]), .bitorout(bitorB));

assign mantissa_a = {bitorA,operand_a[22:0]};
// shifting of mantissa
assign mantissa_b = {bitorB,operand_b[22:0]} >> expo_diff;

complement C12(.I(mantissa_b[7:0]  ), .ctrl(real_sign), .O(mantissa_b_comp[7:0])  );
complement C13(.I(mantissa_b[15:8] ), .ctrl(real_sign), .O(mantissa_b_comp[15:8]) );
complement C14(.I(mantissa_b[23:16]), .ctrl(real_sign), .O(mantissa_b_comp[23:16]));

rca24bit   C15(.A(mantissa_a[23:0] ), .B(mantissa_b_comp[23:0]), .Cin(real_sign), .Sum(mantissa_sum[23:0]), .Cout(mantissa_carry));
not(comp_mantissa_carry,mantissa_carry);
and(temp_bit1,real_sign,comp_mantissa_carry);
complement C16(.I(mantissa_sum[7:0]), .ctrl(temp_bit1), .O(comp_mantissa_sum[7:0]));
complement C17(.I(mantissa_sum[15:8]), .ctrl(temp_bit1), .O(comp_mantissa_sum[15:8]));
complement C18(.I(mantissa_sum[23:16]), .ctrl(temp_bit1), .O(comp_mantissa_sum[23:16]));
rca24bit   C19(.A(comp_mantissa_sum[23:0] ), .B(24'd0), .Cin(temp_bit1), .Sum(final_mantissa_sum[23:0]), .Cout());

bitnor      C20(.in(final_mantissa_sum[23:0]), .bitnorout(bitor_mantissa));
bitnor      C21(.in({16'd0,expo_diff[7:0]}), .bitnorout(bitor_expo_diff));
and(zero,bitor_mantissa,bitor_expo_diff);

not(comp_real_sign,real_sign);
and(temp_bit2,comp_real_sign,mantissa_carry);

demux_multi  C22(.I(final_mantissa_sum[23:0]), .SL(temp_bit2), .A(not_normalised[23:0]), .B(normalised[23:0]));

encoder      C23(.significand_in(not_normalised[23:0]), .shift(dec_expo[4:0]), .significand_out(final_normalised[23:0]));

complement   C24(.I({3'b000,dec_expo[4:0]}), .ctrl(1'b1), .O(comp_dec_expo[7:0]));
rca8bit      C25(.A(res_expo[7:0]), .B(comp_dec_expo[7:0]), .Cin(1'b1), .Sum(temp_expo[7:0]), .Cout(w1));
not(nw1,w1);
complement   C26(.I(temp_expo[7:0]), .ctrl(nw1), .O(comp_temp_expo[7:0]));
rca8bit      C27(.A(comp_temp_expo[7:0]), .B(8'b00000000), .Cin(nw1), .Sum(final_res_expo[7:0]), .Cout());
rca8bit      C28(.A(res_expo[7:0]), .B(8'd0), .Cin(temp_bit2), .Sum(final_res_expo1[7:0]), .Cout());
mux_multi    C29(.A({result_sign,final_res_expo[7:0],final_normalised[22:0]}), .B({result_sign,final_res_expo1[7:0],normalised[23:1]}), .SL(temp_bit2), .O(temp_result1[31:0]));
mux_multi    C30(.A(temp_result1[31:0]), .B(32'd0), .SL(zero), .O(temp_result2[31:0]));
mux_multi    C31(.A(temp_result2[31:0]), .B(32'hFFFFFFFF), .SL(Exception), .O(Result[31:0]));

endmodule

module bitand(
	 input [7:0]bitandin,
	 output bitandout
	 );
and(bitandout,bitandin[7],bitandin[6],bitandin[5],bitandin[4],bitandin[3],bitandin[2],bitandin[1],bitandin[0]);
endmodule

module bitor(
	 input [7:0]bitorin,
	 output bitorout
	 );
or(bitorout,bitorin[7],bitorin[6],bitorin[5],bitorin[4],bitorin[3],bitorin[2],bitorin[1],bitorin[0]);
endmodule

module bitnor(
	 input [22:0]in,
	 output bitnorout
	 );
nor(bitnorout,in[22],in[21],in[20],in[19],in[18],in[17],in[16],in[15],in[14],in[13],in[12],in[11],in[10],in[9],in[8],in[7],in[6],in[5],in[4],in[3],in[2],in[1],in[0]);
endmodule

module complement(
	 input [7:0]I,
	 input ctrl,
	 output [7:0]O
	 );
xor(O[7], ctrl, I[7]);
xor(O[6], ctrl, I[6]);
xor(O[5], ctrl, I[5]);
xor(O[4], ctrl, I[4]);
xor(O[3], ctrl, I[3]);
xor(O[2], ctrl, I[2]);
xor(O[1], ctrl, I[1]);
xor(O[0], ctrl, I[0]);

endmodule


module rca24bit(
	 input [23:0]A,
	 input [23:0]B,
	 input Cin,
	 output [23:0]Sum,
	 output Cout
	 );
rca8bit adder81(.A(A[7:0]), .B(B[7:0]), .Cin(Cin), .Sum(Sum[7:0]), .Cout(ripple1));
rca8bit adder82(.A(A[15:8]), .B(B[15:8]), .Cin(ripple1), .Sum(Sum[15:8]), .Cout(ripple2));
rca8bit adder83(.A(A[23:16]), .B(B[23:16]), .Cin(ripple2), .Sum(Sum[23:16]), .Cout(Cout));
	 
endmodule

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

module demux_multi(
	 input [23:0]I,
	 input SL,
	 output [23:0]A,
	 output [23:0]B
	 );
demux D01(.I(I[23]), .SL(SL), .A(A[23]), .B(B[23]));
demux D02(.I(I[22]), .SL(SL), .A(A[22]), .B(B[22]));
demux D03(.I(I[21]), .SL(SL), .A(A[21]), .B(B[21]));
demux D04(.I(I[20]), .SL(SL), .A(A[20]), .B(B[20]));
demux D05(.I(I[19]), .SL(SL), .A(A[19]), .B(B[19]));
demux D06(.I(I[18]), .SL(SL), .A(A[18]), .B(B[18]));
demux D07(.I(I[17]), .SL(SL), .A(A[17]), .B(B[17]));
demux D08(.I(I[16]), .SL(SL), .A(A[16]), .B(B[16]));
demux D09(.I(I[15]), .SL(SL), .A(A[15]), .B(B[15]));
demux D10(.I(I[14]), .SL(SL), .A(A[14]), .B(B[14]));
demux D11(.I(I[13]), .SL(SL), .A(A[13]), .B(B[13]));
demux D12(.I(I[12]), .SL(SL), .A(A[12]), .B(B[12]));
demux D13(.I(I[11]), .SL(SL), .A(A[11]), .B(B[11]));
demux D14(.I(I[10]), .SL(SL), .A(A[10]), .B(B[10]));
demux D15(.I(I[9]) , .SL(SL), .A(A[9]) , .B(B[9]) );
demux D16(.I(I[8]) , .SL(SL), .A(A[8]) , .B(B[8]) );
demux D17(.I(I[7]) , .SL(SL), .A(A[7]) , .B(B[7]) );
demux D18(.I(I[6]) , .SL(SL), .A(A[6]) , .B(B[6]) );
demux D19(.I(I[5]) , .SL(SL), .A(A[5]) , .B(B[5]) );
demux D20(.I(I[4]) , .SL(SL), .A(A[4]) , .B(B[4]) );
demux D21(.I(I[3]) , .SL(SL), .A(A[3]) , .B(B[3]) );
demux D22(.I(I[2]) , .SL(SL), .A(A[2]) , .B(B[2]) );
demux D23(.I(I[1]) , .SL(SL), .A(A[1]) , .B(B[1]) );
demux D24(.I(I[0]) , .SL(SL), .A(A[0]) , .B(B[0]) );
	 
endmodule

module demux(
	 input I,
	 input SL,
	 output A,
	 output B
	 );
wire invSL;
not(invSL,SL);
and(A,invSL,I);
and(B,SL,I);
endmodule

module encoder(
     input  [23:0]significand_in,
     output reg [4:0]shift,
     output reg [23:0]significand_out
     );


always @(significand_in)
begin
	casex (significand_in)
		24'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
			begin
			significand_out = significand_in;
			shift = 5'd0;
			end
		24'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx :
			begin						
			significand_out = significand_in << 1;
			shift = 5'd1;
			end

		24'b001x_xxxx_xxxx_xxxx_xxxx_xxxx :
			begin						
			significand_out = significand_in << 2;
			shift = 5'd2;
			end

		24'b0001_xxxx_xxxx_xxxx_xxxx_xxxx :
			begin 							
			significand_out = significand_in << 3;
			shift = 5'd3;
			end

		24'b0000_1xxx_xxxx_xxxx_xxxx_xxxx :
			begin						
			significand_out = significand_in << 4;
			shift = 5'd4;
			end

		24'b0000_01xx_xxxx_xxxx_xxxx_xxxx :
			begin						
			significand_out = significand_in << 5;
			shift = 5'd5;
			end

		24'b0000_001x_xxxx_xxxx_xxxx_xxxx :
			begin
			significand_out = significand_in << 6;
			shift = 5'd6;
			end

		24'b0000_0001_xxxx_xxxx_xxxx_xxxx :
			begin
			significand_out = significand_in << 7;
			shift = 5'd7;
			end

		24'b0000_0000_1xxx_xxxx_xxxx_xxxx :
			begin	
			significand_out = significand_in << 8;
			shift = 5'd8;
			end

		24'b0000_0000_01xx_xxxx_xxxx_xxxx : 	begin						// 24'h004000
									 				significand_out = significand_in << 9;
								 	 				shift = 5'd9;
						 				end

		24'b0000_0000_001x_xxxx_xxxx_xxxx : 	begin						// 24'h002000
									 				significand_out = significand_in << 10;
								 	 				shift = 5'd10;
								 		end

		24'b0000_0000_0001_xxxx_xxxx_xxxx : 	begin						// 24'h001000
									 				significand_out = significand_in << 11;
								 	 				shift = 5'd11;
										end

		24'b0000_0000_0000_1xxx_xxxx_xxxx : 	begin						// 24'h000800
									 				significand_out = significand_in << 12;
								 	 				shift = 5'd12;
						 				end

		24'b0000_0000_0000_01xx_xxxx_xxxx : 	begin						// 24'h000400
									 				significand_out = significand_in << 13;
								 	 				shift = 5'd13;
						 				end

		24'b0000_0000_0000_001x_xxxx_xxxx : 	begin						// 24'h000200
									 				significand_out = significand_in << 14;
								 	 				shift = 5'd14;
						 				end

		24'b0000_0000_0000_0001_xxxx_xxxx  : 	begin						// 24'h000100
									 				significand_out = significand_in << 15;
								 	 				shift = 5'd15;
						 				end

		24'b0000_0000_0000_0000_1xxx_xxxx : 	begin						// 24'h000080
									 				significand_out = significand_in << 16;
								 	 				shift = 5'd16;
								 		end

		24'b0000_0000_0000_0000_01xx_xxxx : 	begin						// 24'h000040
											 		significand_out = significand_in << 17;
										 	 		shift = 5'd17;
										end

		24'b0000_0000_0000_0000_001x_xxxx : 	begin						// 24'h000020
									 				significand_out = significand_in << 18;
								 	 				shift = 5'd18;
						 				end

		24'b0000_0000_0000_0000_0001_xxxx : 	begin						// 24'h000010
									 				significand_out = significand_in << 19;
								 	 				shift = 5'd19;
										end

		24'b0000_0000_0000_0000_0000_1xxx :	begin						// 24'h000008
									 				significand_out = significand_in << 20;
								 					shift = 5'd20;
						 				end

		24'b0000_0000_0000_0000_0000_01xx : 	begin						// 24'h000004
									 				significand_out = significand_in << 21;
								 	 				shift = 5'd21;
						 				end

		24'b0000_0000_0000_0000_0000_001x : 	begin						// 24'h000002
									 				significand_out = significand_in << 22;
								 	 				shift = 5'd22;
								 		end

		24'b0000_0000_0000_0000_0000_0001 : 	begin						// 24'h000001
									 				significand_out = significand_in << 23;
								 	 				shift = 5'd23;
										end

		24'b0000_0000_0000_0000_0000_0000 : 	begin						// 24'h000000
								 					significand_out = significand_in << 24;
							 	 					shift = 5'd24;
						 				end
	endcase
end

endmodule
