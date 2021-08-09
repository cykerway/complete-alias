#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  test quoted command in alias body; complete with function;
##
##      . test_quotes_function.sh
##      test_quotes_function <tab>
##
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

complete -F _known_hosts '"/tmp/aaa   bbb"'
alias test_quotes_function='"/tmp/aaa   bbb"'
complete -F _complete_alias test_quotes_function

