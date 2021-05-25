`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:29:32 05/09/2021 
// Design Name: 
// Module Name:    div 
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

module div(
		input [31:0] A,
		input [31:0] B,
		output Exception,
		output Overflow,
		output Underflow,
		output [31:0] Result
		);
wire result_sign,expo_sign,expo_sign_comp,inc_dec_expo,temp_expo_sign,temp_expo_sign_comp;
wire [7:0]res_expo;
wire [7:0] comp_expo_B,diff,temp_expo,temp_expo_comp,final_res_expo;
wire [4:0]change_expo;
wire [7:0]change_expo_comp;
wire [47:0] div_quotient,div_qoutient_normalised; //48 Bits

not(Overflow,1'b1);
not(Underflow,1'b1);
// Result sign will be xor of sign bit of operands
xor (result_sign,A[31],B[31]);

// Subtracting exponents and adding BIAS
complement_div C01(.I(B[30:23]), .ctrl(1'b1), .O(comp_expo_B[7:0]));
rca8bit_div    C02(.A(A[30:23]), .B(comp_expo_B[7:0]), .Cin(1'b1), .Sum(diff[7:0]), .Cout(expo_sign));
not(expo_sign_comp,expo_sign);
rca8bit_div    C03(.A(diff[7:0]), .B(8'b01111111), .Cin(1'b0), .Sum(res_expo[7:0]), .Cout());

//Exception flag sets 1 if either one of the exponent is 255 or  B is 0.
wire bitandA,bitandB,bitnorB,zero;
bitand_div C04(.bitandin(A[30:23]),.bitandout(bitandA));
bitand_div C05(.bitandin(B[30:23]),.bitandout(bitandB));
bitnor_div C06(.bitnorin(A[30:0]), .bitnorout(zero)   );
bitnor_div C07(.bitnorin(B[30:0]), .bitnorout(bitnorB));
or(Exception,bitandA,bitandB,bitnorB);

//If exponent is equal to zero then hidden bit/implied bit will be 0 for that respective significand else it will be 1
wire bitorA,bitorB;
bitor_div  C08(.bitorin(A[30:23]),.bitorout(bitorA));
bitor_div  C09(.bitorin(B[30:23]),.bitorout(bitorB));

// Calculating DIVISION ***************************************************************************************************************
// Add divisord no. of zeros in front of dividend and add one zero in front of divisor
divide C10(.dividend({24'd0,bitorA,A[22:0]}), .divisor({1'b0,bitorB,B[22:0]}), .quotient(div_quotient[47:0]));
// Shifting of quotient for implied bit
encoder_div C11(.significand_in(div_quotient[47:0]), .shift({inc_dec_expo,change_expo[4:0]}), .significand_out(div_qoutient_normalised[47:0]));
// Add or subtract the shift from exponent to get Result exponent
complement_div C12(.I({3'd0,change_expo[4:0]}), .ctrl(inc_dec_expo), .O(change_expo_comp[7:0]));
rca8bit_div    C13(.A(res_expo[7:0]), .B(change_expo_comp[7:0]), .Cin(inc_dec_expo), .Sum(final_res_expo[7:0]), .Cout(temp_expo_sign));

//not(temp_expo_sign_comp,temp_expo_sign);
//complement C14(.I(temp_expo[7:0]), .ctrl(temp_expo_sign_comp), .O(temp_expo_comp[7:0]));
//rca8bit    C15(.A(temp_expo_comp[7:0]), .B(8'd0), .Cin(temp_expo_sign_comp), .Sum(final_res_expo[7:0]), .Cout());

// Multiplexer to choose specific outputs for specific conditions
wire [31:0]ripple_result_1;
mux_multi_div C16( .A({result_sign,final_res_expo[7:0],div_qoutient_normalised[46:24]}), .B(32'hFFFFFFFF),       .SL(Exception),    .O(ripple_result_1[31:0]));
mux_multi_div C17( .A(ripple_result_1[31:0]),                 .B({result_sign,31'd0}), .SL(zero),         .O(Result[31:0]));

endmodule

// division module
module  divide(
	input [47:0]dividend,
	input [24:0]divisor,
	output [47:0]quotient
	 );
wire [23:0]next01,next02,next03,next04,next05,next06,next07,next08,next09,next10,next11,next12,next13,next14,next15,next16,next17,next18,next19,next20,next21,next22,next23,next24;
wire [23:0]next25,next26,next27,next28,next29,next30,next31,next32,next33,next34,next35,next36,next37,next38,next39,next40,next41,next42,next43,next44,next45,next46,next47;
	// take 25 bits from dividend, try to subtract divisor (using 2's complement)
        // if carry is zero => unable to subtract and quotient is 0
	// if carry is 1 => subtracted successfully and quotient is 1
        // in next step move one bit forward do the same thing again and again
procedure P01(.dividend_part(dividend[47:23]),             .divisor_part(divisor[24:0]), .sub_part(next01[23:0]), .q(quotient[47]));
procedure P02(.dividend_part({next01[23:0],dividend[22]}), .divisor_part(divisor[24:0]), .sub_part(next02[23:0]), .q(quotient[46]));
procedure P03(.dividend_part({next02[23:0],dividend[21]}), .divisor_part(divisor[24:0]), .sub_part(next03[23:0]), .q(quotient[45]));
procedure P04(.dividend_part({next03[23:0],dividend[20]}), .divisor_part(divisor[24:0]), .sub_part(next04[23:0]), .q(quotient[44]));
procedure P05(.dividend_part({next04[23:0],dividend[19]}), .divisor_part(divisor[24:0]), .sub_part(next05[23:0]), .q(quotient[43]));
procedure P06(.dividend_part({next05[23:0],dividend[18]}), .divisor_part(divisor[24:0]), .sub_part(next06[23:0]), .q(quotient[42]));
procedure P07(.dividend_part({next06[23:0],dividend[17]}), .divisor_part(divisor[24:0]), .sub_part(next07[23:0]), .q(quotient[41]));
procedure P08(.dividend_part({next07[23:0],dividend[16]}), .divisor_part(divisor[24:0]), .sub_part(next08[23:0]), .q(quotient[40]));
procedure P09(.dividend_part({next08[23:0],dividend[15]}), .divisor_part(divisor[24:0]), .sub_part(next09[23:0]), .q(quotient[39]));
procedure P10(.dividend_part({next09[23:0],dividend[14]}), .divisor_part(divisor[24:0]), .sub_part(next10[23:0]), .q(quotient[38]));
procedure P11(.dividend_part({next10[23:0],dividend[13]}), .divisor_part(divisor[24:0]), .sub_part(next11[23:0]), .q(quotient[37]));
procedure P12(.dividend_part({next11[23:0],dividend[12]}), .divisor_part(divisor[24:0]), .sub_part(next12[23:0]), .q(quotient[36]));
procedure P13(.dividend_part({next12[23:0],dividend[11]}), .divisor_part(divisor[24:0]), .sub_part(next13[23:0]), .q(quotient[35]));
procedure P14(.dividend_part({next13[23:0],dividend[10]}), .divisor_part(divisor[24:0]), .sub_part(next14[23:0]), .q(quotient[34]));
procedure P15(.dividend_part({next14[23:0],dividend[9]}),  .divisor_part(divisor[24:0]), .sub_part(next15[23:0]), .q(quotient[33]));
procedure P16(.dividend_part({next15[23:0],dividend[8]}),  .divisor_part(divisor[24:0]), .sub_part(next16[23:0]), .q(quotient[32]));
procedure P17(.dividend_part({next16[23:0],dividend[7]}),  .divisor_part(divisor[24:0]), .sub_part(next17[23:0]), .q(quotient[31]));
procedure P18(.dividend_part({next17[23:0],dividend[6]}),  .divisor_part(divisor[24:0]), .sub_part(next18[23:0]), .q(quotient[30]));
procedure P19(.dividend_part({next18[23:0],dividend[5]}),  .divisor_part(divisor[24:0]), .sub_part(next19[23:0]), .q(quotient[29]));
procedure P20(.dividend_part({next19[23:0],dividend[4]}),  .divisor_part(divisor[24:0]), .sub_part(next20[23:0]), .q(quotient[28]));
procedure P21(.dividend_part({next20[23:0],dividend[3]}),  .divisor_part(divisor[24:0]), .sub_part(next21[23:0]), .q(quotient[27]));
procedure P22(.dividend_part({next21[23:0],dividend[2]}),  .divisor_part(divisor[24:0]), .sub_part(next22[23:0]), .q(quotient[26]));
procedure P23(.dividend_part({next22[23:0],dividend[1]}),  .divisor_part(divisor[24:0]), .sub_part(next23[23:0]), .q(quotient[25]));
procedure P24(.dividend_part({next23[23:0],dividend[0]}),  .divisor_part(divisor[24:0]), .sub_part(next24[23:0]), .q(quotient[24]));
// decimal point position
procedure P25(.dividend_part({next24[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next25[23:0]), .q(quotient[23]));
procedure P26(.dividend_part({next25[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next26[23:0]), .q(quotient[22]));
procedure P27(.dividend_part({next26[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next27[23:0]), .q(quotient[21]));
procedure P28(.dividend_part({next27[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next28[23:0]), .q(quotient[20]));
procedure P29(.dividend_part({next28[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next29[23:0]), .q(quotient[19]));
procedure P30(.dividend_part({next29[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next30[23:0]), .q(quotient[18]));
procedure P31(.dividend_part({next30[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next31[23:0]), .q(quotient[17]));
procedure P32(.dividend_part({next31[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next32[23:0]), .q(quotient[16]));
procedure P33(.dividend_part({next32[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next33[23:0]), .q(quotient[15]));
procedure P34(.dividend_part({next33[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next34[23:0]), .q(quotient[14]));
procedure P35(.dividend_part({next34[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next35[23:0]), .q(quotient[13]));
procedure P36(.dividend_part({next35[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next36[23:0]), .q(quotient[12]));
procedure P37(.dividend_part({next36[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next37[23:0]), .q(quotient[11]));
procedure P38(.dividend_part({next37[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next38[23:0]), .q(quotient[10]));
procedure P39(.dividend_part({next38[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next39[23:0]), .q(quotient[9]) );
procedure P40(.dividend_part({next39[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next40[23:0]), .q(quotient[8]) );
procedure P41(.dividend_part({next40[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next41[23:0]), .q(quotient[7]) );
procedure P42(.dividend_part({next41[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next42[23:0]), .q(quotient[6]) );
procedure P43(.dividend_part({next42[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next43[23:0]), .q(quotient[5]) );
procedure P44(.dividend_part({next43[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next44[23:0]), .q(quotient[4]) );
procedure P45(.dividend_part({next44[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next45[23:0]), .q(quotient[3]) );
procedure P46(.dividend_part({next45[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next46[23:0]), .q(quotient[2]) );
procedure P47(.dividend_part({next46[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(next47[23:0]), .q(quotient[1]) );
procedure P48(.dividend_part({next47[23:0],1'b0}),         .divisor_part(divisor[24:0]), .sub_part(            ), .q(quotient[0]) );

endmodule //divide

module procedure(
	input [24:0]dividend_part,
	input [24:0]divisor_part,
	output [23:0]sub_part, // subtraction dividend_part - divisor_part
	output q
	 );
wire [24:0]comp_division_part,difference;
wire [7:0]no_use;
// we have to subtract the divisor from dividend part using 25bit adder
// Here we are using 2's complement method for subtraction so
// if carry is zero, means unable to subtract and unable to divide, hence give zero to quotient
// if carry is zero, means subtraction result is positive and hence add give to quotient
complement_div  comp1     (.I(divisor_part[24:17]), .ctrl(1'b1), .O(comp_division_part[24:17]));
complement_div  comp2     (.I(divisor_part[16:9]),  .ctrl(1'b1), .O(comp_division_part[16:9]) );
complement_div  comp3     (.I(divisor_part[8:1]),   .ctrl(1'b1), .O(comp_division_part[8:1])  );
not(comp_division_part[0],divisor_part[0]);

rca25bit    rca251    (.A(dividend_part[24:0]), .B(comp_division_part[24:0]), .Cin(1'b1), .Sum(difference[24:0]), .Cout(q));
mux_multi_div   multi_mux (.A({8'd0,dividend_part[23:0]}), .B({8'd0,difference[23:0]}), .SL(q), .O({no_use[7:0],sub_part[23:0]}));
endmodule //procedure

// encoder module is used for shifting purpose
module encoder_div(
     input  [47:0]significand_in,
     output reg [5:0]shift, // 6th bit is for sign, whether left shift or right shift
     output reg [47:0]significand_out
     );

always @(significand_in)
begin
	casex (significand_in)

	 //         6         5         4        .3         2         1
         //         8765 4321 8765 4321 8765 4321 8765 4321 8765 4321 8765 4321 
		48'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 0;
			shift = 6'b010111; // right shift and hence added to exponent
		end
		48'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 1;
			shift = 6'b010110;
		end
		48'b001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 2;
			shift = 6'b010101;
		end
		48'b0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 3;
			shift = 6'b010100;
		end
		48'b0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 4;
			shift = 6'b010011;
		end
		48'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 5;
			shift = 6'b010010;
		end
		48'b0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 6;
			shift = 6'b010001;
		end
		48'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 7;
			shift = 6'b010000;
		end
		48'b0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 8;
			shift = 6'b001111;
		end
		48'b0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 9;
			shift = 6'b001110;
		end
		48'b0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 10;
			shift = 6'b001101;
		end
		48'b0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 11;
			shift = 6'b001100;
		end
		48'b0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 12;
			shift = 6'b001011;
		end
		48'b0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 13;
			shift = 6'b001010;
		end
		48'b0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 14;
			shift = 6'b001001;
		end
		48'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 15;
			shift = 6'b001000;
		end
		48'b0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 16;
			shift = 6'b000111;
		end
		48'b0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 17;
			shift = 6'b000110;
		end
		48'b0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 18;
			shift = 6'b000101;
		end
		48'b0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 19;
			shift = 6'b000100;
		end
		48'b0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 20;
			shift = 6'b000011;
		end
		48'b0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 21;
			shift = 6'b000010;
		end
		48'b0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 22;
			shift = 6'b000001;
		end
		48'b0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 23;
			shift = 6'b000000;
		end
		48'b0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 24;
			shift = 6'b100001; // Left shift and hence subtracted from exponent
		end
		48'b0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 25;
			shift = 6'b100010;
		end
		48'b0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 26;
			shift = 6'b100011;
		end
		48'b0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 27;
			shift = 6'b100100;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 28;
			shift = 6'b100101;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 29;
			shift = 6'b100110;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 30;
			shift = 6'b100111;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 31;
			shift = 6'b101000;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 32;
			shift = 6'b101001;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 33;
			shift = 6'b101010;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 34;
			shift = 6'b101011;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 35;
			shift = 6'b101100;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 36;
			shift = 6'b101101;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx : 
		begin
			significand_out = significand_in << 37;
			shift = 6'b101110;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx : 
		begin
			significand_out = significand_in << 38;
			shift = 6'b101111;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx : 
		begin
			significand_out = significand_in << 39;
			shift = 6'b110000;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx : 
		begin
			significand_out = significand_in << 40;
			shift = 6'b110001;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx : 
		begin
			significand_out = significand_in << 41;
			shift = 6'b110010;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx : 
		begin
			significand_out = significand_in << 42;
			shift = 6'b110011;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx : 
		begin
			significand_out = significand_in << 43;
			shift = 6'b110100;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx : 
		begin
			significand_out = significand_in << 44;
			shift = 6'b110101;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx : 
		begin
			significand_out = significand_in << 45;
			shift = 6'b110110;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x : 
		begin
			significand_out = significand_in << 46;
			shift = 6'b110111;
		end
		48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001 : 
		begin
			significand_out = significand_in << 47;
			shift = 6'b111000;
		end
	endcase
end

endmodule

// new_module_name_div

module bitand_div(
	 input [7:0]bitandin,
	 output bitandout
	 );
and(bitandout,bitandin[7],bitandin[6],bitandin[5],bitandin[4],bitandin[3],bitandin[2],bitandin[1],bitandin[0]);
endmodule

module bitnor_div(
	 input [30:0]bitnorin,
	 output bitnorout
	 );
nor(bitnorout,bitnorin[30],bitnorin[29],bitnorin[28],bitnorin[27],bitnorin[26],bitnorin[25],bitnorin[24],bitnorin[23],bitnorin[22],bitnorin[21],bitnorin[20],bitnorin[19],bitnorin[18],bitnorin[17],bitnorin[16],bitnorin[15],bitnorin[14],bitnorin[13],bitnorin[12],bitnorin[11],bitnorin[10],bitnorin[9],bitnorin[8],bitnorin[7],bitnorin[6],bitnorin[5],bitnorin[4],bitnorin[3],bitnorin[2],bitnorin[1],bitnorin[0]);
endmodule

module bitor_div(
	 input [7:0]bitorin,
	 output bitorout
	 );
or(bitorout,bitorin[7],bitorin[6],bitorin[5],bitorin[4],bitorin[3],bitorin[2],bitorin[1],bitorin[0]);
endmodule

module complement_div(
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

module rca25bit(
	 input [24:0]A,
	 input [24:0]B,
	 input Cin,
	 output [24:0]Sum,
	 output Cout
	 );
rca8bit_div        adder81   (.A(A[7:0]),   .B(B[7:0]),   .Cin(Cin),      .Sum(Sum[7:0]),   .Cout(ripple1));
rca8bit_div        adder82   (.A(A[15:8]),  .B(B[15:8]),  .Cin(ripple1),  .Sum(Sum[15:8]),  .Cout(ripple2));
rca8bit_div        adder83   (.A(A[23:16]), .B(B[23:16]), .Cin(ripple2),  .Sum(Sum[23:16]), .Cout(ripple3));
adder_full_div     adder41(.a(A[24]),    .b(B[24]),    .cin(ripple3),  .sum(Sum[24]),    .carry(Cout));
endmodule

module rca8bit_div(
    input [7:0] A,
    input [7:0] B,
	 input Cin,
	 output [7:0] Sum,
	 output Cout
    );

adder4_div F0( .a(A[3:0]),  .b(B[3:0]),  .cin(Cin),      .sum(Sum[3:0]),  .carry(ripple));
adder4_div F1( .a(A[7:4]),  .b(B[7:4]),  .cin(ripple),   .sum(Sum[7:4]),  .carry(Cout));
endmodule

module adder4_div(
	 input [3:0]a,
	 input [3:0]b,
	 input cin,
	 output [3:0]sum,
	 output carry
	 );
wire w1,w2,w3;
adder_full_div G0(.a(a[0]),  .b(b[0]),  .cin(cin),  .sum(sum[0]),  .carry(w1));
adder_full_div G1(.a(a[1]),  .b(b[1]),  .cin(w1),   .sum(sum[1]),  .carry(w2));
adder_full_div G2(.a(a[2]),  .b(b[2]),  .cin(w2),   .sum(sum[2]),  .carry(w3));
adder_full_div G3(.a(a[3]),  .b(b[3]),  .cin(w3),   .sum(sum[3]),  .carry(carry));
endmodule

module adder_full_div(
	 input a,
	 input b,
	 input cin,
	 output sum,
	 output carry
	 );
wire w1,w2,w3;
adder_half_div H0(.a(a),    .b(b),    .sum(w1),   .carry(w2));
adder_half_div H1(.a(w1),   .b(cin),  .sum(sum),  .carry(w3));
or(carry,w2,w3);
endmodule

module adder_half_div(
	 input a,
	 input b,
	 output sum,
	 output carry
	 );
xor(sum,a,b);
and(carry,a,b);
endmodule

module mux_multi_div(
	 input [31:0]A,
	 input [31:0]B,
	 input SL,
	 output [31:0]O
	 );
mux_div M01 (.fi(A[31]),.si(B[31]),.SL(SL),.Y(O[31]));
mux_div M02 (.fi(A[30]),.si(B[30]),.SL(SL),.Y(O[30]));
mux_div M03 (.fi(A[29]),.si(B[29]),.SL(SL),.Y(O[29]));
mux_div M04 (.fi(A[28]),.si(B[28]),.SL(SL),.Y(O[28]));
mux_div M05 (.fi(A[27]),.si(B[27]),.SL(SL),.Y(O[27]));
mux_div M06 (.fi(A[26]),.si(B[26]),.SL(SL),.Y(O[26]));
mux_div M07 (.fi(A[25]),.si(B[25]),.SL(SL),.Y(O[25]));
mux_div M08 (.fi(A[24]),.si(B[24]),.SL(SL),.Y(O[24]));
mux_div M09 (.fi(A[23]),.si(B[23]),.SL(SL),.Y(O[23]));
mux_div M10 (.fi(A[22]),.si(B[22]),.SL(SL),.Y(O[22]));
mux_div M11 (.fi(A[21]),.si(B[21]),.SL(SL),.Y(O[21]));
mux_div M12 (.fi(A[20]),.si(B[20]),.SL(SL),.Y(O[20]));
mux_div M13 (.fi(A[19]),.si(B[19]),.SL(SL),.Y(O[19]));
mux_div M14 (.fi(A[18]),.si(B[18]),.SL(SL),.Y(O[18]));
mux_div M15 (.fi(A[17]),.si(B[17]),.SL(SL),.Y(O[17]));
mux_div M16 (.fi(A[16]),.si(B[16]),.SL(SL),.Y(O[16]));
mux_div M17 (.fi(A[15]),.si(B[15]),.SL(SL),.Y(O[15]));
mux_div M18 (.fi(A[14]),.si(B[14]),.SL(SL),.Y(O[14]));
mux_div M19 (.fi(A[13]),.si(B[13]),.SL(SL),.Y(O[13]));
mux_div M20 (.fi(A[12]),.si(B[12]),.SL(SL),.Y(O[12]));
mux_div M21 (.fi(A[11]),.si(B[11]),.SL(SL),.Y(O[11]));
mux_div M22 (.fi(A[10]),.si(B[10]),.SL(SL),.Y(O[10]));
mux_div M23 (.fi(A[9]) ,.si(B[9]) ,.SL(SL),.Y(O[9]) );
mux_div M24 (.fi(A[8]) ,.si(B[8]) ,.SL(SL),.Y(O[8]) );
mux_div M25 (.fi(A[7]) ,.si(B[7]) ,.SL(SL),.Y(O[7]) );
mux_div M26 (.fi(A[6]) ,.si(B[6]) ,.SL(SL),.Y(O[6]) );
mux_div M27 (.fi(A[5]) ,.si(B[5]) ,.SL(SL),.Y(O[5]) );
mux_div M28 (.fi(A[4]) ,.si(B[4]) ,.SL(SL),.Y(O[4]) );
mux_div M29 (.fi(A[3]) ,.si(B[3]) ,.SL(SL),.Y(O[3]) );
mux_div M30 (.fi(A[2]) ,.si(B[2]) ,.SL(SL),.Y(O[2]) );
mux_div M31 (.fi(A[1]) ,.si(B[1]) ,.SL(SL),.Y(O[1]) );
mux_div M32 (.fi(A[0]) ,.si(B[0]) ,.SL(SL),.Y(O[0]) );
	 
endmodule

module mux_div(
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
