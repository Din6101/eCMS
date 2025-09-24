defmodule ECMSWeb.AdminResult.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training

  @impl true
  def mount(_params, _session, socket) do
    results = Training.list_results()
    {:ok, assign(socket, results: results)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#06A295] text-white p-6 font-sans">
    <div class="max-w-7xl mx-auto">
    <div class="flex justify-between items-center mb-6">
    <h1 class="text-3xl font-bold">📊 All Student Results</h1>
    </div>

    <main class="flex-1 flex justify-center items-start p-6 w-full">
    <div class="w-full px-6 py-8">
    <table class="min-w-full text-black bg-white border border-black-300 divide-y divide-gray-200">
      <thead class="bg-gray-100">
        <tr>
          <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Student</th>
          <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Course</th>
          <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Status</th>
          <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Final Score</th>
          <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Certification</th>
        </tr>
      </thead>
      <tbody>
        <%= for result <- @results do %>
          <tr class="hover:bg-gray-50">
            <td class="px-4 py-2"><%= result.user.full_name %></td>
            <td class="px-4 py-2"><%= result.course.title %></td>
            <td class="px-4 py-2"><%= result.status %></td>
            <td class="px-4 py-2"><%= result.final_score %></td>
            <td class="px-4 py-2"><%= result.certification %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    </div>
    </main>
    </div>
    </div>
    """
  end
end
