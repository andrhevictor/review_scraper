defmodule ReviewScraper do
  @moduledoc """
  Exposes functions to fetch overly positive reviews.
  """

  alias ReviewScraper.DealerRater.{Client, Review, Scraper}

  @doc """
  Fetchs the reviews from DealerRater.com and returns the most positive reviews.

  Accepts the following options:

    - `:pages_to_fetch`: Number of pages to be fetched from DealerRater.com. Defaults to `5`.
    - `:reviews_count`: Number of reviews to be returned. Defaults to `3`.
  """
  @spec get_overly_positive_reviews(String.t(), keyword()) ::
          {:ok, [Review.t()]} | {:error, atom()}
  def get_overly_positive_reviews(dealership_name, opts \\ []) do
    pages_to_fetch = Keyword.get(opts, :pages_to_fetch, 5)
    reviews_count = Keyword.get(opts, :reviews_count, 3)

    case Client.find_dealership_by_name(dealership_name) do
      {:ok, dealership} ->
        reviews =
          1..pages_to_fetch
          |> Task.async_stream(fn page ->
            dealership
            |> Client.get_review_page(page)
            |> Scraper.get_reviews()
          end)
          |> Enum.flat_map(fn {:ok, reviews} -> reviews end)
          |> sort_reviews_by_positiveness()
          |> Enum.take(reviews_count)

        {:ok, reviews}

      {:error, :dealership_not_found} ->
        {:error, :dealership_not_found}
    end
  end

  @doc """
  Filters and sorts the reviews by positiveness using three criterias:

    - Recommended the dealer: Filters only reviews that have recommended the dealer.
    - Average rating: sum of all the ratings divided by 5.
    - Occurrences of overly positive words: given a set of overly positive words,
      the occurrence of those words is counted.
  """
  @spec sort_reviews_by_positiveness([Review.t()]) :: [Review.t()]
  def sort_reviews_by_positiveness(reviews) do
    reviews
    |> Enum.filter(& &1.recommend_dealer?)
    |> Enum.sort_by(
      fn review ->
        {calculate_average_rating(review), sum_positive_words_occurences(review)}
      end,
      :desc
    )
  end

  defp sum_positive_words_occurences(%Review{description: review_description}) do
    positive_words = [
      "best",
      "amazing",
      "very",
      "most",
      "ever",
      "wonderful",
      "love",
      "extremely",
      "fantastic",
      "super",
      "excellent",
      "perfect"
    ]

    review_description
    |> String.split()
    |> Enum.frequencies_by(&String.downcase/1)
    |> Map.take(positive_words)
    |> Map.values()
    |> Enum.sum()
  end

  defp calculate_average_rating(%Review{} = review) do
    review
    |> Map.take([
      :dealership_rating,
      :customer_service_rating,
      :friendliness_rating,
      :pricing_rating,
      :overall_experience_rating
    ])
    |> Map.values()
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
    |> Kernel.div(5)
  end
end
