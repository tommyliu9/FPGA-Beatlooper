module drawLUT(keyNum, x, y, writeEn);
	input [7:0] keyNum;
	output reg writeEn;
	output reg [7:0] x;
	output reg [6:0] y;
	always@(keyNum)
	begin
		case(keyNum)
			1:
			begin 
				x <= 0;
				y <= 0;
				writeEn <= 1;
			end
			2:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			3:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			4:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			5:
			begin 
				x <= 52;
				y <= 30;
				writeEn <= 1;
			end
			6:
			begin 
				x <= 200;
				y <= 130;
				writeEn <= 1;
			end
			7:
			begin 
				x <= 5;
				y <= 3;
				writeEn <= 1;
			end
			8:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			9:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			10:
			begin 
				x <= 52;
				y <= 76;
				writeEn <= 1;
			end
			11:
			begin 
				x <= 24;
				y <= 5;
				writeEn <= 1;
			end
			12:
			begin 
				x <= 160;
				y <= 46;
				writeEn <= 1;
			end
			13:
			begin 
				x <= 56;
				y <= 87;
				writeEn <= 1;
			end
			14:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			15:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			16:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			17:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			18:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			19:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			20:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			21:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			22:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			23:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			24:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			25:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
			26:
			begin 
				x <= 1;
				y <= 1;
				writeEn <= 1;
			end
	
	endcase
	end
	
endmodule