defmodule Hydra.IntrospectResponse do
  defstruct [:name, :client_id, :sub, :exp, :iat, :iss, :token_type]

  @type t :: %Hydra.IntrospectResponse{
          name: String.t(),
          client_id: String.t(),
          sub: String.t(),
          exp: integer,
          iat: integer,
          iss: String.t(),
          token_type: String.t()
        }
end
