defmodule Hashcash do

  @type hash_algorithms :: :sha256 | :sha384 | :sha512

  alias Hashcash.Proof

  @doc """
  Finds a proof that contains a hash and nonce. The hash must be less than or
  equal to target
  """
  @spec find_proof(binary, number, hash_algorithms, integer) :: Proof.t
  def find_proof(data, target, hash_algo, nonce \\ 0) do
    hash = :crypto.hash(hash_algo, "#{data}#{nonce}") |> Base.encode16

    case is_hash_less_than_target(hash, target) do
      true -> %Proof{
        hash: hash,
        nonce: nonce
      }
      _ -> find_proof(data, target, hash_algo, nonce + 1)
    end
  end

  @doc """
  Verifies proof against target
  """
  @spec verify_proof(Proof.t, number) :: boolean
  def verify_proof(%Proof{hash: hash}, target) do
    is_hash_less_than_target(hash, target)
  end

  @doc """
  Generates a target number with leading zeros at bit length. For example,
  given 4 leading zeros and bit length of 64 bits, the function will generate a integer
  (target) thats 281474976710655, hex format: 0000FFFFFFFFFFFF
  """
  @spec generate_target(integer, integer) :: number
  def generate_target(zero_count, bit_length) do
    pow2(bit_length - zero_count * 4) - 1
  end

  def target_to_hex(target, bit_length) do
    hex_length = div(bit_length, 4)
    to_string(:io_lib.format("~#{hex_length}.16.0B", [target]))
  end

  @spec pow2(number) :: integer
  defp pow2(n), do: round(:math.pow(2, n))

  @spec is_hash_less_than_target(String.t, number) :: boolean
  defp is_hash_less_than_target(hash, target) do
    {n, _} = Integer.parse(hash, 16)
    n < target
  end
end
