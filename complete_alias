#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  automagical shell alias completion;
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

##  ============================================================================
##  Copyright (C) 2016-2021 Cyker Way
##
##  This program is free software: you can redistribute it and/or modify it
##  under the terms of the GNU General Public License as published by the Free
##  Software Foundation, either version 3 of the License, or (at your option)
##  any later version.
##
##  This program is distributed in the hope that it will be useful, but WITHOUT
##  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
##  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
##  more details.
##
##  You should have received a copy of the GNU General Public License along with
##  this program.  If not, see <http://www.gnu.org/licenses/>.
##  ============================================================================

##  ============================================================================
##  # environment variables
##
##  these are envars read by this script; users are advised to set these envars
##  before sourcing this script to customize its behavior, even though some may
##  still work if set after sourcing this script; these envar names must follow
##  this naming convention: all letters uppercase, no leading underscore, words
##  separated by one underscore;
##  ============================================================================

##  bool: true iff auto unmask alias commands; set it to false if auto unmask
##  feels too slow, or custom unmask is necessary to make an unusual behavior;
COMPAL_AUTO_UNMASK="${COMPAL_AUTO_UNMASK:-0}"

##  ============================================================================
##  # variables
##  ============================================================================

##  register for keeping function return value;
__compal__retval=

##  refcnt for alias expansion; expand aliases iff `_refcnt == 0`;
__compal__refcnt=0

##  an associative array of vanilla completions, keyed by command names;
##
##  when we say this array stores "parsed" cspecs, we actually mean the cspecs
##  have been parsed and indexed by command names in this array; cspec strings
##  themselves have no difference between this array and `_raw_vanilla_cspecs`;
##
##  example:
##
##      _vanilla_cspecs["tee"]="complete -F _longopt tee"
##      _vanilla_cspecs["type"]="complete -c type"
##      _vanilla_cspecs["unalias"]="complete -a unalias"
##      ...
##
declare -A __compal__vanilla_cspecs

##  a set of raw vanilla completions, keyed by cspec; these raw cspecs will be
##  parsed and loaded into `_vanilla_cspecs` on use; we need this lazy loading
##  because parsing all cspecs on sourcing incurs a large performance overhead;
##
##  vanilla completions are alias-free and fetched before `_complete_alias` is
##  set as the completion function for alias commands; the way we enforce this
##  partial order is to init this array on source; the sourcing happens before
##  `complete -F _complete_alias ...` for obvious reasons;
##
##  this is made a set, not an array, to avoid duplication when this script is
##  sourced repeatedly; each sourcing overwrites previous ones on duplication;
##
##  example:
##
##      _raw_vanilla_cspecs["complete -F _longopt tee"]=""
##      _raw_vanilla_cspecs["complete -c type"]=""
##      _raw_vanilla_cspecs["complete -a unalias"]=""
##      ...
##
declare -A __compal__raw_vanilla_cspecs

##  ============================================================================
##  # functions
##  ============================================================================

##  debug bash programmable completion variables;
__compal__debug() {
    echo
    echo "#COMP_WORDS=${#COMP_WORDS[@]}"
    echo "COMP_WORDS=("
    for x in "${COMP_WORDS[@]}"; do
        echo "'$x'"
    done
    echo ")"
    echo "COMP_CWORD=${COMP_CWORD}"
    echo "COMP_LINE='${COMP_LINE}'"
    echo "COMP_POINT=${COMP_POINT}"
    echo
}

##  debug vanilla cspecs;
##
##  $1
##  :   if "key" dump keys, else dump values;
__compal__debug_vanilla_cspecs() {
    if [[ "$1" == "key" ]]; then
        for x in "${!__compal__vanilla_cspecs[@]}"; do
            echo "$x"
        done
    else
        for x in "${__compal__vanilla_cspecs[@]}"; do
            echo "$x"
        done
    fi
}

##  debug raw vanilla cspecs;
__compal__debug_raw_vanilla_cspecs() {
    for x in "${!__compal__raw_vanilla_cspecs[@]}"; do
        echo "$x"
    done
}

##  debug `_split_cmd_line`;
##
##  this function is very easy to use; just call it with a string argument in an
##  interactive shell and look at the result; some interesting string arguments:
##
##  -   (fail) `&> /dev/null ping`
##  -   (fail) `2> /dev/null ping`
##  -   (fail) `2>&1 > /dev/null ping`
##  -   (fail) `> /dev/null ping`
##  -   (work) `&>/dev/null ping`
##  -   (work) `2>&1 >/dev/null ping`
##  -   (work) `2>&1 ping`
##  -   (work) `2>/dev/null ping`
##  -   (work) `>/dev/null ping`
##  -   (work) `FOO=foo true && BAR=bar ping`
##  -   (work) `echo & echo & ping`
##  -   (work) `echo ; echo ; ping`
##  -   (work) `echo | echo | ping`
##  -   (work) `ping &> /dev/null`
##  -   (work) `ping &>/dev/null`
##  -   (work) `ping 2> /dev/null`
##  -   (work) `ping 2>&1 > /dev/null`
##  -   (work) `ping 2>&1 >/dev/null`
##  -   (work) `ping 2>&1`
##  -   (work) `ping 2>/dev/null`
##  -   (work) `ping > /dev/null`
##  -   (work) `ping >/dev/null`
##
##  these failed examples are not an emergency because you can easily find their
##  equivalents in those working ones; and we will check for emergency on failed
##  examples added in the future;
##
##  $1
##  :   command line string;
__compal__debug_split_cmd_line() {
    ##  command line string;
    local str="$1"

    __compal__split_cmd_line "$str"

    for x in "${__compal__retval[@]}"; do
        echo "'$x'"
    done
}

##  print an error message;
##
##  $1
##  :   error message;
__compal__error() {
    printf "error: %s\n" "$1" >&2
}

##  test whether an element is in array;
##
##  $@
##  :   ( elem arr[0] arr[1] ... )
__compal__inarr() {
    for e in "${@:2}"; do
        [[ "$e" == "$1" ]] && return 0
    done
    return 1
}

##  get alias body from alias name;
##
##  this is made a separate function so that users can override this function to
##  provide alternate alias body for specific aliases; such aliases would run as
##  one thing but complete as another; this could be weird and confusing so this
##  is not formally documented;
##
##  $1
##  :   alias name;
##  $?
##  :   alias body;
__compal__get_alias_body() {
    local cmd; cmd="$1"

    local body; body="$(alias "$cmd")"
    echo "${body#*=}" | command xargs
}

##  split command line into words;
##
##  the `bash` reference implementation shows how bash splits command line into
##  word list `COMP_WORDS`:
##
##  -   git repo <https://git.savannah.gnu.org/cgit/bash.git>;
##  -   commit `ce23728687ce9e584333367075c9deef413553fa`;
##  -   function `bashline.c:attempt_shell_completion`;
##  -   function `bashline.c:find_cmd_end`;
##  -   function `bashline.c:find_cmd_start`;
##  -   function `pcomplete.c:command_line_to_word_list`;
##  -   function `pcomplete.c:programmable_completions`;
##  -   function `subst.c:skip_to_delim`;
##  -   function `subst.c:split_at_delims`;
##
##  this function shall give similar result as `bash` reference implementation
##  for common use cases, but will not strive for full compatibility, which is
##  too complicated when written in bash; we will support additional use cases
##  as they show up and prove worthy;
##
##  another reason we not pursue full compatibility is, even bash itself fails
##  on some use cases, such as `ping 2>&1` and `ping &>/dev/null`; ironically,
##  if we define an alias and complete using `_complete_alias`, then it works:
##
##      $ alias ping='ping 2>&1'
##      $ complete -F _complete_alias ping
##      $ ping <tab>
##      {ip}
##      {ip}
##      {ip}
##
##  backslash: a non-quoted backslash (`\`) preserves the literal value of the
##  next character that follows with the exception of `<newline>`; a backslash
##  enclosed in single quotes loses such special meaning; a backslash enclosed
##  in double quotes retains such special meaning only when followed by one of
##  the following (5) characters:
##
##      $ ` " \ <newline>
##
##  we do not allow `<newline>` in alias body; this simplifies our argument: a
##  non-quoted backslash always preserves next character; a backslash enclosed
##  in double quotes only preserves the above 4 characters (minus `<newline>`);
##
##  when a command substitution is enclosed in double quotes, backslash within
##  the command substitution may retain such special meaning, despite whatever
##  bash manual says; compare:
##
##      "`\"`"
##      "$(\")"
##
##  in the first form the backslash is not literal even though not followed by
##  characters mentioned in section command substitution, bash manual; we will
##  not handle backquote correctly in this case; as an advice, avoid backquote;
##
##  warn: the output of this function is *not* a faithful split of the input;
##  this function drops redirections and assignments, and only keeps the last
##  command in the last pipeline;
##
##  warn: this function is made for alias body expansion; as such it does not
##  support commmand substitutions, etc.; if you run its output as argv, then
##  you run at your own risk; quotes and escapes may also disturb the result;
##
##  $1
##  :   command line string;
__compal__split_cmd_line() {
    ##  command line string;
    local str="$1"

    ##  an array that will contain words after split;
    local words=()

    ##  alloc a temp stack to track open and close chars when splitting;
    local sta=()

    ##  we adopt some bool flags to handle redirections and assignments at the
    ##  beginning of the command line, if any; we can simply drop redirections
    ##  and assignments for sake of alias completion; for detail, read `SIMPLE
    ##  COMMAND EXPANSION` in `man bash`;

    ##  bool: check (outmost) redirection or assignment;
    local check_redass=1

    ##  bool: found (outmost) redirection or assignment in current word;
    local found_redass=0

    ##  examine each char of `str`; test branches are ordered; this order has
    ##  two importances: first is to respect substring relationship (eg: `&&`
    ##  must be tested before `&`); second is to test in optimistic order for
    ##  speeding up the testing; the first importance is compulsory and takes
    ##  precedence;
    local i=0 j=0
    for (( ; j < ${#str}; j++ )); do
        if (( ${#sta[@]} == 0 )); then
            if [[ "${str:j:1}" =~ [_a-zA-Z0-9] ]]; then
                :
            elif [[ $' \t\n' == *"${str:j:1}"* ]]; then
                if (( i < j )); then
                    if (( $found_redass == 1 )); then
                        if (( $check_redass == 0 )); then
                            words+=( "${str:i:j-i}" )
                        fi
                        found_redass=0
                    else
                        ##  no redass in current word; stop checking;
                        check_redass=0
                        words+=( "${str:i:j-i}" )
                    fi
                fi
                (( i = j + 1 ))
            elif [[ ":" == *"${str:j:1}"* ]]; then
                if (( i < j )); then
                    if (( $found_redass == 1 )); then
                        if (( $check_redass == 0 )); then
                            words+=( "${str:i:j-i}" )
                        fi
                        found_redass=0
                    else
                        ##  no redass in current word; stop checking;
                        check_redass=0
                        words+=( "${str:i:j-i}" )
                    fi
                fi
                words+=( "${str:j:1}" )
                (( i = j + 1 ))
            elif [[ '$(' == "${str:j:2}" ]]; then
                sta+=( ')' )
                (( j++ ))
            elif [[ '`' == "${str:j:1}" ]]; then
                sta+=( '`' )
            elif [[ '(' == "${str:j:1}" ]]; then
                sta+=( ')' )
            elif [[ '{' == "${str:j:1}" ]]; then
                sta+=( '}' )
            elif [[ '"' == "${str:j:1}" ]]; then
                sta+=( '"' )
            elif [[ "'" == "${str:j:1}" ]]; then
                sta+=( "'" )
            elif [[ '\' == "${str:j:1}" ]]; then
                (( j++ ))
            elif [[ '&>' == "${str:j:2}" ]]; then
                found_redass=1
                (( j++ ))
            elif [[ '>&' == "${str:j:2}" ]]; then
                found_redass=1
                (( j++ ))
            elif [[ "><=" == *"${str:j:1}"* ]]; then
                found_redass=1
            elif [[ '&&' == "${str:j:2}" ]]; then
                words=()
                check_redass=1
                (( i = j + 2 ))
            elif [[ '||' == "${str:j:2}" ]]; then
                words=()
                check_redass=1
                (( i = j + 2 ))
            elif [[ '&' == "${str:j:1}" ]]; then
                words=()
                check_redass=1
                (( i = j + 1 ))
            elif [[ '|' == "${str:j:1}" ]]; then
                words=()
                check_redass=1
                (( i = j + 1 ))
            elif [[ ';' == "${str:j:1}" ]]; then
                words=()
                check_redass=1
                (( i = j + 1 ))
            fi
        elif [[ "${sta[-1]}" == ')' ]]; then
            if [[ ')' == "${str:j:1}" ]]; then
                unset sta[-1]
            elif [[ '$(' == "${str:j:2}" ]]; then
                sta+=( ')' )
                (( j++ ))
            elif [[ '`' == "${str:j:1}" ]]; then
                sta+=( '`' )
            elif [[ '(' == "${str:j:1}" ]]; then
                sta+=( ')' )
            elif [[ '{' == "${str:j:1}" ]]; then
                sta+=( '}' )
            elif [[ '"' == "${str:j:1}" ]]; then
                sta+=( '"' )
            elif [[ "'" == "${str:j:1}" ]]; then
                sta+=( "'" )
            elif [[ '\' == "${str:j:1}" ]]; then
                (( j++ ))
            fi
        elif [[ "${sta[-1]}" == '}' ]]; then
            if [[ '}' == "${str:j:1}" ]]; then
                unset sta[-1]
            elif [[ '$(' == "${str:j:2}" ]]; then
                sta+=( ')' )
                (( j++ ))
            elif [[ '`' == "${str:j:1}" ]]; then
                sta+=( '`' )
            elif [[ '(' == "${str:j:1}" ]]; then
                sta+=( ')' )
            elif [[ '{' == "${str:j:1}" ]]; then
                sta+=( '}' )
            elif [[ '"' == "${str:j:1}" ]]; then
                sta+=( '"' )
            elif [[ "'" == "${str:j:1}" ]]; then
                sta+=( "'" )
            elif [[ '\' == "${str:j:1}" ]]; then
                (( j++ ))
            fi
        elif [[ "${sta[-1]}" == '`' ]]; then
            if [[ '`' == "${str:j:1}" ]]; then
                unset sta[-1]
            elif [[ '$(' == "${str:j:2}" ]]; then
                sta+=( ')' )
                (( j++ ))
            elif [[ '(' == "${str:j:1}" ]]; then
                sta+=( ')' )
            elif [[ '{' == "${str:j:1}" ]]; then
                sta+=( '}' )
            elif [[ '"' == "${str:j:1}" ]]; then
                sta+=( '"' )
            elif [[ "'" == "${str:j:1}" ]]; then
                sta+=( "'" )
            elif [[ '\' == "${str:j:1}" ]]; then
                (( j++ ))
            fi
        elif [[ "${sta[-1]}" == "'" ]]; then
            if [[ "'" == "${str:j:1}" ]]; then
                unset sta[-1]
            fi
        elif [[ "${sta[-1]}" == '"' ]]; then
            if [[ '"' == "${str:j:1}" ]]; then
                unset sta[-1]
            elif [[ '$(' == "${str:j:2}" ]]; then
                sta+=( ')' )
                (( j++ ))
            elif [[ '`' == "${str:j:1}" ]]; then
                sta+=( '`' )
            elif [[ '\$' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\`' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\"' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\\' == "${str:j:2}" ]]; then
                (( j++ ))
            fi
        fi
    done

    ##  append the last word;
    if (( i < j )); then
        if (( $found_redass == 1 )); then
            if (( $check_redass == 0 )); then
                words+=( "${str:i:j-i}" )
            fi
            found_redass=0
        else
            ##  no redass in current word; stop checking;
            check_redass=0
            words+=( "${str:i:j-i}" )
        fi
    fi

    ##  unset the temp stack;
    unset sta

    ##  return value;
    __compal__retval=( "${words[@]}" )
}

##  expand aliases in command line;
##
##  $1
##  :   beg word index;
##  $2
##  :   end word index;
##  $3
##  :   ignored word index (can be null);
##  $4
##  :   number of used aliases;
##  ${@:4}
##  :   used aliases;
##  $?
##  :   difference of `${#COMP_WORDS}` before and after expansion;
__compal__expand_alias() {
    local beg="$1" end="$2" ignore="$3" n_used="$4"; shift 4
    local used=( "${@:1:$n_used}" ); shift "$n_used"

    if (( $beg == $end )) ; then
        ##  case 1: range is empty;
        __compal__retval=0
    elif [[ -n "$ignore" ]] && (( $beg == $ignore )); then
        ##  case 2: beg index is ignored; pass it;
        __compal__expand_alias \
            "$(( $beg + 1 ))" \
            "$end" \
            "$ignore" \
            "${#used[@]}" \
            "${used[@]}"
    elif ! alias "${COMP_WORDS[$beg]}" &>/dev/null; then
        ##  case 3: command is not an alias;
        __compal__retval=0
    elif ( __compal__inarr "${COMP_WORDS[$beg]}" "${used[@]}" ); then
        ##  case 4: command is an used alias;
        __compal__retval=0
    else
        ##  case 5: command is an unused alias;

        ##  get alias name;
        local cmd="${COMP_WORDS[$beg]}"

        ##  get alias body;
        local str0; str0="$(__compal__get_alias_body "$cmd")"

        ##  split alias body into words;
        __compal__split_cmd_line "$str0"
        local words0=( "${__compal__retval[@]}" )

        ##  rebuild alias body; we need this because function `_split_cmd_line`
        ##  drops redirections and assignments, and only keeps the last command
        ##  in the last pipeline, in `words0`; therefore `str0` is not a simple
        ##  concat of `words0`; we rebuild this simple concat as `nstr0`; maybe
        ##  it is easier to view `str0` as raw and `nstr0` as genuine;
        local nstr0="${words0[*]}"

        ##  find index range of word `$COMP_WORDS[$beg]` in string `$COMP_LINE`;
        local i=0 j=0
        for (( i = 0; i <= $beg; i++ )); do
            for (( ; j <= ${#COMP_LINE}; j++ )); do
                [[ "${COMP_LINE:j}" == "${COMP_WORDS[i]}"* ]] && break
            done
            (( i == $beg )) && break
            (( j += ${#COMP_WORDS[i]} ))
        done

        ##  now `j` is at the beginning of word `$COMP_WORDS[$beg]`; and we know
        ##  the index range is `[j, j+${#cmd})`;

        ##  update `$COMP_LINE` and `$COMP_POINT`;
        COMP_LINE="${COMP_LINE:0:j}${nstr0}${COMP_LINE:j+${#cmd}}"
        if (( $COMP_POINT < j )); then
            :
        elif (( $COMP_POINT < j + ${#cmd} )); then
            ##  set current cursor position to the end of replacement string;
            (( COMP_POINT = j + ${#nstr0} ))
        else
            (( COMP_POINT += ${#nstr0} - ${#cmd} ))
        fi

        ##  update `$COMP_WORDS` and `$COMP_CWORD`;
        COMP_WORDS=(
            "${COMP_WORDS[@]:0:beg}"
            "${words0[@]}"
            "${COMP_WORDS[@]:beg+1}"
        )
        if (( $COMP_CWORD < $beg )); then
            :
        elif (( $COMP_CWORD < $beg + 1 )); then
            ##  set current word index to the last of replacement words;
            (( COMP_CWORD = $beg + ${#words0[@]} - 1 ))
        else
            (( COMP_CWORD += ${#words0[@]} - 1 ))
        fi

        ##  update `$ignore` if it is not empty; if so, we know `$ignore` is not
        ##  equal to `$beg` because we checked that in case 2; we need to update
        ##  `$ignore` only when `$ignore > $beg`; save this condition in a local
        ##  var `$ignore_gt_beg` because we need it later;
        if [[ -n "$ignore" ]]; then
            local ignore_gt_beg=0
            if (( $ignore > $beg )); then
                ignore_gt_beg=1
                (( ignore += ${#words0[@]} - 1 ))
            fi
        fi

        ##  recursively expand part 0;
        local used0=( "${used[@]}" "$cmd" )
        __compal__expand_alias \
            "$beg" \
            "$(( $beg + ${#words0[@]} ))" \
            "$ignore" \
            "${#used0[@]}" \
            "${used0[@]}"
        local diff0="$__compal__retval"

        ##  update `$ignore` if it is not empty and `$ignore_gt_beg` is true;
        if [[ -n "$ignore" ]] && (( $ignore_gt_beg == 1 )); then
            (( ignore += $diff0 ))
        fi

        ##  recursively expand part 1; must check `str0` not `nstr0`;
        if [[ -n "$str0" ]] && [[ "${str0: -1}" == ' ' ]]; then
            local used1=( "${used[@]}" )
            __compal__expand_alias \
                "$(( $beg + ${#words0[@]} + $diff0 ))" \
                "$(( $end + ${#words0[@]} - 1 + $diff0 ))" \
                "$ignore" \
                "${#used1[@]}" \
                "${used1[@]}"
            local diff1="$__compal__retval"
        else
            local diff1=0
        fi

        ##  return value;
        __compal__retval=$(( ${#words0[@]} - 1 + diff0 + diff1 ))
    fi
}

##  run a cspec using its args in argv fashion;
##
##  despite as described in `man bash`, `complete -p` does not always print an
##  existing completion in a way that can be reused as input; what complicates
##  the matter here are quotes and escapes;
##
##  as an example, when `complete -p` prints:
##
##      $ complete -p
##      complete -F _known_hosts "/tmp/aaa   bbb"
##
##  copy-paste running the above output gives wrong result:
##
##      $ complete -F _known_hosts "/tmp/aaa   bbb"
##      $ complete -p
##      complete -F _known_hosts /tmp/aaa   bbb
##
##  the correct command to give the same `complete -p` result is:
##
##      $ complete -F _known_hosts '"/tmp/aaa   bbb"'
##      $ complete -p
##      complete -F _known_hosts "/tmp/aaa   bbb"
##
##  to see another issue, this command gives a different result:
##
##      $ complete -F _known_hosts '/tmp/aaa\ \ \ bbb'
##      $ complete -p
##      complete -F _known_hosts /tmp/aaa\ \ \ bbb
##
##  note that these two `complete -p` results are *not* the same:
##
##      complete -F _known_hosts "/tmp/aaa   bbb"
##      complete -F _known_hosts /tmp/aaa\ \ \ bbb
##
##  despite this is true:
##
##      [[ "/tmp/aaa   bbb" == /tmp/aaa\ \ \ bbb ]]
##
##  so we must parse the `complete -p` result and run parsed result;
##
##  using `_split_cmd_line` to parse a cspec should be ok, because a cspec has
##  only one command without redirections or assignments, also without command
##  substitutions, etc.; we can then rerun this cspec in an argv fashion using
##  this function;
##
##  $@
##  :   cspec args;
__compal__run_cspec_args() {
    local cspec_args=( "$@" )

    ##  ensure this is indeed a cspec;
    if [[ "${cspec_args[0]}" == "complete" ]]; then
        ##  run parsed completion command;
        "${cspec_args[@]}"
    else
        __compal__error "not a complete command: ${cspec_args[*]}"
    fi
}

##  the "auto" implementation of `_unmask_alias`;
##
##  this function is called only when using auto unmask;
##
##  $1
##  :   alias command;
__compal__unmask_alias_auto() {
    local cmd="$1"

    ##  load vanilla completion of this command;
    local cspec="${__compal__vanilla_cspecs[$cmd]}"

    if [[ -n "$cspec" ]]; then
        ##  a vanilla cspec for this command is found; due to some issues with
        ##  `complete -p` we cannot eval this cspec directly; instead, we need
        ##  to parse and run it in argv fashion; see `_run_cspec_args` comment;
        __compal__split_cmd_line "$cspec"
        local cspec_args=( "${__compal__retval[@]}" )
        __compal__run_cspec_args "${cspec_args[@]}"
    else
        ##  a (parsed) vanilla cspec for this command is not found; search raw
        ##  vanilla cspecs for this command; if a matched raw vanilla cspec is
        ##  found, then parse, save and run it; search is a loop because these
        ##  raw cspecs are not parsed yet;
        for _cspec in "${!__compal__raw_vanilla_cspecs[@]}"; do
            if [[ "$_cspec" == *" $cmd" ]]; then
                __compal__split_cmd_line "$_cspec"
                local _cspec_args=( "${__compal__retval[@]}" )

                ##  ensure this cspec has the correct command;
                local _cspec_cmd="${_cspec_args[-1]}"
                if [[ "$_cspec_cmd" == "$cmd" ]]; then
                    __compal__vanilla_cspecs["$_cspec_cmd"]="$_cspec"
                    unset __compal__raw_vanilla_cspecs["$_cspec"]
                    __compal__run_cspec_args "${_cspec_args[@]}"
                    return
                fi
            fi
        done

        ##  no vanilla cspec for this command is found; we remove the current
        ##  cspec for this command (which should be `_complete_alias`), which
        ##  effectively uses the default cspec (ie: `complete -D`) to process
        ##  this command; we do not fallback to `_completion_loader`, because
        ##  the default cspec could be something else, and here we want to be
        ##  consistent;
        complete -r "$cmd"
    fi
}

##  the "manual" implementation of `_unmask_alias`;
##
##  this function is called only when using manual unmask;
##
##  users may edit this function to customize vanilla command completions;
##
##  $1
##  :   alias command;
__compal__unmask_alias_manual() {
    local cmd="$1"

    case "$cmd" in
        bind)
            complete -A binding "$cmd"
            ;;
        help)
            complete -A helptopic "$cmd"
            ;;
        set)
            complete -A setopt "$cmd"
            ;;
        shopt)
            complete -A shopt "$cmd"
            ;;
        bg)
            complete -A stopped -P '"%' -S '"' "$cmd"
            ;;
        service)
            complete -F _service "$cmd"
            ;;
        unalias)
            complete -a "$cmd"
            ;;
        builtin)
            complete -b "$cmd"
            ;;
        command|type|which)
            complete -c "$cmd"
            ;;
        fg|jobs|disown)
            complete -j -P '"%' -S '"' "$cmd"
            ;;
        groups|slay|w|sux)
            complete -u "$cmd"
            ;;
        readonly|unset)
            complete -v "$cmd"
            ;;
        traceroute|traceroute6|tracepath|tracepath6|fping|fping6|telnet|rsh|\
            rlogin|ftp|dig|mtr|ssh-installkeys|showmount)
            complete -F _known_hosts "$cmd"
            ;;
        aoss|command|do|else|eval|exec|ltrace|nice|nohup|padsp|then|time|\
            tsocks|vsound|xargs)
            complete -F _command "$cmd"
            ;;
        fakeroot|gksu|gksudo|kdesudo|really)
            complete -F _root_command "$cmd"
            ;;
        a2ps|awk|base64|bash|bc|bison|cat|chroot|colordiff|cp|csplit|cut|date|\
            df|diff|dir|du|enscript|env|expand|fmt|fold|gperf|grep|grub|head|\
            irb|ld|ldd|less|ln|ls|m4|md5sum|mkdir|mkfifo|mknod|mv|netstat|nl|\
            nm|objcopy|objdump|od|paste|pr|ptx|readelf|rm|rmdir|sed|seq|\
            sha{,1,224,256,384,512}sum|shar|sort|split|strip|sum|tac|tail|tee|\
            texindex|touch|tr|uname|unexpand|uniq|units|vdir|wc|who)
            complete -F _longopt "$cmd"
            ;;
        *)
            _completion_loader "$cmd"
            ;;
    esac
}

##  set completion function of an alias command to the vanilla one;
##
##  $1
##  :   alias command;
__compal__unmask_alias() {
    local cmd="$1"

    ##  ensure current completion function of this command is `_complete_alias`;
    if [[ "$(complete -p "$cmd")" != *"-F _complete_alias"* ]]; then
        __compal__error "cannot unmask alias command: $cmd"
        return
    fi

    ##  decide which unmask function to call;
    if (( "$COMPAL_AUTO_UNMASK" == 1 )); then
        __compal__unmask_alias_auto "$@"
    else
        __compal__unmask_alias_manual "$@"
    fi
}

##  set completion function of an alias command to `_complete_alias`; doing so
##  overwrites the original completion function for this command, if any; this
##  makes `_complete_alias` look like a "mask" on the alias command; then, why
##  is this function called a "remask"? because this function is always called
##  in pair with (and after) a corresponding "unmask" function; the 1st "mask"
##  happens when user directly runs `complete -F _complete_alias ...`;
##
##  $1
##  :   alias command;
__compal__remask_alias() {
    local cmd="$1"

    complete -F _complete_alias "$cmd"
}

##  delegate completion to `bash-completion`;
__compal__delegate() {
    ##  `_command_offset` is a meta-command completion function provided by
    ##  `bash-completion`; the documentation does not say it will work with
    ##  argument `0`, but looking at its code (version 2.11) it should;
    _command_offset 0
}

##  delegate completion to `bash-completion`, within a transient context in
##  which the input alias command is unmasked;
##
##  this function expects current completion function of this command to be
##  `_complete_alias`;
##
##  $1
##  :   alias command to be unmasked;
__compal__delegate_in_context() {
    local cmd="$1"

    ##  unmask alias:
    __compal__unmask_alias "$cmd"

    ##  do actual completion;
    __compal__delegate

    ##  remask alias:
    __compal__remask_alias "$cmd"
}

##  save vanilla completions; run this function when this script is sourced;
##  this ensures vanilla completions of alias commands are fetched and saved
##  before they are overwritten by `complete -F _complete_alias`;
##
##  this function saves raw cspecs and does not parse them; for other useful
##  comments about parsing and running cspecs see function `_run_cspec_args`;
##
##  running this function on source is mandatory only when using auto unmask;
##  when using manual unmask, it is safe to skip this function on source;
__compal__save_vanilla_cspecs() {
    ##  get default cspec;
    local def_cspec; def_cspec="$(complete -p -D 2>/dev/null)"

    ##  `complete -p` prints cspec for one command per line; so we can loop;
    while IFS= read -r cspec; do

        ##  skip default cspec;
        [[ "$cspec" != "$def_cspec" ]] || continue

        ##  skip `-F _complete_alias` cspecs;
        [[ "$cspec" != *"-F _complete_alias"* ]] || continue

        ##  now we have a vanilla cspec; save it in `_raw_vanilla_cspecs`;
        __compal__raw_vanilla_cspecs["$cspec"]=""

    done < <(complete -p 2>/dev/null)
}

##  completion function for non-alias commands; normally, the mere invocation of
##  this function indicates an error of command completion configuration because
##  we are invoking `_complete_alias` on a non-alias command; but there can be a
##  special case: `_command_offset` will try with command basename when there is
##  no completion for the command itself; an example is `sudo /bin/ls` when both
##  `sudo` and `ls` are aliases; this function takes care of this special case;
##
##  $1
##  :   the name of the command whose arguments are being completed;
##  $2
##  :   the word being completed;
##  $3
##  :   the word preceding the word being completed on the current command line;
__compal__complete_non_alias() {
    ##  get command name; must be non-alias;
    local cmd="${COMP_WORDS[0]}"

    ##  get command basename;
    local compcmd="${cmd##*/}"

    if alias "$compcmd" &>/dev/null; then
        ##  if command basename is an alias, delegate completion;
        __compal__delegate_in_context "$compcmd"
    else
        ##  else, this indicates an error;
        __compal__error "command is not an alias: $cmd"
    fi
}

##  completion function for alias commands;
##
##  $1
##  :   the name of the command whose arguments are being completed;
##  $2
##  :   the word being completed;
##  $3
##  :   the word preceding the word being completed on the current command line;
__compal__complete_alias() {
    ##  get command name; must be alias;
    local cmd="${COMP_WORDS[0]}"

    ##  we expand aliases only for the original command line (ie: the command
    ##  line on which user pressed `<tab>`); unfortunately, we may not have a
    ##  chance to see the original command line, and we have no way to ensure
    ##  that; we take an approximation: we expand aliases only in the outmost
    ##  call of this function, which implies only on the first occasion of an
    ##  alias command; we can ensure this condition using a refcnt and expand
    ##  aliases iff the refcnt is equal to 0; this approximation always works
    ##  correctly when the 1st word on the original command line is an alias;
    ##
    ##  this approximation may fail when the 1st word on the original command
    ##  line is not an alias; an example that expects files but gets ip addrs:
    ##
    ##      $ unalias sudo
    ##      $ complete -r sudo
    ##      $ alias ls='ping'
    ##      $ complete -F _complete_alias ls
    ##      $ sudo ls <tab>
    ##      {ip}
    ##      {ip}
    ##      {ip}
    ##      ...
    ##
    if (( __compal__refcnt == 0 )); then

        ##  find index range of word `$COMP_WORDS[$COMP_CWORD]` in string
        ##  `$COMP_LINE`; dont expand this word if `$COMP_POINT` (cursor
        ##  position) lies in this range because the word may be incomplete;
        local i=0 j=0
        for (( ; i <= $COMP_CWORD; i++ )); do
            for (( ; j <= ${#COMP_LINE}; j++ )); do
                [[ "${COMP_LINE:j}" == "${COMP_WORDS[i]}"* ]] && break
            done
            (( i == $COMP_CWORD )) && break
            (( j += ${#COMP_WORDS[i]} ))
        done

        ##  now `j` is at the beginning of word `$COMP_WORDS[$COMP_CWORD]`; and
        ##  we know the index range is `[j, j+${#COMP_WORDS[$COMP_CWORD]}]`; we
        ##  include the right endpoint to cover the case where cursor is at the
        ##  exact end of the word; compare the index range with `$COMP_POINT`;
        if (( j <= $COMP_POINT )) && \
            (( $COMP_POINT <= j + ${#COMP_WORDS[$COMP_CWORD]} )); then
            local ignore="$COMP_CWORD"
        else
            local ignore=""
        fi

        ##  expand aliases;
        __compal__expand_alias 0 "${#COMP_WORDS[@]}" "$ignore" 0
    fi

    ##  increase refcnt;
    (( __compal__refcnt++ ))

    ##  delegate completion in context; this actually contains several steps:
    ##
    ##  -   unmask alias:
    ##
    ##      since aliases have been fully expanded, no need to consider aliases
    ##      in the resulting command line; therefore, we now set the completion
    ##      function for this alias to the vanilla, alias-free one; this avoids
    ##      infinite recursion when using self-aliases (eg: `alias ls='ls -a'`);
    ##
    ##  -   do actual completion:
    ##
    ##      `_command_offset` is a meta-command completion function provided by
    ##      `bash-completion`; the documentation does not say it will work with
    ##      argument `0`, but looking at its code (version 2.11) it should;
    ##
    ##  -   remask alias:
    ##
    ##      reset this command completion function to `_complete_alias`;
    ##
    ##  these steps are put into one function `_delegate_in_context`;
    __compal__delegate_in_context "$cmd"

    ##  decrease refcnt;
    (( __compal__refcnt-- ))
}

##  this is the function to be set with `complete -F`; this function expects
##  alias commands, but can also handle non-alias commands in rare occasions;
##
##  as a standard completion function, this function can take 3 arguments as
##  described in `man bash`; they are currently not being used, though;
##
##  $1
##  :   the name of the command whose arguments are being completed;
##  $2
##  :   the word being completed;
##  $3
##  :   the word preceding the word being completed on the current command line;
_complete_alias() {
    ##  get command;
    local cmd="${COMP_WORDS[0]}"

    ##  complete command;
    if ! alias "$cmd" &>/dev/null; then
        __compal__complete_non_alias "$@"
    else
        __compal__complete_alias "$@"
    fi
}

##  main function;
__compal__main() {
    if (( "$COMPAL_AUTO_UNMASK" == 1 )); then
        ##  save vanilla completions;
        __compal__save_vanilla_cspecs
    fi
}

##  ============================================================================
##  # script
##  ============================================================================

##  run main function;
__compal__main

##  ============================================================================
##  # complete user-defined aliases
##  ============================================================================

##  to complete specific aliases, uncomment and edit these lines;
#complete -F _complete_alias myalias1
#complete -F _complete_alias myalias2
#complete -F _complete_alias myalias3

##  to complete all aliases, run this line after all aliases have been defined;
#complete -F _complete_alias "${!BASH_ALIASES[@]}"

