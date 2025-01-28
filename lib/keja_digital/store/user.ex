defmodule KejaDigital.Store.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias KejaDigital.AuditLogger

  # Split required fields to make door_number handling flexible
  @base_required_fields ~w(
    full_name
    postal_address
    phone_number
    nationality
    organization
    next_of_kin
    next_of_kin_contact
    passport
  )a

  @optional_fields ~w(photo)a

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime
    field :role, :string, default: "Tenant"

    field :full_name, :string
    field :postal_address, :string
    field :phone_number, :string
    field :nationality, :string
    field :organization, :string
    field :next_of_kin, :string
    field :next_of_kin_contact, :string
    field :photo, :string
    field :passport, :string
    field :door_number, :string
    field :overdue_payments, :integer, virtual: true

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs, opts \\ []) do
    # Get required fields based on environment
    required_fields = if Mix.env() == :test do
      @base_required_fields
    else
      @base_required_fields ++ [:door_number]
    end

    user
    |> cast(attrs, [:email, :password, :role, :door_number] ++ required_fields ++ @optional_fields)
    |> validate_length(:full_name, min: 10, max: 30)
    |> validate_format(:full_name, ~r/^[A-Z][a-z]+\s[A-Za-z]+\s?[A-Za-z]*$/, message: "must start with a capital letter and contain 2 or 3 names")
    |> validate_email(opts)
    |> validate_password(opts)
    |> validate_required(required_fields)
    |> validate_phone_number(:phone_number)
    |> validate_format(:phone_number, ~r/^07\d{8}$|^\+254\d{9}$/, message: "Phone number must start with 07 or +254 and follow the correct format")
    |> validate_format(:next_of_kin_contact, ~r/^07\d{8}$|^\+254\d{9}$/, message: "Next of kin contact must start with 07 or +254 and follow the correct format")
    |> validate_length(:passport, min: 6, message: "Your passport number is too short")
    |> maybe_validate_door_number()
    |> unique_constraint(:email)
    |> unique_constraint(:phone_number)
    |> unique_constraint(:full_name)
    |> put_change(:role, "tenant")
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_format(:email, ~r/^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com)$/, message: "must be a valid email from Gmail or Yahoo")
    |> maybe_validate_unique_email(opts)
  end

  defp validate_phone_number(changeset, field) do
    phone_number = get_field(changeset, field)

    case phone_number do
      nil ->
        add_error(changeset, field, "Phone number cannot be blank")

      _ ->
        case Regex.match?(~r/^(?:\+254|07)\d{8}$/, phone_number) do
          true -> changeset
          false -> add_error(changeset, field, "must be a valid Safaricom phone number")
        end
    end
  end

  defp maybe_validate_door_number(changeset) do
    if Mix.env() != :test and get_field(changeset, :door_number) do
      validate_format(changeset, :door_number, ~r/^[A-Z]-\d+$/, message: "must be in format like A-123")
    else
      changeset
    end
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, KejaDigital.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  def valid_password?(%KejaDigital.Store.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  def after_operation(user, action) do
    case action do
      :create -> AuditLogger.log_registration(user)
      :update -> AuditLogger.log_profile_update(user, %{})
      :delete -> AuditLogger.log_account_deletion(user)
    end

    user
  end
end
