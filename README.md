# complete-alias

Programmable completion function for shell aliases.

# Intro

If you are wondering how to let the shell complete aliases automagically, then
this program is your friend.

This program provides a shell alias completion tool which:

-   Works with all commonly defined aliases, including self-aliases.

-   Uses a single function to complete all aliases.

-   Completes aliases as you type in the command line and press `<Tab>`. Nothing
    else.

See **Portability** for supported environments.

# Install & Use

1.  Install [bash-completion][bash-completion], which is a dependency of this
    program.

    You may find it already installed on your system, or, you may be able to
    install it via your system's package manager.

2.  Append the content of `completions/bash_completion.sh` into
    `~/.bash_completion`:

        cat completions/bash_completion.sh >> ~/.bash_completion

3.  Edit `~/.bash_completion` with completion functions for your own aliases.
    For example, if you want to complete alias `foo`, then add a line in its
    end:

        complete -F _complete_alias foo

4.  To complete an alias, type it and press `<Tab>`.

# Example

-   In `~/.bash_profile`:

        alias sctl='systemctl'

-   In `~/.bash_completion`:

        complete -F _complete_alias sctl

-   Type `sctl <tab>` to show `systemctl` commands:

        $ sctl <Tab>
        add-requires
        add-wants
        cancel
        cat
        condreload
        ...

# Portability

This program is expected to work with GNU Bash on Linux.

Support for additional shells is not yet implemented.

Support for MacOS and other operating systems is experimental.

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


[GPLv3]: https://www.gnu.org/licenses/gpl-3.0.txt
[bash-completion]: https://github.com/scop/bash-completion
