defmodule KejaDigital.Store.UserToken do
  use Ecto.Schema
  import Ecto.Query
  alias KejaDigital.Store.UserToken
  alias KejaDigital.Repo

  @hash_algorithm :sha256
  @rand_size 32

  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, KejaDigital.Store.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days
  defp days_for_context(_), do: nil  # Catch invalid contexts

  def verify_email_token_query(token, context) do
    IO.inspect(token, label: "Raw Token Received")

    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        IO.inspect(decoded_token, label: "Decoded Token")

        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        IO.inspect(hashed_token, label: "Hashed Token")

        days = days_for_context(context)
        IO.inspect(days, label: "Validity Days for Context")

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day"),
            select: user

        IO.inspect(Repo.all(query), label: "Query Results Before Match Check")

        case Repo.one(query) do
          nil ->
            IO.puts("No matching token found in DB. Token: #{inspect(hashed_token)}, Context: #{inspect(context)}")
            :error
          user ->
            IO.puts("Token verified successfully!")
            {:ok, user}  # Return the user, not the query
        end

      :error ->
        IO.puts("Token decoding failed!")
        :error
    end
  end

  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day"),
            select: user

        IO.inspect(Repo.all(query), label: "Change Email Token Query Results")

        case Repo.one(query) do
          nil ->
            IO.puts("Change email token validation failed!")
            :error
          _user ->
            IO.puts("Change email token verified successfully!")
            {:ok, query}  # Changed from {:ok, user}
        end

      :error ->
        IO.puts("Change email token decoding failed!")
        :error
    end
  end

  def by_token_and_context_query(token, context) do
    IO.inspect({token, context}, label: "Looking Up Token in DB")
    from UserToken, where: [token: ^token, context: ^context]
  end

  def by_user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
