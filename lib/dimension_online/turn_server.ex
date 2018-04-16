defmodule DimensionOnline.TurnServer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end


  ## Callbacks

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  # def init(tick_ms) do
  #   Process.start(self(), tick_ms)
  #
  #   {:ok, tick_ms}
  # end

  # def handle_call(:pop, _from, [h | t]) do
  #   {:reply, h, t}
  # end
  #
  # def handle_cast({:push, h}, t) do
  #   {:noreply, [h | t]}
  # end

  # def handle_info({tick_ms, rabbit_server} = state) do
  #   start_time = Time.utc_now
  #
  #
  #   # for rabbit <- rabbit_server.rabbits do
  #   #   rabbit.tick
  #   # end
  #
  #   process_ms = Time.diff(Time.utc_now, start_time, :millisecond)
  #
  #   if process_ms < tick_ms
  #     Process.sleep(tick_ms - process_ms)
  #   end
  #
  #   schedule_work() # Reschedule once more
  #   {:noreply, state}
  # end

  def handle_info(:work, state) do
    # Do the work you desire here
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 2000) # Every 2 seconds
  end
end
