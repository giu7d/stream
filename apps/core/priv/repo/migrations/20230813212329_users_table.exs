defmodule StreamCore.Repo.Migrations.UsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string, null: false)
      add(:email, :string, null: false)
      add(:hashed_password, :string, null: false)
      add(:stream_key, :binary)
      timestamps()
    end

    create(unique_index(:users, [:email, :username]))
  end
end
