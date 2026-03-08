# DigimonFetch

A **Digimon companion for your terminal** that evolves based on your
**system uptime**.

DigimonFetch integrates with **Fastfetch** and displays a Digimon
partner directly in your terminal, complete with image, name, and
evolution stage.

Your Digimon **persists between sessions** and evolves while your system
stays online.

Perfect for people who love:

-   Linux terminal customization
-   Fastfetch / Neofetch setups
-   Digimon
-   nerdy terminal aesthetics

------------------------------------------------------------------------

# Features

-   Random **partner Digimon**
-   **Evolution system** based on system uptime
-   **Persistent state** between terminal sessions
-   **Image rendering** in terminal using Fastfetch
-   Uses the public **Digimon API**
-   Minimal dependencies
-   Lightweight and fast

------------------------------------------------------------------------

# Preview

Add a screenshot here after installation:

![DigimonFetch Screenshot](examples/screenshot.png)

------------------------------------------------------------------------

# Requirements

DigimonFetch requires the following tools:

-   `bash`
-   `curl`
-   `jq`
-   `fastfetch`

Optional but recommended:

-   `chafa` (for image rendering in terminal)

------------------------------------------------------------------------

# Install Dependencies

## Ubuntu / Debian

``` bash
sudo apt install curl jq fastfetch chafa
```

## Arch Linux

``` bash
sudo pacman -S curl jq fastfetch chafa
```

## Fedora

``` bash
sudo dnf install curl jq fastfetch chafa
```

------------------------------------------------------------------------

# Installation

Clone the repository:

``` bash
git clone https://github.com/YOUR_USERNAME/digimonfetch.git
```

Enter the directory:

``` bash
cd digimonfetch
```

Run the installer:

``` bash
chmod +x install.sh
./install.sh
```

This installs the command:

    digimonfetch

into:

    ~/.local/bin

------------------------------------------------------------------------

# Usage

Run:

``` bash
digimonfetch
```

You can also add it to your shell startup file.

### Zsh

Edit:

    ~/.zshrc

Add:

``` bash
digimonfetch
```

### Bash

Edit:

    ~/.bashrc

Add:

``` bash
digimonfetch
```

Now your Digimon will appear every time you open a terminal.

------------------------------------------------------------------------

# Fastfetch Integration

You can integrate DigimonFetch directly into your Fastfetch config.

Example module:

``` json
{
  "type": "custom",
  "key": "󰐗 Partner Digimon",
  "exec": "digimonfetch --name"
},
{
  "type": "custom",
  "key": "󰆧 Level",
  "exec": "digimonfetch --level"
}
```

This will display your Digimon information alongside your system info.

------------------------------------------------------------------------

# How Evolution Works

DigimonFetch checks your **system uptime** and evolves your Digimon
accordingly.

Example progression:

  Uptime           Stage
  ---------------- ----------
  0--15 minutes    Baby
  15--60 minutes   Rookie
  1--4 hours       Champion
  4--10 hours      Ultimate
  10+ hours        Mega

The Digimon state is cached in:

    ~/.cache/digimonfetch

This allows the Digimon to persist across terminal sessions.

------------------------------------------------------------------------

# Data Source

DigimonFetch uses the public Digimon API:

https://digi-api.com/

This API provides:

-   Digimon names
-   Images
-   Levels
-   Evolution data

------------------------------------------------------------------------

# Uninstall

Run:

``` bash
./uninstall.sh
```

This will remove:

    ~/.local/bin/digimonfetch
    ~/.local/share/digimonfetch
    ~/.cache/digimonfetch

------------------------------------------------------------------------

# Project Structure

    digimonfetch
    │
    ├── digimonfetch.sh
    ├── install.sh
    ├── uninstall.sh
    │
    ├── config
    │   └── fastfetch-module.json
    │
    ├── examples
    │   └── screenshot.png
    │
    ├── README.md
    └── LICENSE

------------------------------------------------------------------------

# Contributing

Contributions are welcome.

Possible improvements:

-   Better evolution logic
-   Evolution tree visualization
-   ASCII fallback mode
-   Neofetch support
-   Custom Digimon selection
-   Theme integration with Fastfetch

Feel free to open an issue or submit a pull request.

------------------------------------------------------------------------

# License

GNU GENERAL PUBLIC LICENSE

------------------------------------------------------------------------

# Credits

DigimonFetch uses the public Digimon API:

https://digi-api.com/

Digimon is a trademark of **Bandai** and related companies.

This project is a **fan-made terminal utility** and is not affiliated
with Bandai.