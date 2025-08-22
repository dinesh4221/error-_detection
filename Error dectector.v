`timescale 1ns / 1ps
// Hamming (7,4) Encoder
module hamming74_encoder(
    input  [3:0] data_in,     // 4-bit input
    output [6:0] code_out     // 7-bit encoded output
);
    wire p1, p2, p4;

    // Parity bits calculation
    assign p1 = data_in[0] ^ data_in[1] ^ data_in[3]; // covers bits 3,5,7
    assign p2 = data_in[0] ^ data_in[2] ^ data_in[3]; // covers bits 3,6,7
    assign p4 = data_in[1] ^ data_in[2] ^ data_in[3]; // covers bits 5,6,7

    // Final 7-bit code (positions: p1 p2 d0 p4 d1 d2 d3)
    assign code_out = {data_in[3], data_in[2], data_in[1], p4, data_in[0], p2, p1};

endmodule

// Hamming (7,4) Decoder with Single Error Correction
module hamming74_decoder(
    input  [6:0] code_in,   // Received 7-bit code
    output [3:0] data_out,  // Corrected 4-bit data
    output reg error_detected,
    output reg error_corrected
);
    wire p1, p2, p4;
    wire c1, c2, c4; // check bits
    reg [6:0] corrected;

    // Recompute parity checks
    assign c1 = code_in[6] ^ code_in[4] ^ code_in[2] ^ code_in[0];
    assign c2 = code_in[5] ^ code_in[4] ^ code_in[1] ^ code_in[0];
    assign c4 = code_in[3] ^ code_in[2] ^ code_in[1] ^ code_in[0];

    wire [2:0] syndrome = {c4,c2,c1};

    always @(*) begin
        corrected = code_in;
        error_detected = 0;
        error_corrected = 0;

        if (syndrome != 3'b000) begin
            error_detected = 1;
            corrected[7 - syndrome] = ~corrected[7 - syndrome]; // flip error bit
            error_corrected = 1;
        end
    end

    assign data_out = {corrected[0], corrected[1], corrected[2], corrected[4]};

endmodule