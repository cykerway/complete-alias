#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  test escaped command in alias body; complete with option;
##
##      . test_escape_option.sh
##      test_escape_option <tab>
##
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

complete -u '/tmp/aaa\ \ \ bbb'
alias test_escape_option='/tmp/aaa\ \ \ bbb'
complete -F _complete_alias test_escape_option

