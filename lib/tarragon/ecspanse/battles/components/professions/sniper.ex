defmodule Tarragon.Ecspanse.Battles.Components.Professions.Sniper do
  @moduledoc """
  Character specializes in long range shooting
  """

  use Tarragon.Ecspanse.Battles.Components.Professions.Template,
    state: [
      name: "Sniper",
      type: :sniper,
      image_url:
        "https://aaah0mnbncqtinas.public.blob.vercel-storage.com/SKScbHcpEJ-no-background-7z70SXKTFHbwAwXjHeerSsEYxIrKIV.png"
    ],
    tags: [:sniper]
end
