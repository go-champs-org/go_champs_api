defmodule GoChampsApiWeb.UserControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Accounts
  alias GoChampsApi.Organizations

  @create_attrs %{
    email: "someuser@email.com",
    password: "some password",
    username: "someusername"
  }
  @create_with_facebook_attrs %{
    email: "someuser@email.com",
    facebook_id: "some-facebook-id",
    username: "someusername"
  }
  @update_attrs %{
    email: "someuser@email.com",
    password: "some other password",
    username: "someusername"
  }
  @invalid_attrs %{email: nil, password: nil}

  @associated_org %{
    slug: "associated-org-slug",
    name: "associated org name",
    members: [
      %{
        username: "someuser"
      }
    ]
  }
  @not_associated_org %{
    slug: "not-associated-org-slug",
    name: "not associated org name",
    members: [
      %{
        username: "someotheruser"
      }
    ]
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.v1_user_path(conn, :create), user: @create_attrs)
      assert %{"email" => _email} = json_response(conn, 201)["data"]

      conn = post(conn, Routes.v1_user_path(conn, :signin), @create_attrs)

      %{"email" => result_email, "token" => result_token, "username" => result_username} =
        json_response(conn, 200)["data"]

      assert result_email == "someuser@email.com"
      assert result_token != nil
      assert result_username == "someusername"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.v1_user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create user with facebook" do
    test "renders user when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.v1_user_path(conn, :create_with_facebook),
          user: @create_with_facebook_attrs
        )

      assert %{"email" => result_email, "username" => result_username} =
               json_response(conn, 201)["data"]

      assert result_email == "someuser@email.com"
      assert result_username == "someusername"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.v1_user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    @tag :authenticated
    test "renders user when data is valid", %{
      conn: conn
    } do
      conn = patch(conn, Routes.v1_user_path(conn, :update), %{user: @update_attrs})
      %{"email" => result_email} = json_response(conn, 200)["data"]
      assert result_email == "someuser@email.com"

      conn = post(conn, Routes.v1_user_path(conn, :signin), @update_attrs)

      %{"email" => result_email, "token" => result_token, "username" => result_username} =
        json_response(conn, 200)["data"]

      assert result_email == "someuser@email.com"
      assert result_token != nil
      assert result_username == "someusername"
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = patch(conn, Routes.v1_user_path(conn, :update), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show user" do
    @tag :authenticated
    test "renders user when data associated with token", %{
      conn: conn
    } do
      {:ok, _associated_org} = Organizations.create_organization(@associated_org)
      {:ok, _not_associated_org} = Organizations.create_organization(@not_associated_org)
      conn = get(conn, Routes.v1_user_path(conn, :show, "someuser"))

      assert %{
               "email" => "some@email.com",
               "username" => "someuser",
               "organizations" => [
                 %{
                   "slug" => "associated-org-slug",
                   "name" => "associated org name"
                 }
               ]
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "returns forbidden for an user that is not associated with the token", %{
      conn: conn
    } do
      conn = get(conn, Routes.v1_user_path(conn, :show, "someotheruser"))

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
