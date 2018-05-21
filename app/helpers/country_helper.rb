# frozen_string_literal: true

module CountryHelper
  def display_country(selected_country = params[:country])
    @countries = ISO3166::Country.all.sort
    collection_select(:profile, :country, @countries, :alpha3, :name,
                      { prompt: 'Select country', selected: selected_country },
                      class: 'form-control form-control-lg underlined')
  end
end
