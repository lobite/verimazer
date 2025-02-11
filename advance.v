module moveChild (

    input wire [1:0] dir,
    input wire [63:0] mapData,
    input wire [2:0] x,
    input wire [2:0] y,
    input wire alive,
    output wire [2:0] xnew,
    output wire [2:0] ynew,
    output wire alivenew
);
    wire [2:0] xnewTemp;
    wire [2:0] ynewTemp;
    wire aliveTemp;



    //mapROM map (.clk(clk), .rst(rst), .addr(mapAddr), .data(mapData));
    //x, y, alive without walls
    assign xnewTemp = (dir == 0)?((x == 7) ? x : x+1):((dir == 1)?((x == 0) ? x : x-1):x);
    assign ynewTemp = (dir == 2)?((y == 7) ? y : y+1):((dir == 3)?((y == 0) ? y : y-1):y);
    assign aliveTemp = ((dir == 0 && x == 7) || (dir == 1 && x == 0) || (dir == 2 && y == 7) || (dir == 3 && y == 0)) ? 0 : 1;

    //x, y, alive with wall collision
    assign xnew = ((x == 7 && y == 7) || (xnewTemp == 7 && ynewTemp == 7)) ? 7 : (((mapData[63 - (8 * ynewTemp + xnewTemp)] == 1) || (alive == 0)) ? x : xnewTemp);
    assign ynew = ((x == 7 && y == 7) || (xnewTemp == 7 && ynewTemp == 7)) ? 7 : (((mapData[63 - (8 * ynewTemp + xnewTemp)] == 1) || (alive == 0)) ? y : ynewTemp);
    assign alivenew = ((x == 7 && y == 7) || (xnewTemp == 7 && ynewTemp == 7)) ? 1 : (((mapData[63 - (8 * ynewTemp + xnewTemp)] == 1) || (alive == 0)) ? 0 : aliveTemp);
endmodule