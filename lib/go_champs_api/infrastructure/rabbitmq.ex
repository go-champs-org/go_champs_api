defmodule GoChampsApi.Infrastructure.RabbitMQ do
  alias GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor
  use GenServer
  require Logger

  @queue "game-events-live-mode"
  # @queue_error "#{@queue}_error"
  @accepted_sender "go-champs-scoreboard"

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
            {:ok, _} = AMQP.Queue.declare(chan, @queue, durable: true)

            AMQP.Basic.consume(chan, @queue)
            Logger.info("Connected to RabbitMQ")
            {:ok, %{channel: chan}}

          {:error, reason} ->
            Logger.error("Failed to open channel with RabbitMQ: #{inspect(reason)}")
            {:stop, reason}
        end

      {:error, reason} ->
        Logger.error("Failed to open connection with RabbitMQ: #{inspect(reason)}")
        {:ok, %{}}
    end
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, state) do
    decoded_payload = Poison.decode!(payload)
    accepted_env = System.get_env("APP_ENV") || "development"

    if decoded_payload["metadata"]["sender"] == @accepted_sender &&
         decoded_payload["metadata"]["env"] == accepted_env do
      Logger.info("Received message from accepted sender")
      # Temporary solution to avoid duplicate messages
      AMQP.Basic.ack(state.channel, tag)

      case GameEventsLiveModeProcessor.process(decoded_payload) do
        :ok -> Logger.info("Message processed successfully")
        :error -> :ok = AMQP.Basic.reject(state.channel, tag, requeue: true)
      end

      {:noreply, state}
    else
      Logger.info("Received message from unaccepted sender")
      :ok = AMQP.Basic.reject(state.channel, tag, requeue: true)
      {:noreply, state}
    end
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
    {:noreply, channel}
  end
end
