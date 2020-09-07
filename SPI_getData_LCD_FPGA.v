
`define Ascii1 6'h00
`define Ascii2 6'h01
`define Ascii3 6'h02
`define Ascii4 6'h03

module SPI_getData_LCD_FPGA(DSP_Address, DSP_Data, WR, RD, CS1, sysrs, sysrs_key, clk,
									lcd_rs, lcd_rw, lcd_e, lcd_data, update);

parameter NUM_OF_BITS = 4;

// Interfacing with EXINT zone 1
input [5:0] DSP_Address;
input WR,RD,CS1; 
input sysrs_key;
input clk;
input update;

//output DSP_RS;
output sysrs;
output lcd_rs, lcd_rw, lcd_e;
output [7:0] lcd_data;


inout [7:0] DSP_Data;

// Reg for storing data
reg [7:0] inputAsciiValue [0:NUM_OF_BITS-1];
reg [7:0] DSP_Data_reg;
reg [7:0] counter = 'h10;
reg [7:0] data = 'b0;
reg wren = 'b0;

integer k;

initial
begin //Init value for reg
	for (k = 0; k < NUM_OF_BITS; k = k + 1)
	begin
		 inputAsciiValue[k] = 'd0;
	end
end

//Instantiation for modules
lcd_top MyLCDModule(.clk(clk), .sysrst(sysrs_key), .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), 
						.lcd_e(lcd_e), .lcd_data(lcd_data), .update(update),
						.dataDsp(data), .addressDsp(counter), .wren(wren));

always @(posedge WR) // WRITE command, TODO: why posedge?
begin
	if (CS1 == 1'b0) // And FPGA is selected
	begin
		case (DSP_Address) // Determine the address
			`Ascii1: begin
				inputAsciiValue[0] = DSP_Data[7:0];
				counter = 'h10;
			end
			`Ascii2: begin
				inputAsciiValue[1] = DSP_Data[7:0];
				counter = 'h11;
			end
			`Ascii3: begin
				inputAsciiValue[2] = DSP_Data[7:0];
				counter = 'h12;
			end
			`Ascii4: begin
				inputAsciiValue[3] = DSP_Data[7:0];
				counter = 'h13;
			end
		endcase
		data = DSP_Data;
	end
end

always@(WR)
begin
	if (WR == 1)
		wren = 'b1;
	else
		wren = 'b0;
end

always @(negedge RD) // RD low
begin
	if (CS1 == 1'b0)
	begin
		case (DSP_Address)
			`Ascii1: begin
				DSP_Data_reg = inputAsciiValue[0];
			end
			`Ascii2: begin
				DSP_Data_reg = inputAsciiValue[1];
			end
			`Ascii3: begin
				DSP_Data_reg = inputAsciiValue[2];
			end
			`Ascii4: begin
				DSP_Data_reg = inputAsciiValue[3];
			end
		endcase
	end
end

assign DSP_Data = (CS1 == 1'b0 && RD == 1'b0) ? DSP_Data_reg:8'hz;  // Select and not read.
assign sysrs = sysrs_key;

endmodule

