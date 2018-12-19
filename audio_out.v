module audio_out (CLOCK_50, CLOCK2_50, rst, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT, keyNum);

	input CLOCK_50, CLOCK2_50;
	input rst;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	input [63:0] keyNum;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = rst;
	
	reg [18:0] delay_cnt [7:0];
	wire [18:0] delay [7:0];

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 


genvar i;
generate
	for (i=0; i < 8; i = i + 1) begin : trackGenerator
		always @(posedge CLOCK_50)
			if(delay_cnt[i] == delay[i]) begin
				delay_cnt[i] <= 0;
			end 
			else 
				delay_cnt[i] <= delay_cnt[i] + 1;
	end
endgenerate

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
	/////////////////////////////////
	// Your code goes here 
	/////////////////////////////////
	
genvar c;
generate
	for (c = 0; c < 8; c = c + 1) begin : freqGenerator
		freqLUT f(
			.keyNum(keyNum[((c+1)*8)-1:c*8]),
			.freq3000(delay[c])
		);
	end
endgenerate

	wire [23:0] sound [7:0];
	
genvar k;
generate

	for (k = 0; k < 8; k = k + 1) begin : sinGenerator
		sinLUT sin(
			.amount((delay_cnt[k]*1024)/delay[k]),
			.sinval(sound[k])
		);
	end
endgenerate
	
	assign writedata_left  = sound[0];
	assign writedata_right = sound[0] + sound[1] + sound[2] + sound[3] + sound[4] + sound[5] + sound[6] + sound[7];
	assign read = read_ready & write_ready;
	assign write = read_ready & write_ready && (keyNum != 0);
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule

module freqLUT(keyNum, freq3000);
	input [7:0] keyNum;
	reg [9:0] freq;
	output reg [18:0] freq3000;
	
	always @(keyNum) begin
		case (keyNum)
		26: freq <= 130;
		25: freq <= 138;
		24: freq <= 146;
		23: freq <= 155;
		22: freq <= 164;
		21: freq <= 174;
		20: freq <= 184;
		19: freq <= 195;
		18: freq <= 207;
		17: freq <= 220;
		16: freq <= 233;
		15: freq <= 246;
		14: freq <= 261;
		13: freq <= 261;
		12: freq <= 277;
		11: freq <= 293;
		10: freq <= 311;
		9: freq <= 329;
		8: freq <= 349;
		7: freq <= 369;
		6: freq <= 391;
		5: freq <= 415;
		4: freq <= 440;
		3: freq <= 466;
		2: freq <= 493;
		1: freq <= 523;
		default: freq <= 0;
		endcase
		
		if (freq != 0)
			freq3000 <= {freq, 9'd3000};
		else
			freq3000 <= freq;
	end
	
	
endmodule