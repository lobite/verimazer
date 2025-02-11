module fitness (
    input wire [3:0] xFin,
    input wire [3:0] yFin,
    input wire alive,
    output wire [6:0] f
);

    assign f = (xFin == 7 && yFin == 7) ? (7'b1000000 + xFin * yFin + xFin + yFin) : (xFin * yFin + xFin + yFin);
    //assign f = xFin * yFin + xFin + yFin;
    //if alive at tFinal fitness = 1xxxxxx
    //if dead at tFinal fitness = 0xxxxxx
    //this prioritizes staying alive instead of solving the maze...
    //this calls for an efficient scoring algorithm to get the best results in the least generations


    //IDEA: get rid off the staying alive bonus
    //
endmodule