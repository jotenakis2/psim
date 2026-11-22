# psim

`psim` met en forme la sortie de `ps` : tableau aligné, couleurs, totaux, tri,
filtre, arbre des processus, et un mode dynamique avec raccourcis clavier.
Le même binaire reste utilisable dans un pipe ou une redirection, sans séquence
ANSI ni troncature.

Version 1.8.1 — GPLv3. Auteur original : jotenakis.

## Fonctionnalités

- **Mode dynamique** sur un terminal (rafraîchissement, tri, filtre, sélection,
  détails, fin de processus) et **mode statique** avec `--N`, `--watch 0` ou
  hors terminal.
- **Tri** par PID, PPID, %CPU, mémoire résidente, nice, utilisateur ou commande.
- **Filtre** ERE (utilisateur, commande, arguments), en option ou en direct avec
  `/`.
- **Arbre des processus** (`-t`, touche `t`) : hiérarchie des `ppid`, les frères
  suivent le tri actif. Un parent absent de la vue donne une forêt, pas une
  branche coupée.
- **%CPU** réel, par cœur (défaut) ou en pourcentage de la machine (`-M`).
- **Sortie propre** dans un pipe : `psim > liste.txt`, `psim -k | grep ssh`.
- **Configuration** validée clé par clé (`~/.config/psim/default.conf`), jamais
  évaluée comme du shell.
- **Souris** : clic = sélection, double-clic = détails.
- Terminal toujours restauré (trap `EXIT` + signaux), journal borné avec
  rotation.

## Dépendances

- `bash`
- `ps` (procps-ng)
- `awk` : gawk, mawk ou busybox awk
- `tput` (optionnel)

## Installation

```bash
git clone https://github.com/jotenakis2/psim.git
cd psim
make install
```

Par défaut, `make install` installe dans `~/.local` :

| Élément | Destination |
| --- | --- |
| binaire | `~/.local/bin/psim` |
| complétion zsh | `~/.local/share/zsh/completions/_psim` |
| page de manuel (EN) | `~/.local/share/man/man1/psim.1` |
| page de manuel (FR) | `~/.local/share/man/fr/man1/psim.1` |

`~/.local/share/zsh/completions` doit figurer dans `$fpath` (c'est le cas de la
configuration zsh d'Omarchy) ; un nouveau shell charge alors la complétion.

Les répertoires sont configurables :

```bash
make install PREFIX=/usr/local              # installation système
make install MANDIR=/usr/share/man          # manuels ailleurs
make install DESTDIR=/tmp/pkg PREFIX=/usr   # empaquetage
make uninstall                              # retrait
make check                                  # shellcheck --enable=all
```

Sans installation, le script est autonome : `./psim`.

## Documentation

`man psim` après installation, ou directement depuis le dépôt :

```bash
man ./man/psim.1
man ./man/fr/psim.1
```

## Utilisation

```
psim [OPTIONS] [--N]
```

| Option | Effet |
| --- | --- |
| `-p`, `--pid` | tri par PID |
| `-P`, `--ppid` | tri par PPID |
| `-m`, `--mem` | tri par mémoire résidente |
| `-c`, `--cpu` | tri par %CPU |
| `-N`, `--nice` | tri par valeur nice |
| `-u`, `--user` | tri par propriétaire |
| `-C`, `--cmd` | tri par commande |
| `-t`, `--tree` | hiérarchie des processus (arbre des ppid) |
| `--no-tree` | annuler `--tree` (y compris `TREE=1` de la configuration) |
| `-n`, `--newbie` | affichage simplifié (PID USER MiB %CPU CMD) |
| `--normal` | colonnes complètes (annule `--newbie`) |
| `-k`, `--kernel` | inclure les threads noyau |
| `-K`, `--kernel-only` | uniquement les threads noyau |
| `-g`, `--filter MOTIF` | filtre ERE (utilisateur + commande + arguments) |
| `-w`, `--watch N` | rafraîchir toutes les N s (`0` = statique) |
| `-H`, `--no-header` | masquer l'entête |
| `-F`, `--no-footer` | masquer le pied de page |
| `-O`, `--fullcmd` | chemin complet et arguments |
| `-0`, `--no-color` | sans couleurs |
| `-M`, `--machine-cpu` | %CPU en pourcentage de la machine |
| `--per-core` | %CPU par cœur (défaut) |
| `--no-config` | ignorer le fichier de configuration |
| `--debug` | ne pas masquer les erreurs `ps`/`awk` |
| `--N` | N premiers processus, une seule fois (`0` : tout) |
| `-v`, `--version` | version |
| `-h`, `--help` | aide complète |

Les options courtes se groupent (`-pn`, `-w5`, `-gfirefox`).

### Exemples

```bash
psim                        # moniteur temps réel
psim -g 'firefox|telegram'  # filtrer
psim --20                   # 20 premiers processus, une seule fois
psim -K --0                 # threads noyau uniquement
psim -t -c                  # arbre trié par CPU
psim -k | grep kworker      # dans un pipe
```

## Raccourcis (mode dynamique)

| Touche | Action |
| --- | --- |
| `/` | filtre interactif (Entrée valide, Échap annule, Ctrl-U efface) |
| `c` `m` `p` `P` `N` `u` `C` | tri CPU / mémoire / PID / PPID / nice / utilisateur / commande |
| `t` | arbre des processus |
| `k` | threads noyau : masqués / inclus / seuls |
| `h` `f` | entête / pied de page |
| `M` | %CPU machine ou par cœur |
| `←` `→` | affichage simplifié / étendu |
| `↑` `↓` | sélectionner (maintenir accélère) ; Échap relâche |
| `PgUp` `PgDn` `Home` `End` | défilement de la vue |
| `Entrée` / `d` | détails du processus sélectionné (la fiche défile : `↑` `↓` `PgUp` `PgDn` `Home` `End`) |
| `x` / `X` | TERM / KILL, après confirmation |
| `+` `-` | intervalle de rafraîchissement |
| `F` | gel / reprise |
| `o` | options |
| `?` | aide en sur-impression |
| `q` | quitter |

Clic : sélection de la ligne ; double-clic : détails.
`Maj+clic` laisse la sélection de texte du terminal opérationnelle.
`PID 1`, `psim` et ses propres parents sont refusés à la terminaison.

## Configuration

`~/.config/psim/default.conf`, une clé `CLÉ=VALEUR` par ligne. Le fichier n'est
jamais interprété comme du shell ; une clé inconnue ou une valeur invalide est
signalée puis ignorée.

```conf
# affichage
NEWBIE=1          # 1 = simplifié, 0 = colonnes complètes
HEADER=1
FOOTER=1
NO_COLOR=0
SHOW_OPTS=0
TREE=0
# comportement
INTERVAL=1        # secondes ; 0 = statique
KERNEL=0          # 0, 1 (inclure) ou 2 (seulement)
CPU_MODE=0        # 1 = %CPU de la machine
SORT=-%cpu        # pid, -pid, ppid, user, cmd, rss, %cpu, %mem, nice…
FILTER=
LOG=1
DEBUG=0
```

`--no-config` ignore le fichier : la session repart des valeurs par défaut.
Les options de la ligne de commande l'emportent sur la configuration.

## Fichiers

| Chemin | Rôle |
| --- | --- |
| `~/.config/psim/default.conf` | configuration |
| `~/.cache/psim/log` | journal (`LOG=1`, rotation à 256 Kio) |

## Développement

```bash
make check        # shellcheck --enable=all (le vrai ShellCheck)
```

Après tout ajout, retrait ou changement d'option, mettre à jour ensemble :
`psim`, `completions/_psim`, `man/psim.1` et `man/fr/psim.1`.

## Licence

GPLv3 — voir [LICENSE](LICENSE).
