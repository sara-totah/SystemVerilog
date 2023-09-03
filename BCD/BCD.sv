module full_adder (
    input wire A,
    input wire B,
    input wire Cin,
    output wire Sum,
    output wire Cout
);

    wire w1, w2, w3, w4;

    xor #12 (w1, A, B); // XOR gate to generate sum
    and #8 (w2, A, B); // AND gate
    and #8 (w3, A, Cin); // AND gate
    and #8 (w4, B, Cin); // AND gate

    or #8 (Cout, w2, w3, w4); // OR gate to generate Carry out
    xor #12 (Sum, w1, Cin); // XOR gate
endmodule

module ripple_carry_adder (
    input wire [3:0] A,
    input wire [3:0] B,
    output wire [3:0] Sum,
    output wire Cout
);

    wire w1, w2, w3;

    full_adder fa0 (.A(A[0]), .B(B[0]), .Cin(1'b0), .Sum(Sum[0]), .Cout(w1));
    full_adder fa1 (.A(A[1]), .B(B[1]), .Cin(w1), .Sum(Sum[1]), .Cout(w2));
    full_adder fa2 (.A(A[2]), .B(B[2]), .Cin(w2), .Sum(Sum[2]), .Cout(w3));
    full_adder fa3 (.A(A[3]), .B(B[3]), .Cin(w3), .Sum(Sum[3]), .Cout(Cout));
endmodule

module CarryLookaheadAdder4Bit(
    input [3:0] A, 
    input [3:0] B, 
    input carryIn, 
    output [3:0] S,
    output carryOut
);
    wire g0, g1, g2, g3, p0, p1, p2, p3, c1, c2, c3, c4;

    // Instantiate the 1-bit full adders
    full_adder fa0(.A(A[0]), .B(B[0]), .Cin(carryIn), .Sum(S[0]), .Cout(g0));
    full_adder fa1(.A(A[1]), .B(B[1]), .Cin(c1), .Sum(S[1]), .Cout(g1));
    full_adder fa2(.A(A[2]), .B(B[2]), .Cin(c2), .Sum(S[2]), .Cout(g2));
    full_adder fa3(.A(A[3]), .B(B[3]), .Cin(c3), .Sum(S[3]), .Cout(g3));

    assign p0 = A[0] ^ B[0];
    assign p1 = A[1] ^ B[1];
    assign p2 = A[2] ^ B[2];
    assign p3 = A[3] ^ B[3];

    // Generate carry for the 4-bit carry look-ahead adder
    assign c1 = (g0) || (p0 && carryIn);
    assign c2 = (g1) || (p1 && c1);
    assign c3 = (g2) || (p2 && c2);
    assign c4 = (g3) || (p3 && c3);

    // Propagate the carry out
    assign carryOut = c4;

endmodule

module BCDAdder1Digit(
    input [3:0] A,
    input [3:0] B,
    output [4:0] Sum
);
    wire [3:0] FourBitSum;
    wire [4:0] AdjustedSum;
    wire Cout;
    wire Adjust = |FourBitSum[3:2]; // If any of the upper two bits are set, adjust.

    // Use the 4-bit carry look-ahead adder
    CarryLookaheadAdder4Bit cla(.A(A), .B(B), .carryIn(0), .S(FourBitSum), .carryOut(Cout));

    // Adjust the sum if it's greater than 9
    assign AdjustedSum = FourBitSum + 4'b0110;
    assign Sum = Adjust ? AdjustedSum : {Cout, FourBitSum};

endmodule

module BCDAdder2Digit(
    input [7:0] A,
    input [7:0] B,
    output reg [8:0] Sum,
    output reg Error,
    output reg Overflow
);
    wire [4:0] Sum1;
    wire [4:0] Sum2;

    // 1st Digit BCD adder
    BCDAdder1Digit bcd_adder1(
        .A(A[3:0]),
        .B(B[3:0]),
        .Sum(Sum1)
    );

    // 2nd Digit BCD adder with the carry in
    BCDAdder1Digit bcd_adder2(
        .A(A[7:4] + Sum1[4]),
        .B(B[7:4]),
        .Sum(Sum2)
    );

    // Combining both results
    assign Sum = {Sum2[4], Sum2[3:0], Sum1[3:0]};

    // Check each digit for error
    always @(A, B) begin
        if(A[3:0] > 4'b1001 || A[7:4] > 4'b1001 || B[3:0] > 4'b1001 || B[7:4] > 4'b1001)
            Error <= 1'b1;
        else
            Error <= 1'b0;
    end

    // Check for overflow
    always @(Sum2) begin
        if(Sum2[4] == 1'b1)
            Overflow <= 1'b1;
        else
            Overflow <= 1'b0;
    end
endmodule
