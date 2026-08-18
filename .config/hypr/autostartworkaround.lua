local M = {}

local workspace_apps = {
  {
    command = 'xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"',
    classes = { "kitty" },
    match = "(?i)^kitty$",
    workspace = "1",
  },
  {
    command = "zen-browser",
    classes = { "zen" },
    match = "(?i)^zen$",
    workspace = "2",
  },
  {
    command = "uwsm app -- nautilus --new-window",
    classes = { "org.gnome.nautilus", "nautilus" },
    match = "(?i)^(org[.]gnome[.]nautilus|nautilus)$",
    workspace = "4",
  },
  {
    command = "uwsm app -- chatgpt",
    classes = { "chatgpt", "codex" },
    match = "(?i)^(chatgpt|codex)$",
    workspace = "5",
  },
}

for _, app in ipairs(workspace_apps) do
  app.rule = hl.window_rule({
    name = "manual-workspace-" .. app.workspace,
    enabled = false,
    match = { initial_class = app.match },
    workspace = app.workspace,
  })
end

local active_subscription

function M.launch()
  if #workspace_apps == 0 then
    return
  end

  if active_subscription then
    active_subscription:remove()
    active_subscription = nil
  end

  local pending = {}
  for _, app in ipairs(workspace_apps) do
    app.rule:set_enabled(true)
    for _, class in ipairs(app.classes) do
      pending[class] = app
    end
  end

  active_subscription = hl.on("window.open", function(window)
    local app = pending[window.initial_class:lower()]
    if not app then
      return
    end

    app.rule:set_enabled(false)
    for _, class in ipairs(app.classes) do
      pending[class] = nil
    end

    if next(pending) == nil then
      active_subscription:remove()
      active_subscription = nil
    end
  end)

  for _, app in ipairs(workspace_apps) do
    hl.exec_cmd(app.command)
  end
end

return M
