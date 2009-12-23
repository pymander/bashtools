# Stuff to set an intelligent prompt -- note that all the Aegis stuff
# has been stripped away.

HOST=tyche

if [ -n "$PS1" ]; then

  ## prompt ##
  _BOLD="\[\033[1m\]"
  _NORM="\[\033[0m\]"

  case "$TERM" in
    *xterm*|*rxvt*)
       PROMPT_COMMAND="prompt"
       PS1=$"[${_BOLD}\u${_NORM}@${_BOLD}\h${_NORM}:${_BOLD}\w${_NORM}]\\$ "
       PS2="> "
       ;;
    *)
       # Because tramp hates my funky prompt, non-xterm logins get the shaft.  :)
       PS1="[\u@\h:\w]\\$ "
       PS2="> "
       ;;
  esac
fi

# The rest of this is stuff for title bars et al.
case $TERM in
  xterm* | kterm | rxvt*)
    title () { echo -en "\033]2;${*}\007"; }
    icon () { echo -en "\033]1;${*}\007"; }
    ;;
  *)
    title () { :; }
    icon () { :; }
    ;;
esac

prompt () {
  local pwd=$PWD

  case $PWD in
    $HOME*)
      pwd=~${PWD#$HOME}
      ;;
  esac

  # Set up titles the way I like them.  Include the AEGIS_PROJECT
  # variable, so I can tell what I'm working on!
  title "$USER@$HOST:$pwd"
  icon "$USER@$HOST:${pwd##*/}"
}

# End of file.
