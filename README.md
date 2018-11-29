# complete-alias

programmable completion function for shell aliases;

this project provides a tool which completes shell aliases automagically:

-   it works with all commonly used aliases (including self-aliases);

-   it uses a single function to complete all these aliases;

-   it completes aliases as you type it and press `<tab>`;

## install

1.  install [bash-completion][], which is a dependency of this project;

    bash-completion is available in repositories of many linux distributions;

2.  append `bash_completion.sh` to `~/.bash_completion`:

        cat bash_completion.sh >> ~/.bash_completion

## usage

1.  add completion functions for your own shell aliases in `~/.bash_completion`:

    for example, to complete alias `foo`, add a line:

        complete -F _complete_alias foo

2.  to complete an alias, type it and press `<tab>`;

## example

to complete alias `sctl`, which is aliased to `systemctl`:

    # alias sctl='systemctl'
    # echo 'complete -F _complete_alias sctl' >> ~/.bash_completion
    # sctl <tab>
    add-requires
    add-wants
    cancel
    cat
    condreload
    ...

## compat

-   this project is expected to work with gnu bash on linux;

-   support for other shells is not yet implemented;

-   support for macos and other operating systems is experimental;

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

