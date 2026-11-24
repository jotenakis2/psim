# psim

[Français](README.fr.md) · English

`psim` formats the output of `ps`: an aligned table, colours, totals, sort,
filter, process tree, and a dynamic mode with keyboard shortcuts.
The same binary stays usable inside a pipe or a redirection, without ANSI
sequences or truncation.

Version 1.9.0 — GPLv3. Original author: jotenakis.

## Features

- **Dynamic mode** on a terminal (refresh, sort, filter, selection, details,
  ending a process) and **static mode** with `--N`, `--watch 0` or outside a
  terminal.
- **Sort** by PID, PPID, %CPU, resident memory, nice, user or command.
- **Filter** (ERE over user, command, arguments), as an option or live with
  `/`.
- **Process tree** (`-t`, `t` key): the `ppid` hierarchy, siblings following the
  active sort. A parent missing from the view yields a forest, not a cut branch.
- **Real %CPU**, per core (default) or as a share of the machine (`-M`).
- **Clean output** in a pipe: `psim > list.txt`, `psim -k | grep ssh`.
- **Configuration** validated key by key (`~/.config/psim/default.conf`), never
  evaluated as shell.
- **Mouse**: click selects, double-click shows details.
- Terminal always restored (`EXIT` trap + signals), bounded log with rotation.
- **Bilingual interface**: French or English, following the locale (see
  [Interface language](#interface-language)).

## Dependencies

- `bash`
- `ps` (procps-ng)
- `awk`: gawk, mawk or busybox awk
- `tput` (optional)

## Installation

```bash
git clone https://github.com/jotenakis2/psim.git
cd psim
make install
```

By default `make install` installs into `~/.local`:

| Item | Destination |
| --- | --- |
| binary | `~/.local/bin/psim` |
| zsh completion | `~/.local/share/zsh/completions/_psim` |
| manual page (EN) | `~/.local/share/man/man1/psim.1` |
| manual page (FR) | `~/.local/share/man/fr/man1/psim.1` |

`~/.local/share/zsh/completions` must be in `$fpath` (the Omarchy zsh
configuration does this); a new shell then loads the completion.

The directories are configurable:

```bash
make install PREFIX=/usr/local              # system-wide install
make install MANDIR=/usr/share/man          # manuals elsewhere
make install DESTDIR=/tmp/pkg PREFIX=/usr   # packaging
make uninstall                              # removal
make check                                  # shellcheck --enable=all
```

Without installing, the script is self-contained: `./psim`.

## Documentation

`man psim` after installation, or straight from the repository:

```bash
man ./man/psim.1
man ./man/fr/psim.1
```

## Usage

```
psim [OPTIONS] [--N]
```

| Option | Effect |
| --- | --- |
| `-p`, `--pid` | sort by PID |
| `-P`, `--ppid` | sort by PPID |
| `-m`, `--mem` | sort by resident memory |
| `-c`, `--cpu` | sort by %CPU |
| `-N`, `--nice` | sort by nice value |
| `-u`, `--user` | sort by owner |
| `-C`, `--cmd` | sort by command |
| `-t`, `--tree` | process hierarchy (ppid tree) |
| `--no-tree` | cancel `--tree` (including `TREE=1` from the configuration) |
| `-n`, `--newbie` | compact view (PID USER MiB %CPU CMD) |
| `--normal` | full columns (cancels `--newbie`) |
| `-k`, `--kernel` | include kernel threads |
| `-K`, `--kernel-only` | kernel threads only |
| `-g`, `--filter PATTERN` | ERE filter (user + command + arguments) |
| `-w`, `--watch N` | refresh every N s (`0` = static) |
| `-H`, `--no-header` | hide the header |
| `-F`, `--no-footer` | hide the footer |
| `-O`, `--fullcmd` | full path and arguments |
| `-0`, `--no-color` | no colours |
| `-M`, `--machine-cpu` | %CPU as a share of the machine |
| `--per-core` | %CPU per core (default) |
| `--no-config` | ignore the configuration file |
| `--debug` | do not hide `ps`/`awk` errors |
| `--N` | first N processes, once (`0`: all) |
| `-v`, `--version` | version |
| `-h`, `--help` | full help |

Short options can be grouped (`-pn`, `-w5`, `-gfirefox`).

### Examples

```bash
psim                        # real-time monitor
psim -g 'firefox|telegram'  # filter
psim --20                   # first 20 processes, once
psim -K --0                 # kernel threads only
psim -t -c                  # tree sorted by CPU
psim -k | grep kworker      # inside a pipe
```

## Keys (dynamic mode)

| Key | Action |
| --- | --- |
| `/` | interactive filter (Enter applies, Esc cancels, Ctrl-U clears) |
| `c` `m` `p` `P` `N` `u` `C` | sort CPU / memory / PID / PPID / nice / user / command |
| `t` | process tree |
| `k` | kernel threads: hidden / included / only |
| `h` `f` | header / footer |
| `M` | %CPU of the machine or per core |
| `←` `→` | compact / extended view |
| `↑` `↓` | select (holding accelerates); Esc releases |
| `PgUp` `PgDn` `Home` `End` | scroll the view |
| `Enter` / `d` | details of the selected process (the panel scrolls: `↑` `↓` `PgUp` `PgDn` `Home` `End`) |
| `x` / `X` | TERM / KILL, after confirmation |
| `+` `-` | refresh interval |
| `F` | freeze / thaw |
| `o` | options |
| `?` | shortcut overlay |
| `q` | quit |

Click: select the row; double-click: details.
`Shift+click` keeps the terminal's own text selection working.
`PID 1`, `psim` and its own parents are refused when ending a process.

## Configuration

`~/.config/psim/default.conf`, one `KEY=VALUE` per line. The file is never
evaluated as shell; an unknown key or an invalid value is reported then ignored.

```conf
# display
NEWBIE=1          # 1 = compact, 0 = full columns
HEADER=1
FOOTER=1
NO_COLOR=0
SHOW_OPTS=0
TREE=0
# behaviour
INTERVAL=1        # seconds; 0 = static
KERNEL=0          # 0, 1 (include) or 2 (only)
CPU_MODE=0        # 1 = machine-wide %CPU
SORT=-%cpu        # pid, -pid, ppid, user, cmd, rss, %cpu, %mem, nice…
FILTER=
LOG=1
DEBUG=0
```

`--no-config` skips the file: the session starts from the defaults.
Command-line options win over the configuration.

## Files

| Path | Role |
| --- | --- |
| `~/.config/psim/default.conf` | configuration |
| `~/.cache/psim/log` | log (`LOG=1`, rotated at 256 KiB) |

## Interface language

The interface follows the locale: the first of `LC_ALL`, `LC_MESSAGES`,
`LANGUAGE`, `LANG` that is set decides. A value starting with `fr` gives
French, anything else English — so `LC_ALL=fr_FR.UTF-8 psim` forces French and
`LC_ALL=C psim` gives English.

This covers the help, the error and warning messages, the status line, the
shortcut overlay, the process box, the kill confirmation, the zsh completion
descriptions and the log file. Code comments stay in French, and the technical
labels (`PID`, `USER`, `MiB`, `%CPU`, `TOTAL (displayed)`, `proc`) are the same
in both languages.

## Development

```bash
make check        # shellcheck --enable=all (the real ShellCheck)
```

After adding, removing or changing an option, update together:
`psim`, `completions/_psim`, `man/psim.1` and `man/fr/psim.1`.
The two interface catalogs (`CATALOG_FR`, `CATALOG_EN`) and the two help pages
must always be modified in pairs.

## Licence

GPLv3 — see [LICENSE](LICENSE).
