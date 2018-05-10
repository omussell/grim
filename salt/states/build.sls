bazel:
  pkg.installed

bash:
  pkg.installed

bash_symlink:
  file.symlink:
    - name: /bin/bash
    - target: /usr/local/bin/bash
