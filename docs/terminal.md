# Build a Great Terminal

![screenshot](img/Tux-Terminal.resized.png)

----------------------------------------------------------------

:arrow_forward: KEY TAKEAWAYS

- We will install z shell (ZSH) and set it as the default shell.
- Then we will install [Oh-My-ZSH](https://ohmyz.sh/) and configure it for awsomeness.
- We will enable syntax highlighting, autosuggestions, History-substring-search, git integration and docker aliases!!
- We will install `Terminator` which has tabs, logging, and several available plugins.
- You will be the envy of your network engineering friends.

----------------------------------------------------------------

## Change Shells

There are several shells available for Ubuntu. To name a few:

- BASH - The default shell Ubuntu. This is the `Bourne Again Shell` first developed for the [GNU Project](https://en.wikipedia.org/wiki/GNU_Project) by Brian Fox in 1989!
- ZSH - My preferred shell! Zsh was created by Paul Falstad in 1990 while he was a student at Princeton University.
- FISH - Friendly Interactive Shell is a smart and user-friendly command line shell for Linux, macOS, and the rest of the family.
- KORN - The KornShell (ksh) is a Unix shell and language based on the Bourne shell (sh) developed in the early 1980s.

A google search for `Linux shells` will return many articles on shells.

But I like zsh so that's the one I will cover. It is the standard on recent versions of macOS which is a plus for me since I use Linux and macOS depending on what I am doing.

There is a great add-on to zsh called “Oh My ZSH” which is an unbelievably active community that creates themes and plugins for zsh. We will install it after we install zsh.

Some zsh Features

- Command-line completion.
- History can be shared among all shells.
- Extended file globbing.
- Better variable and array handling.
- Compatibility with shells like bourne shell.
- Spelling correction and autofill of command names.
- Named directories.

**Installation Instructions**

Open the terminal, `ctrl+alt+t`, and enter:

```bash
sudo apt update
sudo apt upgrade
sudo apt install zsh
```

**Check the version**

```bash hl_lines="1"
zsh --version`
zsh 5.9 (x86_64-ubuntu-linux-gnu)
```

This is the current version as of December 2024

You can check your current shell using the echo command:

```bash hl_lines="1"
echo $SHELL
/bin/bash
```

You can see that the current shell is bash

Run this to make zsh the default

```bash
chsh -s $(which zsh)`
```

Verify that zsh is the new shell

```bash  hl_lines="1"
grep zsh /etc/passwd
mhubbard:x:1000:1000:Michael Hubbard,,,:/home/mhubbard:/usr/bin/zsh
```

The file `/etc/passwd` contains the individual user settings. You can see that my shell is now `/usr/bin/zsh`.

!!! note
    You must log out and back in to make zsh the active shell. I usually reboot at this point instead using `sudo reboot now`

### Configure zsh

Once you log back in, open a terminal with  `ctrl+alt+t`

You will get a message saying zsh needs some configuration:

```text
This is the Z Shell configuration function for new users,
zsh-newuser-install.

You are seeing this message because you have no zsh startup files
(the files .zshenv, .zprofile, .zshrc, .zlogin in the directory
~).  This function can help you with a few settings that should
make your use of the shell easier.

You can:

(q)  Quit and do nothing.  The function will be run again next time.
(0)  Exit, creating the file ~/.zshrc containing just a comment.
     That will prevent this function being run again.
(1)  Continue to the main menu.
(2)  Populate your ~/.zshrc with the configuration recommended
     by the system administrator and exit (you will need to edit
     the file by hand, if so desired).

--- Type one of the keys in parentheses ---
```

**Choose 0 to just create the .zshrc file and exit because we are going to install a tool called “Oh My ZSH” to customize the shell.**

### Install Oh My ZSH

The zsh project uses a `shell script` to install `Oh My ZSH` on your system. In general, you should never copy a shell script from Internet and run it. There are a lot of malicious scripts on the Internet! But the zsh project is a FOSS project and you can trust the shell script.

I have it here for convenience but you are free to go to the [zsh project](https://ohmyz.sh/#install) and copy the shell script from the official website.

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

When the install shell script starts you will see:

```text
Found ~/.zshrc. Backing up to /home/mhubbard/.zshrc.pre-oh-my-zsh
Using the Oh My Zsh template file and adding it to ~/.zshrc.

Time to change your default shell to zsh:
Do you want to change your default shell to zsh? [Y/n] y
Changing the shell...
Password:
Shell successfully changed to '/usr/bin/zsh'.



         __                                     __
  ____  / /_     ____ ___  __  __   ____  _____/ /_
 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
                        /____/                       ....is now installed!

Before you scream Oh My Zsh! please look over the ~/.zshrc file to select plugins, themes, and options.

• Follow us on Twitter: https://twitter.com/ohmyzsh
• Join our Discord server: https://discord.gg/ohmyzsh
• Get stickers, shirts, coffee mugs and other swag: https://shop.planetargon.com/collections/oh-my-zsh
```

**Add a theme, some plugins and aliases**

Open the .zshrc file using:
`nano ~/.zshrc` or `gnome-text-editor ~/.zshrc`

Find the plugin line and change it to

```text
plugins=(
            git
            zsh-completions
            zsh-autosuggestions
            history-substring-search
            colored-man-pages
            zsh-docker-aliases
        )
```

**Download the plugins**

Copy each of these lines and paste it into the terminal:

```bash
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
```

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

```bash
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

```bash
git clone https://github.com/akarzim/zsh-docker-aliases.git  ~/.oh-my-zsh/custom/plugins/zsh-docker-aliases
```

#### Update zsh

Anytime that you make changes to `~/.zshrc` you have to reload the configuration. You do this at a terminal using `exec zsh`. If there are no errors, all that you will see in the terminal is a new line.

#### Set the default editor

Especially in the beginning you will be making a lot of changes to `.zshrc` and you won't want to type `nano ~/.zshrc` or `gnome-text-editor ~/.zshrc` every time. First we will set the default editor. Open `~/.zshrc` and search for `export EDITOR`. Then modify the configuration as follows:

----------------------------------------------------------------

```bash
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nano'
 else
   export EDITOR='subl'
 fi
```

----------------------------------------------------------------

 This will make `nano` the default editor when you open a file over ssh and `sublime text` the default editor locally. If you haven't installed `sublime text` use the editor of your choice.

Then add the following to ~/.zshrc:

----------------------------------------------------------------

```bash
# open ~/.zshrc in using the default editor specified in $EDITOR
alias ec="$EDITOR $HOME/.zshrc"
# rerun ~/.zshrc after making changes
alias sc="exec zsh"
```

----------------------------------------------------------------

Close and reload the configuration using `exec zsh`

The code that we added has two aliases:

- ec - Open ~/.zshrc in the default editor
- sc - reload the zsh configuration using `exec zsh`

These two aliases will save a ton of time when you are making changes to `~/.zshrc`.

----------------------------------------------------------------

**Plug-ins References**

You can read the documentation for the plug-ins on their github repository

- [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git) - The git plugin provides many aliases and a few useful functions.
- [zsh completions](https://github.com/zsh-users/zsh-completions) - Additional completion definitions for Zsh
- [zsh autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like fast/unobtrusive autosuggestions for zsh. It suggests commands as you type based on history and completions.
- [History Substring Search](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/history-substring-search) -This is a clean-room implementation of the Fish shell's history search feature, where you can type in any part of any command from history and then press chosen keys, such as the UP and DOWN arrows, to cycle through matches.
- [colored man pages](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colored-man-pages) - This plugin adds colors to man pages.
- [zsh docker aliases](https://github.com/akarzim/zsh-docker-aliases) - Defines Docker aliases and functions.

----------------------------------------------------------------

### zsh-syntax-highlighting

The zsh-syntax-highlighting package ( z-sy-h) is a **MUST**. It does a lot but the most important to me is that as you start typing a command it will be red, as soon as the shell matches it, zsh-syntax-highlighting turns it green. It is hard to describe how useful this in on the terminal until you use it.

----------------------------------------------------------------

#### Installation

In zsh prior to 5.8 I used the zsh plugin to install z-sy-h. The install page now recommends installing z-sy-h manually instead of using the `oh-my-zsh` plugin. The installation instructions are [here](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md).

Luckily, z-sy-h is in the Ubuntu repository so installation of the package is simple. Here is how you would check if you weren’t sure

```bash hl_lines="1"
sudo apt search zsh-syntax-highlighting
zsh-syntax-highlighting/oracular,oracular 0.7.1-2 all
```

So now we know the package is named `zsh-syntax-highlighting` so we can install is using:

```bash hl_lines="1 2"
sudo apt install zsh-syntax-highlighting
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
```

These commands install the `z-sy-h` package then echo the source command into the .zshrc file.

Now enter `sc` to reload zsh.

For reference, the last part of the echo command is a variable. We can echo it to the terminal using:

```bash hl_lines="1"
echo ${ZDOTDIR:-$HOME}/.zshrc
/home/mhubbard/.zshrc
```

Showing that my `.zshrc` is located at `/home/mhubbard/` or the root of my home directory.

!!! Note
    In zsh newer than 5.8 (not including 5.8 itself), zsh-syntax-highlighting uses the add-zle-hook-widget facility to install a zle-line-pre-redraw hook. Hooks are run in order of registration, therefore, z-sy-h must be sourced (and register its hook) after anything else that adds hooks that modify the command-line buffer.

The line in the .zshrc file they are referring to is `source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh` . I make it the last line to the `.zshrc` file.

----------------------------------------------------------------

### Themes

Oh My ZSH offers a lot of themes. I found one that I really like called duellj. To install it, Open the .zshrc file using:
`nano ~/.zshrc` or `gnome-text-editor ~/.zshrc` and change the ZSH-THEME line to:
ZSH_THEME="duellj"

I also like “amuse”. It’s similar to duellj but doesn’t put the username/machine name in the terminal. Since I’m on my personal laptop I don’t need that information. To use “amuse”

ZSH_THEME="amuse"

You can put a `#` symbol in front of the theme line to comment it out. I leave both themes in my `.zshrc` file and then switch back and forth as needed.

You can find all of the themes here: [zsh themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)

----------------------------------------------------------------

### BAT

This is a great upgrade to the built in cat command. The automatic paging, syntax highlighting, Git integration and the ability to show non-printable characters makes replacing cat with bat a no brainer.

There are a lot of other features to bat. You should review the official Git repository at [bat](https://github.com/sharkdp/bat)

**Syntax highlighting**

bat supports syntax highlighting for a large number of programming and markup languages:

----------------------------------------------------------------

![screenshot](img/bat.png)

----------------------------------------------------------------

**Git integration**

bat communicates with git to show modifications with respect to the index (see left side bar):

----------------------------------------------------------------

![screenshot](img/bat1.png)

----------------------------------------------------------------

**Show non-printable characters**

You can use the -A/--show-all option to show and highlight non-printable characters. There are some malicious text files that embed non-printing characters. Use this method so see them.

----------------------------------------------------------------

![screenshot](img/bat2.png)

----------------------------------------------------------------

**Installation Instructions**

Download the latest `.deb` package from the release page [bat](https://github.com/sharkdp/bat/releases) and install it via:

`sudo dpkg -i bat-musl_0.24.0_amd64.deb`  # adapt version number and architecture

!!! attention
     If you install bat this way, please note that the executable may be installed as batcat instead of bat (due to a name clash with another package). I have not ever had this happen.

If this happens, you can set up a bat -> batcat symlink or alias to prevent any issues that may come up because of this and to be consistent with other distributions:

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

If you want to use an alias instead of a symlink, add

`alias cat='batcat'`

to `~/.zshrc`

#### Hubbard's .zshrc file

```zsh title="Hubbard's .zshrc file"
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/mhubbard/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="duellj"
ZSH_THEME="amuse"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
    history-substring-search
    aliases
    colored-man-pages
    zsh-docker-aliases
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='gedit'
 else
   export EDITOR='subl'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias python=python3
# alias pip=pip3

# open ~/.zshrc in using the default editor specified in $EDITOR
alias ec="$EDITOR $HOME/.zshrc"
# rerun ~/.zshrc after making changes
alias sc="exec zsh"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Zoxide https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Configure fzf
eval "$(fzf --zsh)"
```

### Plugins

There are many plug-ins for zsh

#### Copy BASH history

https://gist.github.com/muendelezaji/c14722ab66b505a49861b8a74e52b274

### zsh References

[Install zsh in Ubuntu](https://www.tecmint.com/install-zsh-in-ubuntu/) - The Tecmint site has a tutorial for installing zsh
