# Fix Duplicate `$PATH` Entries in Zsh with Oh My Zsh

When using Zsh with Oh My Zsh, you may notice repeated entries like:

```
/home/youruser/.local/bin
/home/youruser/.local/bin
/snap/bin
/snap/bin
...
```

This happens because multiple files append to `$PATH` without checking first. Here's how to fix it properly.

---

## 🔍 Step 1: Understand What's Adding to `$PATH`

Zsh with Oh My Zsh can add to `$PATH` from:

- `~/.zshrc`
- `~/.zprofile`
- `~/.zshenv`
- `~/.oh-my-zsh/lib/path.zsh`
- Plugins or system-wide files (`/etc/zsh/zshenv`, `/etc/profile`)

---

## ✅ Step 2: Deduplicate `$PATH` Automatically

Zsh stores `$PATH` as an array called `path`.

At the **top of your `.zshrc` file, add:

```zsh
# Automatically remove duplicates from $PATH
typeset -U path PATH
```

This makes the `path` array **unique**, keeping `$PATH` clean.

---

## 📟 Step 3: Check and Remove Redundant Path Additions

Run this command to find where `.local/bin` or other paths are being added:

```bash
grep -i '.local/bin' ~/.zshrc ~/.zprofile ~/.zshenv ~/.oh-my-zsh/lib/path.zsh
```

If you see `export PATH="$HOME/.local/bin:$PATH"` in **more than one** file, delete it from all but one — ideally keep it in `~/.zshrc`.

---

## ✨ Step 4: Use Zsh Arrays for Clean Path Management

Instead of modifying `$PATH` as a string, do this:

```zsh
[[ "$path" != *"$HOME/.local/bin"* ]] && path+=("$HOME/.local/bin")
[[ "$path" != *"/snap/bin"* ]] && path+=("/snap/bin")
```

This safely appends to the `path` array **only if not already present**.

---

## 📊 Step 5: Verify It Works

1. Restart your terminal
2. Run this:

```bash
echo "$PATH" | tr ':' '\n'
```

You should now see **only one line per path** — no duplicates.

Or use this Zsh-friendly function:

```zsh
path() {
  if [[ -n "$1" ]]; then
    for p in "${path[@]}"; do
      [[ "$p" == *"$1"* ]] && echo "$p"
    done
  else
    for p in "${path[@]}"; do
      echo "$p"
    done
  fi
}
```

---

## 🗞 Sample `.zshrc` Snippet

Here’s what your path section might look like:

```zsh
# Deduplicate PATH
typeset -U path PATH

# Append paths safely
[[ "$path" != *"$HOME/.local/bin"* ]] && path+=("$HOME/.local/bin")
[[ "$path" != *"/snap/bin"* ]] && path+=("/snap/bin")

# Oh My Zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh
```

---

## ✅ You're Done!

Zsh will now keep your `$PATH` clean, no matter how many times you open a terminal. 🎉

---
