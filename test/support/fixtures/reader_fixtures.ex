defmodule Garrulus.ReaderFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Garrulus.Reader` context.
  """

  @doc """
  Generate a feed.
  """
  def feed_fixture(attrs \\ %{}) do
    {:ok, feed} =
      attrs
      |> Enum.into(%{
        backoff: 42,
        etag: "some etag",
        guid: "some guid",
        last_failed: ~N[2023-02-20 12:03:00],
        last_fetched: ~N[2023-02-20 12:03:00],
        next_fetch: ~N[2023-02-20 12:03:00],
        title: "some title",
        url: "some url"
      })
      |> Garrulus.Reader.create_feed()

    feed
  end

  @doc """
  Generate a entry.
  """
  def entry_fixture(attrs \\ %{}) do
    {:ok, entry} =
      attrs
      |> Enum.into(%{
        author: "some author",
        description: "some description",
        guid: "some guid",
        link: "some link",
        published: ~N[2023-02-20 12:04:00],
        title: "some title"
      })
      |> Garrulus.Reader.create_entry()

    entry
  end

  @doc """
  Generate a subscription.
  """
  def subscription_fixture(attrs \\ %{}) do
    {:ok, subscription} =
      attrs
      |> Enum.into(%{

      })
      |> Garrulus.Reader.create_subscription()

    subscription
  end

  @doc """
  Generate a u_entry.
  """
  def u_entry_fixture(attrs \\ %{}) do
    {:ok, u_entry} =
      attrs
      |> Enum.into(%{
        read: true
      })
      |> Garrulus.Reader.create_u_entry()

    u_entry
  end
end
