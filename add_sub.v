`timescale 1ns / 1ps
`include "rca8bit.v"

module addsub(
    input [31:0] input_a,
    input [31:0] input_b,
	 input a_sig,
	 input b_sig,
	 input [1:0] sign,  // 2 bit binary number , 00 => add ; 01 => substract ; 10 => multiply ; 11 => divide
    output [31:0] out_ans
    );
	 
wire [7:0]b_input;
wire [7:0]temp_sum;
wire carry_out;
wire [7:0]x_input;
wire [7:0]y_input;
wire [7:0]expo_diff;
wire expo_carry;
wire w1,w2;
// For (00)+ , (01)- and (11)/ => substraction of exponents is required hence w1 = 1'b1
// For (10)x => addition of exponents is required hence w1 = 1'b0
// acts as input carry for rca8bit adder
// if w1 = 1'b1 then taking it's xor with E2 will give complemented output of E2
// if w1 = 1'b0 then taking it's xor with E2 will give same output as E2
// Substraction of exponents using 2's compliment
assign w1 = 1'b1;
assign y_input = 8'b00000000;
not(b_input[0],input_b[23]);
not(b_input[1],input_b[24]);
not(b_input[2],input_b[25]);
not(b_input[3],input_b[26]);
not(b_input[4],input_b[27]);
not(b_input[5],input_b[28]);
not(b_input[6],input_b[29]);
not(b_input[7],input_b[30]);
rca8bit  sum(input_a[30:23],    b_input[7:0],    w1,    temp_sum[7:0],    carry_out);
not(w2,carry_out);
xor(x_input[0],w2,temp_sum[0]);
xor(x_input[1],w2,temp_sum[1]);
xor(x_input[2],w2,temp_sum[2]);
xor(x_input[3],w2,temp_sum[3]);
xor(x_input[4],w2,temp_sum[4]);
xor(x_input[5],w2,temp_sum[5]);
xor(x_input[6],w2,temp_sum[6]);
xor(x_input[7],w2,temp_sum[7]);
rca8bit diff(x_input[7:0],     y_input[7:0],    w2,    expo_diff[7:0],  expo_carry);


// If expo_carry is 1 then expo_difference is positive means expo_a > expo_b then mantissa_b should be right shifted by expo_diff
// If expo_carry is 0 then expo_difference is positive means expo_a < expo_b then mantissa_a should be right shifted by expo_diff
// expo_carry will act as SELECT LINE
// Twenty four CC are required (this CC will have two 2X1 MUX )
// Each of them take two inputs and based on select line they give two outputs
//                     _________________
//                     |               |
// mantissa_A[22:0]----|               |----------X[23:0] => (~S)B + SA  , X will go to the Big ALU
//    a_significand    | COMBINATIONAL |
//                     |    CIRCUIT    |
//                     |               |
//                     |               |
// mantissa_B[22:0]----|               |----------Y[23:0] => (~S)A + SB  , Y will go to the SHIFTER input then after shifting it will go to Big ALU
//    a_significand    |_______________|
//                             |
//                             |
//                  select line/carry_out
//
wire [23:0]shift_input; // SHIFT input
wire [23:0]shift_output; // SHIFT output
wire [23:0]temp;
wire [23:0]ALU_in_1; // input 1 of big ALU
wire [23:0]ALU_in_2; // input 2 of big ALU

 CC(.A(input_a[0]),  .B(input_b[0]),  .select_line(carry_out), .X_out(temp[0]),  .Y_out(shift_input[0]));
 CC(.A(input_a[1]),  .B(input_b[1]),  .select_line(carry_out), .X_out(temp[1]),  .Y_out(shift_input[1]));
 CC(.A(input_a[2]),  .B(input_b[2]),  .select_line(carry_out), .X_out(temp[2]),  .Y_out(shift_input[2]));
 CC(.A(input_a[3]),  .B(input_b[3]),  .select_line(carry_out), .X_out(temp[3]),  .Y_out(shift_input[3]));
 CC(.A(input_a[4]),  .B(input_b[4]),  .select_line(carry_out), .X_out(temp[4]),  .Y_out(shift_input[4]));
 CC(.A(input_a[5]),  .B(input_b[5]),  .select_line(carry_out), .X_out(temp[5]),  .Y_out(shift_input[5]));
 CC(.A(input_a[6]),  .B(input_b[6]),  .select_line(carry_out), .X_out(temp[6]),  .Y_out(shift_input[6]));
 CC(.A(input_a[7]),  .B(input_b[7]),  .select_line(carry_out), .X_out(temp[7]),  .Y_out(shift_input[7]));
 CC(.A(input_a[8]),  .B(input_b[8]),  .select_line(carry_out), .X_out(temp[8]),  .Y_out(shift_input[8]));
 CC(.A(input_a[9]),  .B(input_b[9]),  .select_line(carry_out), .X_out(temp[9]),  .Y_out(shift_input[9]));
 CC(.A(input_a[10]), .B(input_b[10]), .select_line(carry_out), .X_out(temp[10]), .Y_out(shift_input[10]));
 CC(.A(input_a[11]), .B(input_b[11]), .select_line(carry_out), .X_out(temp[11]), .Y_out(shift_input[11]));
 CC(.A(input_a[12]), .B(input_b[12]), .select_line(carry_out), .X_out(temp[12]), .Y_out(shift_input[12]));
 CC(.A(input_a[13]), .B(input_b[13]), .select_line(carry_out), .X_out(temp[13]), .Y_out(shift_input[13]));
 CC(.A(input_a[14]), .B(input_b[14]), .select_line(carry_out), .X_out(temp[14]), .Y_out(shift_input[14]));
 CC(.A(input_a[15]), .B(input_b[15]), .select_line(carry_out), .X_out(temp[15]), .Y_out(shift_input[15]));
 CC(.A(input_a[16]), .B(input_b[16]), .select_line(carry_out), .X_out(temp[16]), .Y_out(shift_input[16]));
 CC(.A(input_a[17]), .B(input_b[17]), .select_line(carry_out), .X_out(temp[17]), .Y_out(shift_input[17]));
 CC(.A(input_a[18]), .B(input_b[18]), .select_line(carry_out), .X_out(temp[18]), .Y_out(shift_input[18]));
 CC(.A(input_a[19]), .B(input_b[19]), .select_line(carry_out), .X_out(temp[19]), .Y_out(shift_input[19]));
 CC(.A(input_a[20]), .B(input_b[20]), .select_line(carry_out), .X_out(temp[20]), .Y_out(shift_input[20]));
 CC(.A(input_a[21]), .B(input_b[21]), .select_line(carry_out), .X_out(temp[21]), .Y_out(shift_input[21]));
 CC(.A(input_a[22]), .B(input_b[22]), .select_line(carry_out), .X_out(temp[22]), .Y_out(shift_input[22]));
 CC(.A(a_sig),       .B(b_sig),       .select_line(carry_out), .X_out(temp[23]), .Y_out(shift_input[23]));
//                                                             _________________
//                                                             |               |
//  temp[23:0]-------------------------------------------------|               |----------ALU_in_1[23:0] => (~S)B + SA
//                                                             | COMBINATIONAL |
//                                                             |    CIRCUIT    |
//                     __________________                      |               |
//                     |                |                      |               |
//  shift_in[23:0]-----|  RIGHT SHIFT   |----shift_out[23:0]---|               |----------ALU_in_2[23:0] => (~S)A + SB
//                     |________________|                      |_______________|
//                                                                     |
//                                                                     |
//                                                          select line/expo_carry
//
// shifting
assign shift_output = shift_input >> expo_diff;

 CC(.A(temp[0]),   .B(shift_output[0]),   .select_line(carry_out), .X_out(ALU_in_1[0]),   .Y_out(ALU_in_2[0]));
 CC(.A(temp[1]),   .B(shift_output[1]),   .select_line(carry_out), .X_out(ALU_in_1[1]),   .Y_out(ALU_in_2[1]));
 CC(.A(temp[2]),   .B(shift_output[2]),   .select_line(carry_out), .X_out(ALU_in_1[2]),   .Y_out(ALU_in_2[2]));
 CC(.A(temp[3]),   .B(shift_output[3]),   .select_line(carry_out), .X_out(ALU_in_1[3]),   .Y_out(ALU_in_2[3]));
 CC(.A(temp[4]),   .B(shift_output[4]),   .select_line(carry_out), .X_out(ALU_in_1[4]),   .Y_out(ALU_in_2[4]));
 CC(.A(temp[5]),   .B(shift_output[5]),   .select_line(carry_out), .X_out(ALU_in_1[5]),   .Y_out(ALU_in_2[5]));
 CC(.A(temp[6]),   .B(shift_output[6]),   .select_line(carry_out), .X_out(ALU_in_1[6]),   .Y_out(ALU_in_2[6]));
 CC(.A(temp[7]),   .B(shift_output[7]),   .select_line(carry_out), .X_out(ALU_in_1[7]),   .Y_out(ALU_in_2[7]));
 CC(.A(temp[8]),   .B(shift_output[8]),   .select_line(carry_out), .X_out(ALU_in_1[8]),   .Y_out(ALU_in_2[8]));
 CC(.A(temp[9]),   .B(shift_output[9]),   .select_line(carry_out), .X_out(ALU_in_1[9]),   .Y_out(ALU_in_2[9]));
 CC(.A(temp[10]),  .B(shift_output[10]),  .select_line(carry_out), .X_out(ALU_in_1[10]),  .Y_out(ALU_in_2[10]));
 CC(.A(temp[11]),  .B(shift_output[11]),  .select_line(carry_out), .X_out(ALU_in_1[11]),  .Y_out(ALU_in_2[11]));
 CC(.A(temp[12]),  .B(shift_output[12]),  .select_line(carry_out), .X_out(ALU_in_1[12]),  .Y_out(ALU_in_2[12]));
 CC(.A(temp[13]),  .B(shift_output[13]),  .select_line(carry_out), .X_out(ALU_in_1[13]),  .Y_out(ALU_in_2[13]));
 CC(.A(temp[14]),  .B(shift_output[14]),  .select_line(carry_out), .X_out(ALU_in_1[14]),  .Y_out(ALU_in_2[14]));
 CC(.A(temp[15]),  .B(shift_output[15]),  .select_line(carry_out), .X_out(ALU_in_1[15]),  .Y_out(ALU_in_2[15]));
 CC(.A(temp[16]),  .B(shift_output[16]),  .select_line(carry_out), .X_out(ALU_in_1[16]),  .Y_out(ALU_in_2[16]));
 CC(.A(temp[17]),  .B(shift_output[17]),  .select_line(carry_out), .X_out(ALU_in_1[17]),  .Y_out(ALU_in_2[17]));
 CC(.A(temp[18]),  .B(shift_output[18]),  .select_line(carry_out), .X_out(ALU_in_1[18]),  .Y_out(ALU_in_2[18]));
 CC(.A(temp[19]),  .B(shift_output[19]),  .select_line(carry_out), .X_out(ALU_in_1[19]),  .Y_out(ALU_in_2[19]));
 CC(.A(temp[20]),  .B(shift_output[20]),  .select_line(carry_out), .X_out(ALU_in_1[20]),  .Y_out(ALU_in_2[20]));
 CC(.A(temp[21]),  .B(shift_output[21]),  .select_line(carry_out), .X_out(ALU_in_1[21]),  .Y_out(ALU_in_2[21]));
 CC(.A(temp[22]),  .B(shift_output[22]),  .select_line(carry_out), .X_out(ALU_in_1[22]),  .Y_out(ALU_in_2[22]));
 CC(.A(temp[23]),  .B(shift_output[23]),  .select_line(carry_out), .X_out(ALU_in_1[23]),  .Y_out(ALU_in_2[23]));

// Addition or Substraction of mantissa

wire b_sign,opr;
wire [23:0]alu_in_2;

wire carry1,carry2,carry3,carry4,carry_inv,complement,mantissa_carry,ALU_carry;
wire [23:0]ALU_out;
wire [23:0]alu_temp1;
wire [23:0]alu_temp2;
wire [23:0]mantissa_result;
assign alu_temp2 = 24'b000000000000000000000000;

xor(b_sign,input_b[31],sign[0]);
xor(opr,b_sign,input_a[31]);

xor(alu_in_2[0], opr,ALU_in_2[0]);
xor(alu_in_2[1], opr,ALU_in_2[1]);
xor(alu_in_2[2], opr,ALU_in_2[2]);
xor(alu_in_2[3], opr,ALU_in_2[3]);
xor(alu_in_2[4], opr,ALU_in_2[4]);
xor(alu_in_2[5], opr,ALU_in_2[5]);
xor(alu_in_2[6], opr,ALU_in_2[6]);
xor(alu_in_2[7], opr,ALU_in_2[7]);
xor(alu_in_2[8], opr,ALU_in_2[8]);
xor(alu_in_2[9], opr,ALU_in_2[9]);
xor(alu_in_2[10],opr,ALU_in_2[10]);
xor(alu_in_2[11],opr,ALU_in_2[11]);
xor(alu_in_2[12],opr,ALU_in_2[12]);
xor(alu_in_2[13],opr,ALU_in_2[13]);
xor(alu_in_2[14],opr,ALU_in_2[14]);
xor(alu_in_2[15],opr,ALU_in_2[15]);
xor(alu_in_2[16],opr,ALU_in_2[16]);
xor(alu_in_2[17],opr,ALU_in_2[17]);
xor(alu_in_2[18],opr,ALU_in_2[18]);
xor(alu_in_2[19],opr,ALU_in_2[19]);
xor(alu_in_2[20],opr,ALU_in_2[20]);
xor(alu_in_2[21],opr,ALU_in_2[21]);
xor(alu_in_2[22],opr,ALU_in_2[22]);
xor(alu_in_2[23],opr,ALU_in_2[23]);

// Mantissa is 24bit number so we can instantiate 8bit adder three times

rca8bit mantissa_add_sub1( ALU_in_1[7:0],      alu_in_2[7:0],      opr,                mantissa_result[7:0],     carry1);
rca8bit mantissa_add_sub2( ALU_in_1[15:8],     alu_in_2[15:8],     carry1,             mantissa_result[15:8],    carry2);
rca8bit mantissa_add_sub3( ALU_in_1[23:16],    alu_in_2[23:16],    carry2,             mantissa_result[23:16],   mantissa_carry);

not(carry_inv,mantissa_carry);
and(complement,opr,carry_inv);

xor(alu_temp1[0],  complement, mantissa_result[0]);
xor(alu_temp1[1],  complement, mantissa_result[1]);
xor(alu_temp1[2],  complement, mantissa_result[2]);
xor(alu_temp1[3],  complement, mantissa_result[3]);
xor(alu_temp1[4],  complement, mantissa_result[4]);
xor(alu_temp1[5],  complement, mantissa_result[5]);
xor(alu_temp1[6],  complement, mantissa_result[6]);
xor(alu_temp1[7],  complement, mantissa_result[7]);
xor(alu_temp1[8],  complement, mantissa_result[8]);
xor(alu_temp1[9],  complement, mantissa_result[9]);
xor(alu_temp1[10], complement, mantissa_result[10]);
xor(alu_temp1[11], complement, mantissa_result[11]);
xor(alu_temp1[12], complement, mantissa_result[12]);
xor(alu_temp1[13], complement, mantissa_result[13]);
xor(alu_temp1[14], complement, mantissa_result[14]);
xor(alu_temp1[15], complement, mantissa_result[15]);
xor(alu_temp1[16], complement, mantissa_result[16]);
xor(alu_temp1[17], complement, mantissa_result[17]);
xor(alu_temp1[18], complement, mantissa_result[18]);
xor(alu_temp1[19], complement, mantissa_result[19]);
xor(alu_temp1[20], complement, mantissa_result[20]);
xor(alu_temp1[21], complement, mantissa_result[21]);
xor(alu_temp1[22], complement, mantissa_result[22]);
xor(alu_temp1[23], complement, mantissa_result[23]);

rca8bit ALU_result1( alu_temp1[7:0],        alu_temp2[7:0],        complement,          ALU_out[7:0],       carry3);
rca8bit ALU_result2( alu_temp1[15:8],       alu_temp2[15:8],       carry3,              ALU_out[15:8],      carry4);
rca8bit ALU_result3( alu_temp1[23:16],      alu_temp2[23:16],      carry4,              ALU_out[23:16],     ALU_carry);



endmodule

module CC(
	 input A,
	 input B,
	 input select_line,
	 output X_out,
	 output Y_out
	 );
wire inv_select_line;
wire or1,or2;
wire and1,and2,and3,and4;

not(inv_select_line,  select_line);

and(and1, inv_select_line, B);
and(and2, select_line,  A);
or(X_out, and1, and2);

and(and3, inv_select_line, A);
and(and4, select_line,  B);
or(Y_out, and3,and4);

endmodule
