defmodule KejaDigital.Release do
  @app :keja_digital

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(
          repo,
          &Ecto.Migrator.run(&1, :up, all: true)
        )
    end
  end

  def seed_doors do
    load_app()

    alias KejaDigital.Repo
    alias KejaDigital.Store.DoorNumber

    door_numbers = [
      %{number: "Door 01", occupied: false},
      %{number: "Door 02", occupied: false},
      %{number: "Door 03", occupied: false},
      %{number: "Door 04", occupied: false},
      %{number: "Door 05", occupied: false},
      %{number: "Door 06", occupied: false},
      %{number: "Door 07", occupied: false},
      %{number: "Door 08", occupied: false},
      %{number: "Door 09", occupied: false},
      %{number: "Door 10", occupied: false}
    ]

    Enum.each(door_numbers, fn door_number ->
      case Repo.get_by(DoorNumber, number: door_number.number) do
        nil ->
          DoorNumber.changeset(%DoorNumber{}, door_number)
          |> Repo.insert!()

        _existing_door ->
          :already_exists
      end
    end)
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(
        repo,
        &Ecto.Migrator.run(&1, :down, to: version)
      )
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
