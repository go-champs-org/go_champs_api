defmodule GoChampsApi.Infrastructure.RabbitMQ do
  alias GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor
  use GenServer
  require Logger

  @retry_exchange "retry-exchange"

  @queue "game-events-live-mode"

  @accepted_sender "go-champs-scoreboard"
  @max_retries 5

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
            AMQP.Basic.consume(chan, @queue)
            Logger.info("Started consuming from main queue: #{@queue}")

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

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, headers: headers}}, state) do
    decoded_payload = Poison.decode!(payload)
    accepted_env = System.get_env("APP_ENV") || "development"

    # Get retry count from headers
    retry_count = get_retry_count_from_headers(headers)

    if decoded_payload["metadata"]["sender"] == @accepted_sender &&
         decoded_payload["metadata"]["env"] == accepted_env do
      Logger.info("Received message from accepted sender (attempt #{retry_count + 1})")

      case GameEventsLiveModeProcessor.process(decoded_payload) do
        :ok ->
          AMQP.Basic.ack(state.channel, tag)
          Logger.info("Message processed successfully")

        :error ->
          if retry_count >= @max_retries do
            # Max retries reached - send to dead letter queue
            AMQP.Basic.reject(state.channel, tag, requeue: false)
            Logger.warn("Message sent to dead letter queue after #{@max_retries} attempts")
          else
            # Schedule retry with exponential backoff
            next_retry = retry_count + 1
            delay_ms = calculate_backoff_delay(next_retry)

            # Acknowledge original message
            AMQP.Basic.ack(state.channel, tag)

            # Add retry count to headers
            new_headers = update_retry_headers(headers, next_retry)

            # Publish to retry queue with TTL
            AMQP.Basic.publish(
              state.channel,
              @retry_exchange,
              "game-events-live-mode-retry-#{next_retry}",
              payload,
              persistent: true,
              expiration: "#{delay_ms}",
              headers: new_headers
            )

            Logger.info(
              "Message scheduled for retry in #{delay_ms}ms. Attempt: #{next_retry}/#{@max_retries}"
            )
          end
      end

      {:noreply, state}
    else
      Logger.info("Received message from unaccepted sender")
      :ok = AMQP.Basic.reject(state.channel, tag, requeue: false)
      {:noreply, state}
    end
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
    {:noreply, channel}
  end

  # Calculate exponential backoff delay (in milliseconds)
  defp calculate_backoff_delay(retry) do
    # Base delay of 1 second with exponential increase
    # 1s, 2s, 4s, 8s, 16s
    (:math.pow(2, retry - 1) * 1000) |> round()
  end

  # Extract retry count from headers
  defp get_retry_count_from_headers(nil), do: 0

  defp get_retry_count_from_headers(headers) when is_list(headers) do
    case List.keyfind(headers, "x-retry-count", 0) do
      {"x-retry-count", :long, count} -> count
      _ -> 0
    end
  end

  defp get_retry_count_from_headers(_), do: 0

  # Update retry count in headers
  defp update_retry_headers(nil, retry_count), do: [{"x-retry-count", :long, retry_count}]

  defp update_retry_headers(headers, retry_count) when is_list(headers) do
    headers
    |> List.keydelete("x-retry-count", 0)
    |> List.keystore("x-retry-count", 0, {"x-retry-count", :long, retry_count})
  end
end
