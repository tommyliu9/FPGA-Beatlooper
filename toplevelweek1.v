module toplevelweek1( SW, CLOCK_50, HEX0, LEDR, PS2_DAT, PS2_CLK, CLOCK2_50, KEY, 
	FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK,  AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, 
	AUD_ADCDAT, AUD_DACDAT, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
	//AUDIO 
	input CLOCK2_50;
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	input [9:0] SW;
	// PS_2 PORTS
	input PS2_DAT;
	input PS2_CLK;
	input CLOCK_50;
	//DE1 OUTPUTS
	input [3:0] KEY;
	
	
	output [6:0] HEX0;
	
	output [9:0] LEDR;

	
	wire [63:0] notes;

	reg [32:0] rateSelect;
	wire rateClock;
	reg [6:0] counter;
	wire [7:0] keyNum;
	
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour({1'b1,1'b1,1'b1}),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "piano.mif";
		
	
	// Increments the counter every clock cycle
	always @(posedge rateClock) begin
		if (!KEY[0]) begin
			counter <= 0;
		end
		else begin
			if (counter != 127)
				counter <= counter + 1;
			else
				counter <= 7'b0;
		end
	end
	
	sevsegdisplay hex1({1'b0,counter[6:4]+1}, HEX0);
	
	always @(posedge CLOCK_50) begin
		if (!KEY[0])
			rateSelect <= 1687500;
		if (!KEY[2] && rateSelect >= 687500)
			rateSelect <= rateSelect - 1;
		if (!KEY[3] & rateSelect <= 4687500)
			rateSelect <= rateSelect + 1;
	end

	looperModule looper(
		.clk(rateClock),
		.reset(KEY[0]),
		.dataIn(keyNum),
		.trackChooser(SW[7:0]),
		.trackCount(counter),
		.notesOut(notes)
		);
		
	rateDivider rate(
		.speed(rateSelect),
		.reset(KEY[0]),
		.clock(CLOCK_50),
		.out(rateClock)
	);
	
	genvar c;
		generate        
			for (c = 0; c < 8 ; c = c + 1) begin: noteAssigner
				assign LEDR[c] = (notes[((c+1)*8)-1:c*8] != 0) ? 1'b1 : 1'b0;  
			end
		endgenerate
	
	wire [7:0] keywire;
	key key_to_freq(CLOCK_50, PS2_DAT, PS2_CLK, keyNum, keywire);
	
	audio_out aout(CLOCK_50, CLOCK2_50, ~KEY[0], FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT, notes);
				
	
	drawLUT drawer(keyNum, x, y, writeEn);
endmodule 











module rateDivider(speed, reset, clock, out);

	input clock, reset;
	input [32:0] speed;
	output reg out;
	
	reg [32:0] counter;
	reg [32:0] load_val;
	
	always @(posedge clock)
	begin
		load_val <= speed;
			
		if (reset == 1'b0)
			begin
				out <= 0;
				counter <= 0;
			end
		else
			begin
				if (counter == 0)
					begin
						counter <= load_val;
						out <= 1'b1;
					end
				else
					begin
						counter <= counter - 1'b1;
						out <= 1'b0;
					end
			end
	end
	
endmodule

module sevsegdisplay(c, seg);
	input [3:0] c;
	output [6:0] seg;
	
	assign seg[0] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & ~c[1] & c[0]) | (c[3] & ~c[2] & c[1] & c[0]);
	assign seg[1] = (~c[3] & c[2] & ~c[1] & c[0]) | (c[3] & c[2] & ~c[0]) | (c[3] & c[1] & c[0]) | (c[2] & c[1] & ~c[0]);
	assign seg[2] = (~c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & ~c[0]) | (c[3] & c[2] & c[1]);
	assign seg[3] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & ~c[0]) | (c[2] & c[1] & c[0]);
	assign seg[4] = (~c[3] & c[0]) | (~c[3] & c[2] & ~c[1]) | (~c[2] & ~c[1] & c[0]);
	assign seg[5] = (c[3] & c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[0]) | (~c[3] & c[1] & c[0]) | (~c[3] & ~c[2] & c[1]);
	assign seg[6] = (~c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & ~c[2] & ~c[1]);

endmodule
