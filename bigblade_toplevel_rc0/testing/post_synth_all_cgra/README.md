## Post-synth GL CGRA + RTL-hard chip simulation

Files in this directory allow you to swap in eight post-synth GL CGRA
instances and simulate with RTL-hard chip. The diagram below shows
the relative positions of all eight CGRA instances to the four pod
rows.

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

This simulation setting is useful for verifying the connectivity
between the pod rows and all CGRA instances.
