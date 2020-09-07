module lcd_top(clk, sysrst, lcd_rs, lcd_rw, lcd_e, lcd_data, update, wren, dataDsp, addressDsp);

input clk;
input sysrst;
input update;
input [7:0] dataDsp;
input [7:0] addressDsp;
input wren;

output lcd_rs, lcd_rw, lcd_e;
output [7:0] lcd_data;

wire clk_3m;
wire [7:0] lcd_data_in;
wire [6:0] char_address;

div16 DivideBy16(.clk(clk), .rst(sysrst), .out(clk_3m));

char_ram_2port_bb CharacterRam(
	.data(dataDsp), 
	.rdaddress(char_address),
	.rdclock(clk),
	.wraddress(addressDsp),
	.wrclock(clk),
	.wren(wren),
	.q(lcd_data_in));
	
lcd MyLCD(	.clk(clk_3m), .reset(sysrst), .update(update), .lcd_data_in(lcd_data_in),
				.lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_e(lcd_e), .data(lcd_data),
				.char_address(char_address));

endmodule