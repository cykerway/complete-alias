#!/bin/bash

##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##  automagical shell alias completion;
##  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

##  ============================================================================
##  Copyright (C) 2016-2018 Cyker Way
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
##  variable;
##  ============================================================================

##  register for keeping function return value;
_retval=

##  refcnt for alias expansion; expand aliases iff `_refcnt == 0`;
_refcnt=0

##  ============================================================================
##  function;
##  ============================================================================

##  debug;
_debug() {
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

##  test whether element is in array;
##
##  $@
##  :   ( elem arr[0] arr[1] ... )
_inarr() {
    for e in "${@:2}"; do
        [[ "$e" == "$1" ]] && return 0
    done
    return 1
}

##  split command line into words;
##
##  $1
##  :   command line string;
_split_cmd_line() {
    ##  command line string;
    local str="$1"

    ##  an array that will contain words after split;
    local words=()

    ##  alloc a temp stack to track open and close chars when splitting;
    local sta=()

    ##  examine each char of `str`;
    local i=0 j=0
    for (( ; j < ${#str}; j++ )); do
        if (( ${#sta[@]} == 0 )); then
            if [[ '$(' == "${str:j:2}" ]]; then
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
            elif [[ '\$' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\`' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\"' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\\' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ "\'" == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ $' \t\n' == *"${str:j:1}"* ]]; then
                (( i < j )) && words+=( "${str:i:j-i}" )
                (( i = j + 1 ))
            elif [[ "><=;|&:" == *"${str:j:1}"* ]]; then
                (( i < j )) && words+=( "${str:i:j-i}" )
                words+=( "${str:j:1}" )
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
            elif [[ '\$' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\`' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\"' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\\' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ "\'" == "${str:j:2}" ]]; then
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
            elif [[ '\$' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\`' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\"' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\\' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ "\'" == "${str:j:2}" ]]; then
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
            elif [[ '\$' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\`' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\"' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ '\\' == "${str:j:2}" ]]; then
                (( j++ ))
            elif [[ "\'" == "${str:j:2}" ]]; then
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
    (( i < j )) && words+=( "${str:i:j-i}" )

    ##  unset the temp stack;
    unset sta

    ##  return value;
    _retval=( "${words[@]}" )
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
_expand_alias() {
    local beg="$1" end="$2" ignore="$3" n_used="$4"; shift 4
    local used=( "${@:1:$n_used}" ); shift "$n_used"

    if (( $beg == $end )) ; then
        ##  case 1: range is empty;
        _retval=0
    elif [[ -n "$ignore" ]] && (( $beg == $ignore )); then
        ##  case 2: beg index is ignored; pass it;
        _expand_alias \
            "$(( $beg + 1 ))" \
            "$end" \
            "$ignore" \
            "${#used[@]}" \
            "${used[@]}"
    elif ! alias "${COMP_WORDS[$beg]}" &>/dev/null; then
        ##  case 3: command is not an alias;
        _retval=0
    elif ( _inarr "${COMP_WORDS[$beg]}" "${used[@]}" ); then
        ##  case 4: command is an used alias;
        _retval=0
    else
        ##  case 5: command is an unused alias;

        ##  get alias name;
        local cmd="${COMP_WORDS[$beg]}"

        ##  get alias body;
        local str0="$( alias "$cmd" | sed -E 's/[^=]*=//' | xargs )"

        ##  split alias body into words;
        _split_cmd_line "$str0"
        local words0=( "${_retval[@]}" )

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
        ##  the index range is `[j, j+${#cmd})`; update `$COMP_LINE` and
        ##  `$COMP_POINT`;
        COMP_LINE="${COMP_LINE:0:j}${str0}${COMP_LINE:j+${#cmd}}"
        if (( $COMP_POINT < j )); then
            :
        elif (( $COMP_POINT < j + ${#cmd} )); then
            ##  set current cursor position to the end of replacement string;
            (( COMP_POINT = j + ${#str0} ))
        else
            (( COMP_POINT += ${#str0} - ${#cmd} ))
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

        ##  update `$ignore` if it is not empty; if `$ignore` is not empty, then
        ##  we know it is not equal to `$beg` because we checked that in case 2;
        if [[ -n "$ignore" ]] && (( $ignore > $beg )); then
            (( ignore += ${#words0[@]} - 1 ))
        fi

        ##  recursively expand part 0;
        local used0=( "${used[@]}" "$cmd" )
        _expand_alias \
            "$beg" \
            "$(( $beg + ${#words0[@]} ))" \
            "$ignore" \
            "${#used0[@]}" \
            "${used0[@]}"
        local diff0="$_retval"

        ##  recursively expand part 1;
        if [[ -n "$str0" ]] && [[ "${str0: -1}" == ' ' ]]; then
            local used1=( "${used[@]}" )
            _expand_alias \
                "$(( $beg + ${#words0[@]} + $diff0 ))" \
                "$(( $end + ${#words0[@]} - 1 + $diff0 ))" \
                "$ignore" \
                "${#used1[@]}" \
                "${used1[@]}"
            local diff1="$_retval"
        else
            local diff1=0
        fi

        ##  return value;
        _retval=$(( ${#words0[@]} - 1 + diff0 + diff1 ))
    fi
}

##  set a command completion function to the default one; users may edit this
##  function to fit their own needs;
_set_default_completion() {
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

##  programmable completion function for aliases; this is the function to be set
##  with `complete -F`;
_complete_alias() {
    ##  get command;
    local cmd="${COMP_WORDS[0]}"

    ##  we expand aliases only for the original command line (ie: the command
    ##  line after which user pressed `<tab>`); this means we expand aliases
    ##  only in the outmost call of this function; we ensure this by using a
    ##  refcnt and expand aliases iff the refcnt is equal to 0;
    if (( _refcnt == 0 )); then

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
        _expand_alias 0 "${#COMP_WORDS[@]}" "$ignore" 0
    fi

    ##  increase refcnt;
    (( _refcnt++ ))

    ##  since aliases have been fully expanded, we no longer need to consider
    ##  aliases in the resulting command line; so we now set this command
    ##  completion function to the default one (which is alias-agnostic); this
    ##  avoids infinite recursion when a command is aliased to itself (ie:
    ##  `alias ls='ls -a'`);
    _set_default_completion "$cmd"

    ##  do actual completion;
    _command_offset 0

    ##  reset this command completion function to `_complete_alias`;
    complete -F _complete_alias "$cmd"

    ##  decrease refcnt;
    (( _refcnt-- ))
}

##  ============================================================================
##  complete user-defined aliases;
##
##  uncomment and edit these lines to complete your aliases;
##  ============================================================================

#complete -F _complete_alias myalias1
#complete -F _complete_alias myalias2
#complete -F _complete_alias myalias3

