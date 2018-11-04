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

  @spec consent(String.t()) :: any()
  def consent(consent) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.get("/oauth2/auth/requests/consent/#{consent}", [])

    body
  end

  @spec consent_accept(String.t(), any()) :: any()
  def consent_accept(consent, body) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.put("/oauth2/auth/requests/consent/#{consent}/accept", body, [])

    body
  end

  @spec challenge_accept(String.t(), any()) :: any()
  def challenge_accept(challenge, body) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.put("/oauth2/auth/requests/login/#{challenge}/accept", body, [])

    body
  end

  @spec challenge(String.t()) :: any()
  def challenge(challenge) do
    {:ok, %HTTPoison.Response{body: body}} = Admin.get("/oauth2/auth/requests/login/#{challenge}")
    body
  end

  @spec introspect(String.t(), any()) :: Hydra.IntrospectResponse
  def introspect(token, _scope) do
    {:ok, %HTTPoison.Response{body: body}} =
      Admin.post("/oauth2/introspect", {:form, [token: token]}, [
        {"Content-Type", "application/x-www-form-urlencoded"}
      ])

    body
  end
end
