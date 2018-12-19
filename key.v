	module key(clk, dat, psclk, freq, out);
	input clk;
	input dat;
	input psclk;
	
	output reg [7:0] freq;
	
	output [7:0] out;
	assign out = scan_code_raw;
	
	reg [7:0] history[1:2];
			
	reg [7:0] scan_code;
	wire [7:0] scan_code_raw;
	wire scan_ready;
	wire read;
	wire reset = 1'b0;
	
	oneshot pulser(
	  .pulse_out(read),
	  .trigger_in(scan_ready),
	  .clk(clk)
	);
	
	keyboard kbd(
	  .keyboard_clk(psclk),
	  .keyboard_data(dat),
	  .clock50(clk),
	  .reset(reset),
	  .read(read),
	  .scan_ready(scan_ready),
	  .scan_code(scan_code_raw)
	);
	
	always @(posedge scan_ready)
	begin
		history[2] <= history[1];
		history[1] <= scan_code_raw;
	end
	
	reg released;
	always@(history[2])
	begin
		if (history[2] != 8'hf0)
		begin
			case(history[1])
				8'h1A: freq <= 1; //Z is C
				8'h1B: freq <= 2; //S is C#
				8'h22: freq <= 3; //X is D
				8'h23: freq <= 4; //D is D#
				8'h21: freq <= 5; //C is E
				8'h2A: freq <= 6; //V is F
				8'h34: freq <= 7; //G is F#
				8'h32: freq <= 8; //B is G
				8'h33: freq <= 9; //H is G#
				8'h31: freq <= 10; //N is A
				8'h3B: freq <= 11; //J is A#
				8'h3A: freq <= 12; //M is B
				8'h41: freq <= 13; //, is C
				8'h15: freq <= 14; //q is C
				8'h1E: freq <= 15; //2 is C#
				8'h1D: freq <= 16; //w is D
				8'h26: freq <= 17; //3 is D#
				8'h24: freq <= 18; //e is E
				8'h2D: freq <= 19; //r is F
				8'h2E: freq <= 20; //5 is F#
				8'h2C: freq <= 21; //t is G
				8'h36: freq <= 22; //6 is G#
				8'h35: freq <= 23; //y is A
				8'h3D: freq <= 24; //7 is A#
				8'h3C: freq <= 25; //u is B
				8'h43: freq <= 26; //i is C
				default: freq <= 0;
			endcase
		end
		else freq <= 0;
		
		
	end
	
endmodule
