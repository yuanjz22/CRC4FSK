module write_bit(
   input [3:0]sign_cnt,
   input [15:0]CRC_code,
   output wire out_bit
);
   assign out_bit = CRC_code[sign_cnt];
endmodule

module read_bit(
   input [3:0]sign_cnt,
   input in_bit,
   output reg [15:0]CRC_code
);
   always @(sign_cnt) begin
   if (sign_cnt >= 2)
       CRC_code[sign_cnt-2] <= in_bit;
   else
       CRC_code[sign_cnt+14] <= in_bit;
   end
endmodule

module clk_trans(
   input clk_sys,
	output reg [7:0]phase,
	output reg [3:0]sign_cnt,
	output wire sign_clk
);
	 initial begin
	      sign_cnt <= 0;
		  phase <= 0;
	 end
	 
	 assign sign_clk = (phase==0);
	 
   always @(posedge clk_sys) begin
       if (phase == 255) begin
		      phase <= 0;
				if (sign_cnt == 15)
				    sign_cnt <= 0;
				else
				    sign_cnt <= sign_cnt + 1;
				end
		  else
		      phase <= phase + 1;
   end
endmodule