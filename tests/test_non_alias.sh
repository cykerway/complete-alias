#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  test non-alias command;
##
##      . test_non_alias.sh
##      test_non_alias <tab>
##
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

alias ls="ls --color=auto"
alias sudo="sudo "
alias test_non_alias="sudo /bin/ls"
complete -F _complete_alias test_non_alias

