defmodule Hydra.Admin do
  use HTTPoison.Base
  alias Hydra.Admin

  def process_request_url(url) do
    Application.get_env(:hydra, :admin_url) <> url
  end

  def process_response_body(body), do: body |> Poison.decode!()

  def process_request_body({:form, data}), do: {:form, data}

  def process_request_body(body), do: Poison.encode!(body)

  def process_request_headers([]), do: [{"Content-Type", "application/json"}]

  def process_request_headers(headers), do: headers

  def consent(consent) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.get("/oauth2/auth/requests/consent/#{consent}", [])

    body
  end

  @spec consent_accept(any(), any()) :: any()
  def consent_accept(consent, body) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.put("/oauth2/auth/requests/consent/#{consent}/accept", body, [])

    body
  end

  def challenge_accept(challenge, body) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.put("/oauth2/auth/requests/login/#{challenge}/accept", body, [])

    body
  end

  def challenge(challenge) do
    {:ok, %HTTPoison.Response{body: body}} = Admin.get("/oauth2/auth/requests/login/#{challenge}")
    body
  end

  #   {
  #     "active": true,
  #     "client_id": "web-client",
  #     "sub": "1",
  #     "exp": 1540768377,
  #     "iat": 1540764777,
  #     "iss": "http://localhost:4444/",
  #     "token_type": "access_token"
  # }

  def introspect(token, _scope) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.post("/oauth2/introspect", {:form, [token: token]}, [
        {"Content-Type", "application/x-www-form-urlencoded"}
      ])

    body
  end

  # %{
  #   "challenge" => "5be3dccf45704e81b81c427a4bc715e7",
  #   "client" => %{
  #     "allowed_cors_origins" => [],
  #     "client_id" => "auth-code-client",
  #     "client_name" => "",
  #     "client_secret_expires_at" => 0,
  #     "client_uri" => "",
  #     "contacts" => [],
  #     "grant_types" => ["authorization_code", "refresh_token"],
  #     "jwks" => %{"keys" => nil},
  #     "logo_uri" => "",
  #     "owner" => "",
  #     "policy_uri" => "",
  #     "redirect_uris" => ["http://127.0.0.1:4000/callback"],
  #     "response_types" => ["code", "id_token"],
  #     "scope" => "openid offline",
  #     "subject_type" => "public",
  #     "token_endpoint_auth_method" => "client_secret_basic",
  #     "tos_uri" => "",
  #     "userinfo_signed_response_alg" => "none"
  #   },
  #   "oidc_context" => %{},
  #   "request_url" => "http://localhost:4444/oauth2/auth?client_id=auth-code-client&response_type=code&state=12345678",
  #   "requested_scope" => [],
  #   "session_id" => "",
  #   "skip" => false,
  #   "subject" => ""
  # }
end
