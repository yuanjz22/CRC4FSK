`timescale 1ns / 1ps


module cmxsb(
    input sys_clk,
    input reset,
    //input wire [7:0]inputdata,
    input wire next,
    output wire[7:0]inputdata,
    output wire [7:0]outputdata
    );
    
   wire [7:0]phase;
   wire [3:0]sign_cnt;
   wire sign_clk;
   wire [15:0]crc_encode_data;
   wire [15:0]recieve_data;
   wire [15:0]maybefalse_recieve_data;
//    wire [7:0]crc_decode_data;
   wire err;
   wire [7:0]channel;
   wire bit_write;
   wire bit_read;
   reg sign = 1'b1;

// initialize the inputdata
//    wire [7:0]inputdata;
//    assign inputdata = 8'b10111011;
   reg next_sync_0, next_sync_1;
   always @(posedge sys_clk or posedge reset) begin
       if (reset) begin
           next_sync_0 <= 1'b0;
           next_sync_1 <= 1'b0;
       end else begin
           next_sync_0 <= next;
           next_sync_1 <= next_sync_0;
       end
   end
   wire next_rising = next_sync_0 & ~next_sync_1;

   reg [1:0] data_idx;
   always @(posedge sys_clk or posedge reset) begin
       if (reset) data_idx <= 2'd0;
       else if (next_rising) data_idx <= data_idx + 2'd1;
   end

   reg [7:0] inputdata_reg;
   always @(*) begin
       case (data_idx)
         2'd0: inputdata_reg = 8'b10111011;
         2'd1: inputdata_reg = 8'b11110000;
         2'd2: inputdata_reg = 8'b00001111;
         2'd3: inputdata_reg = 8'b00110011;
         default: inputdata_reg = 8'b10111011;
       endcase
   end

   assign inputdata = inputdata_reg;

   // Clock and Data Path 
   clk_trans clk_trans1(
       .clk_sys(sys_clk),
       .reset(reset),
       .phase(phase),
       .sign_cnt(sign_cnt),
       .sign_clk(sign_clk)
   );

   // crc encode
   crc8_encoder_strict_add crc8_encoder_strict_add1(
        .data_in(inputdata_reg),
       //.data_in(inputdata),
       .codeword(crc_encode_data)
   );

   // encoded data to bit stream
   write_bit write_bit1(
      .sign_cnt(sign_cnt),
      .CRC_code(crc_encode_data),
      .out_bit(bit_write)
   );   

   // FSK Modulation 
   FSK_modulator FSK_modulator1(
         .sys_clk(sys_clk),
         .rst_n(reset),
         .enable(bit_write),
         .phase(phase),
         .signal(channel)
    );

   // FSK Demodulation
    FSK_demodulator FSK_demodulator1(
         .sys_clk(sys_clk),
         .rst_n(reset),
         .phase(phase),
         .signal(channel),
         .sign(bit_read)
    ); 

   // bit stream to received data
   read_bit read_bit1(
        .clk_sys(sys_clk),
        .rst_n(reset),
        .phase(phase),
       .sign_cnt(sign_cnt),
       .in_bit(bit_read),
       .CRC_code(recieve_data)
   );

   // asssume capcity channel(noise added here if needed)
   capacity capacity1(
        .sys_clk(sys_clk),
        .rst_n(reset),
        .sign(sign),
        .input_channel(recieve_data),
        .output_channel(maybefalse_recieve_data)
   );  

   // crc decode
    crc8_decoder_strict_add crc8_decoder_strict_add1(
         .codeword(maybefalse_recieve_data),
         .crc_ok(err),
         .data_out(outputdata)
    );


endmodule