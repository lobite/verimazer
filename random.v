module random_bit_generator (
  input wire clk,
  input wire rst,
  input wire seedA,
  //input wire seedB,
  output reg [31:0] rand
);

  reg [31:0] x;
  reg [31:0] y;
  reg [31:0] z;
  reg [31:0] w;
  reg [31:0] t;

  always @(posedge clk) begin
    if (!rst) begin
      x <= seedA; //seed 1
      y <= 438747135; //seed 2
      z <= 789789237; //seed 3
      w <= 129856379; //seed 4
      t <= 0;
      rand <= 0;
    end
    else begin
      t <= x ^ (x<<11);
      x <= y;
      y <= z;
      z <= w;
      w <= (w ^ (w >> 19)) ^ (t ^ (t >> 8));
      rand <= w;
    end
  end
endmodule