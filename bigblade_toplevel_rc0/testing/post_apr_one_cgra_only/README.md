## Post-apr GL CGRA + RTL-hard chip simulation

Files in this directory allow you to swap in one post-apr GL CGRA
instance and simulate with RTL-hard chip. There are eight (8) CGRA
instances that you can choose to swap in (4 pod rows, 2 half pod CGRAs
per pod row). The diagram below shows the relative positions of all
eight CGRA instances to the four pod rows.

-----------------     --------------------------------------
                |     | CGRA #0: BSG_POD_Y=0, LOWER_HALF=0 |
  POD ROW 0     |     --------------------------------------
                |     --------------------------------------
                |     | CGRA #1: BSG_POD_Y=0, LOWER_HALF=1 |
-----------------     --------------------------------------
-----------------     --------------------------------------
                |     | CGRA #2: BSG_POD_Y=1, LOWER_HALF=0 |
  POD ROW 1     |     --------------------------------------
                |     --------------------------------------
                |     | CGRA #3: BSG_POD_Y=1, LOWER_HALF=1 |
-----------------     --------------------------------------
-----------------     --------------------------------------
                |     | CGRA #4: BSG_POD_Y=2, LOWER_HALF=0 |
  POD ROW 2     |     --------------------------------------
                |     --------------------------------------
                |     | CGRA #5: BSG_POD_Y=2, LOWER_HALF=1 |
-----------------     --------------------------------------
-----------------     --------------------------------------
                |     | CGRA #6: BSG_POD_Y=3, LOWER_HALF=0 |
  POD ROW 3     |     --------------------------------------
                |     --------------------------------------
                |     | CGRA #7: BSG_POD_Y=3, LOWER_HALF=1 |
-----------------     --------------------------------------

You can specify which CGRA instance to swap in by passing in
BSG_POD_Y and LOWER_HALF through the commandline. For example,
the following command builds simv-debug with CGRA #0 swapped in:

    make WAVE=1 BSG_POD_Y=0 LOWER_HALF=0
