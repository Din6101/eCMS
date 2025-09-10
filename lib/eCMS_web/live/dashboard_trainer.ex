defmodule ECMSWeb.DashboardTrainer do
  use ECMSWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Trainer Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen w-full bg-[#06A295] text-white p-8">
      <h1 class="text-4xl font-bold mb-4">Trainer Dashboard</h1>
      <p>Welcome, trainer! Here you can see stats and quick links.</p>
    </div>
    """
  end
end
