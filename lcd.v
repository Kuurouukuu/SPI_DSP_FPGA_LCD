
module lcd(clk, reset, lcd_rs, lcd_rw, lcd_e, data, update, char_address, lcd_data_in);

// Parameter definition
parameter IDLE = 'b000_0000_0000;
parameter CLEAR = 'b000_0000_0001;
parameter RETURNCURSOR = 'b000_0000_0010;
parameter SETMODE = 'b000_0000_0100;
parameter SWITCHMODE = 'b000_0000_1000;
parameter SHIFT = 'b000_0001_0000;
parameter SETFUNCTION = 'b000_0010_0000;
parameter SETCGRAM = 'B000_0100_0000;
parameter SETDDRAM = 'b000_1000_0000;
parameter READFLAG = 'b001_0000_0000;
parameter WRITERAM = 'b010_0000_0000;
parameter READRAM = 'b100_0000_0000;

parameter cur_inc = 1'b1;
parameter cur_dec = 1'b0;
parameter cur_shift = 1'b1;
parameter cur_noshift = 1'b0;
parameter open_display = 1'b1;
parameter open_cur = 1'b0;
parameter blank_cur = 1'b0;
parameter shift_display = 1'b1;
parameter shift_cur = 1'b0;
parameter right_shift = 1'b1;
parameter left_shift = 1'b0;
parameter datawidth8 = 1'b1;
parameter datawidth4 = 1'b0;
parameter twoline = 1'b1;
parameter oneline = 1'b0;
parameter font5x10 = 1'b1;
parameter font5x7 = 1'b0;

parameter DIVSS = 15;
parameter [15:0] divcnt = 'b1001110001000000;

// Port definition
input clk, reset;
input update;
input [7:0] lcd_data_in;

output [6:0] char_address;
output reg lcd_rs, lcd_rw;
output reg lcd_e = 1'b0;
output reg [7:0] data;

// Register Definition
reg [15:0] clkcnt = 16'b0;
reg tc_clkcnt = 1'b0;
reg clk_div = 1'b1;
reg clk_int = 1'b0;
reg flag = 1'b0;
//reg [7:0] data_in = 'h41;
reg [10:0] state = IDLE;
reg [6:0] counter = 'b0;
reg [4:0] div_counter = 'b0;
reg [10:0] nextstate = IDLE;
reg updateFlag = 'b0;
reg updateACK = 'b0;
reg next_lcd_rw = 'b0;
reg next_lcd_rs = 'b0;
reg [7:0] next_data = 'b0;
reg [5:0] address = 'b0;
reg row = 'b0;
reg [3:0] waitCounter = 'b0;

//Module instantiation

// Sequential
always @(posedge clk)
begin
	if (reset == 'b0) 
	begin
		clkcnt <= 'd0;
	end
	else
		begin
			if (clkcnt == divcnt)
			begin
				clkcnt <= 'b0;
				tc_clkcnt <= 'b1;
			end
			else
			begin
				clkcnt <= clkcnt + 1;
				tc_clkcnt <= 'b0;
			end
		end
end

always@(posedge tc_clkcnt)
begin
	if (reset == 'b0)
		clk_div <= 'b0;
	else
		clk_div <= ~clk_div;
end 

reg clk_int_counter = 'b0;
always@(posedge clk_div)
begin
	if (reset == 'b0)
		clk_int <= 'b0;
	else
		clk_int <= ~clk_int;
end 

always@(negedge clk_div)
begin
	if (reset == 'b0)
		lcd_e <= 'b0;
	else
		lcd_e <= ~lcd_e;
end 

/* always @ (posedge clk_int or negedge reset)
	if(!reset)
	begin
		state<=IDLE;
		address<=6'b000_000;
		flag<=0;
	end
	else
	begin
		case(state)
		IDLE		:begin 
						data<=8'bzzzz_zzzz;
						if(flag==0)
						begin
							state<=SETFUNCTION;
							flag<=1;
						end
						else
							state<=SHIFT;
					 end
		CLEAR			:begin lcd_rs<=0;lcd_rw<=0;data<=8'b0000_0001;
								state<=SETMODE;end   
		SETMODE			:begin lcd_rs<=0;lcd_rw<=0;data[7:2]<=6'b000001;data[1]<=cur_inc;data[0]<=cur_noshift;
								state<=WRITERAM;end
		RETURNCURSOR	:begin lcd_rs<=0;lcd_rw<=0;data<=8'b00000010;
								state<=WRITERAM;end
		SWITCHMODE 		:begin lcd_rs<=0;lcd_rw<=0;data[7:3]<=5'b00001;data[2]<=open_display;data[1]<=open_cur;data[0]<=blank_cur;
							state<=CLEAR;end
		SHIFT			:begin lcd_rs<=0;lcd_rw<=0;data[7:4]<=4'b0001;data[3]<=shift_cur;data[2]<=left_shift;data[1:0]<=2'b00;
							state<=IDLE;end
		SETFUNCTION		:begin lcd_rs<=0;lcd_rw<=0;data[7:5]<=3'b001;data[4]<=datawidth8;data[3]<=twoline;data[2]<=font5x10;data[1:0]<=2'b00;
							state<=SWITCHMODE;end
		SETCGRAM		:begin lcd_rs<=0;lcd_rw<=0;data<=8'b01000000;state<=IDLE;end
		SETDDRAM		:begin lcd_rs<=0;lcd_rw<=0;data<=8'b10000000;state<=WRITERAM;end
		WRITERAM		:begin
						if(address<=6'b001_011)
						begin
							lcd_rs<=1;
							lcd_rw<=0;
							data<='h51;
							address<=address+1;
							state<=WRITERAM;
						end
						else
						begin
							lcd_rs<=0;
							lcd_rw<=0;
							state<=SHIFT;
							//state<=CLEAR;
							address<=6'b000_000;
						end
					end
		endcase
end
 */
always@(posedge clk_int or negedge reset)
begin
	if (reset == 'b0)
	begin
		data <= {8{1'bz}};
		lcd_rs <= 'b0;
		lcd_rw <= 'b1;
		counter <= 'b0;
		row <= 'b0;
		state <= IDLE;
	end else
	begin
/* 		state <= nextstate;
		lcd_rs <= next_lcd_rs;
		lcd_rw <= next_lcd_rw;
		data <= next_data; */
		case (state)
			IDLE :begin 
				if (flag == 'b0)
				begin
					state <= SETFUNCTION;
					flag <= 'b1;
				end else if (update == 'b0) // to keep the nextstate value
				begin
					updateACK <= 'b1;
					state <= CLEAR;
				end else
					state <= IDLE;
			 end
			 CLEAR :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				data <= 'b0000_0001;
				state <= SETMODE;
			 end
			 RETURNCURSOR :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				data <= 'b0000_0010;
				state <= WRITERAM;
			 end
			 SETMODE :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				data <= {6'b0000_01, cur_inc, cur_noshift};				
				state <= WRITERAM;				
			 end
			 SWITCHMODE :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				data <= {5'b0000_1, open_display, open_cur, blank_cur};		
				state <= CLEAR;
			 end
			 SHIFT :begin 
				div_counter <= 'b0;
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				data <= {4'b0001, shift_cur, left_shift, 2'b00};			
				state <= IDLE;
			 end
			 SETFUNCTION :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				data <= {3'b001, datawidth8, twoline, font5x10, 2'b00};		
				state <= SWITCHMODE;
			 end
			 SETCGRAM :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				data <= 'b0100_0000;
				
				state <= IDLE;	
			 end
			 SETDDRAM :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b0;
				if (row == 0) // FirST row
					data <= 'b1000_0000;
				else if (row == 1) // Second row
					data <= 'b1100_0000;
				if (waitCounter == 6) begin
					state <= WRITERAM;
					waitCounter <= 'b0;
				end else begin
					waitCounter <= waitCounter + 'b1;
				end
			 end
			 READFLAG :begin 
				lcd_rs <= 'b0;
				lcd_rw <= 'b1;
				data <=  {8{1'bz}};
				state <= IDLE;
			 end
			 WRITERAM :begin 
				lcd_rs <= 'b1;
				lcd_rw <= 'b0;
				data <= lcd_data_in;				
				if (counter == 'd16 && row == 0) // Finish fireset row
					begin
						row <= 1;
						state <= SETDDRAM;
					end else if (counter < 'd32)
					begin
						counter <= counter + 'b1;
						state <= WRITERAM;
					end else 
					begin // finish writing to DDRAM, reset counter, wait for update command
						updateACK <= 'b0;
						counter <= 'b0;
						row <= 'b0;
						state <= SHIFT;
					end
			 end
			 READRAM :begin 
				lcd_rs <= 'b1;
				lcd_rw <= 'b1;
				data <=  {8{1'bz}};
				state <= IDLE;
			 end
			 default: begin
				state <= IDLE;
				data <= {8{1'bz}};
			 end
		endcase
	end
end 
//
//// Combination
//
//always@(*)
//begin
//	if (reset == 'b0) begin
//		next_data =  {8{1'bz}};
//		flag = 'b0;
//		nextstate = IDLE;
//		div_counter = 'b0;
//	end else begin
//		case (state)
//			 IDLE :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b1;
//				next_data =  {8{1'bz}};	
//				div_counter = div_counter + 1;
//				if (flag == 'b0) // start initialization
//				begin
//					nextstate = SETFUNCTION;
//					flag = 'b1;
//				end else if (update == 'b1 || updateACK == 'b1) // to keep the nextstate value
//				begin
//					updateACK = 'b1;
//					nextstate = WRITERAM;
//				end else
//						nextstate = WRITERAM;
//				end
//			 CLEAR :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				next_data = 'b0000_0001;
//				
//				nextstate = SETMODE;
//			 end
//			 RETURNCURSOR :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				next_data = 'b0000_0010;				
//				nextstate = WRITERAM;
//			 end
//			 SETMODE :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				next_data = {6'b0000_01, cur_inc, cur_noshift};				
//				nextstate = WRITERAM;
//			 end
//			 SWITCHMODE :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				next_data = {5'b0000_1, open_display, open_cur, blank_cur}		
//				nextstate = CLEAR;
//			 end
//			 SHIFT :begin 
//				div_counter = 'b0;
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				next_data = {4'b0001, shift_cur, left_shift, 2'b00};			
//				nextstate = IDLE;
//			 end
//			 SETFUNCTION :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				next_data = {3'b001, datawidth8, twoline, font5x10, 2'b00};		
//				nextstate = SWITCHMODE;
//			 end
//			 SETCGRAM :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				next_data = 'b0100_0000;
//				
//				nextstate = IDLE;	
//			 end
//			 SETDDRAM :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b0;
//				if (counter == 0) // Fireset row
//					next_data = 'b1000_0000;
//				else if (counter != 0) // Second row
//					next_data = 'b1100_0000;				
//				nextstate = WRITERAM;	
//			 end
//			 READFLAG :begin 
//				next_lcd_rs = 'b0;
//				next_lcd_rw = 'b1;
//				next_data =  {8{1'bz}};
//				
//				nextstate = IDLE;
//			 end
//			 WRITERAM :begin // Counter goes from 0 to 32
//				next_lcd_rs = 'b1;
//				next_lcd_rw = 'b0;
//				next_data = 'h50;				
//				if (counter == 16) // Finish fireset row
//					begin
//						nextstate = SETDDRAM;
//					end else if (counter < 32)
//					begin
//						nextstate = WRITERAM;
//					end else 
//					begin // finish writing to DDRAM, reset counter, wait for update command
//						updateACK = 'b0;
//						nextstate = IDLE;
//					end
//				end
//			 READRAM :begin 
//				next_lcd_rs = 'b1;
//				next_lcd_rw = 'b1;
//				next_data =  {8{1'bz}};
//				
//				nextstate = IDLE;
//			 end			 
//			 default: begin
//				nextstate = IDLE;
//				next_data = {8{1'bz}};
//			end
//		endcase
//	end
//end

// Assignment
assign char_address = counter;


endmodule