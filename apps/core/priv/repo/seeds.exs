alias StreamCore.Users.User
alias StreamCore.Repo

%User{}
|> User.registration_changeset(%{
  username: "test",
  email: "dev@domain.com",
  password: "password"
})
|> Repo.insert!()
