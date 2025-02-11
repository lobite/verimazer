module simrandomgene;
   reg clk, nrst;


   top top (.clk(clk), .rst(nrst));

   initial begin
      clk <= 0;
      nrst <= 0;
      #100 nrst <= 1;
      #100000000
	$finish;
   end
   always #10 clk <= ~clk;
endmodule