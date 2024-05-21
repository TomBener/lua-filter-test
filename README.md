# Lua Filter Does Not Work in Quarto

The following command does not work in Quarto:

```shell
quarto render --to html
```

But by applying the Lua filter on the command line, it works:

```shell
quarto render --to html -L _extensions/filters/localize-cnbib/localize-cnbib.lua
```

Quarto check:

```
$ quarto check

Quarto 1.5.37
[✓] Checking versions of quarto binary dependencies...
      Pandoc version 3.2.0: OK
      Dart Sass version 1.70.0: OK
      Deno version 1.41.0: OK
      Typst version 0.11.0: OK
[✓] Checking versions of quarto dependencies......OK
[✓] Checking Quarto installation......OK
      Version: 1.5.37
      Path: /Applications/quarto/bin

[✓] Checking tools....................OK
      TinyTeX: v2024.05
      Chromium: (not installed)

[✓] Checking LaTeX....................OK
      Using: TinyTex
      Path: /Users/username/Library/TinyTeX/bin/universal-darwin
      Version: 2024

[✓] Checking basic markdown render....OK

[✓] Checking Python 3 installation....OK
      Version: 3.10.10
      Path: /Users/username/.pyenv/versions/3.10.10/bin/python3
      Jupyter: 5.7.2
      Kernels: python3

[✓] Checking Jupyter engine render....OK

[✓] Checking R installation...........OK
      Version: 4.4.0
      Path: /opt/homebrew/Cellar/r/4.4.0_1/lib/R
      LibPaths:
        - /Users/username/.R/packages
        - /opt/homebrew/lib/R/4.4/site-library
        - /opt/homebrew/Cellar/r/4.4.0_1/lib/R/library
      knitr: 1.46
      rmarkdown: 2.26

[✓] Checking Knitr engine render......OK
```
