defmodule CooxWeb.PageController do
  use CooxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
