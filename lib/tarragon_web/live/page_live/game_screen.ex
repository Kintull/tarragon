defmodule TarragonWeb.PageLive.GameScreen do
  use TarragonWeb, :live_view

  alias Tarragon.Accounts.UserCharacter

  @compiled_images (fn ->
                      path = "#{File.cwd!()}/priv/static/images/cuts/"
                      files = File.ls!(path)

                      for file <- files, String.ends_with?(file, ".webp") do
                        image_binary = File.read!(path <> file)
                        name = Path.basename(file, ".webp")
                        [_, x, y0] = String.split(name, "_")
                        [y | _] = String.split(y0, "-")

                        {{String.to_integer(x), String.to_integer(y)},
                         Base.encode64(image_binary)}
                      end
                      |> Enum.into(%{})
                    end).()


  def mount(_params, %{"user_id" => user_id}, socket) do
    socket =
      if connected?(socket) do
        viewport_width = socket.private.connect_params["viewport"]["width"]
        viewport_height = socket.private.connect_params["viewport"]["height"]
        {w_tiles, h_tiles, grid_map} = handle_viewport(viewport_width, viewport_height, {10, 10})

        socket =
          case socket.assigns[:show_loading_map_animation] do
            true -> %{socket | assigns: Map.delete(socket.assigns, :show_loading_map_animation)}
            false -> socket
            nil -> socket
          end

        user_character = Tarragon.Accounts.impl().get_character_by_user_id!(user_id)

        socket
        |> assign(:compiled_images, @compiled_images)
        |> assign(:grid_map, grid_map)
        |> assign(:w_tiles, w_tiles)
        |> assign(:h_tiles, h_tiles)
        |> assign(:user_character, user_character)
        |> assign(:user_x, 10)
        |> assign(:user_y, 10)
        |> assign(:tile_size, 48)
      else
        socket
        |> assign(:show_loading_map_animation, true)
        |> assign(:compiled_images, @compiled_images)
        |> assign(:grid_map, %{tiles: []})
        |> assign(:user_character, %UserCharacter{})
        |> assign(:w_tiles, 0)
        |> assign(:h_tiles, 0)
        |> assign(:tile_size, 0)
      end

    {:ok, socket, layout: false}
  end

  def mount(_params, _, socket) do
    {:ok, push_redirect(socket, to: ~p"/login/1")}
  end

  def handle_event("resized", params, socket) do
    IO.inspect("handle_event(resized)")
    %{"width" => viewport_width, "height" => viewport_height} = params
    x = socket.assigns.user_x
    y = socket.assigns.user_y
    {w_tiles, h_tiles, grid_map} = handle_viewport(viewport_width, viewport_height, {x, y})
    socket = assign(socket, :grid_map, grid_map)
    socket = assign(socket, :w_tiles, w_tiles)
    socket = assign(socket, :h_tiles, h_tiles)
    {:noreply, socket}
  end

  def handle_event("change-location", params, socket) do
    %{"x" => x, "y" => y} = params
    x = String.to_integer(x)
    y = String.to_integer(y)
    grid_grid_map = socket.assigns.grid_map

    grid_map =
      calculate_grid_map(socket.assigns.w_tiles, socket.assigns.h_tiles, {x, y}, grid_grid_map)

    socket = assign(socket, :grid_map, grid_map)
    socket = assign(socket, :user_x, x)
    socket = assign(socket, :user_y, y)
    {:noreply, socket}
  end

  def handle_viewport(width, height, {x, y}) do
    w_tiles = div(width, 48)
    h_tiles = div(height, 48)

    max_x_tiles = max_y_tiles = 30

    # make a bit more to hide empty space
    w_tiles = w_tiles + 1
    h_tiles = h_tiles + 1

    # never more than 29 blocks in w or h
    w_tiles = if w_tiles > max_x_tiles, do: max_x_tiles, else: w_tiles
    h_tiles = if h_tiles > max_y_tiles, do: max_y_tiles, else: h_tiles

    grid_map = calculate_grid_map(w_tiles, h_tiles, {x, y})

    {w_tiles, h_tiles, grid_map}
  end

  def calculate_grid_map(w_screen, h_screen, {x, y}, old_grid_map \\ nil) do
    max_x = max_y = 29

    need_recalculate =
      if old_grid_map do
        {x_min, x_max} = old_grid_map.x_range
        {y_min, y_max} = old_grid_map.y_range

        x_relative = (x - x_min) / (x_max - x_min) * 100
        y_relative = (y - y_min) / (y_max - y_min) * 100
        x_relative > 85 or x_relative < 15 or (y_relative > 85 or y_relative < 15)
      else
        true
      end

    if need_recalculate do
      y_range = calculate_range(h_screen, max_y, y)
      x_range = calculate_range(w_screen, max_x, x)

      tiles =
        for y <- y_range do
          for x <- x_range do
            {x, y}
          end
        end

      x_range = {Enum.at(x_range, 0), Enum.at(x_range, -1)}
      y_range = {Enum.at(y_range, 0), Enum.at(y_range, -1)}

      %{tiles: tiles, y_range: y_range, x_range: x_range}
    else
      old_grid_map
    end
  end

  def calculate_range(screen_len, max_index, index) do
    half = div(screen_len, 2)
    is_even = rem(screen_len, 2) == 0

    index =
      cond do
        index < half -> half
        is_even && index > max_index - half + 1 -> max_index - half + 1
        !is_even && index > max_index - half -> max_index - half
        true -> index
      end

    if is_even do
      (index - half)..(index + half - 1)
    else
      (index - half)..(index + half)
    end
  end

  def compile_images do
    files = File.ls!("#{File.cwd!()}/priv/static/images/cuts")

    for file <- files do
      image_binary = File.read!(file)
      name = Path.basename(file, ".webp")
      [_, y, x0] = String.split(name, "_")
      [x] = String.split(x0, "-")

      {{x, y}, Base.encode64(image_binary)}
    end
  end
end
