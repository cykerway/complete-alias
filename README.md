# complete-alias

automagical shell alias completion;

-   works with all common aliases, even self-aliases;

-   one completion function, for all aliases;

-   alias completion as easy as type-and-tab;

## install

1.  install dependency [bash-completion][];

    -   linux:

        install `bash-completion` using system package manager:

            dnf install bash-completion     ##  fedora
            apt install bash-completion     ##  debian

        for other linux distros, see faq;

    -   macos (experimental):

        install `bash-completion` homebrew formulae version 2:

            brew install bash-completion@2

    -   windows (experimental):

        see faq;

2.  source `complete_alias` in `~/.bash_completion`:

        . {complete_alias}

    where `{complete_alias}` is the path of `complete_alias`;

## usage

1.  edit aliases to complete in `complete_alias`:

    for example, to complete aliases `foo`, `bar` and `baz`:

        complete -F _complete_alias foo
        complete -F _complete_alias bar
        complete -F _complete_alias baz

2.  to complete an alias, type it and press `<tab>`;

## example

to complete alias `sctl` aliased to `systemctl`:

    $ alias sctl='systemctl'
    $ cp complete_alias ~/.complete_alias
    $ echo ". ~/.complete_alias" >> ~/.bash_completion
    $ echo "complete -F _complete_alias sctl" >> ~/.complete_alias
    $ sctl <tab>
    add-requires
    add-wants
    cancel
    cat
    condreload
    ...

## config

to config `complete-alias`, set these envars *before* sourcing the main script:

-   `COMPAL_AUTO_UNMASK`

    this is a bool; default is `0`; when set to `1`, enables auto unmask; when
    set to `0`, uses manual unmask;

    auto unmask automatically manages non-alias command completions, but incurs
    a small overhead on source; manual unmask is the traditional way of setting
    non-alias command completions, which is static and faster but requires user
    intervention if the preset is not satisfying;

## compat

-   support for gnu bash(>=4.4) on linux is aimed;

-   support for older versions of bash is uncertain;

-   support for other shells is possible but unlikely;

-   support for other operating systems is experimental;

## faq

-   how to install it on windows?

    support for windows is limited to [msys2][] and [git for windows][gfw]:

    -   msys2:

        msys2 features [pacman][] so you can install like linux:

            pacman -S bash-completion
            cat complete_alias >> ~/.bash_completion

    -   git for windows:

        tldr: steal `bash_completion` and source it before `complete_alias`;

        git for windows provides git bash, which is a minimal environment based
        on msys2; for what matters here, git bash does not have package manager;
        so the above install procedure does not apply;

        the idea is, you must somehow get `bash-completion` and load it before
        `complete-alias` in a shell environment; for example, you can download
        `bash-completion` package from [a msys2 mirror][msys2-mirror]; however,
        the easiest solution i found to make things work is to simply download
        the main script [`bash_completion`][bash_completion] from its git repo;
        this does not give you its entirety, but is good enough to work;

        now you have 2 files: `bash_completion` and `complete_alias`; you need
        to source them in this order in `~/.bashrc`:

            . ~/.bash_completion.sh
            . ~/.complete_alias.sh

        attention: here we renamed the files; we cannot use `~/.bash_completion`
        because this is the very filename sourced by the very script; using this
        filename will cause an infinite loop;

        now install is complete; add your own aliases in `~/.complete_alias.sh`;

-   how to install `bash-completion` on other linux distros?

    these commands are sourced from wikis and users:

        pacman -S bash-completion               ##  arch
        yum install bash-completion             ##  centos
        emerge --ask app-shells/bash-completion ##  gentoo
        zypper install bash-completion          ##  suse
        apt install bash-completion             ##  ubuntu

    these commands are not tested; open a ticket if you find them not working;

-   how to complete *all* my aliases?

    run this one-liner *after* all aliases have been defined:

        complete -F _complete_alias "${!BASH_ALIASES[@]}"

    it works like this:

        complete -F _complete_alias foo
        complete -F _complete_alias bar
        complete -F _complete_alias baz
        ...

    note that if you simply put this one-liner in `complete_alias` code, things
    may not work, depending on the order of file sourcing, which in turn varies
    across user configurations; the correct way to use this one-liner is to put
    it in the same file where aliases are defined; for example, if your aliases
    are defined in `~/.bashrc`, then that file should look like this:

        alias foo='...'
        alias bar='...'
        alias baz='...'
        ...
        complete -F _complete_alias "${!BASH_ALIASES[@]}"

-   what are special characters in alias body?

    these characters have special meanings and may cause errors when used in
    alias body (this is not a complete list):

    -   newline (`\n`):

        we do not allow alias body to contain the newline character; this limits
        the cases to consider and makes smaller, faster code; we treat a newline
        as a word breaker in the outmost scope, but you better not rely on this;

    -   backquote (`` ` ``):

        avoid the old-style backquote form `` `command` `` of command
        substitution as much as possible; instead, use the `$(command)` form;
        the backquote form is more tricky and less legible when nested in quotes
        or another command substitution; we do not intend to fully support
        backquotes;

    -   backslash (`\`):

        avoid backslashes unless you absolutely have to use them; they are
        mostly used to escape a character; we have double quotes that can do the
        same; the bash manual is not complete on where a backslash is special
        and where it is literal; and we may make mistakes on its interpretation;

    -   colon (`:`):

        a colon seems innocent but is special to word completion code: it is one
        of the characters that breaks words for the completer; you can read more
        about it at [this link][bash-faq]; however, we do not guarantee the same
        treatment of colons here as there; we treat a colon as a word breaker in
        the outmost scope and a literal otherwise; if you always want it to be a
        literal, just quote it;

-   why is `sudo` completion not working correctly?

    there is a known case with `sudo` that can go wrong; for example:

        $ unalias sudo
        $ complete -r sudo
        $ alias ls='ping'
        $ complete -F _complete_alias ls
        $ sudo ls <tab>
        {ip}
        {ip}
        {ip}
        ...

    here we are expecting a list of files, but the completion reply is a list of
    ip addrs; the reason is, the completion function for `sudo` is almost always
    `_sudo`, which is provided by `bash-completion`; this function strips `sudo`
    then meta-completes the remaining command line; in our case, this is `ls` to
    be completed by `_complete_alias`; but there is no way for `_complete_alias`
    to see the original command line, and so it cannot tell `ls` from `sudo ls`;
    as a result, `ls` and `sudo ls` are always completed the same even when they
    should not; unfortunately, there is nothing `_complete_alias` can do here;

    the easiest solution is to make `sudo` a self-alias:

        $ alias sudo='sudo'
        $ complete -F _complete_alias sudo
        $ alias ls='ping'
        $ complete -F _complete_alias ls
        $ sudo ls <tab>
        {file}
        {file}
        {file}
        ...

    this gives `_complete_alias` a chance to see the original command line, then
    decide what is the right thing to do; you may add a trailing space to `sudo`
    alias body if you like it that way, and things still work correctly (listing
    ip addrs is correct in this case):

        $ alias sudo='sudo '
        $ complete -F _complete_alias sudo
        $ alias ls='ping'
        $ complete -F _complete_alias ls
        $ sudo ls <tab>
        {ip}
        {ip}
        {ip}
        ...

## license

The source code is licensed under the [GNU General Public License v3.0][GPLv3].

Copyright (C) 2016-2021 Cyker Way

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

[GPLv3]: https://www.gnu.org/licenses/gpl-3.0.txt
[bash-completion]: https://github.com/scop/bash-completion
[bash-faq]: https://tiswww.case.edu/php/chet/bash/FAQ
[bash_completion]: https://raw.githubusercontent.com/scop/bash-completion/master/bash_completion
[gfw]: https://gitforwindows.org/
[msys2-mirror]: http://repo.msys2.org/
[msys2]: http://www.msys2.org/
[pacman]: https://wiki.archlinux.org/index.php/Pacman
