
import sys
import os
import glob
import re

if __name__ == "__main__":

  if len(sys.argv) == 2:
    outpath = sys.argv[1]
    filelist = glob.glob(os.path.join(outpath, '*.log'))
    filelist.sort()
    for file in filelist:
      corner = os.path.basename(file).replace('.log', '')
      print(corner+',', end='')
      f = open(file, "r")
      lines = f.readlines()
      for line in lines:
        numpattern = ".*[0-9]*\.[0-9]*"
        pattern = re.compile(".* *\(.*\) *"+numpattern+" *[fr] *"+numpattern+" *"+numpattern+" *"+numpattern)
        if pattern.match(line):
          slack = line.split()[-1]
          print(slack+',', end='')
      print('')
  else:
    print("USAGE:")
    command = "python output_csv.py {outpath}"
    print(command)
