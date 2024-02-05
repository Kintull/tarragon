defmodule Tarragon.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Comeonin.Bcrypt

  alias Tarragon.Accounts.UserCharacter

  @type t :: %__MODULE__{}

  schema "users" do
    field :email, :string
    field :name, :string
    field :is_bot, :boolean
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :characters, UserCharacter

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :is_bot])
    |> validate_required([:name, :email, :password])
    |> hash_password()
  end

  defp hash_password(changeset) do
    case changeset do
      %{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end
