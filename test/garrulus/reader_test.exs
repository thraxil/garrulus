defmodule Garrulus.ReaderTest do
  use Garrulus.DataCase

  alias Garrulus.Reader

  describe "feeds" do
    alias Garrulus.Reader.Feed

    import Garrulus.ReaderFixtures

    @invalid_attrs %{
      backoff: nil,
      etag: nil,
      guid: nil,
      last_failed: nil,
      last_fetched: nil,
      next_fetch: nil,
      title: nil,
      url: nil
    }

    test "list_feeds/0 returns all feeds" do
      feed = feed_fixture()
      assert Reader.list_feeds() == [feed]
    end

    test "get_feed!/1 returns the feed with given id" do
      feed = feed_fixture()
      assert Reader.get_feed!(feed.id) == feed
    end

    test "create_feed/1 with valid data creates a feed" do
      valid_attrs = %{
        backoff: 42,
        etag: "some etag",
        guid: "some guid",
        last_failed: ~N[2023-02-20 12:03:00],
        last_fetched: ~N[2023-02-20 12:03:00],
        next_fetch: ~N[2023-02-20 12:03:00],
        title: "some title",
        url: "some url"
      }

      assert {:ok, %Feed{} = feed} = Reader.create_feed(valid_attrs)
      assert feed.backoff == 42
      assert feed.etag == "some etag"
      assert feed.guid == "some guid"
      assert feed.last_failed == ~N[2023-02-20 12:03:00]
      assert feed.last_fetched == ~N[2023-02-20 12:03:00]
      assert feed.next_fetch == ~N[2023-02-20 12:03:00]
      assert feed.title == "some title"
      assert feed.url == "some url"
    end

    test "create_feed/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reader.create_feed(@invalid_attrs)
    end

    test "update_feed/2 with valid data updates the feed" do
      feed = feed_fixture()

      update_attrs = %{
        backoff: 43,
        etag: "some updated etag",
        guid: "some updated guid",
        last_failed: ~N[2023-02-21 12:03:00],
        last_fetched: ~N[2023-02-21 12:03:00],
        next_fetch: ~N[2023-02-21 12:03:00],
        title: "some updated title",
        url: "some updated url"
      }

      assert {:ok, %Feed{} = feed} = Reader.update_feed(feed, update_attrs)
      assert feed.backoff == 43
      assert feed.etag == "some updated etag"
      assert feed.guid == "some updated guid"
      assert feed.last_failed == ~N[2023-02-21 12:03:00]
      assert feed.last_fetched == ~N[2023-02-21 12:03:00]
      assert feed.next_fetch == ~N[2023-02-21 12:03:00]
      assert feed.title == "some updated title"
      assert feed.url == "some updated url"
    end

    test "update_feed/2 with invalid data returns error changeset" do
      feed = feed_fixture()
      assert {:error, %Ecto.Changeset{}} = Reader.update_feed(feed, @invalid_attrs)
      assert feed == Reader.get_feed!(feed.id)
    end

    test "delete_feed/1 deletes the feed" do
      feed = feed_fixture()
      assert {:ok, %Feed{}} = Reader.delete_feed(feed)
      assert_raise Ecto.NoResultsError, fn -> Reader.get_feed!(feed.id) end
    end

    test "change_feed/1 returns a feed changeset" do
      feed = feed_fixture()
      assert %Ecto.Changeset{} = Reader.change_feed(feed)
    end
  end

  describe "entries" do
    alias Garrulus.Reader.Entry

    import Garrulus.ReaderFixtures

    @invalid_attrs %{
      author: nil,
      description: nil,
      guid: nil,
      link: nil,
      published: nil,
      title: nil
    }

    test "list_entries/0 returns all entries" do
      entry = entry_fixture()
      assert Reader.list_entries() == [entry]
    end

    test "get_entry!/1 returns the entry with given id" do
      entry = entry_fixture()
      assert Reader.get_entry!(entry.id) == entry
    end

    test "create_entry/1 with valid data creates a entry" do
      valid_attrs = %{
        author: "some author",
        description: "some description",
        guid: "some guid",
        link: "some link",
        published: ~N[2023-02-20 12:04:00],
        title: "some title"
      }

      assert {:ok, %Entry{} = entry} = Reader.create_entry(valid_attrs)
      assert entry.author == "some author"
      assert entry.description == "some description"
      assert entry.guid == "some guid"
      assert entry.link == "some link"
      assert entry.published == ~N[2023-02-20 12:04:00]
      assert entry.title == "some title"
    end

    test "create_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reader.create_entry(@invalid_attrs)
    end

    test "update_entry/2 with valid data updates the entry" do
      entry = entry_fixture()

      update_attrs = %{
        author: "some updated author",
        description: "some updated description",
        guid: "some updated guid",
        link: "some updated link",
        published: ~N[2023-02-21 12:04:00],
        title: "some updated title"
      }

      assert {:ok, %Entry{} = entry} = Reader.update_entry(entry, update_attrs)
      assert entry.author == "some updated author"
      assert entry.description == "some updated description"
      assert entry.guid == "some updated guid"
      assert entry.link == "some updated link"
      assert entry.published == ~N[2023-02-21 12:04:00]
      assert entry.title == "some updated title"
    end

    test "update_entry/2 with invalid data returns error changeset" do
      entry = entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Reader.update_entry(entry, @invalid_attrs)
      assert entry == Reader.get_entry!(entry.id)
    end

    test "delete_entry/1 deletes the entry" do
      entry = entry_fixture()
      assert {:ok, %Entry{}} = Reader.delete_entry(entry)
      assert_raise Ecto.NoResultsError, fn -> Reader.get_entry!(entry.id) end
    end

    test "change_entry/1 returns a entry changeset" do
      entry = entry_fixture()
      assert %Ecto.Changeset{} = Reader.change_entry(entry)
    end
  end

  describe "subscriptions" do
    alias Garrulus.Reader.Subscription

    import Garrulus.ReaderFixtures

    @invalid_attrs %{}

    test "list_subscriptions/0 returns all subscriptions" do
      subscription = subscription_fixture()
      assert Reader.list_subscriptions() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert Reader.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      valid_attrs = %{}

      assert {:ok, %Subscription{} = _subscription} = Reader.create_subscription(valid_attrs)
    end

    # test "create_subscription/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Reader.create_subscription(@invalid_attrs)
    # end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()
      update_attrs = %{}

      assert {:ok, %Subscription{} = _subscription} =
               Reader.update_subscription(subscription, update_attrs)
    end

    # test "update_subscription/2 with invalid data returns error changeset" do
    #   subscription = subscription_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Reader.update_subscription(subscription, @invalid_attrs)
    #   assert subscription == Reader.get_subscription!(subscription.id)
    # end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Reader.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Reader.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Reader.change_subscription(subscription)
    end
  end

  describe "uentries" do
    alias Garrulus.Reader.UEntry

    import Garrulus.ReaderFixtures

    @invalid_attrs %{read: nil}

    test "list_uentries/0 returns all uentries" do
      uentry = uentry_fixture()
      assert Reader.list_uentries() == [uentry]
    end

    test "get_uentry!/1 returns the uentry with given id" do
      uentry = uentry_fixture()
      assert Reader.get_uentry!(uentry.id) == uentry
    end

    test "create_uentry/1 with valid data creates a uentry" do
      valid_attrs = %{read: true}

      assert {:ok, %UEntry{} = uentry} = Reader.create_uentry(valid_attrs)
      assert uentry.read == true
    end

    test "create_uentry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reader.create_uentry(@invalid_attrs)
    end

    test "update_uentry/2 with valid data updates the uentry" do
      uentry = uentry_fixture()
      update_attrs = %{read: false}

      assert {:ok, %UEntry{} = uentry} = Reader.update_uentry(uentry, update_attrs)
      assert uentry.read == false
    end

    test "update_uentry/2 with invalid data returns error changeset" do
      uentry = uentry_fixture()
      assert {:error, %Ecto.Changeset{}} = Reader.update_uentry(uentry, @invalid_attrs)
      assert uentry == Reader.get_uentry!(uentry.id)
    end

    test "delete_uentry/1 deletes the uentry" do
      uentry = uentry_fixture()
      assert {:ok, %UEntry{}} = Reader.delete_uentry(uentry)
      assert_raise Ecto.NoResultsError, fn -> Reader.get_uentry!(uentry.id) end
    end

    test "change_uentry/1 returns a uentry changeset" do
      uentry = uentry_fixture()
      assert %Ecto.Changeset{} = Reader.change_uentry(uentry)
    end
  end
end
