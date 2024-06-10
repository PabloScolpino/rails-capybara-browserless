# frozen_string_literal: true

require 'system_helper'

describe 'HomeController', :js do
  describe '#index' do
    it 'sees the rails logo' do
      visit '/'
      expect(page).to have_text('Rails version: 7.1.3.4')
    end
  end
end
