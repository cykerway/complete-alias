#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  test escaped command in alias body; complete with function;
##
##      . test_escape_function.sh
##      test_escape_function <tab>
##
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

complete -F _known_hosts '/tmp/aaa\ \ \ bbb'
alias test_escape_function='/tmp/aaa\ \ \ bbb'
complete -F _complete_alias test_escape_function

