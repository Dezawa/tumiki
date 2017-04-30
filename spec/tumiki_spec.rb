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
  describe "version" do
    it 'has a version number' do
      expect(Tumiki::VERSION).not_to be nil
    end
  end
  
  describe "cntroller" do
    # view で labels_for
    before do
      @controller = BlockController.new
      @controller.tumiki_instanse_variable
      @controller.index_columns
    end
    it 'columns labels' do
      expect(@controller.columns.map{|c| c.label}).to eq(%w(名前 Address))
    end
    it 'columns label for' do
      expect(label(:block,:name)).to eq('<label for="block_name">Name</label>')
    end
    it 'columns label_for' do
      expect(@controller.columns.map{|c| c.label_for}).
        to eq( ['<label for="block_name">名前</label>',
                '<label for="block_address">Address</label>',
               ])
    end
  end
end
