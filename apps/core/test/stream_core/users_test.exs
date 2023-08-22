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

  describe "add_follower/1" do
    test "follows streamer successfully" do
      user_follower = insert(:user)
      user_streamer = insert(:user)

      assert {:ok, follower} =
               Users.add_follower(%{
                 follower_id: user_follower.id,
                 streamer_id: user_streamer.id
               })

      assert equals(follower.follower_id, user_follower.id)
      assert equals(follower.streamer_id, user_streamer.id)
    end

    test "does not follows streamer if it does not exists" do
      user_follower = insert(:user)

      assert {:error, _} =
               Users.add_follower(%{
                 follower_id: user_follower.id,
                 streamer_id: 99_999
               })
    end
  end

  describe "remove_follower/1" do
    test "unfollows streamer successfully" do
      follower = insert(:follower)

      assert {:ok, _} =
               Users.remove_follower(%{
                 follower_id: follower.follower_id,
                 streamer_id: follower.streamer_id
               })
    end

    test "does not unfollows streamer if it does not exists" do
      follower = insert(:follower)

      assert {:error, :not_found} =
               Users.remove_follower(%{
                 follower_id: follower.follower_id,
                 streamer_id: 99_999
               })
    end
  end

  describe "toggle_follower/1" do
    test "add follows streamer successfully" do
      user_follower = insert(:user)
      user_streamer = insert(:user)

      assert {:ok, _} =
               Users.toggle_follower(%{
                 follower_id: user_follower.id,
                 streamer_id: user_streamer.id
               })
    end

    test "remove follows streamer successfully" do
      follower = insert(:follower)

      assert {:ok, _} =
               Users.toggle_follower(%{
                 follower_id: follower.follower_id,
                 streamer_id: follower.streamer_id
               })
    end

    test "toggle follows streamer successfully" do
      user_follower = insert(:user)
      user_streamer = insert(:user)

      assert {:ok, _} =
               Users.toggle_follower(%{
                 follower_id: user_follower.id,
                 streamer_id: user_streamer.id
               })

      assert {:ok, _} =
               Users.toggle_follower(%{
                 follower_id: user_follower.id,
                 streamer_id: user_streamer.id
               })

      assert {:error, :not_found} =
               Users.remove_follower(%{
                 follower_id: user_follower.id,
                 streamer_id: user_streamer.id
               })
    end

    test "does not unfollows streamer if it does not exists" do
      user_follower = insert(:user)

      assert {:error, _} =
               Users.toggle_follower(%{
                 follower_id: user_follower.id,
                 streamer_id: 99_999
               })
    end
  end
end
