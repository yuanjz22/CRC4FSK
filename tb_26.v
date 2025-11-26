`timescale 1ns / 1ps

module sim;
    // Testbench signals
    reg clk;
    reg reset;
    reg [7:0] inputdata;
    wire [7:0] outputdata;

    // Instantiate the mail module
    main uut (
        .sys_clk(clk),
        .reset(reset),
        .inputdata(inputdata),
        .outputdata(outputdata)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock, period of 10ns
    end
    initial begin
    end
    // Test sequence
    initial begin
        // Initialize inputs
       inputdata <= 8'b01011011;
        
        // Wait for a few clock cycles
        #20;

        // Apply test vector to inputdata
//        inputdata = 100'b0110101010110001100110101111001111011011100001001011010000111111101000001100110110011110100010111001;
        #100;
        // $stop;
    end

    // Monitoring
    initial begin
        $monitor("Time: %0d ns, inputdata: %b, outputdata: %b", $time, inputdata, outputdata);
    end

endmodule
