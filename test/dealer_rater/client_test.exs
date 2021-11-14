defmodule ReviewScraper.DealerRater.ClientTest do
  use ExUnit.Case

  alias ReviewScraper.DealerRater.{Client, Dealership}

  import ReviewScraper.DealerRaterMock

  setup do
    mock_dealer_rater_endpoint(200)
  end

  describe "get_review_page/2" do
    test "returns html document if page is found" do
      dealership = %Dealership{dealer_id: "123456", dealer_name_encoded: "Dealer-Name"}
      assert Client.get_review_page(dealership) =~ "html"
    end

    test "returns an empty string if page is not found" do
      mock_dealer_rater_endpoint(500)

      dealership = %Dealership{dealer_id: "123456", dealer_name_encoded: "Dealer-Name"}
      assert Client.get_review_page(dealership) == ""
    end
  end

  describe "find_dealership_by_name/1" do
    test "returns the dealership if it exists" do
      assert {:ok, %Dealership{} = dealership} = Client.find_dealership_by_name("Dealership Name")

      assert dealership.dealer_name == "Dealership Name"
    end

    test "returns an error if dealership is not found" do
      mock_dealer_rater_endpoint(500)

      assert {:error, :dealership_not_found} = Client.find_dealership_by_name("Dealership Name")
    end
  end
end
