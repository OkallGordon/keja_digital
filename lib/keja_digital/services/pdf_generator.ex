defmodule KejaDigital.Services.PDFGenerator do
  @moduledoc """
  Service module for generating PDF documents.
  """

  @doc """
  Generates a PDF statement for the given payments.
  Returns {:ok, binary_data} on success or {:error, reason} on failure.
  """
  def generate_statement(payments) do
    payments
    |> generate_statement_html()
    |> generate_pdf()
  end

  defp generate_statement_html(payments) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; border: 1px solid #ddd; }
        th { background-color: #f4f4f4; }
        .total { font-weight: bold; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Rent Payment Statement</h1>
        <p>Generated on #{DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d %H:%M:%S UTC")}</p>
      </div>

      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Transaction ID</th>
            <th>Amount</th>
            <th>Phone Number</th>
          </tr>
        </thead>
        <tbody>
          #{generate_payment_rows(payments)}
        </tbody>
      </table>

      <div class="total">
        Total Amount: KES #{calculate_total(payments)}
      </div>
    </body>
    </html>
    """
  end

  defp generate_payment_rows(payments) do
    payments
    |> Enum.map(fn payment ->
      """
      <tr>
        <td>#{Calendar.strftime(payment.paid_at, "%Y-%m-%d %H:%M:%S")}</td>
        <td>#{payment.transaction_id}</td>
        <td>#{payment.amount}</td>
        <td>#{payment.phone_number}</td>
      </tr>
      """
    end)
    |> Enum.join("\n")
  end


  defp calculate_total([]), do: "0.00"  # Handle empty payment list
  defp calculate_total(payments) do
    payments
    |> Enum.reduce(0, & &1.amount + &2)
    |> to_string()
  end

  defp generate_pdf(html) do
    case PdfGenerator.generate(html, page_size: "A4") do
      {:ok, path} ->
        case File.read(path) do
          {:ok, binary} -> {:ok, binary}
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
