defmodule Hydra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    admin_url = Application.get_env(:admin_url, :address, System.get_env("HYDRA_ADMIN_URL"))

    # _httpoison_opts = Application.get_env(:hydra, :httpoison_opts, [])

    config = %{
      admin_url: admin_url
    }

    Agent.start_link(fn -> config end, name: __MODULE__)
  end
end
