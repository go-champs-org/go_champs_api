defmodule GoChampsApiWeb.OrganizationControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Organizations
  alias GoChampsApi.Organizations.Organization

  @create_attrs %{
    slug: "some-slug",
    name: "some name",
    members: [
      %{
        username: "someuser"
      }
    ]
  }
  @update_attrs %{
    slug: "some-updated-slug",
    name: "some updated name",
    members: [
      %{
        username: "someuser"
      },
      %{
        username: "someupdatedusername"
      }
    ]
  }
  @org_with_member_attrs %{
    slug: "some-slug",
    name: "some name",
    members: [
      %{
        username: "someotheruser"
      }
    ]
  }
  @invalid_attrs %{slug: nil, name: nil, members: [%{username: "someuser"}]}

  def fixture(:organization) do
    {:ok, organization} = Organizations.create_organization(@create_attrs)
    organization
  end

  def fixture(:organization_with_member) do
    {:ok, organization} = Organizations.create_organization(@org_with_member_attrs)
    organization
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all organizations", %{conn: conn} do
      conn = get(conn, Routes.v1_organization_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all organizations matching where", %{conn: conn} do
      fixture(:organization)

      {:ok, second_organization} =
        Organizations.create_organization(%{
          name: "another organization",
          slug: "another-org-slug"
        })

      where = %{"slug" => second_organization.slug}

      conn = get(conn, Routes.v1_organization_path(conn, :index, where: where))
      [organization_result] = json_response(conn, 200)["data"]
      assert organization_result["id"] == second_organization.id
    end
  end

  describe "create organization" do
    @tag :authenticated
    test "renders organization when data is valid", %{conn: conn} do
      conn = post(conn, Routes.v1_organization_path(conn, :create), organization: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_organization_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "slug" => "some-slug",
               "name" => "some name",
               "members" => [
                 %{
                   "username" => "someuser"
                 }
               ]
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.v1_organization_path(conn, :create), organization: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create organization with different member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = %{
        members: [
          %{
            username: "someotheruser"
          }
        ],
        name: "some organization",
        slug: "some-org-slug"
      }

      conn = post(conn, Routes.v1_organization_path(conn, :create), organization: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update organization" do
    setup [:create_organization]

    @tag :authenticated
    test "renders organization when data is valid", %{
      conn: conn,
      organization: %Organization{id: id} = organization
    } do
      conn =
        put(conn, Routes.v1_organization_path(conn, :update, organization),
          organization: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_organization_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "slug" => "some-updated-slug",
               "name" => "some updated name",
               "members" => [
                 %{
                   "username" => "someuser"
                 },
                 %{
                   "username" => "someupdatedusername"
                 }
               ]
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, organization: organization} do
      conn =
        put(conn, Routes.v1_organization_path(conn, :update, organization),
          organization: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update organization with different member" do
    setup [:create_organization_for_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      organization: %Organization{} = organization
    } do
      conn =
        put(conn, Routes.v1_organization_path(conn, :update, organization),
          organization: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete organization" do
    setup [:create_organization]

    @tag :authenticated
    test "deletes chosen organization", %{conn: conn, organization: organization} do
      conn = delete(conn, Routes.v1_organization_path(conn, :delete, organization))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_organization_path(conn, :show, organization))
      end
    end
  end

  describe "delete organization with different member" do
    setup [:create_organization_for_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      organization: %Organization{} = organization
    } do
      conn = delete(conn, Routes.v1_organization_path(conn, :delete, organization))

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_organization(_) do
    organization = fixture(:organization)
    {:ok, organization: organization}
  end

  defp create_organization_for_member(_) do
    organization = fixture(:organization_with_member)
    {:ok, organization: organization}
  end
end
