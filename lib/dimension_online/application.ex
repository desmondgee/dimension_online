defmodule DimensionOnline.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: DimensionOnline.PubSub},
      # Start the Ecto repository
      DimensionOnline.Repo,
      # Start the endpoint when the application starts
      DimensionOnlineWeb.Endpoint,
      # Start your own worker by calling: DimensionOnline.Worker.start_link(arg1, arg2, arg3)
      # worker(DimensionOnline.Worker, [arg1, arg2, arg3]),
      DimensionOnline.TurnServer,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DimensionOnlineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
