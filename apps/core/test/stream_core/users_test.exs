defmodule StreamCore.UsersTest do
  alias StreamCore.Users.UserToken
  alias StreamCore.Users.User
  alias StreamCore.Users

  use StreamCoreWeb.ConnCase

  import StreamCore.Mocks
  import StreamCore.Factories
  import StreamCore.Helpers

  #
  # Users
  #
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

  describe "update_user/1" do
    test "update user email successfully" do
      user = insert(:user)
      new_user_email = gen_email()

      assert {:ok, updated_user} = Users.update_user(user, %{email: new_user_email})

      assert equals(updated_user.email, new_user_email)
    end

    test "update username successfully" do
      user = insert(:user)
      new_username = gen_username()

      assert {:ok, updated_user} = Users.update_user(user, %{username: new_username})

      assert equals(updated_user.username, new_username)
    end

    test "does not update user email if format is invalid" do
      user = insert(:user)
      assert {:error, _} = Users.update_user(user, %{email: "invalid_email"})
    end

    test "does not update username if format is invalid" do
      user = insert(:user)
      assert {:error, _} = Users.update_user(user, %{username: ""})
    end

    test "does not update password" do
      user = insert(:user)
      assert {:ok, updated_user} = Users.update_user(user, %{password: "wrong_password"})
      assert User.valid_password?(updated_user, "valid_password")
    end
  end

  describe "update_user_password/1" do
    test "update password successfully" do
      user = insert(:user)

      assert {:ok, updated_user} =
               Users.update_user_password(user, "valid_password", %{password: "updated_password"})

      assert User.valid_password?(updated_user, "updated_password")
    end

    test "does not update password if it is wrong" do
      user = insert(:user)

      assert {:error, updated_user} =
               Users.update_user_password(user, "wrong_password", %{password: "updated_password"})

      refute User.valid_password?(updated_user, "updated_password")
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

  describe "find_user/2" do
    test "finds user by id successfully" do
      user = insert(:user)
      assert {:ok, result} = Users.find_user(%{id: user.id})
      assert equals(user.id, result.id)
    end

    test "finds user by email successfully" do
      user = insert(:user)
      assert {:ok, result} = Users.find_user(%{email: user.email})
      assert equals(user.id, result.id)
    end

    test "finds user by username successfully" do
      user = insert(:user)
      assert {:ok, result} = Users.find_user(%{username: user.username})
      assert equals(user.id, result.id)
    end

    test "returns error if user not found" do
      insert(:user)
      assert {:error, :not_found} = Users.find_user(%{email: "wrong@mail.com"})
    end
  end

  #
  # Followers
  #
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

  #
  # User Session Tokens
  #
  describe "create_user_session_token/1" do
    test "creates user session token successfully" do
      user = insert(:user)
      assert {:ok, %UserToken{}} = Users.create_user_session_token(user)
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes user session token successfully" do
      token = insert(:user_token)
      assert {:ok, 1} = Users.delete_user_session_token(token.token)
      assert {:error, :not_found} = Users.find_user_by_session_token(token.token)
    end

    test "deletes expired tokens successfully" do
      token = insert(:user_token, %{inserted_at: ~N[2000-01-01 01:00:00.000000]})
      assert {:ok, 1} = Users.delete_user_session_token(token.token)
    end

    test "does not delete tokens if token does not exists" do
      bad_token = gen_token()
      assert {:error, :not_found} = Users.delete_user_session_token(bad_token)
    end
  end

  describe "find_user_by_session_token/2" do
    test "finds user from session token successfully" do
      token = insert(:user_token)
      assert {:ok, %User{}} = Users.find_user_by_session_token(token.token)
    end

    test "does not find user from expired session token" do
      token = insert(:user_token, %{inserted_at: ~N[2000-01-01 01:00:00.000000]})
      assert {:error, :not_found} = Users.find_user_by_session_token(token.token)
    end
  end
end
