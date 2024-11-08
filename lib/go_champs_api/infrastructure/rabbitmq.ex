defmodule GoChampsApi.Infrastructure.RabbitMQ do
  use GenServer
  require Logger

  @exchange "game-events"
  @queue "game-events"
  @routing_key "game-events"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    case AMQP.Connection.open(
           Application.get_env(:go_champs_api, GoChampsApi.Infrastructure.RabbitMQ)
         ) do
      {:ok, conn} ->
        case AMQP.Channel.open(conn) do
          {:ok, chan} ->
            AMQP.Queue.declare(chan, @queue, durable: true)
            Logger.info("Connected to RabbitMQ")
            {:ok, %{channel: chan}}

          {:error, reason} ->
            Logger.error("Failed to open channel: #{inspect(reason)}")
            {:stop, reason}
        end

      {:error, reason} ->
        Logger.error("Failed to open connection: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  def publish(message) do
    GenServer.call(__MODULE__, {:publish, message})
  end

  def handle_call({:publish, message}, _from, %{channel: chan} = state) do
    AMQP.Basic.publish(chan, @exchange, @routing_key, message)
    {:reply, :ok, state}
  end
end
