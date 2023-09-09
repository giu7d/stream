alias StreamCore.Users.Follower
alias StreamCore.Users.User
alias StreamCore.Repo

user_1 =
  %User{}
  |> User.registration_changeset(%{
    username: "test",
    email: "dev@domain.com",
    password: "password"
  })
  |> Repo.insert!()

user_2 =
  %User{}
  |> User.registration_changeset(%{
    username: "test_2",
    email: "dev2@domain.com",
    password: "password"
  })
  |> Repo.insert!()

%Follower{}
|> Follower.changeset(%{
  follower_id: user_1.id,
  streamer_id: user_2.id
})
|> Repo.insert!()

%Follower{}
|> Follower.changeset(%{
  follower_id: user_2.id,
  streamer_id: user_1.id
})
|> Repo.insert!()
