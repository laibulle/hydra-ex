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
__Config__

```
config :hydra,
  admin_url: "${HYDRA_ADMIN_URL}",
  auth_url: "${ISSUER}",
  client_id: "${HYDRA_CLIENT_ID}",
  client_secret: "${HYDRA_CLIENT_SECRET}"
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

__Consent controller__

```
defmodule MyAppWeb.ConsentController do
  use MyAppWeb, :controller
  alias Hydra.Admin

  def index(conn, params) do
    consent_challenge = params["consent_challenge"]

    case Admin.consent(consent_challenge) do
      %{"skip" => true} ->
        accept_consent(conn, consent_challenge, %{})

      %{"skip" => false} ->
        accept_consent(conn, consent_challenge, %{})
    end

    Admin.consent_accept(consent_challenge, %{})
    render(conn, "new.html")
  end

  def accept_consent(conn, challenge, params) do
    %{"redirect_to" => redirect_to} = Admin.consent_accept(challenge, params)
    redirect(conn, external: redirect_to)
  end
end

```

__Login controller__
```
defmodule MyAppWeb.LoginController do
  use MyAppWeb, :controller
  alias Hydra.Admin
  alias MyAppWeb.Repo
  alias MyAppWeb.Auth.User
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def index(conn, params) do
    login_challenge = params["login_challenge"]

    case Admin.challenge(login_challenge) do
      %{"skip" => true, "subject" => subject} ->
        accept_challenge(conn, login_challenge, %{"subject" => subject})

      %{"skip" => false} ->
        render(conn, "new.html", changeset: %{:login_challenge => login_challenge})
    end
  end

  def create(conn, %{"session" => params}) do
    user = Repo.get_by(User, email: params["email"])

    result =
      cond do
        # if user was found and provided password hash equals to stored
        # hash
        user && checkpw(params["password"], user.password_hash) ->
          {:ok, conn}

        # else if we just found the use
        user ->
          {:error, :unauthorized, conn}

        # otherwise
        true ->
          # simulate check password hash timing
          dummy_checkpw()
          {:error, :not_found, conn}
      end

    case result do
      {:ok, conn} ->
        accept_challenge(conn, params["login_challenge"], %{"subject" => "#{user.id}"})

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html", changeset: %{:login_challenge => params["login_challenge"]})
    end
  end

  defp accept_challenge(conn, challenge, params) do
    %{"redirect_to" => redirect_to} = Admin.challenge_accept(challenge, params)
    redirect(conn, external: redirect_to)
  end
end
```