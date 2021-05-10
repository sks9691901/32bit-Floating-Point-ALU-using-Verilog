`include"add_sub.v"
`include"mul.v"
`include "div.v"
module ALU (
    input [31:0]A,
    input [31:0]B,
    input [2:0]operation,
    output Exception,
    output Overflow,
    output Underflow,
    output [31:0]Result
);
// operation[2:0]
//      000         =>   Addition
//      001         =>   Substraction
//      010         =>   Multiplication
//      011         =>   Division

wire [31:0]result_add,result_sub,result_mul,result_div;

// Subtraction is also a type of addition so it is necessary to send sign bit
// 1'b0 is for addition of operands
// 1'b1 is for subtraction of operands
add_sub  Add(.A(A[31:0]),.B(B[31:0]),.sign(1'b0),.Exception(Exc_add),.Overflow(OF_add),.Underflow(UF_add),.Result(result_add[31:0]));
add_sub  Sub(.A(A[31:0]),.B(B[31:0]),.sign(1'b1),.Exception(Exc_sub),.Overflow(OF_sub),.Underflow(UF_sub),.Result(result_sub[31:0]));
mul      Mul(.A(A[31:0]),.B(B[31:0]),            .Exception(Exc_mul),.Overflow(OF_mul),.Underflow(UF_mul),.Result(result_mul[31:0]));
div      Div(.A(A[31:0]),.B(B[31:0]),            .Exception(Exc_div),.Overflow(OF_div),.Underflow(UF_div),.Result(result_div[31:0]));

mux_multi_41 MUX1  (.I1({Exc_add,OF_add,UF_add,result_add[31:0]}), 
                    .I2({Exc_sub,OF_sub,UF_sub,result_sub[31:0]}), 
                    .I3({Exc_mul,OF_mul,UF_mul,result_mul[31:0]}), 
                    .I4({Exc_div,OF_div,UF_div,result_div[31:0]}), 
                    .SL(operation[1:0]), 
                    .Y({Exception, Overflow,   Underflow,  Result[31:0]}));

endmodule

module mux_multi_41(
    input [34:0]I1,
    input [34:0]I2,
    input [34:0]I3,
    input [34:0]I4,
    input [1:0]SL,
    output [34:0]Y
);
mux41 mx00(.I1(I1[34]), .I2(I2[34]), .I3(I3[34]), .I4(I4[34]), .S(SL[1:0]), .Y(Y[34]));
mux41 mx01(.I1(I1[33]), .I2(I2[33]), .I3(I3[33]), .I4(I4[33]), .S(SL[1:0]), .Y(Y[33]));
mux41 mx02(.I1(I1[32]), .I2(I2[32]), .I3(I3[32]), .I4(I4[32]), .S(SL[1:0]), .Y(Y[32]));
mux41 mx03(.I1(I1[31]), .I2(I2[31]), .I3(I3[31]), .I4(I4[31]), .S(SL[1:0]), .Y(Y[31]));
mux41 mx04(.I1(I1[30]), .I2(I2[30]), .I3(I3[30]), .I4(I4[30]), .S(SL[1:0]), .Y(Y[30]));
mux41 mx05(.I1(I1[29]), .I2(I2[29]), .I3(I3[29]), .I4(I4[29]), .S(SL[1:0]), .Y(Y[29]));
mux41 mx06(.I1(I1[28]), .I2(I2[28]), .I3(I3[28]), .I4(I4[28]), .S(SL[1:0]), .Y(Y[28]));
mux41 mx07(.I1(I1[27]), .I2(I2[27]), .I3(I3[27]), .I4(I4[27]), .S(SL[1:0]), .Y(Y[27]));
mux41 mx08(.I1(I1[26]), .I2(I2[26]), .I3(I3[26]), .I4(I4[26]), .S(SL[1:0]), .Y(Y[26]));
mux41 mx09(.I1(I1[25]), .I2(I2[25]), .I3(I3[25]), .I4(I4[25]), .S(SL[1:0]), .Y(Y[25]));
mux41 mx10(.I1(I1[24]), .I2(I2[24]), .I3(I3[24]), .I4(I4[24]), .S(SL[1:0]), .Y(Y[24]));
mux41 mx11(.I1(I1[23]), .I2(I2[23]), .I3(I3[23]), .I4(I4[23]), .S(SL[1:0]), .Y(Y[23]));
mux41 mx12(.I1(I1[22]), .I2(I2[22]), .I3(I3[22]), .I4(I4[22]), .S(SL[1:0]), .Y(Y[22]));
mux41 mx13(.I1(I1[21]), .I2(I2[21]), .I3(I3[21]), .I4(I4[21]), .S(SL[1:0]), .Y(Y[21]));
mux41 mx14(.I1(I1[20]), .I2(I2[20]), .I3(I3[20]), .I4(I4[20]), .S(SL[1:0]), .Y(Y[20]));
mux41 mx15(.I1(I1[19]), .I2(I2[19]), .I3(I3[19]), .I4(I4[19]), .S(SL[1:0]), .Y(Y[19]));
mux41 mx16(.I1(I1[18]), .I2(I2[18]), .I3(I3[18]), .I4(I4[18]), .S(SL[1:0]), .Y(Y[18]));
mux41 mx17(.I1(I1[17]), .I2(I2[17]), .I3(I3[17]), .I4(I4[17]), .S(SL[1:0]), .Y(Y[17]));
mux41 mx18(.I1(I1[16]), .I2(I2[16]), .I3(I3[16]), .I4(I4[16]), .S(SL[1:0]), .Y(Y[16]));
mux41 mx19(.I1(I1[15]), .I2(I2[15]), .I3(I3[15]), .I4(I4[15]), .S(SL[1:0]), .Y(Y[15]));
mux41 mx20(.I1(I1[14]), .I2(I2[14]), .I3(I3[14]), .I4(I4[14]), .S(SL[1:0]), .Y(Y[14]));
mux41 mx21(.I1(I1[13]), .I2(I2[13]), .I3(I3[13]), .I4(I4[13]), .S(SL[1:0]), .Y(Y[13]));
mux41 mx22(.I1(I1[12]), .I2(I2[12]), .I3(I3[12]), .I4(I4[12]), .S(SL[1:0]), .Y(Y[12]));
mux41 mx23(.I1(I1[11]), .I2(I2[11]), .I3(I3[11]), .I4(I4[11]), .S(SL[1:0]), .Y(Y[11]));
mux41 mx24(.I1(I1[10]), .I2(I2[10]), .I3(I3[10]), .I4(I4[10]), .S(SL[1:0]), .Y(Y[10]));
mux41 mx25(.I1(I1[9]),  .I2(I2[9]),  .I3(I3[9]),  .I4(I4[9]),  .S(SL[1:0]), .Y(Y[9]));
mux41 mx26(.I1(I1[8]),  .I2(I2[8]),  .I3(I3[8]),  .I4(I4[8]),  .S(SL[1:0]), .Y(Y[8]));
mux41 mx27(.I1(I1[7]),  .I2(I2[7]),  .I3(I3[7]),  .I4(I4[7]),  .S(SL[1:0]), .Y(Y[7]));
mux41 mx28(.I1(I1[6]),  .I2(I2[6]),  .I3(I3[6]),  .I4(I4[6]),  .S(SL[1:0]), .Y(Y[6]));
mux41 mx29(.I1(I1[5]),  .I2(I2[5]),  .I3(I3[5]),  .I4(I4[5]),  .S(SL[1:0]), .Y(Y[5]));
mux41 mx30(.I1(I1[4]),  .I2(I2[4]),  .I3(I3[4]),  .I4(I4[4]),  .S(SL[1:0]), .Y(Y[4]));
mux41 mx31(.I1(I1[3]),  .I2(I2[3]),  .I3(I3[3]),  .I4(I4[3]),  .S(SL[1:0]), .Y(Y[3]));
mux41 mx32(.I1(I1[2]),  .I2(I2[2]),  .I3(I3[2]),  .I4(I4[2]),  .S(SL[1:0]), .Y(Y[2]));
mux41 mx33(.I1(I1[1]),  .I2(I2[1]),  .I3(I3[1]),  .I4(I4[1]),  .S(SL[1:0]), .Y(Y[1]));
mux41 mx34(.I1(I1[0]),  .I2(I2[0]),  .I3(I3[0]),  .I4(I4[0]),  .S(SL[1:0]), .Y(Y[0]));

endmodule

module mux41(
    input I1,
    input I2,
    input I3,
    input I4,
    input [1:0]S,
    output Y
);
wire invS0,invS1,select1,select2,select3,select4;
not(invS0,S[0]);
not(invS1,S[1]);
and(select1,  invS1,  invS0,  I1);
and(select2,  invS1,  S[0],   I2);
and(select3,  S[1],   invS0,  I3);
and(select4,  S[1],   S[0],   I4);
or(Y,select1,select2,select3,select4);

endmodule
