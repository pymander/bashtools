#!/bin/bash
#
# Include git information in the bash prompt.  Stolen from
# http://railstips.org/blog/archives/2009/02/02/bedazzle-your-bash-prompt-with-git-info/

function git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "("${ref#refs/heads/}")"
}

# This can be added to your prompt like this:
# PS1="blah blah \$(git_branch)"
# (That backslash is important.)
