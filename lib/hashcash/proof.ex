defmodule Hashcash.Proof do

  @type t :: %__MODULE__{
    hash: String.t,
    nonce: integer
  }

  defstruct [
    :hash,
    :nonce
  ]
  
end
