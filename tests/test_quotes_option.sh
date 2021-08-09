#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  test quoted command in alias body; complete with option;
##
##      . test_quotes_option.sh
##      test_quotes_option <tab>
##
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

complete -u '"/tmp/aaa   bbb"'
alias test_quotes_option='"/tmp/aaa   bbb"'
complete -F _complete_alias test_quotes_option

