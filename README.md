# Hydra client for Elixir

__mix.exs__

```elixir
  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MyApp.Application, [:hydra]},
      ...
    ]
  end

  {:hydra, git: "https://github.com/laibulle/hydra-ex.git", tag: "master"}
```


__Plug__


```elixir
defmodule MyAppWeb.HydraPipeline do
  import Plug.Conn
  alias Hydra.Admin
  alias MyAppWeb.Auth

  def init(default), do: default

  def call(conn, _default) do
    case get_req_header(conn, "authorization") do
      [] -> conn
      [authorization] -> authenticate(conn, authorization)
    end
  end

  defp authenticate(conn, "Bearer " <> token) do
    case Admin.introspect(token, []) do
      %{"active" => false} ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(401, Poison.encode!(%{"errors" => [%{"message" => "unauthorized"}]}))
        |> halt()

      %{"active" => true, "sub" => sub} ->
        {user_id, ""} = Integer.parse(sub)
        user = Auth.get_user!(user_id)

        conn
        |> assign(:current_user, user)
    end
  end
end

```