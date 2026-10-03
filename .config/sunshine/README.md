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
- `~/.local/bin/sunshine-session`: compatibility wrapper for the package-owned
  `/usr/bin/omarchy-pondhouse-sunshine-session`. The helper creates the output,
  moves workspace `sunshine` to it, places Steam Big Picture there, then removes
  the output and restores previous focus when the session is quit.
- `/usr/lib/systemd/user/app-dev.lizardbyte.app.Sunshine.service.d/display-ready.conf`:
  supplied by `pondhouse-omarchy`, not yadm. It waits for a usable Hyprland/Wayland
  output before starting Sunshine and cleans up helper-owned streaming sessions
  on service stop, restart or crash.
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

## Startup readiness and sleeping screens

Sunshine checks the Wayland output list once when initializing its capture
backend. If it starts during login before any output is exposed, it keeps serving
the web UI but every launch fails with error 503 until the service is restarted.
The distribution service's fixed five-second sleep did not prevent this on
`phd-an-office` (27 September 2026).

The package-owned systemd drop-in replaces that sleep with
`/usr/bin/omarchy-pondhouse-sunshine-session wait-ready`:
the Wayland socket must exist and Hyprland must report usable, stable outputs.
It waits up to 60 seconds; on failure systemd retries via the vendor service's
restart policy instead of leaving a running server with a broken capture backend.
This gate does not create a virtual monitor or wake the physical display.
It assumes a connected monitor exposed by Hyprland, which may be DPMS asleep;
fully unplugged/headless startup is not provided by this configuration.

On stream launch, the encoder preflight can use the existing physical output;
the prep command then creates the dedicated `sunshine` output for capture and
wakes only that output. Previously the virtual monitor inherited DPMS-off from
the sleeping office screen. Quit the app/session in Moonlight to remove it;
disconnect-with-resume intentionally retains it. Failed preparation and service
stop/restart also clean up the output. Saved focus is captured before creation.
Service cleanup runs only when this helper's saved session state exists, so it
does not remove an unrelated output also named `sunshine`.

The original shared hotfix was verified on 27 September 2026:

- The same authenticated office `/launch` request returned 503 before recovery
  and 200 afterward. With the shared drop-in installed, a real Moonlight Desktop
  stream used the 4K `sunshine` capture output and AMD VAAPI, delivered at 1080p60
  (60.86 FPS received/decoded, 59.12 FPS rendered). Quit removed the output.
- Local NVIDIA startup found NVENC; local prepare created an awake independent
  4K output. On both hosts, service restart removed the temporary output and
  restarted successfully without creating another one.
- The readiness gate rejects an empty monitor list and accepts the live desktop.
  Cold reboot has not been exercised; the persistent drop-in is loaded and the
  service remains enabled on both machines.

## System package prerequisite

Install `pondhouse-omarchy` version `2026.10.03-1` or newer before restoring these
dotfiles. It owns the session helper and readiness drop-in. The package migration
backs up and replaces the recognized legacy helper and removes the recognized
user-level hotfix. Do not restore the old
`~/.config/systemd/user/app-dev.lizardbyte.app.Sunshine.service.d/display-ready.conf`:
that file would override the package-owned drop-in.

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
