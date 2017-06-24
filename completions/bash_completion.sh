# Copyright (C) 2016 Cyker Way
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

# Flag: Use alias or not.
_use_alias=1

# Function: Test whether the given array contains the given element.
# Usage: _in <elem> <arr_elem_0> <arr_elem_1> ...
_in () {
    for e in "${@:2}"; do
        [[ "$e" == "$1" ]] && return 0
    done
    return 1
}

# Function: Core implementation of command line alias expansion.
# Usage: _expand_alias_core <#words> <words> <#ignore> <ignore>
# <words>   : Words in a command line.
# <ignore>  : Words ignored for alias expansion.
_expand_alias_core () {

    # Read parameters `words` and `ignore`.
    local n_words="$1"; shift 1
    local words=( "${@:1:$n_words}" ); shift $n_words
    local n_ignore="$1"; shift 1
    local ignore=( "${@:1:$n_ignore}" ); shift $n_ignore

    # Global var to store result.
    g_ans=()

    # Local vars.
    local str0
    local ans0
    local ans1
    local ignore0
    local ignore1
    local words0
    local words1

    # Begin expansion.
    if [[ $n_words -eq 0 ]]; then
        # Case 1: Empty input gives empty output.
        g_ans=()
    else
        if ! ( alias "${words[0]}" &>/dev/null ) || ( _in "${words[0]}" "${ignore[@]}" ); then
            # Case 2: If the first word "is not an alias" or "is an alias that
            # has already been expanded in higher scope", then don't expand it.
            g_ans=( "${words[@]}" )
        else
            # Case 3: The first word is an alias that hasn't been expanded yet. Now expand it.
            str0="$( alias "${words[0]}" | sed -r 's/[^=]*=//' | xargs )"

            local OIFS="$IFS"; IFS=$'\n'; words0=( $(xargs -n1 <<< "$str0") ); IFS="$OIFS"
            ignore0=( "${ignore[@]}" "${words[0]}" )

            words1=( "${words[@]:1}" )
            ignore1=( "${ignore[@]}" )

            _expand_alias_core "${#words0[@]}" "${words0[@]}" "${#ignore0[@]}" "${ignore0[@]}"; ans0=( "${g_ans[@]}" )
            if [[ -n "$str0" ]] && [[ "${str0: -1}" == ' ' ]]; then
                # If the first word ends with a blank, then continue expanding the following words.
                _expand_alias_core "${#words1[@]}" "${words1[@]}" "${#ignore1[@]}" "${ignore1[@]}"; ans1=( "${g_ans[@]}" )
            else
                # Else, append the following words verbatim.
                ans1=( "${words1[@]}" )
            fi

            # Combine the two parts to get the final result.
            g_ans=( "${ans0[@]}" "${ans1[@]}" )
        fi
    fi

}

# Function: Expand aliases in a command line.
_expand_alias () {
    _expand_alias_core "${#COMP_WORDS[@]}" "${COMP_WORDS[@]}" "0" ""

    # Rewrite current completion context after alias expansion.
    COMP_WORDS=( "${g_ans[@]}" )
    COMP_CWORD="$(( ${#COMP_WORDS[@]}-1 ))"
    COMP_LINE="${COMP_WORDS[*]}"
    COMP_POINT="$(( ${#COMP_LINE} ))"
}

# Function: Load a command's default completion function.
# Users may adjust this function to fit their own needs.
_load_default_completion () {
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
            complete -F _completion_loader "$cmd"
            ;;
    esac
}

# Function: Main alias completion function.
_complete_alias () {
    # Get command.
    local cmd="${COMP_WORDS[0]}"

    if [[ $_use_alias -ne 0 ]]; then
        # Expand aliases in command.
        _expand_alias

        # Clear use-alias flag.
        _use_alias=0
    fi

    # Load this command's default completion function. This avoids infinite
    # recursion when a command is aliased to itself (i.e. alias ls='ls -a').
    _load_default_completion "$cmd"

    # Do completion.
    _command_offset 0

    # Set use-alias flag.
    _use_alias=1

    # Restore this command's completion function to `_complete_alias`.
    complete -F _complete_alias "$cmd"
}

# Set alias completions.
#
# Uncomment these lines to add your own alias completions.
#
#complete -F _complete_alias myalias1
#complete -F _complete_alias myalias2
#complete -F _complete_alias myalias3

