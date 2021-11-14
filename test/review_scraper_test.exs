defmodule ReviewScraperTest do
  use ExUnit.Case

  import ReviewScraper.DealerRaterMock

  alias ReviewScraper.DealerRater.Review

  setup do
    mock_dealer_rater_endpoint(200)
  end

  describe "get_overly_positive_reviews/2" do
    test "loads the three most positive reviews from a dealership" do
      assert {:ok, reviews} = ReviewScraper.get_overly_positive_reviews("Dealership Name")

      assert length(reviews) == 3
    end

    test "loads the specified amount of reviews from a dealership" do
      options = [reviews_count: 5]

      assert {:ok, reviews} =
               ReviewScraper.get_overly_positive_reviews("Dealership Name", options)

      assert length(reviews) == 5
    end

    test "returns error if a dealership is not found by its name" do
      mock_dealer_rater_endpoint(500)

      assert {:error, :dealership_not_found} =
               ReviewScraper.get_overly_positive_reviews("Dealership Name")
    end
  end

  describe "sort_reviews_by_positiveness/1" do
    test "filters reviews that haven't recommended the dealer" do
      reviews = [
        %Review{recommend_dealer?: false},
        %Review{recommend_dealer?: false},
        %Review{recommend_dealer?: false},
        %Review{description: "I recommend this dealer.", recommend_dealer?: true}
      ]

      assert [
               %Review{
                 description: "I recommend this dealer.",
                 recommend_dealer?: true
               }
             ] = ReviewScraper.sort_reviews_by_positiveness(reviews)
    end

    test "sorts reviews by average rating" do
      review_1 = %Review{
        recommend_dealer?: true,
        dealership_rating: 1,
        customer_service_rating: 1,
        friendliness_rating: 1,
        pricing_rating: 1,
        overall_experience_rating: 1
      }

      review_2 = %Review{
        recommend_dealer?: true,
        dealership_rating: 2,
        customer_service_rating: 2,
        friendliness_rating: 2,
        pricing_rating: 2,
        overall_experience_rating: 2
      }

      review_3 = %Review{
        recommend_dealer?: true,
        dealership_rating: 3,
        customer_service_rating: 3,
        friendliness_rating: 3,
        pricing_rating: 3,
        overall_experience_rating: 3
      }

      review_4 = %Review{
        recommend_dealer?: true,
        dealership_rating: 4,
        customer_service_rating: 4,
        friendliness_rating: 4,
        pricing_rating: 4,
        overall_experience_rating: 4
      }

      review_5 = %Review{
        recommend_dealer?: true,
        dealership_rating: 5,
        customer_service_rating: 5,
        friendliness_rating: 5,
        pricing_rating: 5,
        overall_experience_rating: 5
      }

      reviews = [review_1, review_2, review_3, review_4, review_5]

      assert ReviewScraper.sort_reviews_by_positiveness(reviews) == [
               review_5,
               review_4,
               review_3,
               review_2,
               review_1
             ]
    end

    test "sorts by usage of positive words" do
      review_1 = %Review{
        description: "The most amazing dealer",
        recommend_dealer?: true,
        dealership_rating: 5,
        customer_service_rating: 5,
        friendliness_rating: 5,
        pricing_rating: 5,
        overall_experience_rating: 5
      }

      review_2 = %Review{
        description: "Super excellent and perfect dealer",
        recommend_dealer?: true,
        dealership_rating: 5,
        customer_service_rating: 5,
        friendliness_rating: 5,
        pricing_rating: 5,
        overall_experience_rating: 5
      }

      review_3 = %Review{
        description:
          "Extremely fantastic. An wonderful experience. " <>
            "I'm sure it's the most amazing dealer in the world.",
        recommend_dealer?: true,
        dealership_rating: 5,
        customer_service_rating: 5,
        friendliness_rating: 5,
        pricing_rating: 5,
        overall_experience_rating: 5
      }

      reviews = [review_1, review_2, review_3]

      assert ReviewScraper.sort_reviews_by_positiveness(reviews) == [
               review_3,
               review_2,
               review_1
             ]
    end
  end
end
