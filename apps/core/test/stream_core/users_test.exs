defmodule StreamCore.UsersTest do
  alias StreamCore.Users

  use StreamCoreWeb.ConnCase

  import StreamCore.Mocks
  import StreamCore.Factories
  import StreamCore.Helpers

  describe "create_user/1" do
    test "creates user successfully " do
      user_input = gen_user_attributes()
      assert {:ok, _} = Users.create_user(user_input)
    end

    test "does not create user if attribute missing" do
      user_input = gen_user_attributes(%{password: ''})
      assert {:error, _} = Users.create_user(user_input)
    end
  end

  describe "list_users/0" do
    test "lists users successfully" do
      insert(:user)
      assert {:ok, users} = Users.list_users()

      assert users
             |> length()
             |> equals(1)
    end

    test "lists empty array if no users" do
      assert {:ok, []} = Users.list_users()
    end
  end

  describe "delete_user/1" do
    test "delete user successfully" do
      user = insert(:user)
      assert {:ok, _} = Users.delete_user(user)
      assert {:ok, []} = Users.list_users()
    end
  end

  describe "find_user_by/1" do
    test "finds user by id successfully" do
      user = insert(:user)
      assert {:ok, result} = Users.find_user_by(%{id: user.id})
      assert equals(user.id, result.id)
    end

    test "finds user by email successfully" do
      user = insert(:user)
      assert {:ok, result} = Users.find_user_by(%{email: user.email})
      assert equals(user.id, result.id)
    end

    test "finds user by username successfully" do
      user = insert(:user)
      assert {:ok, result} = Users.find_user_by(%{username: user.username})
      assert equals(user.id, result.id)
    end

    test "returns error if user not found" do
      insert(:user)
      assert {:error, :not_found} = Users.find_user_by(%{email: "wrong@mail.com"})
    end
  end
end
