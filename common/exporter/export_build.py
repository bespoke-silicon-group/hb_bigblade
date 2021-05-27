#!/usr/bin/env python3
import sys, os, glob, subprocess, datetime, socket
from subprocess import run

# The build dir to export (comes from command line, should be something like
# bsg_14/current_bulid)
BUILD_DIR = sys.argv[1]

# Netlist export mode:
#   0 = no netlist export mode (full build export to gf14 share)
#   1 = post-synth netlist export mode for hb_bigblade_netlists
#   2 = post-apr netlist export mode for hb_bigblade_netlists
NETLIST_EXPORT_MODE = 0
if len(sys.argv) > 2:
  if sys.argv[2] == '--netlist-post-synth':
    NETLIST_EXPORT_MODE = 1
  elif sys.argv[2] == '--netlist-post-apr':
    NETLIST_EXPORT_MODE = 2

# RELEASE name and directory for build export
if NETLIST_EXPORT_MODE == 0:
  RELEASE     = 'rc-alpha-rtlfreeze'
  RELEASE_DIR = '/nbu/spin/share/gf14/bigblade_exports'

# RELEASE name and directory for netlist export (check to make sure repo exists too!)
elif NETLIST_EXPORT_MODE == 1 or NETLIST_EXPORT_MODE == 2:
  RELEASE     = 'rc-alpha-rtlfreeze'
  RELEASE_DIR = './hb_bigblade_netlists'
  if not os.path.exists(RELEASE_DIR):
    print('ERROR: please clone hb_bigblade_netlists before proceeding!')
    print('\tgit clone git@github.com:bespoke-silicon-group/hb_bigblade_netlists.git')
    sys.exit(0)

# Print some system information and current directory
print('System Information:')
print(f'\tDate:     {datetime.datetime.now()}')
print(f'\tUsername: {os.environ["USER"]}')
print(f'\tHostname: {socket.gethostname()}')
print(f'\tExec Dir: {os.getcwd()}')
print()

# Grab the name of the current directory which is the project name (or design
# name). This will be the directory name in the release dir where the build is
# exported to.
project_name = os.getcwd().split(os.sep)[-1]
print(f'Packaging design "{project_name}", build at "{BUILD_DIR}"')
print()

olddir = os.getcwd()
print('Searching for repositories...')

# Function takes a path to a repo and returns the repo name, commit and branch
def get_git_commit_branch(path):
  old_dir = os.getcwd()
  os.chdir(path)
  repo_name = os.getcwd().split(os.sep)[-1]
  results = run(['git', 'rev-parse', 'HEAD'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  commit = results.stdout.decode('utf-8').strip()
  results = run(['git', 'describe', '--exact-match', '--tags', commit], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  if results.returncode == 0:
    branch = results.stdout.decode('utf-8').strip()
  else:
    results = run(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    branch = results.stdout.decode('utf-8').strip()
  os.chdir(old_dir)
  return (repo_name, commit, branch)

# holds all the information about repos
repos = {}
  
# get the commit/branch for the current dir (hb_bigblade) and search all
# sub-dirs for a .git directory and grab the commit/branch for those as well.
_,commit,branch = get_git_commit_branch('./')
repos['hb_bigblade'] = {'commit': commit, 'branch': branch}
for d in glob.glob("./*/.git"):
  repo_name,commit,branch = get_git_commit_branch(d + '/..')
  repos[repo_name] = {'commit': commit, 'branch': branch}

for k,v in repos.items():
  print(f'\t{k} ({v["commit"]}) ({v["branch"]})')
print()

# Search for all releases in the release dir. The list is in order
# (alphabetical and dictionary order so the newest version should be list in
# the list).
print(f'Searching for release "{RELEASE}" in directory "{RELEASE_DIR}"')
release_dirs = [d for d in glob.glob(os.sep.join([RELEASE_DIR, RELEASE]) + '*')]
for d in release_dirs:
  print(f'\t{d}')
print()

# No releases found
if len(release_dirs) == 0:
  release_dirs.append( os.sep.join([RELEASE_DIR, RELEASE + '-0']) )
  current_release = release_dirs[-1]
  print(f'No release dirs found, starting with: {current_release}')

# Releases found
else:
  current_release = release_dirs[-1]
  print(f'Current release: {current_release}')

# The path where we are going to copy our build
if NETLIST_EXPORT_MODE == 0:
  result_dir = os.sep.join([current_release, project_name])
elif NETLIST_EXPORT_MODE == 1:
  result_dir = os.sep.join([current_release, 'post-synth', project_name])
elif NETLIST_EXPORT_MODE == 2:
  result_dir = os.sep.join([current_release, 'post-apr', project_name])

# If this project is in the current release, we need to create a new release
# with the release number incremented by 1.
if len(glob.glob(result_dir + '*')) > 0:
  next_release_num = int(current_release.split('-')[-1]) + 1
  current_release = os.sep.join([RELEASE_DIR, RELEASE + '-%d' % next_release_num])
  print(f'\tDesign "{project_name}" already exists, incrementing relase to "{current_release}"')
print()

# Redo incase the release dir number was incremented...
if NETLIST_EXPORT_MODE == 0:
  result_dir = os.sep.join([current_release, project_name])
elif NETLIST_EXPORT_MODE == 1:
  result_dir = os.sep.join([current_release, 'post-synth', project_name])
elif NETLIST_EXPORT_MODE == 2:
  result_dir = os.sep.join([current_release, 'post-apr', project_name])

# Begin checking for all the files to export and adding them to the all_files list
print('Checking for files to export...')
all_files = []

# Utility function. Returns if the path globed any files, the list of files it
# globed, and a list of sizes for each globed file.
def check_for_file( path ):
  files = glob.glob(path)
  found = None
  size = []
  if len(files) > 0:
    for f in files:
      results = run(['du', '-hd0', f], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
      size.append(results.stdout.decode('utf-8').split()[0].strip())
    found = True
  else:
    found = False
  return (found, files, size)

# Search for the synth/ directory
if NETLIST_EXPORT_MODE == 0:
  print('\tChecking for synthesis run... ', end='')
  synth_run_path = os.sep.join([BUILD_DIR, 'synth'])
  (synth_run_found, synth_run_files, synth_run_size) = check_for_file(synth_run_path)
  all_files.extend(synth_run_files)
  print(f'FOUND!' if synth_run_found else f'NOT FOUND!')
  if synth_run_found:
    for f,s in zip(synth_run_files,synth_run_size):
      print(f'\t\t{f} ({s})')

# Search for the pnr/ directory
if NETLIST_EXPORT_MODE == 0:
  print('\tChecking for place-and-route run... ', end='')
  pnr_run_path = os.sep.join([BUILD_DIR, 'pnr'])
  (pnr_run_found, pnr_run_files, pnr_run_size) = check_for_file(pnr_run_path)
  all_files.extend(pnr_run_files)
  print(f'FOUND!' if pnr_run_found else f'NOT FOUND!')
  if pnr_run_found:
    for f,s in zip(pnr_run_files,pnr_run_size):
      print(f'\t\t{f} ({s})')

# Search for the export_etm/ directory
if NETLIST_EXPORT_MODE == 0:
  print('\tChecking for exported ETM... ', end='')
  export_etm_path = os.sep.join([BUILD_DIR, 'export_etm'])
  (export_etm_found, export_etm_files, export_etm_size) = check_for_file(export_etm_path)
  all_files.extend(export_etm_files)
  print(f'FOUND!' if export_etm_found else f'NOT FOUND!')
  if export_etm_found:
    for f,s in zip(export_etm_files,export_etm_size):
      print(f'\t\t{f} ({s})')

# Search for the xray parasitic files (spef)
if NETLIST_EXPORT_MODE == 0:
  print('\tChecking for xray pex spef files... ', end='')
  spef_path = os.sep.join([BUILD_DIR, 'pex_xray_gate/*/results/*'])
  (spef_found, spef_files, spef_size) = check_for_file(spef_path)
  all_files.extend(spef_files)
  print(f'FOUND! ({spef_size[0]})' if spef_found else f'NOT FOUND!')
  if spef_found:
    for f,s in zip(spef_files,spef_size):
      print(f'\t\t{f} ({s})')

  # If no xray parasitics were found, look for normal parasitics (spef)
  if not spef_found:
    print('\tChecking for pex spef files... ', end='')
    spef_path = os.sep.join([BUILD_DIR, 'pex_gate/*/results/*'])
    (spef_found, spef_files, spef_size) = check_for_file(spef_path)
    all_files.extend(spef_files)
    print(f'FOUND!' if spef_found else f'NOT FOUND!')
    if spef_found:
      for f,s in zip(spef_files,spef_size):
        print(f'\t\t{f} ({s})')

# Search for xray delay annotation files (sdf)
if NETLIST_EXPORT_MODE == 0:
  print('\tChecking for xray ptsi sdf files... ', end='')
  sdf_path = os.sep.join([BUILD_DIR, 'ptsi_xray/*/*/results/*.sdf.gz'])
  (sdf_found, sdf_files, sdf_size) = check_for_file(sdf_path)
  all_files.extend(sdf_files)
  print(f'FOUND! ({sdf_size[0]})' if sdf_found else f'NOT FOUND!')
  if sdf_found:
    for f,s in zip(sdf_files,sdf_size):
      print(f'\t\t{f} ({s})')

  # If no xray delay annotation files were found, look for normal ones (sdf)
  if not sdf_found:
    print('\tChecking for ptsi sdf files... ', end='')
    sdf_path = os.sep.join([BUILD_DIR, 'ptsi/*/*/results/*.sdf.gz'])
    (sdf_found, sdf_files, sdf_size) = check_for_file(sdf_path)
    all_files.extend(sdf_files)
    print(f'FOUND!' if sdf_found else f'NOT FOUND!')
    if sdf_found:
      for f,s in zip(sdf_files,sdf_size):
        print(f'\t\t{f} ({s})')

# Search for the fill/ directory
if NETLIST_EXPORT_MODE == 0:
  print('\tChecking for fill gds... ', end='')
  fill_gds_path = os.sep.join([BUILD_DIR, 'fill'])
  (fill_gds_found, fill_gds_files, fill_gds_size) = check_for_file(fill_gds_path)
  all_files.extend(fill_gds_files)
  print(f'FOUND!' if fill_gds_found else f'NOT FOUND!')
  if fill_gds_found:
    for f,s in zip(fill_gds_files,fill_gds_size):
      print(f'\t\t{f} ({s})')

# Search for post-synth netlists
if NETLIST_EXPORT_MODE == 1:
  print('\tChecking for synthesis netlist... ', end='')
  synth_netlist_path = os.sep.join([BUILD_DIR, 'synth', '*', 'results', '*.mapped.v'])
  (synth_netlist_found, synth_netlist_files, synth_netlist_size) = check_for_file(synth_netlist_path)
  all_files.extend(synth_netlist_files)
  print(f'FOUND!' if synth_netlist_found else f'NOT FOUND!')
  if synth_netlist_found:
    for f,s in zip(synth_netlist_files,synth_netlist_size):
      print(f'\t\t{f} ({s})')

# Search for post-apr netlists
if NETLIST_EXPORT_MODE == 2:
  print('\tChecking for place-and-route netlist... ', end='')
  pnr_netlist_path = os.sep.join([BUILD_DIR, 'pnr', '*', 'results', '*_chip_finish.v.gz'])
  (pnr_netlist_found, pnr_netlist_files, pnr_netlist_size) = check_for_file(pnr_netlist_path)
  all_files.extend(pnr_netlist_files)
  print(f'FOUND!' if pnr_netlist_found else f'NOT FOUND!')
  if pnr_netlist_found:
    for f,s in zip(pnr_netlist_files,pnr_netlist_size):
      print(f'\t\t{f} ({s})')

print()

# Re-print right before confirm, this is pretty important info
print(f'Resulting export directory: {result_dir}')
print()

# User confirm
user_input = input("Confirm? [y/n] ")
if user_input.lower() != 'y':
  print('Export canceled, exiting.')
  sys.exit()

# Make the result dir (using subprocess because I want to make sure the unix
# g+s permissions are used... not sure if I use they python API from shutils if
# this permssion is held)
subprocess.run(['mkdir', '-p', result_dir])

# Create the COMMIT file
print('Creating COMMIT file...', end='')
with open(os.sep.join([result_dir,'COMMIT']), 'w') as fid:
  fid.write(f'Build Date: {datetime.datetime.now()}\n')
  for k,v in repos.items():
    fid.write(f'{k}: {v["commit"]} ({v["branch"]})\n')
print(' DONE!\n')

# Rsync the files to the directory
rsync_flags = '-trav'
if NETLIST_EXPORT_MODE == 0:
  rsync_flags += 'R'
cmd = ['rsync', rsync_flags] + all_files + [result_dir]
print(f'Running command: {" ".join(cmd)}')
subprocess.run(cmd)
subprocess.run(['chgrp', '-R', 'gf14', result_dir])
subprocess.run(['chmod', '-R', 'g+r',  result_dir])
print()

# Get the total size of the export
results = run(['du', '-hd0', result_dir], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
size = results.stdout.decode('utf-8').split()[0].strip()
print(f'Export complete {result_dir} ({size})')
print()

# For netlist post-apr exports, unzip files before encrypt
if NETLIST_EXPORT_MODE == 2:
  print(f'Uncompressing files in {result_dir}')
  os.chdir(result_dir)
  subprocess.run(['gunzip'] + glob.glob('*.gz'))
  os.chdir(olddir)

# For netlist exports, encrypt the results dir
if NETLIST_EXPORT_MODE == 1 or NETLIST_EXPORT_MODE == 2:
  print(f'Encrypting result directory {result_dir}')
  os.chdir(RELEASE_DIR)
  subprocess.run(['./enc.sh', result_dir.split(RELEASE_DIR+os.sep)[-1]])
  os.chdir(olddir)

