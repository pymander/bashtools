#!/bin/bash
# Bash2 directory history/stack by Erik Arneson <dybbuk@lnouv.com>
#
# This script wraps the 'cd' command to
# store a history of recently visited directories.  One can view the
# history, change directly to a given spot in the history, or move
# forward and backward on the history stack.
#
# dl  --  Display history stack
# go  --  Go directly to an entry on the stack using a number or name.
# f   --  Forward one entry
# b   --  Back one entry
# cd  --  Change directory.  If the directory is "," followed by a number,
#         treat it like 'go'.
#
# Set the STARTSTACK environment variable before loading this file to
# have a startup list of common directories available.  Use something
# like this:
#
#    declare -a STARTSTACK
#    STARTSTACK=(/home/foobar/projects /etc/foobar)
#
# Adapted from some login script somebody sent me long ago, when I was
# working at Yahoo.

# Declare our _DL variable as an array.
declare -a _DL
declare -i _STACK_SIZE=50

## directory history ##
_cd_hist () {
  case "$1" in
    ,*)
      go "${1#,}"
      ;;
    *)
      if [ "x$1" = "x" ]; then
        builtin cd $HOME
      else
        builtin cd "$1"
      fi
      [ $? -eq 0 ] || return 1;
  
      case "$PWD" in
        "$_LAST_DIR")
          _PTR=$_DIR
          ;;
        *)
          _DIR=$[$_DIR+1]
          _DL[$_DIR]="$PWD"
          _LAST_DIR="$PWD"
          _PTR=$_DIR
          ;;
      esac
      ;;
  esac
}

_init_cd_hist () {
  _DIR=1
  _LAST_DIR="$PWD"

  # Initialize our stack.
  if [ ${#STARTSTACK[*]} > 0 ]
  then
      for (( i=0; i < ${#STARTSTACK[*]}; i++ ))
      do
          _DL[$_DIR]="${STARTSTACK[$i]}"
          _DIR=$[$_DIR+1]
      done
  fi

  # Stick us at the end of the stack in our current directory.
  _DL[$_DIR]="$PWD"
  _PTR=$_DIR
}

# Removes duplicates from our directory stack.  This actually could be
# used as a general-purpose uniq'er for Bash arrays.  However, this
# attempts to retain the original order of the stack, so it's a bit
# different.  Also, it checks for the validity of the directory.  We
# work in an environment where directories frequently disappear and have
# a short lifespan, so this is very useful to me.
_clean_cd_hist () {
    declare -a _NEW_DIR
    local -i i
    local -i n=1
    local old_ifs=$IFS

    IFS=":"

    for (( i=1; i <= ${#_DL[*]} ; i++ ))
    do
        [ "x${_DL[$i]}" == "x" ] && continue
        echo "${IFS}${_NEW_DIR[*]}${IFS}" | grep -q "${IFS}${_DL[$i]}${IFS}"
        if [ $? -ne 0 -a -d "${_DL[$i]}" ]
        then
            _NEW_DIR[$n]="${_DL[$i]}"
            n=$[$n+1]
        fi
    done

    unset _DL
    for (( i=1; i <= ${#_NEW_DIR[*]} ; i++ ))
    do
        _DL[$i]=${_NEW_DIR[$i]}
    done
    _DIR=${#_DL[*]}
    _PTR=$_DIR
    _LAST_DIR="${_DL[$_DIR]}"
    IFS="$old_ifs"
    go "$PWD"
}
         
dl () {
  local dir
  declare -i i=1

  for (( i=1 ; i <= ${#_DL[*]} ; i++ )); do
    dir="${_DL[$i]}"
    echo -n "$i"
    [ $i -eq $_PTR ] && echo -n " *";
    echo -ne "\t"
    case "$dir" in
        $HOME*)
            echo "~${dir#$HOME}"
            ;;
        *)
            echo $dir
            ;;
    esac
  done
}

go () {
    declare -i i=$_DIR
  
    local dir 
      
    [ $# -eq 1 ] || go $HOME;

    command test "$1" -gt 0 -a "$1" -le $_DIR 2>/dev/null
    if [ $? -eq 0 ]; then
        dir="${_DL[$1]}"
        builtin cd "$dir"
        if [ $? -eq 0 ]
        then
            _PTR=$1
            echo -e "$1\t$dir"
        fi
    else
        local found=0
        for (( i=1 ; i <= ${#_DL[*]} ; i++ )); do
            dir="${_DL[$i]}"
            case "$dir/" in
                *"$1"|*"$1"/)
                    found=1
                    go $i
                    break
                    ;;
            esac
        done
        if [ $found -eq 0 ]; then
            _cd_hist "$1"
        fi
    fi
} 

_back () {
    local dir
    local _oldptr=$_PTR

    [ $_PTR -gt 1 ] || return 1;

    _PTR=$[$_PTR-1]

    dir="${_DL[$_PTR]}"
    builtin cd "$dir"
    if [ $? -eq 0 ]
    then
        echo -e "$_PTR\t$dir"
    else
        _PTR=$_oldptr
    fi
}

_forward () {
    local dir
    local _oldptr=$_PTR

    [ $_PTR -lt $_DIR ] || return 1;

    _PTR=$[$_PTR+1]

    dir="${_DL[$_PTR]}"
    builtin cd "$dir"
    if [ $? -eq 0 ]
    then
        echo -e "$_PTR\t$dir"
    else
        _PTR=$_oldptr
    fi
}

alias cd='_cd_hist'
alias b='_back'
alias f='_forward'

[ "$_DIR" ] || _init_cd_hist

# Redefine aecd so it meshes cleanly with these functions.  Otherwise,
# it bypasses the directory stack.
aecd () {
        cd `aegis -cd "$@" -v`
}
