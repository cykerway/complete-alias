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

# Use-alias flag.
_use_alias=1

# Disable the use of alias for a command.
_disable_alias () {
    local cmd="$1"

    # Remove completion for this command.
    complete -r "$cmd"

    # Reset static completions.
    #
    # We don't know the original no-alias completion for $cmd because it has
    # been overwritten by the alias completion function. What we do here is that
    # we reset all static completions to those in vanilla bash_completion. This
    # may be an overkill becase we only need to reset completion for $cmd, but
    # it works.
    complete -u groups slay w sux
    complete -A stopped -P '"%' -S '"' bg
    complete -j -P '"%' -S '"' fg jobs disown
    complete -v readonly unset
    complete -A setopt set
    complete -A shopt shopt
    complete -A helptopic help
    complete -a unalias
    complete -A binding bind
    complete -c command type which
    complete -b builtin
    complete -F _service service
    complete -F _known_hosts traceroute traceroute6 tracepath tracepath6 \
        fping fping6 telnet rsh rlogin ftp dig mtr ssh-installkeys showmount
    complete -F _command aoss command do else eval exec ltrace nice nohup \
        padsp then time tsocks vsound xargs
    complete -F _root_command fakeroot gksu gksudo kdesudo really
    complete -F _longopt a2ps awk base64 bash bc bison cat chroot colordiff cp \
        csplit cut date df diff dir du enscript env expand fmt fold gperf \
        grep grub head irb ld ldd less ln ls m4 md5sum mkdir mkfifo mknod \
        mv netstat nl nm objcopy objdump od paste pr ptx readelf rm rmdir \
        sed seq sha{,1,224,256,384,512}sum shar sort split strip sum tac tail tee \
        texindex touch tr uname unexpand uniq units vdir wc who
    complete -F _minimal ''
    complete -D -F _completion_loader

    # Reset _use_alias flag.
    _use_alias=0
}

# Enable the use of alias for a command.
_enable_alias () {
    local cmd="$1"

    # Set completion for this command.
    complete -F _complete_alias "$cmd"

    # Set _use_alias flag.
    _use_alias=1
}

# Expand the first command as an alias, stripping all leading redirections.
_expand_alias () {
    local alias_name="${COMP_WORDS[0]}"
    local alias_namelen="${#alias_name}"
    local alias_array=( $(alias "$alias_name" | sed -r 's/[^=]*=//' | xargs) )
    local alias_arraylen="${#alias_array[@]}"
    local alias_str="${alias_array[*]}"
    local alias_strlen="${#alias_str}"

    # Rewrite current completion context by expanding alias.
    COMP_WORDS=(${alias_array[@]} ${COMP_WORDS[@]:1})
    (( COMP_CWORD+=($alias_arraylen-1) ))
    COMP_LINE="$alias_str""${COMP_LINE:$alias_namelen}"
    (( COMP_POINT+=($alias_strlen-$alias_namelen) ))

    # Strip leading redirections in alias-expanded command line.
    local redir="@(?([0-9])<|?([0-9&])>?(>)|>&)"
    while [[ "${#COMP_WORDS[@]}" -gt 0 && "${COMP_WORDS[0]}" == $redir* ]]; do
        local word="${COMP_WORDS[0]}"
        COMP_WORDS=(${COMP_WORDS[@]:1})
        (( COMP_CWORD-- ))
        local linelen="${#COMP_LINE}"
        COMP_LINE="${COMP_LINE#$word+( )}"
        (( COMP_POINT-=($linelen-${#COMP_LINE}) ))
    done
}

# Alias completion function.
_complete_alias () {
    local cmd="${COMP_WORDS[0]}"

    if [[ "$_use_alias" -eq 1 ]]; then
        _expand_alias
    fi
    _disable_alias "$cmd"
    _command_offset 0
    _enable_alias "$cmd"
}

# Set alias completions.
#
# Uncomment these lines to add your own aliases.
#
# All of them should have `_complete_alias` as the completion function.
#
#complete -F _complete_alias myalias1
#complete -F _complete_alias myalias2
#complete -F _complete_alias myalias3
