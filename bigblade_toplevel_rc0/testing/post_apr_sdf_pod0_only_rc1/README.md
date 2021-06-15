###
How to use:

- To build simv in all 32 corners
  - make build -j32
  - make build-debug -j32

- To build invididual simv
  - make out/{corner_name}_min/simv
  - make out/{corner_name}_max/simv
  - make out/{corner_name}_min/simv-debug
  - make out/{corner_name}_max/simv-debug

- To run in min/max version
  - make {corner_name}.min.run
  - make {corner_name}.max.run
  - make {corner_name}.min.debug
  - make {corner_name}.max.debug

- To open waveform
  - make {corner_name}.min.dve
  - make {corner_name}.max.dve
###
