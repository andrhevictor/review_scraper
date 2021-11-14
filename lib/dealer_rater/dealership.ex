defmodule ReviewScraper.DealerRater.Dealership do
  defstruct dealer_id: "",
            dealer_name: "",
            dealer_name_encoded: ""

  @type t() :: %__MODULE__{
          dealer_id: String.t(),
          dealer_name: String.t(),
          dealer_name_encoded: String.t()
        }
end
