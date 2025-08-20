defmodule ECMSWeb.DashboardAdmin do
  use ECMSWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Admin Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen w-full bg-[#06A295] text-white p-8">
      <h1 class="text-4xl font-bold mb-4">Admin Dashboard</h1>
      <p>Welcome, admin! Here you can see stats and quick links.</p>
    </div>
    """
  end
end
