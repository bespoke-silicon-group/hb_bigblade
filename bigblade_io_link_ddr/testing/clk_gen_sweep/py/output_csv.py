
import sys
import os
import glob
import re

if __name__ == "__main__":

  if len(sys.argv) == 2:
    logpath = sys.argv[1]
    filelist = glob.glob(os.path.join(logpath, '*.log'))
    filelist.sort()
    for file in filelist:
      corner = os.path.basename(file).replace('.log', '')
      print(corner, end='')
      f = open(file, "r")
      lines = f.readlines()
      edge = 'NEG'
      for line in lines:
        pattern = re.compile("[0-9]+\s[0-9]+\s[0-9]+\s[0-9]+\s.*")
        if pattern.match(line):
          print(','+edge+',', end='')
          array = line.split()
          # remove first number if it is smaller than second one
          # usually caused by glitch from clk_gen downsampler
          if int(array[0]) < int(array[1]):
            array.pop(0)
          for num in array:
            print(num+',',end='')
          print('')
          edge = 'POS'
  else:
    print("USAGE:")
    command = "python output_csv.py {logpath}"
    print(command)
