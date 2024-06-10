# frozen_string_literal: true

require 'system_helper'

describe 'HomeController', :js do
  describe '#index' do
    it 'validates access to the page' do
      visit '/'
      expect(page).to have_text('Home#index')
    end
  end
end
