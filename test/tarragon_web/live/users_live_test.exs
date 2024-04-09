defmodule TarragonWeb.UsersLiveTest do
  use TarragonWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tarragon.AccountsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_users(_) do
    users = users_fixture()
    %{users: users}
  end

  describe "Index" do
    setup [:create_users]

    test "lists all users", %{conn: conn, users: users} do
      {:ok, _index_live, html} = live(conn, ~p"/users")

      assert html =~ "Listing Users"
      assert html =~ users.name
    end

    test "saves new users", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert index_live |> element("a", "New Users") |> render_click() =~
               "New Users"

      assert_patch(index_live, ~p"/users/new")

      assert index_live
             |> form("#users-form", users: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#users-form", users: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/users")

      html = render(index_live)
      assert html =~ "Users created successfully"
      assert html =~ "some name"
    end

    test "updates users in listing", %{conn: conn, users: users} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert index_live |> element("#users-#{users.id} a", "Edit") |> render_click() =~
               "Edit Users"

      assert_patch(index_live, ~p"/users/#{users}/edit")

      assert index_live
             |> form("#users-form", users: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#users-form", users: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/users")

      html = render(index_live)
      assert html =~ "Users updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes users in listing", %{conn: conn, users: users} do
      {:ok, index_live, _html} = live(conn, ~p"/users")

      assert index_live |> element("#users-#{users.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#users-#{users.id}")
    end
  end

  describe "Show" do
    setup [:create_users]

    test "displays users", %{conn: conn, users: users} do
      {:ok, _show_live, html} = live(conn, ~p"/users/#{users}")

      assert html =~ "Show Users"
      assert html =~ users.name
    end

    test "updates users within modal", %{conn: conn, users: users} do
      {:ok, show_live, _html} = live(conn, ~p"/users/#{users}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Users"

      assert_patch(show_live, ~p"/users/#{users}/show/edit")

      assert show_live
             |> form("#users-form", users: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#users-form", users: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/users/#{users}")

      html = render(show_live)
      assert html =~ "Users updated successfully"
      assert html =~ "some updated name"
    end
  end
end
