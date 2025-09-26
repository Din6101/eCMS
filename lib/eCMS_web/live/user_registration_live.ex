defmodule ECMSWeb.UserRegistrationLive do
  use ECMSWeb, :live_view

  alias ECMS.Accounts
  alias ECMS.Accounts.User

  def render(assigns) do
    ~H"""
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

  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
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

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

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
