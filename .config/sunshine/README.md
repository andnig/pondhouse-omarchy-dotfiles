# Sunshine on Hyprland

This setup captures an independent `sunshine` display at 3840×2160, 60 Hz,
using Wayland capture and automatic encoder selection. NVIDIA hosts can use
NVENC; AMD hosts can select their supported encoder (such as VAAPI).
The shared configuration does not force an NVIDIA encoder. NVENC tuning lives only
in this NVIDIA host's yadm alternate.

## Files

- `~/.config/sunshine/sunshine.conf`: capture, output, and session commands. A yadm
  alternate: `##default` for all machines, `##hostname.archlinux` adds NVENC tuning.
- `~/.config/sunshine/apps.json`: Moonlight applications and Steam launcher.
- `~/.local/bin/sunshine-session`: creates the output, moves workspace `sunshine`
  to it, places Steam Big Picture there, then removes the output and restores
  previous focus when the session is quit.
- `~/.config/hypr/monitors.lua`: the independent 4K monitor definition. A yadm
  alternate: `##default` for all machines, `##hostname.archlinux` adds that host's
  DP-1/HDMI-A-1 mirror layout.

The `sunshine` output exists only during a session: Sunshine's global prep command
creates it when a Moonlight session starts and removes it when the session is
quit. Outside streaming there is no hidden display and no extra workspaces.

Steam is launched in its own systemd scope so restarting Sunshine does not stop
Steam or its games. Workspace placement uses startup commands, not Steam-specific
Hyprland window or workspace rules. Quitting the session in Moonlight removes
the output; the next session recreates it. Merely disconnecting without quitting
keeps the output available for resuming the session.

## System package prerequisite

For NVIDIA, use the CUDA-enabled upstream LizardByte package. The Omarchy build
`2026.516.143833-4` omitted Sunshine's CUDA conversion code and failed with
`Couldn't scale frame: Invalid argument` when using Wayland + NVENC.

`/etc/pacman.conf` is outside this home-directory yadm repository. On a new
machine, add the upstream repository **before `[omarchy]`**, preserving the other
repositories and options:

```ini
[lizardbyte]
SigLevel = Optional
Server = https://github.com/LizardByte/pacman-repo/releases/latest/download

[omarchy]
Server = https://pkgs.omarchy.org/stable/$arch
```

Install `lizardbyte/sunshine` through pacman as part of a normal system update:

```sh
sudo pacman -Syu lizardbyte/sunshine
```

Repository order makes future normal updates prefer upstream Sunshine. Check
`pacman -Si sunshine`: its first repository should be `lizardbyte`.
Install the driver and encoding support appropriate to each machine's GPU.
For AMD this is normally Mesa with its VAAPI driver; NVIDIA uses the NVIDIA
driver. The full CUDA development toolkit was not needed to run the upstream
binary on the NVIDIA machine. The upstream package can be used on either GPU
vendor; GPU drivers and pacman repository configuration are local system setup,
not automatically applied by these dotfiles.

Related packaging bug: https://github.com/omacom/omarchy/issues/7752

## After restoring the dotfiles

These files assume this user's Omarchy/Hyprland Lua configuration loads
`hypr.monitors`. Sunshine's commands currently use `/home/andreas`; adjust those
paths in `sunshine.conf` and `apps.json` if restoring under another username.

```sh
hyprctl reload
hyprctl configerrors
yadm alt
systemctl --user daemon-reload
systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service
```

Restart the service to apply settings if it was already running. An older Steam
instance launched inside Sunshine's service group should be exited first.

Pair Moonlight with Sunshine, then select **Steam Big Picture**. Client video
resolution is configured in Moonlight independently of the 4K host display.
Start at 60 FPS to match the virtual display's refresh rate.

Pairings, credentials, logs, and backup files are machine-local and are not part
of these tracked configuration files.
