module BCD4bit(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] Sum,
    output reg Carry,
    output reg Error
);

    wire [4:0] tmp_sum;

    assign tmp_sum = A + B;

    always @(tmp_sum) begin
        if (A > 4'h9 || B > 4'h9) begin
            Error <= 1'b1;
        end else begin
            if (tmp_sum > 4'h9) begin
                Sum <= tmp_sum + 4'h6;
                Carry <= 1'b1;
                Error <= 1'b0;
            end else begin
                Sum <= tmp_sum;
                Carry <= 1'b0;
                Error <= 1'b0;
            end
        end
    end
endmodule

module BCD8bit(
    input [7:0] A,
    input [7:0] B,
    output reg [7:0] Sum,
    output reg Carry,
    output reg Error
);

    wire [3:0] lower_sum;
    wire lower_carry;
    wire lower_error;
    wire [3:0] upper_sum;
    wire upper_carry;
    wire upper_error;
    
    BCD4bit bcd_add_lower (
        .A(A[3:0]),
        .B(B[3:0]),
        .Sum(lower_sum),
        .Carry(lower_carry),
        .Error(lower_error)
    );

    BCD4bit bcd_add_upper (
        .A(A[7:4] + lower_carry),
        .B(B[7:4]),
        .Sum(upper_sum),
        .Carry(upper_carry),
        .Error(upper_error)
    );

    always @* begin
        Sum = {upper_sum, lower_sum};
        Carry = upper_carry;
        Error = upper_error || lower_error;
    end

endmodule
