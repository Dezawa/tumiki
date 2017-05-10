# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'i18n'
require 'yaml'
require 'action_view'
require 'action_controller'
require 'active_record'
#require 'action_view/helpers/form_helpe'
require 'tumiki'
require 'pp'

class Block < ActiveRecord::Base
end
class BlockDumy
  ATTR = [:id, :name,:address,:date,:col1]
  attr_accessor *ATTR
  def initialize(args)
    ATTR.each{|attr| instance_variable_set("@#{attr}",args[attr])}
  end  
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
    column :date, format: "%Y-%m-%d"
    #3,4
    column :col1,as: :radio ,correction: [["radio0",0],["radio1",1]]
    column :col1,as: :radio ,correction: ["radio0","radio1"]
    # 5,6,7
    column :col1,as: :select ,correction: [["select0",0],["select1",1]]
    column :col1,as: :select ,correction: ["select0","select1"]
    column :col1,as: :select ,correction: [["select0",0],["select1",1]],
           include_blank: true, editable: true
    # 8,9
     column :col1,as: :hidden
     column :col1,as: :area
     # 10,11,12,13
     column :col1,as: :checkbox
     column :col1,as: :checkbox,correction: ["可"]
     column :col1,as: :checkbox,correction: [["可","1"]]
     column :col1,as: :checkbox,correction: [["可","1"],["否","0"]]
     
  end
end
class Tumiki::Column
  def text=(b); @text = b ; end
  def edit_on_table=(b); @edit_on_table = b ; end
  def correction=(b); @correction = b ; end
end
def diff ary0,ary1
  [ary0 - ary1,ary1 - ary0]
end

radio_pre = %(<nobr><input type="radio" name="block#ID#[col1]"
       id="block_#id#col1_%s" value="%s" )
radio_mid = %(/><label for="block_#id#col1_%s">radio%s</label><input
       type="radio" name="block#ID#[col1]"
       id="block_#id#col1_%s" value="%s" )
radio_post = %(%s /><label for="block_#id#col1_%s">radio%s</label></nobr>)

RadioFormDisabled = (radio_pre + ' disabled="disabled" ' +
                     radio_mid + ' disabled="disabled" ' +
                     radio_post ).gsub(/#ID#/,"").gsub(/#id#/,"")
RadioFormEnable = (radio_pre + radio_mid + radio_post ).gsub(/#ID#/,"").gsub(/#id#/,"")
RadioFormDisabledWithID = (radio_pre + ' disabled="disabled" ' +
                     radio_mid + ' disabled="disabled" ' +
                     radio_post ).gsub(/#ID#/,"[123]").gsub(/#id#/,"123_")
RadioFormEnableWithID  = (radio_pre + radio_mid + radio_post
                         ).gsub(/#ID#/,"[123]").gsub(/#id#/,"123_")

select_com = ' id="block_#id#col1" name="block#ID#[col1]">' +
             '<option value="%s">select0</option>' + "\n" +
             '<option %svalue="%s">select1</option></select>'
SelectFormDisabled = ('<select disabled="disabled"'+select_com
                     ).gsub(/#ID#/,"").gsub(/#id#/,"")
SelectFormEnable   = ('<select' + select_com).gsub(/#ID#/,"").gsub(/#id#/,"")
SelectFormDisabledWithID = ('<select disabled="disabled"'+select_com
                           ).gsub(/#ID#/,"[123]").gsub(/#id#/,"123_")
SelectFormEnableWithID   = ('<select' + select_com).gsub(/#ID#/,"[123]").gsub(/#id#/,"123_")

checkbox = "<input type=\"checkbox\" name=\"block#ID#[col1]\" id=\"block_#id#col1\" value=\"%s\" "

Selected = 'selected="selected" '
NotSelected = ''
Checked = 'checked="checked" '
NotChecked = ""
CheckBoxDisabled = (checkbox + "disabled=\"disabled\" %s/>").gsub(/#ID#/,"").gsub(/#id#/,"")
CheckBoxEnable = (checkbox + "%s/>").gsub(/#ID#/,"").gsub(/#id#/,"")
CheckBoxDisabledWithID = (checkbox + "disabled=\"disabled\" %s/>").gsub(/#ID#/,"[123]").gsub(/#id#/,"123_")
CheckBoxEnableWithID = (checkbox + "%s/>").gsub(/#ID#/,"[123]").gsub(/#id#/,"123_")
# I18n

I18n.enforce_available_locales = true ## 対応ずみ言語かを実行時にチェックして止める
I18n.backend = I18n::Backend::Simple.new

## Yamlのパスをアレイで渡すとロードする
I18n.backend.load_translations(
  Dir.glob(File.expand_path('../locales/*.yml', __FILE__)))
## デフォルト言語にフォールバック https://github.com/svenfuchs/i18n/wiki/Fallbacks
I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
