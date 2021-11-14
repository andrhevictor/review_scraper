defmodule ReviewScraper.DealerRater.ScraperTest do
  use ExUnit.Case

  alias ReviewScraper.DealerRater.{Review, Scraper}

  describe "get_reviews/1" do
    test "parse the html document and return list of reviews" do
      html_document = File.read!("./test/dealer_rater_samples/review_page.html")

      reviews = Scraper.get_reviews(html_document)

      assert length(reviews) == 10

      first_review = Enum.at(reviews, 0)

      assert %Review{
               customer_service_rating: 5,
               date: "November 13, 2021",
               dealership_rating: 5,
               description:
                 "Jeannie was excellent at greeting us and through every step of the process." <>
                   _rest_of_description,
               friendliness_rating: 5,
               overall_experience_rating: 5,
               pricing_rating: 5,
               recommend_dealer?: true,
               reviewer_name: "Pdblair47",
               title: "Jeannie was excellent at greeting us and through every..."
             } = first_review
    end
  end
end
