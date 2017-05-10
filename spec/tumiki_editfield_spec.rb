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
  
  before do
    @controller = BlockController.new
    @controller.tumiki_instanse_variable
    @controller.index_columns
    @block = BlockDumy.new(BlockArgs)
  end
  
  ### Select ##
  describe "Select" do
    describe "text: trueの時" do
      before do
        [5,6].each{|c| @controller.columns[c].text = true }
      end
      describe "editableもediton_tableも未定義だとString" do
        it "初期値 1" do
          @block.col1 = 1 #1
          expect(@controller.columns[5].edit_field(@block)).to eq 'select1'
        end
        it "初期値 select1" do
          @block.col1 = "select1" #1
          expect(@controller.columns[6].edit_field(@block)).to eq 'select1'
        end
      end
      describe "editable true,edit_on_table edditingだとEnable" do
        before do
          [5,6].each{|c| @controller.columns[c].editable = true }
          [5,6].each{|c| @controller.columns[c].edit_on_table = :editting }
        end
        it "初期値 未定義" do
          expect(@controller.columns[5].edit_field(@block)).
          to eq SelectFormEnableWithID%[0,NotChecked,1]
        end
        it "初期値 1" do
          @block.col1 = "select1" #1
          expect(@controller.columns[6].edit_field(@block)).
          to eq SelectFormEnableWithID%["select0",Selected,"select1"]
        end
      end
      describe "editable trueでもedit_on_tableが editだとString" do
        before do
          [5,6].each{|c| @controller.columns[c].editable = true }
          [5,6].each{|c| @controller.columns[c].edit_on_table = :edit }
        end
        it "初期値 未定義" do
          expect(@controller.columns[5].edit_field(@block)).
          to eq "" #SelectFormDisabledWithID%[0,NotSelected,1]
        end
        it "初期値 1" do
          @block.col1 = "select1" #1
          expect(@controller.columns[6].edit_field(@block)).
          to eq "select1" #SelectFormDisabledWithID%[0,Selected,1]
        end
      end
      describe "editable trueでもedit_on_tableが on_cellだとDisable" do
        before do
          [5,6].each{|c| @controller.columns[c].editable = true }
          [5,6].each{|c| @controller.columns[c].edit_on_table = :on_cell }
        end
        it "初期値 未定義" do
          expect(@controller.columns[5].edit_field(@block)).
          to eq SelectFormDisabledWithID%[0,NotSelected,1]
        end
        it "初期値 1" do
          @block.col1 = "select1" #1
          expect(@controller.columns[6].edit_field(@block)).
          to eq SelectFormDisabledWithID%["select0",Selected,"select1"]
        end
      end
    end
    
    describe "text: なし" do
      it 'editableもediton_tableも未定義だと Disabele初期値なし' do
        expect(@controller.columns[5].edit_field(@block)).
          to eq SelectFormDisabledWithID%[0,"",1]
      end
      it 'edit select 初期値 1' do
        @block.col1 = 1
        expect(@controller.columns[5].edit_field(@block)).
          to eq SelectFormDisabledWithID%[0,'selected="selected" ',1]
      end
    end
    
    describe "@edit_on_table == :on_cell" do
      before do
        [5,6].each{|c| @controller.columns[c].edit_on_table = :on_cell}
      end
      describe "editable? is true" do
        before do
          [5,6].each{|c| @controller.columns[c].editable = true }
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit_field(@block).split,
                      (SelectFormDisabledWithID%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].edit_field(@block).split,
                      (SelectFormDisabledWithID%[0,'', 1]).split
                     )).to eq [[],[]]
        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6].each{|c| @controller.columns[c].editable = false }
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit_field(@block).split,
                      (SelectFormDisabledWithID%[0, "",1]).split
                     )).to eq [[],[]]
        end
        
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].edit_field(@block).split,
                      (SelectFormDisabledWithID%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
      end

    end
    describe "@edit_on_table == :editting" do
      before do
        [3,4,5,6,7].each{|c| @controller.columns[c].edit_on_table = :editting }
      end
      describe "editable? is true" do
        before do
          [3,4,5,6,7].each{|c| @controller.columns[c].editable = true }
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit_field(@block).split,
                      (SelectFormEnableWithID%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
            expect(diff(@controller.columns[5].edit_field(@block).split,
                        (SelectFormEnableWithID%[0,'', 1]).split
                       )).to eq [[],[]]
        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6,7].each{|c| @controller.columns[c].editable = false }
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit_field(@block).split,
                      (SelectFormDisabledWithID%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].edit_field(@block).split,
                      (SelectFormDisabledWithID%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
      end
    end
    
  end
  ### Select ここまで ###

  describe "to_sを返すケース:editable=false" do
    before do
      (0..6).each {|clm| @controller.columns[clm].editable = false }
    end
    describe "as が無いかtext" do
      it 'edit' do
        expect(@controller.columns.first.edit_field(@block)).
          to eq "Dezawa"
      end
      it 'edit format付き' do
        expect(@controller.columns[2].edit_field(@block)).
          to eq "2017-02-03"
      end
    end
    describe "as があるが text: true" do
      before do
        [3,4].each{|c| @controller.columns[c].text = true }
      end

      it "radio correction=>[label,idx]" do
        @block.col1 = 1 #1
        expect(@controller.columns[3].edit_field(@block)).to eq 'radio1'
      end
      it "radio correction=>[val,val]" do
        @block.col1 = "radio1" #1
        expect(@controller.columns[4].edit_field(@block)).to eq 'radio1'
      end
    end
  end
  describe "editable=true" do
    it 'as: :text' do
      expect(@controller.columns.first.edit_field(@block)).
        to eq "<input type=\"text\" name=\"block[123][name]\" id=\"block_123_name\" value=\"Dezawa\" />"
    end
    it 'as: :text :format付' do
      expect(@controller.columns[2].edit_field(@block)).
        to eq "<input type=\"text\" name=\"block[123][date]\" id=\"block_123_date\" value=\"2017-02-03\" />"
    end
    describe "Radio" do
      it 'edit radio 初期値なし' do
        puts @controller.columns[3].edit_field(@block)
        expect(diff(@controller.columns[3].edit_field(@block).split,
                    (RadioFormEnableWithID%[0, 0, 0, 0, 1, 1, "", 1,1]).split
                   )).to eq [[],[]]
      end
      it 'edit radio no value 初期値なし' do
        expect( diff(@controller.columns[4].edit_field(@block).split,
                     (RadioFormEnableWithID%["radio0","radio0","radio0", 0,"radio1","radio1","","radio1", 1]).split
                    )).to eq [[],[]]
      end
      it 'edit radio 初期値 1' do
        @block.col1="radio1" #1
        expect(diff(@controller.columns[4].edit_field(@block).split ,
                    (RadioFormEnableWithID%(%w(radio0 radio0 radio0 0 radio1 radio1 checked="checked" radio1 1))).split
                   )).to eq [[],[]]
      end
      it 'edit radio no value 初期値 radio1' do
        @block.col1="radio1"
        expect(diff(@controller.columns[4].edit_field(@block).split,
                    (RadioFormEnableWithID%["radio0","radio0","radio0", 0,"radio1","radio1",
                                      'checked="checked"',"radio1", 1]).split
                   )).to eq [[],[]]
      end
    end
    
    describe "@edit_on_table == :on_cell" do
      before do
        [3,4,5,6,7].each{|c| @controller.columns[c].edit_on_table = :on_cell}
      end
      describe "editable? is true" do
        before do
          [3,4,5,6,7].each{|c| @controller.columns[c].editable = true }
        end
        ###
        it 'edit select 初期値なし radio' do
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormDisabledWithID%[0,0,0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormDisabledWithID%[0,0,0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          expect(@controller.columns[7].edit_field(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_123_col1\" name=\"block[123][col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6].each{|c| @controller.columns[c].editable = false }
        end
        ###
        it 'edit select 初期値なし radio' do
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormDisabledWithID%[0,0,0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormDisabledWithID%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          expect(@controller.columns[7].edit_field(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_123_col1\" name=\"block[123][col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
    end
    
    describe "@edit_on_table == :editting" do
      before do
        [3,4,5,6,7].each{|c| @controller.columns[c].edit_on_table = :editting }
      end
      describe "editable? is true" do
        before do
          [3,4,5,6,7].each{|c| @controller.columns[c].editable = true }
        end
        ###
        it 'edit se,"radio1"lect 初期値なし radio' do
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormEnableWithID%[0,0, 0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormEnableWithID%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          @col7 = @controller.columns[7]
          def @col7.edit_on_table ; :editting ; end
          
          expect(@controller.columns[7].edit_field(@block)).
            to eq "<select id=\"block_123_col1\" name=\"block[123][col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6,7].each{|c| @controller.columns[c].editable = false }
        end
        ###
        it 'edit select 初期値なし radio' do
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormDisabledWithID%[0,0, 0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit_field(@block).split,
                      (RadioFormDisabledWithID%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1"))
          expect(@controller.columns[7].edit_field(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_123_col1\" name=\"block[123][col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
    end
  end
  it "hidden" do
    expect(@controller.columns[8].edit_field(@block)).
      to eq "<input type=\"hidden\" name=\"block[123][col1]\" id=\"block_123_col1\" />"
  end
  it "area" do
    expect(@controller.columns[9].edit_field(@block)).
      to eq "<textarea name=\"block[123][col1]\" id=\"block_123_col1\">\n</textarea>"
  end
end

