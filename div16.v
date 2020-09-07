module div16(clk, rst, out);

input clk, rst;
output out;

reg [3:0] count = 'b0;

always@(posedge clk)
begin
	if (rst == 'b0)
		count <= 'b0;
	else
		count <= count + 1;
end

assign out = count[3];


endmodule