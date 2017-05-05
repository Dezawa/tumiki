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
  describe "to_sを返すケース" do
    describe "as が無いかtext" do
      it 'disp' do
        expect(@controller.columns.first.disp(@block)).
          to eq "Dezawa"
      end
      it 'disp format付き' do
        expect(@controller.columns[2].disp(@block)).
          to eq "2017-02-03"
      end
    end    
    describe "as があるが text: true" do
      before do
        [3,4,5,6].each{|c| @controller.columns[c].text = true }
      end

      it "radio correction=>[label,idx]" do
        @block.col1 = 1 #1
        expect(@controller.columns[3].disp(@block)).to eq 'radio1'
      end
      it "radio correction=>[val,val]" do
        @block.col1 = "radio1" #1
        expect(@controller.columns[4].disp(@block)).to eq 'radio1'
      end
      it "select" do
        @block.col1 = 1 #1
        expect(@controller.columns[5].disp(@block)).to eq 'select1'
      end
      it "radio correction=>[val,val]" do
        @block.col1 = "select1" #1
        expect(@controller.columns[6].disp(@block)).to eq 'select1'
      end
    end
  end
  describe "as があり text: true でない" do
    describe "@edit_on_table == :on_cell,:editing でない" do
      describe "Radio" do
        it 'disp radio 初期値なし' do
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0, 0, 0, 0, 1, 1, "", 1,1]).split
                     )).to eq [[],[]]
        end

        it 'disp radio no value 初期値なし' do
          expect( diff(@controller.columns[4].disp(@block).split,
                       (RadioFormDisabled%["radio0","radio0","radio0", 0,"radio1","radio1","","radio1", 1]).split
                      )).to eq [[],[]]
        end
        it 'disp radio 初期値 1' do
          @block.col1="radio1" #1
          expect(diff(@controller.columns[4].disp(@block).split ,
                      (RadioFormDisabled%(%w(radio0 radio0 radio0 0 radio1 radio1 checked="checked" radio1 1))).split
                     )).to eq [[],[]]
        end
        it 'disp radio no value 初期値 radio1' do
          @block.col1="radio1"
          expect(diff(@controller.columns[4].disp(@block).split,
                      (RadioFormDisabled%["radio0","radio0","radio0", 0,"radio1","radio1",
                                          'checked="checked"',"radio1", 1]).split
                     )).to eq [[],[]]
        end
      end
      describe "Select" do
        it 'disp select 初期値なし' do
          expect(@controller.columns[5].disp(@block)).
            to eq SelectFormDisabled%[0,"",1]
        end
        it 'disp select 初期値 1' do
          @block.col1 = 1
          expect(@controller.columns[5].disp(@block)).
            to eq SelectFormDisabled%[0,'selected="selected" ',1]
        end
      end
    end
    describe "@edit_on_table == :on_cell" do
      before do
        [3,4,5,6].each{|c| @controller.columns[c].edit_on_table = :on_cell}
      end
      describe "editable? is true" do
        before do
          [3,4,5,6].each{|c| @controller.columns[c].editable = true }
        end
        ###
        it 'disp select 初期値なし radio' do
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0,0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値なし select' do
          expect(diff(@controller.columns[5].disp(@block).split,
                      (SelectFormDisabled%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0,0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].disp(@block).split,
                      (SelectFormDisabled%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
        it 'disp select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          expect(@controller.columns[7].disp(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6].each{|c| @controller.columns[c].editable = false }
        end
        ###
        it 'disp select 初期値なし radio' do
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0,0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値なし select' do
          expect(diff(@controller.columns[5].disp(@block).split,
                      (SelectFormDisabled%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].disp(@block).split,
                      (SelectFormDisabled%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
        it 'disp select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          expect(@controller.columns[7].disp(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
    end # of on_cell_edit
    #####################################################
    describe "@edit_on_table == :editting" do
      before do
          [3,4,5,6].each{|c| @controller.columns[c].edit_on_table = :editting }
      end
      describe "editable? is true" do
        before do
          [3,4,5,6].each{|c| @controller.columns[c].editable = true }
        end
        ###
        it 'disp se,"radio1"lect 初期値なし radio' do
          puts @controller.columns[3].disp(@block)
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値なし select' do
          puts @controller.columns[5].disp(@block)
          expect(diff(@controller.columns[5].disp(@block).split,
                      (SelectFormDisabled%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable select' do
          @block.col1="select1"
            expect(diff(@controller.columns[5].disp(@block).split,
                        (SelectFormDisabled%[0,'', 1]).split
                       )).to eq [[],[]]
        end
        
        it 'disp select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          @col7 = @controller.columns[7]
          def @col7.edit_on_table ; :editting ; end
          
          expect(@controller.columns[7].disp(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6].each{|c| @controller.columns[c].editable = false }
        end
        ###
        it 'disp select 初期値なし radio' do
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値なし select' do
          expect(diff(@controller.columns[5].disp(@block).split,
                      (SelectFormDisabled%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].disp(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1,1]).split
                     )).to eq [[],[]]
        end
        it 'disp select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].disp(@block).split,
                      (SelectFormDisabled%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
        it 'disp select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          expect(@controller.columns[7].disp(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
    end
  end
  it "hidden" do
    expect(@controller.columns[8].disp(@block)).
      to eq "<input type=\"hidden\" name=\"block[col1]\" id=\"block_col1\" />"
  end
  it "area" do
    expect(@controller.columns[9].disp(@block)).
      to eq "<textarea name=\"block[col1]\" id=\"block_col1\" " +
            "disabled=\"disabled\">\n</textarea>"
  end

  describe "CheckBox" do
    describe "correction無し" do
      describe "初期値無し" do
        it ":text ありは nil" do
          @controller.columns[10].text = true
          expect(@controller.columns[10].disp(@block)).to eq ""
        end
        it ":text 無しは □" do
          expect(@controller.columns[10].disp(@block)).
            to eq "<input type=\"checkbox\" name=\"block[col1]\" id=\"block_col1\" value=\"1\" disabled=\"disabled\" />"
        end
      end
      describe "初期値 1 " do
        before do
          @block.col1 = "1"
        end
        it ":text ありは nil" do
          @controller.columns[10].text = true
          expect(@controller.columns[10].disp(@block)).to eq "1"
        end
        it ":text 無しは □" do
          expect(@controller.columns[10].disp(@block)).
            to eq CheckBoxDisabled%["1",Checked]
        end
        describe "初期値 0 " do
          before do
            @block.col1 = "0"
          end
          it ":text ありは nil" do
            @controller.columns[10].text = true
            expect(@controller.columns[10].disp(@block)).to eq "0"
          end
          it ":text 無しは □" do
            expect(@controller.columns[10].disp(@block)).
              to eq CheckBoxDisabled%[ "1", NotChecked]
          end
        end
      end
    end
    describe "correctionあり" do
      describe "[可]" do
        describe "初期値無し" do
          it ":text ありでも□" do
            @controller.columns[11].text = true
            expect(@controller.columns[11].disp(@block)).
              to eq CheckBoxDisabled%["可",NotChecked]+"可"
          end
          it ":text 無しは □" do
            expect(@controller.columns[11].disp(@block)).
              to eq CheckBoxDisabled%["可",NotChecked]+"可"
          end
        end
        describe "初期値 可 " do
          before do
            @block.col1 = "可"
          end
          it ":text 無しは □" do
            expect(@controller.columns[11].disp(@block)).
              to eq CheckBoxDisabled%["可",Checked]+"可"
          end
        end
        describe "初期値 1 " do
          before do
            @block.col1 = "1"
          end
          it ":text 無しは □" do
            expect(@controller.columns[12].disp(@block)).
              to eq CheckBoxDisabled%["1",Checked]+"可"
          end
          describe "初期値 0 " do
            before do
              @block.col1 = "0"
            end
            it ":text 無しは □" do
              expect(@controller.columns[12].disp(@block)).
                to eq CheckBoxDisabled%[ "1", NotChecked]+"可"
            end
          end
        end
      end
    end
  end
end

  # with_index
