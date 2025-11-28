module write_bit(
   input [3:0]sign_cnt,
   input [15:0]CRC_code,
   output wire out_bit
);
   assign out_bit = CRC_code[sign_cnt];
endmodule

module read_bit(
   input clk_sys,
   input rst_n,
   input [7:0] phase,
   input [3:0]sign_cnt,
   input in_bit,
   output reg [15:0]CRC_code
);
    always @(posedge clk_sys or posedge rst_n) begin
        if (rst_n) begin
            CRC_code <= 16'b0;
        end else if (phase == 0) begin  // Only update when phase is 0
            // Store bit at position based on sign_cnt
            if (sign_cnt >= 1) begin
                CRC_code[sign_cnt-1] <= in_bit;  // Positions 0-14
            end else begin
                CRC_code[sign_cnt+15] <= in_bit; // Position 15 when sign_cnt=0
            end
        end
    end
endmodule

module clk_trans(
   input clk_sys,
   input reset,    
   output reg [7:0] phase,
   output reg [3:0] sign_cnt,
   output wire sign_clk
);
	 
   assign sign_clk = (phase == 0);
	 
   always @(posedge clk_sys or posedge reset) begin
       if (reset) begin
           phase <= 0;
           sign_cnt <= 0;
       end
       else begin
           if (phase == 255) begin
               phase <= 0;
               if (sign_cnt == 15)
                   sign_cnt <= 0;
               else
                   sign_cnt <= sign_cnt + 1;
           end
           else begin
               phase <= phase + 1;
           end
       end
   end
endmodule

module capacity(
    input sys_clk,
    input rst_n,
    input sign,
    input wire signed [15:0] input_channel,
    output reg signed [15:0] output_channel
   );

    always @(posedge sys_clk or posedge rst_n) begin
        if (rst_n) begin
            // Reset logic here
            output_channel <= 16'h0;
        end else begin
            // Channel processing logic here
            if (~sign) begin
                output_channel <= input_channel; // Simple example processing
            end else begin
                output_channel <= {input_channel[15:1], ~input_channel[0]}; // Invert LSB as example
            end
        end
    end
endmodule