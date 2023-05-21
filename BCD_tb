module BCDAdder2Digit_TB;
    reg [7:0] A, B;
    wire [8:0] Sum;
    wire Error, Overflow;

    // Instantiate the BCDAdder2Digit module
    BCDAdder2Digit uut (
        .A(A),
        .B(B),
        .Sum(Sum),
        .Error(Error),
        .Overflow(Overflow)
    );

    // Initialize the random number generator
    initial begin
        $randomize(seed);
    end

    // Test procedure
    task automatic test();
        integer i;
        reg [8:0] expected_sum;

        for(i = 0; i < 100; i = i + 1) begin
            // Generate random BCD inputs
            A = $random % 100;
            B = $random % 100;
            
            // Compute expected sum and check overflow
            expected_sum = A + B;
            #10; // Wait for the circuit to compute the sum

            // Check if sum and overflow are correct
            if(expected_sum > 99) begin
                assert(Overflow);
                assert(Sum == expected_sum % 100);
            end else begin
                assert(!Overflow);
                assert(Sum == expected_sum);
            end

            // Check if any input is not a valid BCD and if Error is correctly asserted
            if(((A[3:0] > 4'b1001) || (A[7:4] > 4'b1001)) || ((B[3:0] > 4'b1001) || (B[7:4] > 4'b1001))) begin
                assert(Error);
            end else begin
                assert(!Error);
            end
        end
    endtask

    // Run the test procedure
    initial begin
        test();
        $finish;
    end
endmodule
