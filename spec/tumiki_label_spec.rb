# coding: utf-8
require 'spec_helper'
# require 'rubygems'
# require 'rails_railtie'
# require 'rspec-rails'
# require 'rspec-html-matchers'

#  gem 'rspec-rails',columns.map '~> 3.0.0'
#  gem 'rspec-html-matchers'
  
include ActionView::Helpers::FormHelper
RSpec.describe Tumiki, :type => :controller do
  describe "version" do
    it 'has a version number' do
      expect(Tumiki::VERSION).not_to be nil
    end
  end
  
  describe "label 色々" do
    # view で labels_for
    before do
      @controller = BlockController.new
      @controller.tumiki_instanse_variable
      @controller.index_columns
    end
    it 'mode = nil' do
      expect(@controller.columns[0,2].map{|c| c.label}).
        to eq(["名前", "Address"])
    end

    it 'mode = i18n :ja' do
      I18n.locale = :ja
      expect(@controller.columns[0,2].map{|c| c.label :i18n}).
        to eq(["名称", "住所"])
    end
    it 'mode = i18n :en' do
      I18n.locale = :en
      expect(@controller.columns[0,2].map{|c| c.label :i18n}).
        to eq(["NAME", "ADDRESS"])
    end

    it 'columns label for' do
      expect(@controller.columns[0,2].map{|c| c.label :for}).
        to eq(["<label for=\"block_name\">名前</label>",
               "<label for=\"block_address\">Address</label>"])
    end
    it 'columns label_for_i18n :ja' do
      I18n.locale = :ja
      expect(@controller.columns[0,2].map{|c| c.label :for_i18n}).
        to eq( ['<label for="block_name">名称</label>',
                '<label for="block_address">住所</label>',
               ])
    end
    it 'columns label_for_i18n :en' do
      I18n.locale = :en
      expect(@controller.columns[0,2].map{|c| c.label :for_i18n}).
        to eq( ['<label for="block_name">NAME</label>',
                '<label for="block_address">ADDRESS</label>',
               ])
    end
  end
end
