
import sys, os, glob, re

if len(sys.argv) == 2:
  logpath = sys.argv[1]
  filelist = glob.glob(os.path.join(logpath, '*.log'))
  filelist.sort()
  for file in filelist:
    corner = os.path.basename(file).replace('.log', '')
    print(corner+',', end='')
    f = open(file, "r")
    lines = f.readlines()
    pos_list = []
    neg_list = []
    pos_line_num = 0
    neg_line_num = 0
    for line in lines:
      pos_pattern = re.compile(".*POSEDGE.*[0-9]+\s+ps")
      neg_pattern = re.compile(".*NEGEDGE.*[0-9]+\s+ps")
      if neg_pattern.match(line):
        line_num = int(line.split(':')[0])
        # remove previous number if two lines are close to each other
        # usually caused by smooth transition of osc
        if line_num <= neg_line_num + 2:
          neg_list.pop(-1)
        neg_list.append(line.split()[-2])
        neg_line_num = line_num
      if pos_pattern.match(line):
        line_num = int(line.split(':')[0])
        if line_num <= pos_line_num + 2:
          pos_list.pop(-1)
        pos_list.append(line.split()[-2])
        pos_line_num = line_num
    # Print results
    print('NEG,', end='')
    for num in neg_list:
      print(num+',', end='')
    print('\n,POS,', end='')
    for num in pos_list:
      print(num+',', end='')
    print('')

else:
  print("USAGE:")
  command = "python output_csv.py {logpath}"
  print(command)
