defmodule Garrulus.Reader do
  @moduledoc """
  The Reader context.
  """

  import Ecto.Query, warn: false
  alias Garrulus.Repo
  alias Garrulus.Reader.Entry

  alias Garrulus.Reader.Feed
  alias Garrulus.Reader.Subscription
  alias Garrulus.Reader.UEntry
  alias Garrulus.Reader.FetchLog

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

  def get_or_create_feed(attrs \\ %{}) do
    # use the feed's url as the unique identifier
    # technically it *should* be the guid,
    # but the URL is what a user will enter
    case Repo.get_by(Feed, url: attrs["url"]) do
      nil ->
        create_feed(attrs)

      feed ->
        {:ok, feed}
    end
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

  def log_fetch(feed, status, response_status_code, response_body, new_entries) do
    Repo.insert(%FetchLog{
      feed_id: feed.id,
      status: status,
      response_status_code: response_status_code,
      response_body: response_body,
      new_entries: new_entries
    })
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
    delete_feed_subscriptions(feed)
    delete_feed_entries(feed)
    Repo.delete(feed)
  end

  def delete_feed_subscriptions(feed) do
    Repo.delete_all(
      from s in Subscription,
        where: s.feed_id == ^feed.id
    )
  end

  def delete_feed_entries(feed) do
    Repo.delete_all(
      from e in Entry,
        where: e.feed_id == ^feed.id
    )
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

  def get_entry_feed!(%Entry{} = entry) do
    Repo.get!(Feed, entry.feed_id) |> Repo.preload(:users)
  end

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

  def create_entry_if_not_exists(attrs \\ %{}) do
    case Repo.get_by(Entry, guid: attrs[:guid]) do
      nil ->
        {:ok, entry} = create_entry(attrs)
        fanout(entry)
        {:ok, entry, 1}

      entry ->
        {:ok, entry, 0}
    end
  end

  def fanout(entry) do
    # for each user subscribed to this entry's feed
    # create a new uentry
    feed = get_entry_feed!(entry)

    Enum.each(feed.users, fn user ->
      create_uentry(%{
        user_id: user.id,
        entry_id: entry.id
      })
    end)
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
  Returns list of subscriptions for a given user

  ### Examples

  iex> list_user_subscriptions(user)
  [%Subscription{}, ...]

  """
  def list_user_subscriptions(user) do
    Repo.all(
      from s in Subscription,
        where: s.user_id == ^user.id
    )
    |> Repo.preload(:feed)
  end

  def list_user_uentries(user) do
    Repo.all(
      from u in UEntry,
        where: u.user_id == ^user.id
    )
    |> Repo.preload(:entry)
  end

  def list_feed_entries(feed) do
    Repo.all(
      from e in Entry,
        where: e.feed_id == ^feed.id,
        order_by: [desc: e.published, desc: e.id]
    )
  end

  # this returns a list because it can be either
  # one or zero entries
  def get_current_user_uentry(user) do
    Repo.all(
      from u in UEntry,
        where: u.user_id == ^user.id and u.read == false,
        order_by: [asc: u.inserted_at, asc: u.id],
        limit: 1,
        offset: 0
    )
    |> Repo.preload([:entry, [entry: :feed]])
  end

  def list_unread_user_uentries(user, limit \\ 10) do
    Repo.all(
      from u in UEntry,
        where: u.user_id == ^user.id and u.read == false,
        order_by: [asc: u.inserted_at, asc: u.id],
        limit: ^limit,
        offset: 1
    )
    |> Repo.preload([:entry, [entry: :feed]])
  end

  def count_unread_user_uentries(user) do
    Repo.one(
      from u in UEntry,
        where: u.user_id == ^user.id and u.read == false,
        select: count(u.id)
    )
  end

  def list_recent_read_user_uentries(user, limit \\ 10) do
    Repo.all(
      from u in UEntry,
        where: u.user_id == ^user.id and u.read == true,
        order_by: [desc: u.inserted_at, desc: u.id],
        limit: ^limit
    )
    |> Repo.preload([:entry, [entry: :feed]])
  end

  def list_fetchlogs(limit \\ 100) do
    Repo.all(
      from u in FetchLog,
        order_by: [desc: u.inserted_at],
        limit: ^limit
    )
    |> Repo.preload([:feed])
  end

  # delete uentries that are read and older than 7 days
  def purge_uentries() do
    now = DateTime.utc_now()
    days = 7
    cutoff = now |> Timex.shift(days: -1 * days)

    Repo.delete_all(
      from u in UEntry,
        where: u.read == true and u.inserted_at < ^cutoff
    )
  end

  def purge_fetch_logs() do
    now = DateTime.utc_now()
    days = 7
    cutoff = now |> Timex.shift(days: -7 * days)

    Repo.delete_all(
      from fl in FetchLog,
        where: fl.inserted_at < ^cutoff
    )
  end

  @doc """
  Returns list of feeds that a given user is *not* subscribed to

  ### Examples

  iex> list_user_non_subscriptions(user)
  [%Feed{}, ...]

  """
  def list_user_non_subscriptions(user) do
    query = from s in Subscription, where: s.user_id == ^user.id, select: s.feed_id

    Repo.all(
      from f in Feed,
        where: f.id not in subquery(query)
    )
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

  def subscribe(user, feed) do
    # if there's already a subscription, don't create a new one
    case Repo.get_by(Subscription, user_id: user.id, feed_id: feed.id) do
      nil ->
        %Subscription{}
        |> Subscription.changeset(%{user_id: user.id, feed_id: feed.id})
        |> Repo.insert()

      _ ->
        {:ok, %Subscription{}}
    end
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
