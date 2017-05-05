# coding: utf-8
require 'spec_helper'
# require 'rubygems'
# require 'rails_railtie'
# require 'rspec-rails'
# require 'rspec-html-matchers'

#  gem 'rspec-rails', '~> 3.0.0'
#  gem 'rspec-html-matchers'

include ActionView::Helpers::FormHelper
RSpec.describe Tumiki, :type => :controller do
  
  BlockArgs = {id: 123, name: "Dezawa",
          addr: "Kanagawa JAPAN",
          date: Date.new(2017,2,3)
         }
  describe "model#表示 色々" do
    
    before do
      @controller = BlockController.new
      @controller.tumiki_instanse_variable
      @controller.index_columns
      @block = BlockDumy.new(BlockArgs)
    end
    it '' do  
    end
  end
end
