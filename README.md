# complete-alias

Programmable completion function for shell aliases.

# Intro

If you are wondering how to make the programmable completion functionality as
provided by the shell work with aliases automagically, then this program is your
friend.

This program provides a shell alias completion tool which:

-   Works with all properly defined aliases, even those aliasing to themselves.

-   Uses a single function to complete all aliases, which means you don't have
    to define different functions for different aliases.

-   Completes aliases automagically as you type in the command line and press
    `<Tab>`. Nothing else.

# Installation & Usage

Currently the only supported shell is [Bash][Bash].

To use this program with Bash:

1.  Install [bash-completion][bash-completion], which is a dependency of this
    program.

    You may find it already installed on your system or you may be able to
    install it via your system's package manager.

2.  Append the content of `completions/bash_completion.sh` into
    `~/.bash_completion`:

        cat completions/bash_completion.sh >> ~/.bash_completion

3.  Edit `~/.bash_completion` to setup completion functions for your own
    aliases. Usually this involves uncomment and edit some comment lines like
    this:

        #complete -F _complete_alias myalias

    If you want to complete for alias `foo`, then edit this line into:

        complete -F _complete_alias foo

4.  To complete a command line with an alias, simply press `<Tab>`.

# Usage Example

In `~/.bash_profile`:

    alias sctl='systemctl'

In `~/.bash_completion`:

    complete -F _complete_alias sctl

Now typing `<Tab>` after `sctl<space>` will show `systemctl` commands:

    $ sctl <Tab>
    add-requires
    add-wants
    cancel
    cat
    condreload
    ...

# LICENSE

The source code is licensed under the [GNU General Public License v3.0][GPLv3].

Copyright (C) 2016-2017 Cyker Way

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.


[Bash]: https://www.gnu.org/software/bash/
[GPLv3]: https://www.gnu.org/licenses/gpl-3.0.txt
[bash-completion]: https://github.com/scop/bash-completion
