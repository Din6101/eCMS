defmodule ECMSWeb.UserLoginLive do
  use ECMSWeb, :live_view

  def render(assigns) do
    ~H"""
    <link phx-track-static rel="stylesheet" href={~p"/assets/login_styles.css"} />
    <link phx-track-static rel="stylesheet" href={~p"/assets/design.css"} />
    <div class="login-1">
      <div class="group-11-2">

        <p class="text-5"><span class="text-white">"SYSTEMATIC TRAINING, CENTERED ASSESSMENT"</span></p>
        <img src={~p"/images/logo-cms-4-18.png"} class="logo-cms-4-18" alt="logo" />
        <img src={~p"/images/node-16.png"} class="node-16" alt="illustration" />
        <p class="text-17"><span class="text-black">“Real-time progress. Real-world results.”</span></p>
      </div>
      <div class="group-10-19">
          <%= if @role do %>
            <h2 class="text-28"><span class="text-black">Welcome <%= String.capitalize(@role) %>, please log in to your account</span></h2>
          <% end %>
        <img src={~p"/images/icon-login-15-1-29.svg"} alt="login icon" class="icon-login-15-1-29" />
        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">

          <p class="text-21"><span class="text-black">Email</span></p>
          <div class="rectangle-172-23">
            <.input field={@form[:email]} type="email" placeholder="Your email" required class="w-full h-full bg-transparent border-0 focus:ring-0 px-3" />
          </div>

          <p class="text-22"><span class="text-black">Password</span></p>
          <div class="rectangle-173-24">
            <.input field={@form[:password]} type="password" placeholder="Your password" required class="w-full h-full bg-transparent border-0 focus:ring-0 px-3" />
          </div>

          <button type="submit" class="rectangle-567-30 text-31">Login</button>

          <:actions>
            <p class="signup-line">
              Don't have an account?
              <.link navigate={~p"/users/register"} class="text-sm font-semibold">
              <span class="text-26"> Sign up </span>
              </.link>
              for an account now.
            </p>
          </:actions>
        </.simple_form>

      </div>
    </div>

    <!-- Footer Section -->
    <div class="footer">
      <div class="copyright">
        <img src={~p"/images/copyright-34.png"} alt="copyright" class="h-20 w-20" />
        <span>2025 eCMS. All rights reserved.</span>
      </div>
      <div class="social">
        <a class="social-item" href="#"><img src={~p"/images/facebook-17.png"} alt="Facebook" /> <span>facebook.com</span></a>
        <a class="social-item" href="#"><img src={~p"/images/whatsapp-28.png"} alt="WhatsApp" /> <span>whatsapp.com</span></a>
        <a class="social-item" href="#"><img src={~p"/images/linkedin-circled-16.png"} alt="LinkedIn" /> <span>linkedin.com</span></a>
        <a class="social-item" href="#"><img src={~p"/images/twitter-circled-18.png"} alt="Twitter" /> <span>twitter.com</span></a>
      </div>
    </div>
    """
  end
  def mount(params, _session, socket) do
    role = params["role"]
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, role: role), temporary_assigns: [form: form]}
  end


end
