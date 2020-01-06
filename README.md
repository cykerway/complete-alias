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

    -   macos (experimental):

        install `bash-completion` homebrew formulae version 2:

            brew install bash-completion@2

    -   windows (experimental):

        see faq;

2.  append `complete_alias` to `~/.bash_completion`:

        cat complete_alias >> ~/.bash_completion

## usage

1.  add your own aliases in `~/.bash_completion`:

    for example, to complete aliases `foo`, `bar` and `baz`:

        complete -F _complete_alias foo
        complete -F _complete_alias bar
        complete -F _complete_alias baz

2.  to complete an alias, type it and press `<tab>`;

## example

to complete alias `sctl` aliased to `systemctl`:

    $ alias sctl='systemctl'
    $ echo "complete -F _complete_alias sctl" >> ~/.bash_completion
    $ sctl <tab>
    add-requires
    add-wants
    cancel
    cat
    condreload
    ...

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

## license

The source code is licensed under the [GNU General Public License v3.0][GPLv3].

Copyright (C) 2016-2018 Cyker Way

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
[bash_completion]: https://raw.githubusercontent.com/scop/bash-completion/master/bash_completion
[gfw]: https://gitforwindows.org/
[msys2-mirror]: http://repo.msys2.org/
[msys2]: http://www.msys2.org/
[pacman]: https://wiki.archlinux.org/index.php/Pacman
