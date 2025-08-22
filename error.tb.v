`include "Error dectector.v"
`timescale 1ns / 1ps
module tb_hamming();

    reg  [3:0] data;
    wire [6:0] encoded;
    reg  [6:0] noisy;
    wire [3:0] decoded;
    wire error_detected, error_corrected;

    // Instantiate encoder/decoder
    hamming74_encoder enc(.data_in(data), .code_out(encoded));
    hamming74_decoder dec(.code_in(noisy), .data_out(decoded),
                          .error_detected(error_detected),
                          .error_corrected(error_corrected));

    initial begin
         $dumpfile("error.vcd"); // Generate a VCD file for waveform analysis
   $dumpvars(0,tb_hamming);
        data = 4'b1011;
        #10 noisy = encoded; // no error
        #10 noisy = encoded ^ 7'b0001000; // flip one bit
        #10 noisy = encoded ^ 7'b0001100; // flip two bits (cannot correct)
        #10 $finish;
    end

    initial begin
        $monitor("Time=%0t Data=%b Encoded=%b Noisy=%b Decoded=%b ErrDet=%b ErrCorr=%b",
                  $time, data, encoded, noisy, decoded, error_detected, error_corrected);
    end

endmodule