defmodule Garrulus.Reader do
  @moduledoc """
  The Reader context.
  """

  import Ecto.Query, warn: false
  alias Garrulus.Repo

  alias Garrulus.Reader.Feed

  @doc """
  Returns the list of feeds.

  ## Examples

      iex> list_feeds()
      [%Feed{}, ...]

  """
  def list_feeds do
    Repo.all(Feed)
  end

  @doc """
  Returns the list of feeds that are due to be fetched.

  ## Examples

      iex> due_feeds()
      [%Feed{}, ...]

  """
  def due_feeds do
    now = DateTime.utc_now()

    Repo.all(
      from f in Feed,
        where: f.next_fetch < ^now,
        order_by: [asc: f.next_fetch]
    )
  end

  @doc """
  Gets a single feed.

  Raises `Ecto.NoResultsError` if the Feed does not exist.

  ## Examples

      iex> get_feed!(123)
      %Feed{}

      iex> get_feed!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feed!(id), do: Repo.get!(Feed, id)

  @doc """
  Creates a feed.

  ## Examples

      iex> create_feed(%{field: value})
      {:ok, %Feed{}}

      iex> create_feed(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feed(attrs \\ %{}) do
    %Feed{}
    |> Feed.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feed.

  ## Examples

      iex> update_feed(feed, %{field: new_value})
      {:ok, %Feed{}}

      iex> update_feed(feed, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feed(%Feed{} = feed, attrs) do
    feed
    |> Feed.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feed.

  ## Examples

      iex> delete_feed(feed)
      {:ok, %Feed{}}

      iex> delete_feed(feed)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feed(%Feed{} = feed) do
    Repo.delete(feed)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feed changes.

  ## Examples

      iex> change_feed(feed)
      %Ecto.Changeset{data: %Feed{}}

  """
  def change_feed(%Feed{} = feed, attrs \\ %{}) do
    Feed.changeset(feed, attrs)
  end

  alias Garrulus.Reader.Entry

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%Entry{}, ...]

  """
  def list_entries do
    Repo.all(Entry)
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %Entry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id), do: Repo.get!(Entry, id)

  @doc """
  Creates a entry.

  ## Examples

      iex> create_entry(%{field: value})
      {:ok, %Entry{}}

      iex> create_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(attrs \\ %{}) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> Entry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a entry.

  ## Examples

      iex> delete_entry(entry)
      {:ok, %Entry{}}

      iex> delete_entry(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_entry(entry)
      %Ecto.Changeset{data: %Entry{}}

  """
  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    Entry.changeset(entry, attrs)
  end

  alias Garrulus.Reader.Subscription

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions do
    Repo.all(Subscription)
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs \\ %{}) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end

  alias Garrulus.Reader.UEntry

  @doc """
  Returns the list of uentries.

  ## Examples

      iex> list_uentries()
      [%UEntry{}, ...]

  """
  def list_uentries do
    Repo.all(UEntry)
  end

  @doc """
  Gets a single uentry.

  Raises `Ecto.NoResultsError` if the U entry does not exist.

  ## Examples

      iex> get_uentry!(123)
      %UEntry{}

      iex> get_uentry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_uentry!(id), do: Repo.get!(UEntry, id)

  @doc """
  Creates a uentry.

  ## Examples

      iex> create_uentry(%{field: value})
      {:ok, %UEntry{}}

      iex> create_uentry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_uentry(attrs \\ %{}) do
    %UEntry{}
    |> UEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a uentry.

  ## Examples

      iex> update_uentry(uentry, %{field: new_value})
      {:ok, %UEntry{}}

      iex> update_uentry(uentry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_uentry(%UEntry{} = uentry, attrs) do
    uentry
    |> UEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a uentry.

  ## Examples

      iex> delete_uentry(uentry)
      {:ok, %UEntry{}}

      iex> delete_uentry(uentry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_uentry(%UEntry{} = uentry) do
    Repo.delete(uentry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking uentry changes.

  ## Examples

      iex> change_uentry(uentry)
      %Ecto.Changeset{data: %UEntry{}}

  """
  def change_uentry(%UEntry{} = uentry, attrs \\ %{}) do
    UEntry.changeset(uentry, attrs)
  end
end
