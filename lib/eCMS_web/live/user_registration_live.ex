defmodule ECMSWeb.UserRegistrationLive do
  use ECMSWeb, :live_view

  alias ECMS.Accounts
  alias ECMS.Accounts.User

  def render(assigns) do
    ~H"""
<<<<<<< HEAD
    <link phx-track-static rel="stylesheet" href={~p"/assets/registration_styles.css"} />
    <link phx-track-static rel="stylesheet" href={~p"/assets/design.css"} />

    <div class="h-screen flex flex-col overflow-hidden">
      <!-- Main Content -->
      <div class="flex-1 flex items-center justify-center px-4 py-2 min-h-0">
        <div class="w-full max-w-md">
          <!-- Header Section -->
          <div class="text-center mb-3">
            <img src={~p"/images/logo-cms-4-18.png"} class="mx-auto h-10 mb-1" alt="eCMS Logo" />
            <h1 class="text-lg font-bold text-gray-900 mb-0.5">Create your account</h1>
            <p class="text-xs text-gray-600">Sign up to get started</p>
          </div>

          <!-- Registration Form Card -->
          <div class="bg-white rounded-lg shadow-md p-4 border border-gray-200">
            <.simple_form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              class="space-y-3"
            >
              <.error :if={@check_errors}>
                Oops, something went wrong! Please check the errors below.
              </.error>

              <!-- Full name -->
              <.input
                field={@form[:full_name]}
                type="text"
                label="Full name"
                placeholder="Enter your full name"
                required
                autofocus
                class="w-full"
              />

              <!-- Email -->
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                placeholder="Enter your email"
                required
                class="w-full"
              />

              <!-- Password -->
              <.input
                field={@form[:password]}
                type="password"
                label="Password"
                placeholder="Enter your password"
                required
                class="w-full"
              />

              <!-- Submit Button -->
              <:actions>
                <.button
                  phx-disable-with="Creating account..."
                  class="!bg-teal-600 hover:!bg-teal-700 !text-white w-full font-semibold py-2 px-4 rounded-lg transition-colors text-sm"
                >
                  Create Account
                </.button>
              </:actions>
            </.simple_form>

            <!-- Sign In Link -->
            <div class="mt-2 text-center">
              <p class="text-xs text-gray-600">
                Already have an account?
                <.link
                  navigate={~p"/users/log_in"}
                  class="font-semibold text-teal-600 hover:text-teal-800 hover:underline ml-1"
                >
                  Sign in
                </.link>
              </p>
            </div>
          </div>

          <!-- Branding Section -->
          <div class="mt-2 text-center">
            <p class="text-md text-black-600 italic">"SYSTEMATIC TRAINING, CENTERED ASSESSMENT"</p>
            <p class="text-sm !text-white mt-0.5">"Real-time progress. Real-world results."</p>
          </div>
        </div>
      </div>

      <!-- Footer Section -->
      <footer class="relative bg-teal-900/80 text-white py-2 overflow-hidden flex-shrink-0">
        <div class="absolute inset-0 bg-gradient-to-r from-teal-900/20 to-teal-700/20 opacity-30"></div>
        <div class="relative z-10 max-w-7xl mx-auto px-4">
          <div class="flex flex-col md:flex-row justify-between items-center space-y-1 md:space-y-0">
            <!-- Copyright -->
            <div class="flex items-center space-x-2 text-xs text-white">
              <span>© 2025 eCMS. All rights reserved.</span>
            </div>

            <!-- Social Links -->
            <div class="flex items-center space-x-3">
              <a href="#" class="text-white/80 hover:text-white transition-colors" title="Facebook">
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path fill-rule="evenodd" d="M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z" clip-rule="evenodd" />
                </svg>
              </a>
              <a href="#" class="text-white/80 hover:text-white transition-colors" title="WhatsApp">
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                </svg>
              </a>
              <a href="#" class="text-white/80 hover:text-white transition-colors" title="LinkedIn">
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path fill-rule="evenodd" d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z" clip-rule="evenodd" />
                </svg>
              </a>
              <a href="#" class="text-white/80 hover:text-white transition-colors" title="Twitter">
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                </svg>
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
    """
=======
<link phx-track-static rel="stylesheet" href={~p"/assets/registration_styles.css"} />
<link phx-track-static rel="stylesheet" href={~p"/assets/design.css"} />
<div class="mx-auto max-w-sm text-center">
  <!-- Header with logo -->
  <header class="mb-6">
  <div class="group-11-2">
    <img src={~p"/images/logo-cms-4-18.png"} class="logo-cms-3-20" alt="logo" />
    <h1 class="text-28">Register for an account</h1>

  </div>
  </header>

  <div class="group-10-19">
  <!-- Registration form -->
  <div class="form-box">
  <.simple_form
    for={@form}
    id="registration_form"
    phx-submit="save"
    phx-change="validate"
    phx-trigger-action={@trigger_submit}
    action={~p"/users/log_in?_action=registered"}
    method="post"
  >
    <.error :if={@check_errors}>
      <p class="text-15">Oops, something went wrong! Please check the errors below.</p>
    </.error>

    <!-- Full name -->
    <.input
      field={@form[:full_name]}
      type="text"
      label="Full name"
      placeholder="Your full name"
      required
      class="text-16"
    />

    <!-- Email -->
    <.input
      field={@form[:email]}
      type="email"
      label="Email"
      placeholder="Your email"
      required
      class="text-16"
    />

    <!-- Password -->
    <.input
      field={@form[:password]}
      type="password"
      label="Password"
      placeholder="Your password"
      required
      class="text-16"
    />


    <:actions>
      <.button phx-disable-with="Creating account..." class="rectangle-177-4 text-27 w-full">
        Register
      </.button>
    </:actions>
  </.simple_form>
  <p class="text-32 mt-2">
      Already registered?
      <.link navigate={~p"/users/log_in"} class="text-17 hover:underline">
        Log in
      </.link>
      to your account now.
    </p>
  </div>
  </div>
</div>

"""

>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
<<<<<<< HEAD
      |> assign(check_errors: false)
=======
      |> assign(trigger_submit: false, check_errors: false)
>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

<<<<<<< HEAD
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully. Please check your email for confirmation instructions.")
         |> redirect(to: ~p"/landing")}
=======
        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}
>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

<<<<<<< HEAD
  def handle_event("save", _params, socket) do
    # Handle case where params don't match expected format
    changeset = Accounts.change_user_registration(%User{})
    {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
  end

=======
>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
