defmodule KejaDigitalWeb.FaqLive do
  use KejaDigitalWeb, :live_view

  # Comprehensive FAQ definitions with more detailed explanations
  @faqs [
    %{
      id: 1,
      category: "Platform Overview",
      question: "What is KejaDigital?",
      answer: """
      KejaDigital is an innovative digital platform revolutionizing the rental management experience. We bridge the communication gap between tenants and property owners by providing a comprehensive, user-friendly solution that simplifies every aspect of rental management.

      Our platform offers:
      • Seamless communication tools
      • Secure payment processing
      • Property management features
      • Real-time tracking of rental agreements
      • Transparent and efficient rental ecosystem
      """,
      visible: false
    },
    %{
      id: 2,
      category: "Account Management",
      question: "How do I create an account on KejaDigital?",
      answer: """
      Creating an account on KejaDigital is a straightforward, secure process designed to get you started quickly:

      1. Visit our homepage and click the "Register" button
      2. Choose your account type (Tenant or Landlord)
      3. Enter your personal details:
         - Full Name
         - Email Address
         - Phone Number
         - Strong, unique password
      4. Verify your email through the confirmation link
      5. Complete your profile by adding additional information

      We prioritize your privacy and use advanced security protocols during registration.
      """,
      visible: false
    },
    %{
      id: 3,
      category: "Property Management",
      question: "Can I manage multiple properties on KejaDigital?",
      answer: """
      Absolutely! KejaDigital is designed with property managers and landlords in mind. Our platform supports:

      • Unlimited property listings
      • Individual property dashboards
      • Separate tenant management for each property
      • Consolidated financial tracking
      • Customizable settings per property

      Whether you own a single apartment or manage an extensive real estate portfolio, KejaDigital provides the tools you need for efficient property management.
      """,
      visible: false
    },
    %{
      id: 4,
      category: "Payments",
      question: "How do I pay my rent through KejaDigital?",
      answer: """
      KejaDigital offers a secure, convenient rent payment experience:

      Payment Methods:
      • Mobile Money (M-Pesa)
      • Bank Transfer
      • Credit/Debit Cards
      • In-app Wallet

      Payment Process:
      1. Log into your account
      2. Navigate to "Payments" section
      3. Select your property
      4. Choose payment method
      5. Confirm transaction
      6. Receive instant payment confirmation

      Features:
      • Automatic receipt generation
      • Payment history tracking
      • Timely payment reminders
      • Secure transaction encryption
      """,
      visible: false
    },
    %{
      id: 5,
      category: "Account Security",
      question: "What should I do if I forget my password?",
      answer: """
      Password recovery on KejaDigital is designed to be simple and secure:

      Password Reset Steps:
      1. Click "Forgot Password" on login page
      2. Enter registered email address
      3. Check your email for reset link
      4. Click link to create new password
      5. Choose a strong, unique password

      Additional Security Measures:
      • 2-Factor Authentication available
      • Email and SMS verification
      • Account lockout after multiple failed attempts
      • Regular security updates
      """,
      visible: false
    },
    %{
      id: 6,
      category: "Support",
      question: "How can I contact customer support?",
      answer: """
      KejaDigital offers multiple support channels to ensure you receive timely assistance:

      Support Options:
      • Live Chat: Available during business hours
      • Email: support@kejadigital.com
      • Phone: +254 (0) 20 123 4567
      • Support Ticket System
      • Comprehensive Help Center

      Our support team is committed to:
      • Rapid response times
      • Professional and friendly service
      • Comprehensive problem resolution
      • Multilingual support
      """,
      visible: false
    },
    %{
      id: 7,
      category: "User Types",
      question: "Is KejaDigital available for both landlords and tenants?",
      answer: """
      KejaDigital is a versatile platform catering to diverse user needs:

      For Tenants:
      • View rent details
      • Make payments
      • Communicate with landlords
      • Maintenance request submission
      • View lease agreements

      For Landlords:
      • List multiple properties
      • Track rental payments
      • Manage tenant information
      • Generate financial reports
      • Communicate with tenants
      """,
      visible: false
    },
    %{
      id: 8,
      category: "Accessibility",
      question: "Can I access KejaDigital from my phone?",
      answer: """
      Absolutely! KejaDigital is built with a mobile-first approach:

      Mobile Features:
      • Fully responsive design
      • Native-like mobile experience
      • Compatible with:
        - iOS devices
        - Android smartphones
        - Tablets
      • Lightweight application
      • Minimal data consumption
      • Offline mode for critical functions

      Supported Browsers:
      • Chrome
      • Safari
      • Firefox
      • Edge
      """,
      visible: false
    },
    %{
      id: 9,
      category: "Security",
      question: "Are my data and payment details secure?",
      answer: """
      Security is our highest priority at KejaDigital:

      Data Protection Measures:
      • 256-bit SSL Encryption
      • PCI DSS Compliant
      • Regular Security Audits
      • End-to-End Encryption
      • Secure Cloud Infrastructure
      • Advanced Firewall Protection

      Personal Information Security:
      • Anonymous data handling
      • No third-party data sharing
      • Strict privacy policy
      • GDPR and CCPA Compliant
      """,
      visible: false
    },
    %{
      id: 10,
      category: "Account Management",
      question: "How do I log out of my account?",
      answer: """
      Logging out is simple and ensures your account's security:

      Logout Methods:
      1. Desktop:
         • Click profile icon
         • Select "Log Out"
         • Confirm logout

      2. Mobile:
         • Tap hamburger menu
         • Navigate to account settings
         • Choose "Sign Out"

      Security Tips:
      • Always log out on shared devices
      • Use private browsing
      • Enable two-factor authentication
      """,
      visible: false
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(faqs: @faqs)
      |> assign(search_term: "")
    }
  end

  @impl true
  def handle_event("toggle_answer", %{"id" => id}, socket) do
    faqs = Enum.map(socket.assigns.faqs, fn faq ->
      if faq.id == String.to_integer(id) do
        %{faq | visible: !faq.visible}
      else
        faq
      end
    end)

    {:noreply, assign(socket, faqs: faqs)}
  end

  def handle_event("search_faqs", %{"search" => search_term}, socket) do
    filtered_faqs = Enum.filter(@faqs, fn faq ->
      String.contains?(String.downcase(faq.question), String.downcase(search_term)) or
      String.contains?(String.downcase(faq.category), String.downcase(search_term))
    end)

    {:noreply,
      socket
      |> assign(faqs: filtered_faqs)
      |> assign(search_term: search_term)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <div class="bg-white shadow-lg rounded-lg overflow-hidden">
        <div class="px-6 py-4 bg-indigo-600 text-white">
          <h2 class="text-3xl font-bold text-center">Frequently Asked Questions</h2>
          <p class="text-center mt-2 text-indigo-100">
            Find answers to common questions about KejaDigital
          </p>
        </div>

        <div class="p-6">
          <div class="mb-6">
            <input
              type="text"
              placeholder="Search FAQs..."
              phx-keyup="search_faqs"
              value={@search_term}
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          <%= for faq <- @faqs do %>
            <div class="faq-item mb-4 border-b border-gray-200 pb-4">
              <button
                class="w-full text-left flex justify-between items-center text-lg font-medium text-indigo-700 hover:text-indigo-900 focus:outline-none"
                phx-click="toggle_answer"
                phx-value-id={faq.id}
              >
                <span><%= faq.question %></span>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class={["h-6 w-6 transform transition-transform duration-200", if(faq.visible, do: "rotate-180", else: "")]}
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>

              <%= if faq.visible do %>
                <div class="mt-2 text-gray-600 bg-gray-50 p-4 rounded-lg">
                  <%= faq.answer %>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
