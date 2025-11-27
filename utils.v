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