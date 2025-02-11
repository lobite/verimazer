# Verimazer
A genetic learning algorithm written in VerilogHDL that solves grid mazes, designed for the Cyclone V

# About
This program was written during the 5 day FPGA program. I learned VerilogHDL from scratch within the time frame.

# What I wanted to accomplish
- Solve a given maze with genetic learning, starting with pseudorandom inputs
- Parallel processing
- Utilizing the I/O on the DE-10 dev board to allow users to input their own maze grid
- Display the solved path on a screen

# What was accomplished
- Solve a given maze with genetic learning, starting with pseudorandom inputs
- Parallel processing

# How it works
1. Generate 8 random sequence of movements as the starting "genes"
Repeat the following until solved or reaches computation limit:
1. Move through the maze using the provided gene
2. Calculate score based on how close it got to the goal
3. Leaving only the top ranking genes, cross-over and mutate to generate the next batch of genes

# Genes and Mazes
Gene:
- 2x24 bit long
- every 2 bits specify a cardinal direction in which to move
- Meaning, goal must be reached within 24 steps while not colliding with obstacles
![[Pasted image 20250211094300.png]]
Example maze

## Fitness Score
$$f = (\text{Goal reached bias})+ x_{fin}\times y_{fin} + (x_{fin}+y_{fin})$$
The score is both multiplicative and additive of the final x, y coordinates to award genes that moved in any direction, diagonal or not.
Genes are sorted by score and the top half is selected for breeding.
A pair of genes are selected at random, and they cross over their codons (2 bit long) using a randomly generated mask (see diagram below.) Finally, a single bit is flipped under a certain probability. This imitates mutation.
![[Pasted image 20250211094818.png]]

# Results
In the maze below, 0 represents a movable floor, while 1 and out-of-bounds represent walls/pitfalls that terminate the path when stepped on. Every gene starts from the bottom-left and attempt to reach the top-right.
Gen 1.
![[Pasted image 20250211095046.png]]
Gen 7.
![[Pasted image 20250211095103.png]]
Gen 50.
![[Pasted image 20250211095117.png]]
Gen 71 (first goal)
![[Pasted image 20250211095138.png]]
Gen 256 (simulation end)
![[Pasted image 20250211095157.png]]

# Performance on the Cyclone V
- 32445 cycles = 0.7ms taken to solve the above maze, thanks to parallel processing (for reference, a similar program took 2s in Python)
- 8 individuals per generation (can be increased until logic gates are exhausted)
- Logic utilization: 1922/41910 (5%)
- Total registers: 1184
- 546 lines of VerilogHDL code

I was able to write a highly efficient and expandable algorithm thanks to the low level logic that VerilogHDL offers, despite my lack of experience with it.