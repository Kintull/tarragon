defmodule TarragonWeb.Storybook do
  use PhoenixStorybook,
    otp_app: :tarragon_web,
    content_path: Path.expand("../../storybook", __DIR__),
    # assets path are remote path, not local file-system paths
    css_path: "/assets/app.css",
    js_path: "/assets/app.js",
    sandbox_class: "tarragon-web",
    compilation_mode: :eager
end
