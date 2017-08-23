# Copyright (C) 2016-2017 Cyker Way
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

# Function: Debug.
_debug() {
    echo
    echo "COMP_WORDS=("
    for x in "${COMP_WORDS[@]}"; do
        echo "'$x'"
    done
    echo ")"
    echo "#COMP_WORDS=${#COMP_WORDS[@]}"
    echo "COMP_CWORD=${COMP_CWORD}"
    echo "COMP_LINE='${COMP_LINE}'"
    echo "COMP_POINT=${COMP_POINT}"
    echo
}

# Register: Function return value.
_retval=0

# Refcnt: Use alias iff _use_alias == 0.
_use_alias=0

# Function: Test whether the given array contains the given element.
# Usage: _in <elem> <arr_elem_0> <arr_elem_1> ...
_in () {
    for e in "${@:2}"; do
        [[ "$e" == "$1" ]] && return 0
    done
    return 1
}

# Function: Expand aliases in a command line.
# Return: Difference of #COMP_WORDS (before/after expansion).
_expand_alias () {
    local beg="$1" end="$2" ignore="$3" n_used="$4"; shift 4
    local used=( "${@:1:$n_used}" ); shift $n_used

    if [[ "$beg" -eq "$end" ]]; then
        # Case 1: Range is empty.
        _retval=0
    elif [[ -n "$ignore" ]] && [[ "$beg" -eq "$ignore" ]]; then
        # Case 2: Beginning index is ignored. Pass it.
        _expand_alias "$(( $beg+1 ))" "$end" "$ignore" "${#used[@]}" "${used[@]}"
        _retval="$_retval"
    elif ! ( alias "${COMP_WORDS[$beg]}" &>/dev/null ) || ( _in "${COMP_WORDS[$beg]}" "${used[@]}" ); then
        # Case 3: Command is not an alias or is an used alias.
        _retval=0
    else
        # Case 4: Command is an unused alias.

        # Expand 1 level of command alias.
        local cmd="${COMP_WORDS[$beg]}"
        local str0="$( alias "$cmd" | sed -r 's/[^=]*=//' | xargs )"

        # The old way of word breaking (using xargs) is not accurate enough.
        #
        # For example:
        #
        # > alias foo='docker run -u $(id -u $USER):$(id -g $USER)'
        #
        # will be broken as:
        #
        # > docker
        # > run
        # > -u
        # > $(id
        # > -u
        # > $USER):$(id
        # > -g
        # > $USER)
        #
        # while the correct word breaking is:
        #
        # > docker
        # > run
        # > -u
        # > $(id -u $USER)
        # > :
        # > $(id -g $USER)
        #
        # Therefore we implement our own word breaking which gives the correct
        # behavior in this case. It takes the alias body ($str0) as input,
        # breaks it into words and stores them in an array ($words0).
        {
            # An array that will contain the broken words.
            words0=()

            # Create a temp stack which tracks quoting while breaking words.
            local sta=()

            # Examine each char of $str0.
            local i=0 j=0
            for (( j=0;j<${#str0};j++ )); do
                if [[ $' \t\n' == *"${str0:j:1}"* ]]; then
                    # Whitespace chars.
                    if [[ ${#sta[@]} -eq 0 ]]; then
                        if [[ $i -lt $j ]]; then
                            words0+=("${str0:i:j-i}")
                        fi
                        (( i=j+1 ))
                    fi
                elif [[ "><=;|&:" == *"${str0:j:1}"* ]]; then
                    # Break chars.
                    if [[ ${#sta[@]} -eq 0 ]]; then
                        if [[ $i -lt $j ]]; then
                            words0+=("${str0:i:j-i}")
                        fi
                        words0+=("${str0:j:1}")
                        (( i=j+1 ))
                    fi
                elif [[ "\"')}" == *"${str0:j:1}"* ]]; then
                    # Right quote chars.
                    if [[ ${#sta[@]} -ne 0 ]] && [[ "${str0:j:1}" == ${sta[-1]} ]]; then
                        unset sta[-1]
                    fi
                elif [[ "\"'({" == *"${str0:j:1}"* ]]; then
                    # Left quote chars.
                    if [[ "${str0:j:1}" == "\"" ]]; then
                        sta+=("\"")
                    elif [[ "${str0:j:1}" == "'" ]]; then
                        sta+=("'")
                    elif [[ "${str0:j:1}" == "(" ]]; then
                        sta+=(")")
                    elif [[ "${str0:j:1}" == "{" ]]; then
                        sta+=("}")
                    fi
                fi
            done
            # Append the last word.
            if [[ $i -lt $j ]]; then
                words0+=("${str0:i:j-i}")
            fi

            # Unset the temp stack.
            unset sta
        }

        # Rewrite COMP_LINE and COMP_POINT.
        local i j=0
        for (( i=0; i < $beg; i++ )); do
            for (( ; j <= ${#COMP_LINE}; j++ )); do
                [[ "${COMP_LINE:j}" == "${COMP_WORDS[i]}"* ]] && break
            done
            (( j+=${#COMP_WORDS[i]} ))
        done
        for (( ; j <= ${#COMP_LINE}; j++ )); do
            [[ "${COMP_LINE:j}" == "${COMP_WORDS[i]}"* ]] && break
        done

        COMP_LINE="${COMP_LINE[@]:0:j}""$str0""${COMP_LINE[@]:j+${#cmd}}"
        if [[ $COMP_POINT -lt $j ]]; then
            :
        elif [[ $COMP_POINT -lt $(( j+${#cmd} )) ]]; then
            (( COMP_POINT=j+${#str0} ))
        else
            (( COMP_POINT+=${#str0}-${#cmd} ))
        fi

        # Rewrite COMP_WORDS and COMP_CWORD.
        COMP_WORDS=( "${COMP_WORDS[@]:0:beg}" "${words0[@]}" "${COMP_WORDS[@]:beg+1}" )
        if [[ $COMP_CWORD -lt $beg ]]; then
            :
        elif [[ $COMP_CWORD -lt $(( $beg+1 )) ]]; then
            (( COMP_CWORD=beg+${#words0[@]} ))
        else
            (( COMP_CWORD+=${#words0[@]}-1 ))
        fi

        # Rewrite ignore if it's not empty.
        # If ignore is not empty, we already know it's not equal to beg because
        # we have checked it in Case 2.
        if [[ -n "$ignore" ]] && [[ $ignore -gt $beg ]]; then
            (( ignore+=${#words0[@]}-1 ))
        fi

        # Recursively expand Part 0.
        local used0=( "${used[@]}" "$cmd" )
        _expand_alias "$beg" "$(( $beg+${#words0[@]} ))" "$ignore" "${#used0[@]}" "${used0[@]}"
        local diff0="$_retval"

        # Recursively expand Part 1.
        if [[ -n "$str0" ]] && [[ "${str0: -1}" == ' ' ]]; then
            local used1=( "${used[@]}" )
            _expand_alias "$(( $beg+${#words0[@]}+$diff0 ))" "$(( $end+${#words0[@]}-1+$diff0 ))" "$ignore" "${#used1[@]}" "${used1[@]}"
            local diff1="$_retval"
        else
            local diff1=0
        fi

        # Return value.
        _retval=$(( ${#words0[@]}-1+diff0+diff1 ))
    fi
}

# Function: Set a command's completion function to the default one.
# Users may edit this function to fit their own needs.
_set_default_completion () {
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
        aoss|command|do|else|eval|exec|ltrace|nice|nohup|padsp|then|time|tsocks|vsound|xargs)
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

# Function: Programmable completion function for aliases.
_complete_alias () {
    # Get command.
    local cmd="${COMP_WORDS[0]}"

    # We expand aliases only for the original command line (i.e. the command
    # line as verbatim when user presses 'Tab'). That is to say, we expand
    # aliases only in the first call of this function. Therefore we check the
    # refcnt and expand aliases iff it's equal to 0.
    if [[ $_use_alias -eq 0 ]]; then

        # Find the range of indexes of COMP_WORDS[COMP_CWORD] in COMP_LINE. If
        # COMP_POINT lies in this range, don't expand this word because it may
        # be incomplete.
        local i j=0
        for (( i=0; i < $COMP_CWORD; i++ )); do
            for (( ; j <= ${#COMP_LINE}; j++ )); do
                [[ "${COMP_LINE:j}" == "${COMP_WORDS[i]}"* ]] && break
            done
            (( j+=${#COMP_WORDS[i]} ))
        done
        for (( ; j <= ${#COMP_LINE}; j++ )); do
            [[ "${COMP_LINE:j}" == "${COMP_WORDS[i]}"* ]] && break
        done

        # Now j is at the beginning of word COMP_WORDS[COMP_CWORD] and so the
        # range is [j, j+#COMP_WORDS[COMP_CWORD]]. Compare it with COMP_POINT.
        if [[ $j -le $COMP_POINT ]] && [[ $COMP_POINT -le $(( $j+${#COMP_WORDS[$COMP_CWORD]} )) ]]; then
            local ignore="$COMP_CWORD"
        else
            local ignore=""
        fi

        # Expand aliases.
        _expand_alias 0 "${#COMP_WORDS[@]}" "$ignore" 0
    fi

    # Increase _use_alias refcnt.
    (( _use_alias++ ))

    # Since aliases have been fully expanded, we no longer need to consider
    # aliases in the resulting command line. So we now set this command's
    # completion function to the default one (which is alias-agnostic). This
    # avoids infinite recursion when a command is aliased to itself (i.e. alias
    # ls='ls -a').
    _set_default_completion "$cmd"

    # Do actual completion.
    _command_offset 0

    # Decrease _use_alias refcnt.
    (( _use_alias-- ))

    # Reset this command's completion function to `_complete_alias`.
    complete -F _complete_alias "$cmd"
}

# Set alias completions.
#
# Uncomment and edit these lines to add your own alias completions.
#
#complete -F _complete_alias myalias1
#complete -F _complete_alias myalias2
#complete -F _complete_alias myalias3

