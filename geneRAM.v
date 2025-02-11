module geneRAM (
  input clk,
  input rst,
  input [4:0] writeaddress,
  input [4:0] readaddress,
  input wren,
  input [47:0] writedata,
  output [47:0] readdata
);
  reg [47:0] ram[0:31];
  assign readdata = ram[readaddress];
  always @(posedge clk) begin
    if (wren) begin
      ram[writeaddress] <= writedata;
    end
  end
endmodule

module scoreRAM (
  input clk,
  input rst,
  input [4:0] writeaddress,
  input [4:0] readaddress,
  input wren,
  input [6:0] writedata,
  output [6:0] readdata
);
  reg [6:0] ram[0:31];
  assign readdata = ram[readaddress];
  always @(posedge clk) begin
    if (wren) begin
      ram[writeaddress] <= writedata;
    end
  end
endmodule