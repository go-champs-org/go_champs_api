defmodule GoChampsApi.Infrastructure.RabbitMQ do
  use GenServer
  require Logger

  @queue "game-events-live-mode"
  @queue_error "#{@queue}_error"
  @accepted_sender "go-champs-scoreboard"
  @accepted_env System.get_env("APP_ENV")

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
            {:ok, _} = AMQP.Queue.declare(chan, @queue_error, durable: true)
            {:ok, _} = AMQP.Queue.declare(chan, @queue, durable: true)
            # {:ok, _} = AMQP.Queue.declare(chan, @queue, durable: true, arguments: [
            #   {"x-dead-letter-exchange", :longstr, ""},
            #   {"x-dead-letter-routing-key", :longstr, @queue_error}
            # ])

            AMQP.Basic.consume(chan, @queue)
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

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, state) do
    decoded_payload = Poison.decode!(payload)

    if decoded_payload["metadata"]["sender"] == @accepted_sender &&
         decoded_payload["metadata"]["env"] == @accepted_env do
      Logger.info("Received message from accepted sender")
      :ok = AMQP.Basic.ack(state.channel, tag)
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
