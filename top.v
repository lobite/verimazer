module top (
    input clk,
    input rst,
    input start,
    output [6:0] HEX0,
    output [6:0] HEX1
);
    //parameters
    parameter childN = 8; //DON'T CHANGE: CODE IS HARD WIRED TO 8 CHILDREN/GEN
    parameter genN = 256; // <1024
    parameter mutateP = 32;

    //outputs
    reg [6:0] seg0out;
    reg [6:0] seg1out;
    assign HEX0 = seg0out;
    assign HEX1 = seg1out;
    reg [6:0] segNum[0:15];

    /*
    reg [4:0] writeaddress;
    reg [4:0] readaddress;
    reg wren;
    reg [47:0] writedata;
    wire [47:0] readdata;
    reg [6:0] fwdata;
    wire [6:0] frdata;
    */
    
    wire [31:0] randomGene;
    //reg [2:0] mapAddr;
    reg [63:0] mapData;

    //gene pool
    reg [47:0] genes[0:15];

    reg [1:0] p[0:1];
    reg [3:0] selection[0:7];
    reg [6:0] bestScore;

    //positions
    reg [2:0] x[0:7];
    reg [2:0] y[0:7];
    reg [6:0] f[0:7];
    //reg [6:0] fSort[0:7];
    reg [1:0] dir[0:7];

    //simulation time
    reg [4:0] t;
    reg [31:0] absoluteTime;
    reg [31:0] seedZero;

    //life
    reg alive[0:7];

    //loop related variables
    reg [2:0] state;
    reg [3:0] childID; //8 children per generation
    reg half;
    reg [7:0] await;
    reg [2:0] run;
    integer i;
    integer codon;
    integer s;
    reg [9:0] gen;
    reg [5:0] biggen;
    reg mutate;
    reg [31:0] seedA;
    //reg [31:0] seedB;


    //declare wires for positions

    wire [2:0] xnew[0:7];
    wire [2:0] ynew[0:7];
    wire alivenew[0:7];

    wire [6:0] fit[0:7];
    
    wire [47:0] mask;
    reg [1:0] mask_real [0:23];
    genvar gi;
    generate
        for (gi = 0; gi < 24; gi = gi +1) begin : makemask
            assign mask[gi*2+1:gi*2] = mask_real[gi];
        end
    endgenerate

    
    

    //wire [47:0] tmp1,tmp2;
    //assign tmp1 = genes[selection[4+p[0]]];
    //assign tmp2 = genes[selection[4+p[1]]];

    //instance modules
    //geneRAM r (.clk(clk), .rst(rst), .writeaddress(writeaddress), .readaddress(readaddress), .wren(wren), .writedata(writedata), .readdata(readdata));
    //scoreRAM rf (.clk(clk), .rst(rst), .writeaddress(writeaddress), .readaddress(readaddress), .wren(wren), .writedata(fwdata), .readdata(frdata));
    random_bit_generator random (.clk(clk), .rst(rst), .seedA(seedA), .rand(randomGene));
    //mapROM map (.clk(clk), .rst(rst), .addr(mapAddr), .data(mapData));
    moveChild m0c (.dir(dir[0]), .mapData(mapData), .x(x[0]), .y(y[0]), .alive(alive[0]), .xnew(xnew[0]), .ynew(ynew[0]), .alivenew(alivenew[0]));
    moveChild m1c (.dir(dir[1]), .mapData(mapData), .x(x[1]), .y(y[1]), .alive(alive[1]), .xnew(xnew[1]), .ynew(ynew[1]), .alivenew(alivenew[1]));
    moveChild m2c (.dir(dir[2]), .mapData(mapData), .x(x[2]), .y(y[2]), .alive(alive[2]), .xnew(xnew[2]), .ynew(ynew[2]), .alivenew(alivenew[2]));
    moveChild m3c (.dir(dir[3]), .mapData(mapData), .x(x[3]), .y(y[3]), .alive(alive[3]), .xnew(xnew[3]), .ynew(ynew[3]), .alivenew(alivenew[3]));
    moveChild m4c (.dir(dir[4]), .mapData(mapData), .x(x[4]), .y(y[4]), .alive(alive[4]), .xnew(xnew[4]), .ynew(ynew[4]), .alivenew(alivenew[4]));
    moveChild m5c (.dir(dir[5]), .mapData(mapData), .x(x[5]), .y(y[5]), .alive(alive[5]), .xnew(xnew[5]), .ynew(ynew[5]), .alivenew(alivenew[5]));
    moveChild m6c (.dir(dir[6]), .mapData(mapData), .x(x[6]), .y(y[6]), .alive(alive[6]), .xnew(xnew[6]), .ynew(ynew[6]), .alivenew(alivenew[6]));
    moveChild m7c (.dir(dir[7]), .mapData(mapData), .x(x[7]), .y(y[7]), .alive(alive[7]), .xnew(xnew[7]), .ynew(ynew[7]), .alivenew(alivenew[7]));
    //...x8
    fitness f0c (.xFin(x[0]), .yFin(y[0]), .alive(alive[0]), .f(fit[0]));
    fitness f1c (.xFin(x[1]), .yFin(y[1]), .alive(alive[1]), .f(fit[1]));
    fitness f2c (.xFin(x[2]), .yFin(y[2]), .alive(alive[2]), .f(fit[2]));
    fitness f3c (.xFin(x[3]), .yFin(y[3]), .alive(alive[3]), .f(fit[3]));
    fitness f4c (.xFin(x[4]), .yFin(y[4]), .alive(alive[4]), .f(fit[4]));
    fitness f5c (.xFin(x[5]), .yFin(y[5]), .alive(alive[5]), .f(fit[5]));
    fitness f6c (.xFin(x[6]), .yFin(y[6]), .alive(alive[6]), .f(fit[6]));
    fitness f7c (.xFin(x[7]), .yFin(y[7]), .alive(alive[7]), .f(fit[7]));

    always @(posedge clk) begin
        
        if (!rst) begin
            //when reset: (including first run)
            //writeaddress <= 0;
            //readaddress <= 0;
            //wren <= 0;
            //writedata <= 0;
            state <= 0;
            childID <= 0;
            half <= 0;
            await <= 0;
            run <= 0;
            gen <= 0;
            biggen <= 0;
            mapData <= 64'b00000000_00000100_00100110_00000000_00001100_01101000_00100000_00000000;
            bestScore <= 0;
            mutate <= 0;
            absoluteTime <= 0;
            seedZero <= 0;
            seedA <= mapData[31:0];
            //seedB <= mapData[63:32];
            segNum[0] <= 7'b1000000;
            segNum[1] <= 7'b1111001;
            segNum[2] <= 7'b0100100;
            segNum[3] <= 7'b0110000;
            segNum[4] <= 7'b0011001;
            segNum[5] <= 7'b0010010;
            segNum[6] <= 7'b0000010;
            segNum[7] <= 7'b1111000;
            segNum[8] <= 7'b0000000;
            segNum[9] <= 7'b0010000;
            segNum[10] <= ~7'b1110111;
            segNum[11] <= ~7'b1111100;
            segNum[12] <= ~7'b0111001; 
            segNum[13] <= ~7'b1011110; 
            segNum[14] <= ~7'b1111001; 
            segNum[15] <= ~7'b1110001;
            
            
        end
        if (!start) begin
            seedZero <= seedZero + 1;
            seg0out <= segNum[0];
            seg1out <= segNum[0];
        end
        else begin
            absoluteTime <= absoluteTime +1;
            seedA <= absoluteTime;
            case (state)
                0 : begin
                    // wait for the random number generator to start; await time may be user input for added randomness
                    if (await == seedZero) begin
                        state <= 1;
                    end else begin
                        await <= await + 1;
                    end
                end
                1 : begin
                    //initialize

                    // initialize geneRAM (deprecated)
                    //wren <= 1;
                    //writeaddress <= childID;
                    
                    //TEMPORARY 64 bit gene is just repeating two 32bit randomly generated genes (ideally should be 64bit random)
                    case (half)
                        0: begin
                            genes[childID][31:0] <= randomGene;
                            half <= 1;
                        end
                        1 : begin
                            genes[childID][47:32] <= randomGene[15:0];
                            half <= 0;
                        end
                        default begin

                        end
                    endcase
                    // initialize mapROM (deprecated)

                    // initialize leaderboardROM (UNFINISHED)
                    // ...
                    if (childID == childN) begin
                        //finishing up the initialization
                        //wren <= 0; //stop writing to geneRAM
                        //genes[0] <= {6'b111111, 14'b01010101010101, 14'b10101010101010, 14'b00000000000000};

                        //debug perfect gene
                        half <= 0;
                        genes[8] <= 0;
                        state <= 2;
                    end else if (half == 1) begin
                        //iterate through initialization loop
                        childID <= childID + 1;
                    end
                end
                2 : begin
                    //simulate LOOP BEGIN
                    
                    case (run)
                        0 : begin
                            //initialize simulation
                            for (i = 0; i < childN; i = i + 1) begin
                                x[i] <= 0;
                                y[i] <= 0;
                                f[i] <= 0;
                                mutate <= 0;
                                //fSort[i] <= 0;
                                selection[i] <= i;
                                t <= 0;
                                dir[i] <= genes[i][1:0]; //preload first 2 bits
                                genes[i] <= {genes[i][1:0], genes[i][47:2]}; //load next 2 bits
                                alive[i] <= 1;
                                
                                
                                
                            end

                            run <= 1;
                        end
                        1 : begin
                            //run simulation
                            //gene 0~7
                            for (i = 0; i < childN; i = i + 1) begin
                                x[i] <= xnew[i];
                                y[i] <= ynew[i];
                                alive[i] <= alivenew[i];
                                //following may require special logic for reading from 0~7 or 8~15
                                dir[i] <= genes[i][1:0]; //load next 2 bits
                                genes[i] <= {genes[i][1:0], genes[i][47:2]};
                            end
                            //seedA <= absoluteTime;
                            //seedB <= genes[1][31:0];
                            
                            //...
                            
                            if (t == 24 || t == 25) begin
                                for (i = 0; i < childN; i = i + 1) begin

                                //following may require special logic for reading from 0~7 or 8~15
                                dir[i] <= genes[i][1:0]; //load next 2 bits
                                genes[i] <= {genes[i][45:0], genes[i][47:46]};
                                end
                                t <= t+1;
                            end else if (t == 26) begin
                                run <= 2;
                            end else begin
                                t <= t+1;
                            end
                        end
                        2 : begin
                            //end of simulation
                            //calculate fitness
                            for (i = 0; i < childN; i = i + 1) begin
                                f[i] <= fit[i];
                                /*
                                if (fit[i] >= fSort[7]) begin
                                    selection[7] <= i;
                                    fSort[7] <= fit[i];
                                    for (s = 0; s < 8; s = s+1) begin
                                        selection[s] <= selection[s+1];
                                        fSort[s] <= fSort[s+1];
                                    end
                                end
                                */
                            end

                            t <= 1;
                            //commit best f to rom
                            run <= 3;
                        end
                        3 : begin
                            if (f[t] < f[t-1]) begin
                                selection[t] <= selection[t-1];
                                f[t] <= f[t-1];
                                selection[t-1] <= selection[t];
                                f[t-1] <= f[t];

                                t <= t + 1;
                            end else if (f[0] <= f[1] && f[1] <= f[2] && f[2] <= f[3] && f[3] <= f[4] && f[4] <= f[5] && f[5] <= f[6] && f[6] <= f[7]) begin
                                p[0] <= randomGene[1:0];
                                p[1] <= randomGene[3:2];
                                t <= 0;
                                for (codon = 0; codon < 24; codon = codon +1) begin
                                    mask_real[codon] <= {randomGene[codon], randomGene[codon]};
                                end
                                half <= 0;
                                run <= 4;
                            end else begin
                                t <= t + 1;
                            end
                        end
                        
                        4 : begin
                            //create offspring
                            if (t < childN) begin
                                case (half)
                                0 : begin
                                    for (codon = 0; codon < 48; codon = codon +1) begin
                                        genes[8+t][codon] <= (genes[selection[4+p[0]]][codon] & mask[codon]) + (genes[selection[4+p[0]]][codon] & ~mask[codon]);
                                        
                                        
                                        
                                    end
                                    //seedA <= absoluteTime
                                    half <= 1;
                                end
                                1: begin
                                    for (codon = 0; codon < 24; codon = codon +1) begin
                                        mask_real[codon] <= {randomGene[codon], randomGene[codon]};
                                    end
                                    if (randomGene[6:0] < mutateP) begin
                                        genes[8+t][randomGene[5:0]] <= ~genes[8+t][randomGene[5:0]];
                                        
                                        //debug
                                        mutate <= 1;
                                    end
                                    p[0] <= {randomGene[t+1], randomGene[t]};
                                    p[1] <= {randomGene[t+5], randomGene[t+8]};
                                    //seedA <= absoluteTime;
                                    t <= t + 1;
                                    half <= 0;
                                    mutate <= 0;
                                end
                                endcase
                            end else if (t == childN) begin
                                run <= 5;
                            end
                        end
                        5 : begin
                            if (gen == biggen * 8 + 15 || gen == 0) begin
                                    biggen <= biggen + 1;
                                    //wren <= 1;
                                    //writeaddress <= biggen;
                                    //writedata <= genes[selection[7]];
                                    //fwdata <= f[selection[7]];
                                    
                            end
                            for (i = 0; i < childN; i = i + 1) begin
                                genes[i] <= genes[i+8];
                                genes[i+8] <= 0;
                            end
                            if (bestScore < f[selection[7]]) begin
                                bestScore <= f[selection[7]];
                            end
                    
                            // reproduce LOOP END
                    
                            if (gen < genN) begin
                                gen <= gen + 1;
                                //seg1out <= segNum[gen[3:0]]; 
                                //seg0out <= segNum[{gen[6], gen[5], gen[4]}];
                                run <= 0;
                                
                            end else begin
                                biggen <= biggen + 1;
                                //writeaddress <= biggen;
                                //writedata <= genes[selection[7]];
                                
                                run <= 6;
                            end
                                    
                        end
                        6 : begin
                            //wren <= 0;
                            //readaddress <= 3;
                            state <= 3;
                        end
                        default begin

                        end
                    endcase
                    
                    //DEBUG ONLY state <= 3;

                    
                end
                3 : begin
                    state <= 4;

                end
                4 : begin
                    //wren <= 0;
                    state <= 5;
                end
                5 : begin
                    // display
                    seg1out <= segNum[15];
                    //seg0out <= segNum[5];
                    state <= 6;
                end
                default : begin
                    // empty
                end
            endcase
        end
    end
endmodule