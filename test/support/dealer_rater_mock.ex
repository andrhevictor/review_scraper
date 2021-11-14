defmodule ReviewScraper.DealerRaterMock do
  @moduledoc """
  Functions to help testing the DealerRater API.
  """

  import Tesla.Mock

  @base_url Application.fetch_env!(:review_scraper, :dealer_rater_base_url)

  def mock_dealer_rater_endpoint(status) do
    mock_global(fn
      %{method: :get, url: @base_url <> "/json/dealer/dealersearch"} ->
        json([%{"dealerName" => "Dealership Name", "dealerId" => "123456"}], status: status)

      %{method: :get} ->
        response_body = File.read!("./test/dealer_rater_samples/review_page.html")

        %Tesla.Env{status: status, body: response_body}
    end)

    :ok
  end
end
