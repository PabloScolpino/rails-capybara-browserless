# frozen_string_literal: true

require 'rails_helper'

describe 'HomeController', :js do
  describe '#index' do
    it 'validates access to the page' do
      visit '/'
      # To interactively debug
      # debug(binding)
      expect(page).to have_text('Home#index')
    end
  end
end
