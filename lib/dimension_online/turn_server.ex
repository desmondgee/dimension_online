defmodule DimensionOnline.TurnServer do
  use GenServer

  @turn_ms 2000


  def start_link do
    GenServer.start_link(__MODULE__, %{}, [name: __MODULE__])
  end


  ## Callbacks

  def init(_) do
    DimensionOnline.Repo.delete_all(DimensionOnline.Creature)

    for _x <- (1..20) do
      i = Enum.random(-10..1)
      DimensionOnline.Creature.spawn_rabbit(i)
    end

    Process.send(self(), :process_turn, [])

    {:ok, %{turn: 0}}
  end

  def handle_info(:process_turn, %{turn: turn}) do
    start_time = Time.utc_now
    IO.puts "Processing Turn #{turn} at #{start_time}"

    DimensionOnline.Creature.tick_all(turn)

    process_ms = Time.diff(Time.utc_now, start_time, :millisecond)

    sleep_ms = @turn_ms - process_ms
    sleep_ms = if sleep_ms < 1000, do: 1000, else: sleep_ms
    IO.puts "Next turn will be in #{sleep_ms} milliseconds."
    Process.send_after(self(), :process_turn, sleep_ms)

    # How is the turn geting updated before the next process is run? Race condition?
    {:noreply, %{turn: turn + 1}}
  end
end
