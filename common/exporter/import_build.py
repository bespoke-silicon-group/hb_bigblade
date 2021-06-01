#!/usr/bin/env python3
import sys, os, glob, subprocess, datetime, socket
from subprocess import run

# The directoy to copy the design to.
BUILD_DIR   = 'bsg_14'
RELEASE     = 'rc-alpha-rtlfreeze'
RELEASE_DIR = '/nbu/spin/share/gf14/bigblade_exports'

olddir = os.getcwd()

# Grab the name of the current directory which is the project name (or design
# name). This will be the directory name in the release dir where the build is
# exported to.
project_name = os.getcwd().split(os.sep)[-1]
top_block_name = os.environ['TOP_HIER_BLOCK']
print(f'Importing design "{project_name}", top-level block name "{top_block_name}", build at "{BUILD_DIR}"')
print()

# Search for all releases in the release dir. The list is in order
# (alphabetical and dictionary order so the newest version should be list in
# the list).
print(f'Searching for release "{RELEASE}" in directory "{RELEASE_DIR}":')
release_dirs = sorted([d for d in glob.glob(os.sep.join([RELEASE_DIR, RELEASE]) + '*')], key=lambda x : int(x[x.rfind('-'):]), reverse=True)
for d in release_dirs:
  print(f'\t{d}')
print()

# No releases found
if len(release_dirs) == 0:
  print(f'No release dirs found, exiting...')
  sys.exit(1)

# Go through the release dirs from newest to oldest and look for the design.
path_to_build = None
release_dir = None
for d in release_dirs[::-1]:
  if os.path.exists(os.sep.join([d, project_name])):
    path_to_build = os.sep.join([d, project_name])
    release_dir = d.split(os.sep)[-1]
    break

if path_to_build is None:
  print(f'ERROR: Could not find design "{project_name}" in any of the release directories... exiting.')
  sys.exit(1)
else:
  print(f'Design "{project_name}" found in release "{release_dir}" (full path "{path_to_build}")')
print()

# Check the resulting location
result_dir = os.sep.join([ BUILD_DIR, release_dir + "_" + project_name ])
if os.path.exists(result_dir):
  print(f'ERROR: the relase dir {release_dir} already exists in {BUILD_DIR}, cannot override... exiting.')
  sys.exit(1)

print(f'Resulting directory will be imported to "{result_dir}"')
print()

# User confirm
user_input = input("Confirm? [y/n] ")
if user_input.lower() != 'y':
  print('Export canceled, exiting.')
  sys.exit(1)

# Copy the build
cmd = [ 'rsync', '-trav', os.sep.join([path_to_build, 'bsg_14', 'current_build/']), result_dir ]
print(f'Running cmd: {" ".join(cmd)}')
subprocess.run(cmd)

# Symlink current_build
os.chdir(BUILD_DIR)
cmd = [ 'ln', '-nsf', os.sep.join(result_dir.split(os.sep)[1:]), 'current_build']
print(f'Running cmd: {" ".join(cmd)}')
subprocess.run(cmd)

# Relink NDMs
cmd = [ 'make', 'pnr.relink_ndms.%s' % top_block_name ]
print(f'Running cmd: {" ".join(cmd)}')
subprocess.run(cmd)

