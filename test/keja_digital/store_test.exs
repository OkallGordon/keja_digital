defmodule KejaDigital.Store.UserTest do
  use KejaDigital.DataCase, async: true
  alias KejaDigital.Store.User

  @valid_attrs %{
    email: "test@gmail.com",
    password: "valid_password123",
    full_name: "John Smith Doe",
    postal_address: "P.O Box 123",
    phone_number: "0712345678",
    nationality: "Kenyan",
    organization: "Test Org",
    next_of_kin: "Jane Doe",
    next_of_kin_contact: "0787654321",
    passport: "ABC123456",
    door_number: "A-123"
  }

  describe "user registration_changeset/3" do
    test "requires email and password" do
      attrs = Map.drop(@valid_attrs, [:email, :password])
      changeset = User.registration_changeset(%User{}, attrs)
      assert %{email: ["can't be blank"], password: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates email format" do
      attrs = Map.put(@valid_attrs, :email, "invalid")
      changeset = User.registration_changeset(%User{}, attrs)
      assert "must have the @ sign and no spaces" in errors_on(changeset).email

      attrs = Map.put(@valid_attrs, :email, "test@hotmail.com")
      changeset = User.registration_changeset(%User{}, attrs)
      assert "must be a valid email from Gmail or Yahoo" in errors_on(changeset).email
    end

    test "validates password length" do
      attrs = Map.put(@valid_attrs, :password, "short")
      changeset = User.registration_changeset(%User{}, attrs)
      assert "should be at least 12 character(s)" in errors_on(changeset).password
    end

    test "validates full name format" do
      attrs = Map.put(@valid_attrs, :full_name, "john smith")
      changeset = User.registration_changeset(%User{}, attrs)
      assert "must start with a capital letter and contain 2 or 3 names" in errors_on(changeset).full_name
    end

    test "validates phone number format" do
      attrs = Map.put(@valid_attrs, :phone_number, "12345")
      changeset = User.registration_changeset(%User{}, attrs)
      errors = errors_on(changeset).phone_number
      assert "must be a valid Safaricom phone number" in errors
    end

    test "validates door number format" do
      attrs = Map.put(@valid_attrs, :door_number, "123")
      changeset = User.registration_changeset(%User{}, attrs)
      assert "must be in format like A-123" in errors_on(changeset).door_number
    end

    test "validates passport length" do
      attrs = Map.put(@valid_attrs, :passport, "12345")
      changeset = User.registration_changeset(%User{}, attrs)
      assert "Your passport number is too short" in errors_on(changeset).passport
    end

    test "creates valid changeset with valid attributes" do
      changeset = User.registration_changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end
  end

  describe "email_changeset/3" do
    test "validates email format" do
      changeset = User.email_changeset(%User{email: "old@gmail.com"}, %{email: "new@yahoo.com"})
      assert changeset.valid?

      changeset = User.email_changeset(%User{email: "old@gmail.com"}, %{email: "invalid"})
      refute changeset.valid?
    end

    test "requires email to change" do
      changeset = User.email_changeset(%User{email: "test@gmail.com"}, %{email: "test@gmail.com"})
      assert "did not change" in errors_on(changeset).email
    end
  end

  describe "password_changeset/3" do
    test "validates password length" do
      changeset = User.password_changeset(%User{}, %{password: "short"})
      assert "should be at least 12 character(s)" in errors_on(changeset).password
    end

    test "hashes password" do
      changeset = User.password_changeset(%User{}, %{password: "valid_password123"})
      assert changeset.changes.hashed_password
      assert get_change(changeset, :password) == nil
    end
  end
end
defmodule KejaDigital.Store.UserTokenTest do
  use KejaDigital.DataCase, async: true
  alias KejaDigital.Store.{UserToken, User}
  alias KejaDigital.Repo

  setup do

    user_attrs = %{
      email: "test@gmail.com",
      password: "valid_password123",
      full_name: "John Alexander Doe",
      postal_address: "P.O Box 123",
      phone_number: "0712345678",
      nationality: "Kenyan",
      organization: "Test Org",
      next_of_kin: "Jane Elizabeth Doe",
      next_of_kin_contact: "0787654321",
      passport: "ABC123456",
      door_number: "A-123"
    }

    {:ok, user} = %User{}
    |> User.registration_changeset(user_attrs)
    |> Repo.insert()

    %{user: user}
  end

  describe "build_session_token/1" do
    test "generates a token with user id", %{user: user} do
      {token, user_token} = UserToken.build_session_token(user)

      assert is_binary(token)
      assert user_token.token == token
      assert user_token.context == "session"
      assert user_token.user_id == user.id
    end
  end

  describe "build_email_token/2" do
    test "builds token and its hash", %{user: user} do
      {token, user_token} = UserToken.build_email_token(user, "confirm")

      assert is_binary(token)
      assert is_binary(user_token.token)
      assert user_token.context == "confirm"
      assert user_token.sent_to == user.email
      assert user_token.user_id == user.id
    end
  end

  describe "verify_email_token_query/2" do
    test "returns error with invalid token" do
      assert :error = UserToken.verify_email_token_query("invalid", "confirm")
    end

    test "returns user with valid token", %{user: user} do
      {token, user_token} = UserToken.build_email_token(user, "confirm")
      {:ok, _} = Repo.insert(user_token)  # Use {:ok, _} instead of Repo.insert!

      assert {:ok, retrieved_user} = UserToken.verify_email_token_query(token, "confirm")
      assert retrieved_user.id == user.id
    end
  end

  describe "verify_change_email_token_query/2" do
    test "returns error with invalid token" do
      assert :error = UserToken.verify_change_email_token_query("invalid", "change:current@email.com")
    end

    test "returns user with valid change email token", %{user: user} do
      {token, user_token} = UserToken.build_email_token(user, "change:new@email.com")
      {:ok, _} = Repo.insert(user_token)  # Use {:ok, _} instead of Repo.insert!

      assert {:ok, query} = UserToken.verify_change_email_token_query(token, "change:new@email.com")
      assert %Ecto.Query{} = query
    end
  end

  describe "verify_session_token_query/1" do
    test "returns user with valid session token", %{user: user} do
      {token, user_token} = UserToken.build_session_token(user)
      {:ok, _} = Repo.insert(user_token)  # Use {:ok, _} instead of Repo.insert!

      assert {:ok, query} = UserToken.verify_session_token_query(token)
      assert %Ecto.Query{} = query
    end
  end
end
