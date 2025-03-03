defmodule KejaDigital.Services.PDFGenerator do
  @moduledoc """
  Service module for generating professional PDF documents for rent payments.
  """

  @doc """
  Generates a PDF statement for the given payments.
  Returns {:ok, binary_data} on success or {:error, reason} on failure.

  The payments parameter should be a list of payment structs, each containing:
  - paid_at: DateTime when payment was made
  - transaction_id: Unique transaction identifier
  - amount: Payment amount
  - phone_number: Phone number used for payment
  - payer_name: Name of the person who made the payment
  - property_name: Name/ID of the property being paid for (if available)

  The user_credentials parameter should be a map containing:
  - full_name: Full name of the logged-in user
  - door_number: Door number of the tenant
  - email: Email address of the user
  - role: Role of the user (e.g., "Tenant")
  """
  def generate_statement(payments, user_credentials \\ nil, property_info \\ nil) do
    payments
    |> generate_statement_html(user_credentials, property_info)
    |> generate_pdf()
  end

  defp generate_statement_html(payments, user_credentials, property_info) do
    _tenant_name = if user_credentials, do: user_credentials.full_name, else: nil

    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>Rent Payment Statement</title>
      <style>
        body {
          font-family: 'Helvetica', 'Arial', sans-serif;
          margin: 0;
          padding: 0;
          color: #333;
          font-size: 14px;
        }
        .container {
          max-width: 800px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          text-align: center;
          margin-bottom: 30px;
          padding: 20px 0;
          border-bottom: 2px solid #01b5cd;
        }
        .logo {
          max-width: 150px;
          margin-bottom: 10px;
        }
        .company-name {
          font-size: 24px;
          font-weight: bold;
          color: #01b5cd;
          margin: 0;
        }
        .statement-title {
          font-size: 20px;
          margin: 10px 0;
        }
        .tenant-info {
          margin: 20px 0;
          padding: 15px;
          background-color: #f9f9f9;
          border-radius: 5px;
        }
        .statement-info {
          display: flex;
          justify-content: space-between;
          margin-bottom: 20px;
        }
        .statement-date {
          text-align: right;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin: 20px 0;
          box-shadow: 0 2px 3px rgba(0,0,0,0.1);
        }
        th, td {
          padding: 12px 15px;
          text-align: left;
          border-bottom: 1px solid #ddd;
        }
        th {
          background-color: #01b5cd;
          color: white;
          font-weight: 500;
        }
        tr:nth-child(even) {
          background-color: #f8f8f8;
        }
        tr:hover {
          background-color: #f1f1f1;
        }
        .amount {
          text-align: right;
        }
        .summary {
          margin-top: 30px;
          background-color: #f9f9f9;
          padding: 15px;
          border-radius: 5px;
        }
        .total {
          font-weight: bold;
          font-size: 16px;
          text-align: right;
          padding: 10px 15px;
          margin-top: 5px;
          border-top: 2px solid #01b5cd;
        }
        .footer {
          margin-top: 40px;
          padding-top: 20px;
          border-top: 1px solid #ddd;
          font-size: 12px;
          color: #666;
          text-align: center;
        }
        .payment-period {
          font-style: italic;
          color: #666;
        }
        .watermark {
          position: absolute;
          top: 40%;
          left: 30%;
          opacity: 0.05;
          transform: rotate(-45deg);
          font-size: 100px;
          z-index: -1;
          color:rgb(1, 152, 172);
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="watermark">PK RENTALS</div>
        <div class="header">
          <div class="company-name">PK RENTALS</div>
          <h1 class="statement-title">Rent Payment Statement</h1>
        </div>

        <div class="tenant-info">
          <h3>Tenant Information</h3>
          #{generate_tenant_info(user_credentials, property_info)}
        </div>

        <div class="statement-info">
          <div class="payment-period">
            <p><strong>Payment Period:</strong> #{get_period_label(payments)}</p>
          </div>
          <div class="statement-date">
            <p><strong>Statement Date:</strong> #{DateTime.utc_now() |> Calendar.strftime("%B %d, %Y")}</p>
            <p><strong>Generated Time:</strong> #{DateTime.utc_now() |> Calendar.strftime("%H:%M:%S")}</p>
            <p><strong>Reference:</strong> STMT-#{DateTime.utc_now() |> Calendar.strftime("%Y%m%d%H%M")}</p>
          </div>
        </div>

        <table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Transaction ID</th>
              <th>Payer Name</th>
              <th>Phone Number</th>
              <th class="amount">Amount (KES)</th>
            </tr>
          </thead>
          <tbody>
            #{generate_payment_rows(payments)}
          </tbody>
        </table>

        <div class="summary">
          <h3>Payment Summary</h3>
          <p><strong>Total Transactions:</strong> #{length(payments)}</p>
          <div class="total">
            Total Amount: KES #{format_amount(calculate_total(payments))}
          </div>
        </div>

        <div class="footer">
          <p>This is an electronically generated statement and does not require a signature.</p>
          <p>For any queries, please contact us at infopkrentals@yahoo.com or call +254 795 579 388</p>
          <p>&copy; #{DateTime.utc_now().year} PK Rentals. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp generate_tenant_info(user_credentials, property_info) do
    if user_credentials do
      """
      <p><strong>Name:</strong> #{user_credentials.full_name || "Not specified"}</p>
      <p><strong>Door Number:</strong> #{user_credentials.door_number || "Not specified"}</p>
      <p><strong>Email:</strong> #{user_credentials.email || "Not specified"}</p>
      <p><strong>Role:</strong> #{user_credentials.role || "Tenant"}</p>
      #{if property_info do
        """
        <p><strong>Property:</strong> #{property_info.name || "Not specified"}</p>
        <p><strong>Unit/Door:</strong> #{property_info.unit || "Not specified"}</p>
        """
        else
        ""
        end}
      """
    else
      """
      <p><strong>Name:</strong> Not specified</p>
      #{if property_info do
        """
        <p><strong>Property:</strong> #{property_info.name || "Not specified"}</p>
        <p><strong>Unit/Door:</strong> #{property_info.unit || "Not specified"}</p>
        """
        else
        ""
        end}
      """
    end
  end

  defp get_period_label([]), do: "No payments"
  defp get_period_label(payments) do
    earliest = payments |> Enum.min_by(&(&1.paid_at), DateTime) |> Map.get(:paid_at)
    latest = payments |> Enum.max_by(&(&1.paid_at), DateTime) |> Map.get(:paid_at)

    if earliest.year == latest.year && earliest.month == latest.month do
      Calendar.strftime(earliest, "%B %Y")
    else
      "#{Calendar.strftime(earliest, "%B %d, %Y")} - #{Calendar.strftime(latest, "%B %d, %Y")}"
    end
  end

  defp generate_payment_rows([]), do: "<tr><td colspan='5' style='text-align: center;'>No payment records found</td></tr>"
  defp generate_payment_rows(payments) do
    payments
    |> Enum.map(fn payment ->
      """
      <tr>
        <td>#{Calendar.strftime(payment.paid_at, "%d-%b-%Y %H:%M")}</td>
        <td>#{payment.transaction_id}</td>
        <td>#{Map.get(payment, :payer_name, "N/A")}</td>
        <td>#{payment.phone_number}</td>
        <td class="amount">#{format_amount(payment.amount)}</td>
      </tr>
      """
    end)
    |> Enum.join("\n")
  end

  defp calculate_total([]), do: 0  # Handle empty payment list
  defp calculate_total(payments) do
    payments
    |> Enum.reduce(0, & &1.amount + &2)
  end

  defp format_amount(amount) do
    :erlang.float_to_binary(amount * 1.0, [decimals: 2])
  end

  defp generate_pdf(html) do
    pdf_options = [
      page_size: "A4",
      margin: {15, 15, 15, 15}, # {top, right, bottom, left} in mm
      shell_params: [
        "--enable-local-file-access",
        "--print-media-type",
        "--footer-center", "Page [page] of [topage]",
        "--footer-font-size", "9",
        "--footer-line",
        "--footer-spacing", "5"
      ]
    ]
    case PdfGenerator.generate(html, pdf_options) do
      {:ok, path} ->
        case File.read(path) do
          {:ok, binary} ->
            # Clean up the temporary file
            File.rm(path)
            {:ok, binary}
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
