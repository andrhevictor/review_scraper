defmodule ReviewScraper.DealerRater.Client do
  @moduledoc """
  Client that handles HTTP requests to DealerRater.com
  """

  use Tesla

  alias ReviewScraper.DealerRater.Dealership

  @base_url Application.fetch_env!(:review_scraper, :dealer_rater_base_url)

  plug(Tesla.Middleware.BaseUrl, @base_url)
  plug(Tesla.Middleware.JSON)

  @doc """
  Returns the HTML for the dealer reviews page.
  """
  @spec get_review_page(Dealership.t(), non_neg_integer()) :: String.t()
  def get_review_page(%Dealership{} = dealership, page \\ 1) do
    dealer_id = dealership.dealer_id
    dealer_name = dealership.dealer_name_encoded

    case get("/dealer/#{dealer_name}-dealer-reviews-#{dealer_id}/page#{page}") do
      {:ok, %{status: 200, body: body}} -> body
      _ -> ""
    end
  end

  @doc """
  Given the `dealership_name`, it searchs for the dealearship.
  """
  @spec find_dealership_by_name(String.t()) ::
          {:ok, Dealership.t()} | {:error, :dealership_not_found}
  def find_dealership_by_name(dealership_name) do
    headers = [{"Referer", @base_url}]
    query = [MaxItems: 1, term: dealership_name]

    case get("/json/dealer/dealersearch", headers: headers, query: query) do
      {:ok, %{status: 200, body: [body]}} ->
        dealer_name = Map.get(body, "dealerName", "")

        dealer_name_encoded =
          dealer_name
          |> String.replace(["-", "- "], "")
          |> String.replace(" ", "-")

        {:ok,
         %Dealership{
           dealer_id: Map.get(body, "dealerId"),
           dealer_name: dealer_name,
           dealer_name_encoded: dealer_name_encoded
         }}

      _ ->
        {:error, :dealership_not_found}
    end
  end
end
