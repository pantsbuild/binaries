#!/usr/bin/env python

import os
import subprocess
import sys

argv = sys.argv

this_file_dir = os.path.dirname(__file__)

xz_executable = os.path.realpath(os.path.join(this_file_dir, 'xz-real'))

xz_lib_dir = os.path.realpath(os.path.join('..', 'lib'))

platform = os.uname()[0]

if platform == 'Darwin':
  env_var = 'DYLD_LIBRARY_PATH'
elif platform == 'Linux':
  env_var = 'LD_LIBRARY_PATH'
else:
  raise ValueError('Unrecognized platform: {}.'.format(platform))

prev_lib_path = os.environ.get(env_var, '')
lib_path_entries = [s for s in prev_lib_path.split(':') if s != '']
lib_path_ours_first = [xz_lib_dir] + lib_path_entries

new_env = os.environ.copy()

new_env[env_var] = ':'.join(lib_path_ours_first)

# Inherit the standard fds, close any extra we may have opened.
rc = subprocess.call(sys.argv, executable=xz_executable, env=new_env, close_fds=True)
sys.exit(rc)
