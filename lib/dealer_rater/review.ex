defmodule ReviewScraper.DealerRater.Review do
  defstruct title: "",
            description: "",
            reviewer_name: "",
            date: "",
            dealership_rating: nil,
            customer_service_rating: nil,
            friendliness_rating: nil,
            pricing_rating: nil,
            overall_experience_rating: nil,
            recommend_dealer?: false

  @type t() :: %__MODULE__{
          title: String.t(),
          description: String.t(),
          reviewer_name: String.t(),
          date: String.t(),
          dealership_rating: non_neg_integer(),
          customer_service_rating: non_neg_integer() | nil,
          friendliness_rating: non_neg_integer() | nil,
          pricing_rating: non_neg_integer() | nil,
          overall_experience_rating: non_neg_integer() | nil,
          recommend_dealer?: boolean() | nil
        }
end
