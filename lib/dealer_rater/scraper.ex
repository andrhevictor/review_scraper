defmodule ReviewScraper.DealerRater.Scraper do
  @moduledoc """
  Module responsible for parsing the HTML document.
  """

  alias ReviewScraper.DealerRater.Review

  @doc """
  Find the reviews in an HTML document and parse into the `ReviewScraper.DealerRater.Review` struct.
  """
  @spec get_reviews(String.t()) :: [Review.t()]
  def get_reviews(document) do
    document
    |> Floki.parse_document!()
    |> Floki.find("#reviews .review-entry")
    |> Enum.map(&parse_review/1)
  end

  defp parse_review(review_html_tree) do
    optional_ratings = parse_optional_ratings(review_html_tree)

    %Review{
      title: parse_title(review_html_tree),
      description: parse_description(review_html_tree),
      reviewer_name: parse_reviewer_name(review_html_tree),
      date: parse_review_date(review_html_tree),
      dealership_rating: parse_dealership_rating(review_html_tree),
      customer_service_rating: Map.get(optional_ratings, "Customer Service", nil),
      friendliness_rating: Map.get(optional_ratings, "Friendliness", nil),
      pricing_rating: Map.get(optional_ratings, "Pricing", nil),
      overall_experience_rating: Map.get(optional_ratings, "Overall Experience", nil),
      recommend_dealer?: parse_dealer_recommendation(review_html_tree)
    }
  end

  defp parse_title(review_html_tree) do
    review_html_tree
    |> Floki.find("h3")
    |> Floki.text()
    |> String.replace("\"", "")
  end

  defp parse_description(review_html_tree) do
    review_html_tree
    |> Floki.find("p")
    |> Floki.text()
    |> String.replace(["\"", "\n", "\r"], "")
    |> String.trim()
  end

  defp parse_reviewer_name(review_html_tree) do
    review_html_tree
    |> Floki.find("span.notranslate")
    |> Floki.text()
    |> String.replace("- ", "")
    |> String.trim()
  end

  defp parse_review_date(review_html_tree) do
    review_html_tree
    |> Floki.find(".review-date div:first-child")
    |> Floki.text()
    |> String.trim()
  end

  defp parse_dealership_rating(review_html_tree) do
    review_html_tree
    |> Floki.find(".review-date .dealership-rating .rating-static:first-child")
    |> Floki.attribute("class")
    |> extract_rating_from_css_classes()
  end

  defp parse_optional_ratings(review_html_tree) do
    review_html_tree
    |> Floki.find(".review-ratings-all .table .tr")
    |> Map.new(fn rating_html ->
      rating_name =
        Floki.find(rating_html, "div.small-text")
        |> Floki.text()
        |> String.trim()

      rating_value =
        Floki.find(rating_html, "div.rating-static-indv")
        |> Floki.attribute("class")
        |> extract_rating_from_css_classes()

      {rating_name, rating_value}
    end)
  end

  defp parse_dealer_recommendation(review_html_tree) do
    review_html_tree
    |> Floki.find(".review-ratings-all .table .tr:last-child")
    |> Floki.text()
    |> String.trim()
    |> String.upcase()
    |> String.contains?("YES")
  end

  defp extract_rating_from_css_classes(css_classes) when is_list(css_classes) do
    css_classes
    |> Enum.join()
    |> extract_rating_from_css_classes()
  end

  defp extract_rating_from_css_classes(css_classes) do
    ~r/rating-(\d)/
    |> Regex.run(css_classes, capture: :all_but_first)
    |> case do
      nil -> nil
      [rating] -> String.to_integer(rating)
    end
  end
end
