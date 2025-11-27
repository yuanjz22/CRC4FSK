`timescale 1ns / 1ps


module cmxsb(
    input sys_clk,
    input reset,
    input wire [7:0]inputdata,
    output wire [7:0]outputdata
    );
    
   wire [7:0]phase;
   wire [3:0]sign_cnt;
   wire sign_clk;
   wire [15:0]crc_encode_data;
   wire [15:0]recieve_data;
//    wire [7:0]crc_decode_data;
   wire err;
   wire [7:0]channel;
   wire bit_write;
   wire bit_read;
//    wire [7:0]inputdata;
//    assign inputdata = 8'b10111011;

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
       .data_in(inputdata),
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

   // asssume capcity channel(noise added here if needed)   

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

   // crc decode
    crc8_decoder_strict_add crc8_decoder_strict_add1(
         .codeword(recieve_data ),
         .crc_ok(err),
         .data_out(outputdata)
    );


endmodule