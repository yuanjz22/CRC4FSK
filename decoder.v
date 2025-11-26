`timescale 1ns/1ps

module crc8_decoder_strict_add #(
    parameter K = 8
)(
    input  wire [15:0] codeword,
    output wire        crc_ok,
    output wire [K-1:0]   data_out
);  

    reg [15:0] temp;
    integer i;
    localparam [7:0] POLY = 8'h07;

    always @(*) begin
        temp = codeword[15:0];//{codeword[15:2],~codeword[1],~codeword[0]};

        for (i=15; i>=8; i=i-1) begin
            if (temp[i]) begin
                temp[i]     = 1'b0;
                temp[i-1]   = temp[i-1] ^ POLY[7];
                temp[i-2]   = temp[i-2] ^ POLY[6];
                temp[i-3]   = temp[i-3] ^ POLY[5];
                temp[i-4]   = temp[i-4] ^ POLY[4];
                temp[i-5]   = temp[i-5] ^ POLY[3];
                temp[i-6]   = temp[i-6] ^ POLY[2];
                temp[i-7]   = temp[i-7] ^ POLY[1];
                temp[i-8]   = temp[i-8] ^ POLY[0];
            end
        end
    end

    assign crc_ok = (temp[7:0] == 8'h00);

endmodule
