#!/usr/bin/env python3
import sys, os, glob, subprocess, datetime
from subprocess import run

# The build dir to export (comes from command line, should be something like
# bsg_14/current_bulid)
BUILD_DIR = sys.argv[1]

# RELASE name and directory
RELEASE     = 'rc-alpha-freeze'
RELEASE_DIR = '/nbu/spin/share/gf14/bigblade_exports'
#RELEASE_DIR = './release'

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
if len(release_dirs) == 0:
else:
  current_release = release_dirs[-1]
  print(f'Current release: {current_release}')

# If this project is in the current release, we need to create a new release
# with the release number incremented by 1.
if os.path.exists(os.sep.join([release_dirs[-1], project_name])):
  next_release_num = int(current_release.split('-')[-1]) + 1
  current_release = os.sep.join([RELEASE_DIR, RELEASE + '-%d' % next_release_num])
  print(f'\tDesign "{project_name}" already exists, incrementing relase to "{current_release}"')
print()

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
print('\tChecking for synthesis run... ', end='')
synth_run_path = os.sep.join([BUILD_DIR, 'synth'])
(synth_run_found, synth_run_files, synth_run_size) = check_for_file(synth_run_path)
all_files.extend(synth_run_files)
print(f'FOUND!' if synth_run_found else f'NOT FOUND!')
if synth_run_found:
  for f,s in zip(synth_run_files,synth_run_size):
    print(f'\t\t{f} ({s})')

# Search for the pnr/ directory
print('\tChecking for place-and-route run... ', end='')
pnr_run_path = os.sep.join([BUILD_DIR, 'pnr'])
(pnr_run_found, pnr_run_files, pnr_run_size) = check_for_file(pnr_run_path)
all_files.extend(pnr_run_files)
print(f'FOUND!' if pnr_run_found else f'NOT FOUND!')
if pnr_run_found:
  for f,s in zip(pnr_run_files,pnr_run_size):
    print(f'\t\t{f} ({s})')

# Search for the export_etm/ directory
print('\tChecking for exported ETM... ', end='')
export_etm_path = os.sep.join([BUILD_DIR, 'export_etm'])
(export_etm_found, export_etm_files, export_etm_size) = check_for_file(export_etm_path)
all_files.extend(export_etm_files)
print(f'FOUND!' if export_etm_found else f'NOT FOUND!')
if export_etm_found:
  for f,s in zip(export_etm_files,export_etm_size):
    print(f'\t\t{f} ({s})')

# Search for the xray parasitic files (spef)
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
print('\tChecking for fill gds... ', end='')
fill_gds_path = os.sep.join([BUILD_DIR, 'fill'])
(fill_gds_found, fill_gds_files, fill_gds_size) = check_for_file(fill_gds_path)
all_files.extend(fill_gds_files)
print(f'FOUND!' if fill_gds_found else f'NOT FOUND!')
if fill_gds_found:
  for f,s in zip(fill_gds_files,fill_gds_size):
    print(f'\t\t{f} ({s})')

print()

# The path where we are going to copy our build to 
result_dir = os.sep.join([current_release, project_name])
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
with open(os.sep.join([result_dir,'COMMIT']), 'w') as fid:
  fid.write(f'Build Date: {datetime.datetime.now()}\n')
  for k,v in repos.items():
    fid.write(f'{k}: {v["commit"]} ({v["branch"]})\n')

# Rsync the files to the directory
cmd = ['rsync', '-Rtrav'] + all_files + [result_dir]
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

