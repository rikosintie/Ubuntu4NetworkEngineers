# Build a Great Terminal

![screenshot](img/Tux-Terminal.resized.png)

----------------------------------------------------------------

:arrow_forward: KEY TAKEAWAYS

- We will install `Terminator` which has tabs, logging, and several available plugins.
- We will install z shell (ZSH) and set it as the default shell.
- Then we will install [Oh-My-ZSH](https://ohmyz.sh/) and configure it for awsomeness.
- We will enable syntax highlighting, autosuggestions, History-substring-search, git integration and docker aliases!!
- You will be the envy of your network engineering friends.

----------------------------------------------------------------

## Tailspin

**Overview**

tailspin works by reading through a log file line by line, running a series of regexes against each line. The regexes recognize patterns you expect to find in a log file, like dates, numbers, severity keywords and more.

tailspin does not make any assumptions on the format or position of the items it wants to highlight. For this reason, it requires no configuration and the highlighting will work consistently across different log files.

**Installation Instructions**

The repository is located here: [tailspin](https://github.com/bensadeh/tailspin). Tailspin is installed using `brew install tailspin`. There are instructions for tailspin on the README page at the repo.

### Windows

To use tailspin on Windows you will need WSL. See [How to install Homebrew on Windows](https://bobbyhadz.com/blog/how-to-install-brew-on-windows) for instructions.

### tspin examples

**For Linux logs**

- tspin --help
- tspin --print /var/log/ufw.log
- tspin --print /var/log/syslog
- journalctl -ef | tspin
- journalctl -ef | tspin | spacer --after 5

**Network Switch log file specific**

- tspin CX-log.txt --print
- tspin CX-log.txt --print | grep WARN
- tspin CX-log.txt --print | grep VSX
- tspin CX-log.txt --print --words-red LOG_WARN --words-green AMM
- tspin CX-log.txt --print --words-red LOG_WARN,Partner --words-green AMM
- tspin --print --config-path ~/.config/tailspin/cx-config.toml CX-log.txt
- tspin --print --config-path cx-config.toml CX-log.txt

**Add custom word list to color**

tspin uses .toml files for configuration. Here is a sample toml file for a CX switch log

```bash
[[keywords]]
words = ['LOG_WARN', 'Partner', 'AdjChg', 'Authorization', 'Authentication', 'User']
style = { fg = "red" }

[[keywords]]
words = ['LAG', 'VSX', 'LLDP']
style = { fg = "green", italic = true }
```

You can create more `[[keywords]]` entries for other colors.

In the example above I created a directory `~/.config/tailspin/` to save the toml files in. To use tspin with the custom file:
`tspin --print --config-path ~/.config/tailspin/cx-config.toml CX-log.txt`

You could save the toml file in the same directory as the log file and use:
`tspin --print --config-path cx-config.toml CX-log.txt` but that doesn't scale well. I think it's better to put them in `~/.config/tailspin/` and then create an alias.

**alias example**

Place in `.zshrc`

alias tspincx='tspin --print --config-path ~/.config/tailspin/cx-config.toml $1'

To call the alias
`tspincx CX-log.txt`

### Parse

I wrote a python script that parses the CX log file into a csv file. The file can be opened in Excel with each field of the file as a column. That allows you to sort and filter the log file.

If you use VS Code, you can install the `Rainbow CSV` extension and use SQL syntax to parse the file.

#### Execution

Simply grab the CX-Log-Parse.py file from the repository and run:
`CX-Log-Parse.py -f CX-log.txt`

This will create a csv file with the name CX-log.csv.
