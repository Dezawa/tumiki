# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'i18n'
require 'action_view'
require 'action_controller'
require 'active_record'
#require 'action_view/helpers/form_helpe'
require 'tumiki'
require 'pp'

class Block < ActiveRecord::Base
end
class BlockController <  ActionController::Base
  include Tumiki::ApplicationControllerExtension
  include Tumiki
  attr_accessor :params
  before_filter :tumiki_instanse_variable
  def initialize(*args)
    super *args
    @params = {}
  end

  def index_columns
    column :name, label: "名前"
    column :address
  end
end
  
