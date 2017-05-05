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
  describe "to_sを返すケース:editable=false" do
    before do
      (0..6).each {|clm| @controller.columns[clm].editable = false }
    end
    describe "as が無いかtext" do
      it 'edit' do
        expect(@controller.columns.first.edit(@block)).
          to eq "Dezawa"
      end
      it 'edit format付き' do
        expect(@controller.columns[2].edit(@block)).
          to eq "2017-02-03"
      end
    end
    describe "as があるが text: true" do
      before do
        [3,4,5,6].each{|c| @controller.columns[c].text = true }
      end

      it "radio correction=>[label,idx]" do
        @block.col1 = 1 #1
        expect(@controller.columns[3].edit(@block)).to eq 'radio1'
      end
      it "radio correction=>[val,val]" do
        @block.col1 = "radio1" #1
        expect(@controller.columns[4].edit(@block)).to eq 'radio1'
      end
      it "select" do
        @block.col1 = 1 #1
        expect(@controller.columns[5].edit(@block)).to eq 'select1'
      end
      it "radio correction=>[val,val]" do
        @block.col1 = "select1" #1
        expect(@controller.columns[6].edit(@block)).to eq 'select1'
      end
    end
  end
  describe "editable=true" do
    it 'as: :text' do
      expect(@controller.columns.first.edit(@block)).
        to eq "<input type=\"text\" name=\"block[name]\" id=\"block_name\" value=\"Dezawa\" />"
    end
    it 'as: :text :format付' do
      expect(@controller.columns[2].edit(@block)).
        to eq "<input type=\"text\" name=\"block[date]\" id=\"block_date\" value=\"2017-02-03\" />"
    end
    describe "Radio" do
      it 'edit radio 初期値なし' do
        expect(diff(@controller.columns[3].edit(@block).split,
                    (RadioFormEnable%[0, 0, 0, 0, 1, 1, "", 1,1]).split
                   )).to eq [[],[]]
      end
      it 'edit radio no value 初期値なし' do
        expect( diff(@controller.columns[4].edit(@block).split,
                     (RadioFormEnable%["radio0","radio0","radio0", 0,"radio1","radio1","","radio1", 1]).split
                    )).to eq [[],[]]
      end
      it 'edit radio 初期値 1' do
        @block.col1="radio1" #1
        expect(diff(@controller.columns[4].edit(@block).split ,
                    (RadioFormEnable%(%w(radio0 radio0 radio0 0 radio1 radio1 checked="checked" radio1 1))).split
                   )).to eq [[],[]]
      end
      it 'edit radio no value 初期値 radio1' do
        @block.col1="radio1"
        expect(diff(@controller.columns[4].edit(@block).split,
                    (RadioFormEnable%["radio0","radio0","radio0", 0,"radio1","radio1",
                                      'checked="checked"',"radio1", 1]).split
                   )).to eq [[],[]]
      end
    end
    
    describe "Select" do
      SelectForm = '<select %sid="block_col1" name="block[col1]"><option value="%s">select0</option>' + "\n" +
                   '<option %svalue="%s">select1</option></select>'
      it 'edit select 初期値なし' do
        expect(@controller.columns[5].edit(@block)).
          to eq SelectFormEnable%[0,"",1]
      end
      it 'edit select 初期値 1' do
        @block.col1 = 1
        expect(@controller.columns[5].edit(@block)).
          to eq SelectFormEnable%[0,'selected="selected" ',1]
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
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormDisabled%[0,0,0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectFormDisabled%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormDisabled%[0,0,0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectFormDisabled%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          expect(@controller.columns[7].edit(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6].each{|c| @controller.columns[c].editable = false }
        end
        ###
        it 'edit select 初期値なし radio' do
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormDisabled%[0,0,0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectForm%["disabled=\"disabled\" ",0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectForm%["disabled=\"disabled\" ",0,'', 1]).split
                     )).to eq [[],[]]
        end
        
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          expect(@controller.columns[7].edit(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

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
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormEnable%[0,0, 0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectFormEnable%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormEnable%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectFormEnable%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1",editable: true))
          @col7 = @controller.columns[7]
          def @col7.edit_on_table ; :editting ; end
          
          expect(@controller.columns[7].edit(@block)).
            to eq "<select id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
      describe "editable? is false" do
        before do
          [3,4,5,6,7].each{|c| @controller.columns[c].editable = false }
        end
        ###
        it 'edit select 初期値なし radio' do
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"",1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値なし select' do
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectFormDisabled%[0, "",1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable radio' do
          @block.col1 = 1
          expect(diff(@controller.columns[3].edit(@block).split,
                      (RadioFormDisabled%[0,0, 0, 0,1,1,"checked=\"checked\"",1,1,1]).split
                     )).to eq [[],[]]
        end
        it 'edit select 初期値 select1 editable select' do
          @block.col1="select1"
          expect(diff(@controller.columns[5].edit(@block).split,
                      (SelectFormDisabled%[0,'', 1]).split
                     )).to eq [[],[]]
        end
        
        it 'edit select 初期値 select1 空白可能' do
          @block = BlockDumy.
                   new(BlockArgs.merge(col1: "select1"))
          expect(@controller.columns[7].edit(@block)).
            to eq "<select disabled=\"disabled\" id=\"block_col1\" name=\"block[col1]\"><option value=\"\"></option>\n<option value=\"0\">select0</option>\n<option value=\"1\">select1</option></select>"

        end
      end
    end

    it "hidden" do
      expect(@controller.columns[8].edit(@block)).
        to eq "<input type=\"hidden\" name=\"block[col1]\" id=\"block_col1\" />"
    end
    it "area" do
      expect(@controller.columns[9].edit(@block)).
        to eq "<textarea name=\"block[col1]\" id=\"block_col1\">\n</textarea>"
    end
    describe "CheckBox" do
      describe "correction無し" do
        describe "初期値無し" do
          it ":text ありは nil" do
            @controller.columns[10].text = true
            expect(@controller.columns[10].edit(@block)).to eq ""
          end
          it ":text 無しは □" do
            expect(@controller.columns[10].edit(@block)).
              to eq CheckBoxEnable%["1",NotChecked]
          end
        end
        describe "初期値 1 " do
          before do
            @block.col1 = "1"
          end
          it ":text ありは nil" do
            @controller.columns[10].text = true
            expect(@controller.columns[10].edit(@block)).to eq "1"
          end
          it ":text 無しは □" do
            expect(@controller.columns[10].edit(@block)).
              to eq CheckBoxEnable%["1",Checked]
          end
          describe "初期値 0 " do
            before do
              @block.col1 = "0"
            end
            it ":text ありは nil" do
              @controller.columns[10].text = true
              expect(@controller.columns[10].edit(@block)).to eq "0"
            end
            it ":text 無しは □" do
              expect(@controller.columns[10].edit(@block)).
                to eq CheckBoxEnable%[ "1", NotChecked]
            end
          end
        end
      end
      describe "correctionあり" do
        describe "[可]" do
          describe "初期値無し" do
          it ":text ありでも□" do
            @controller.columns[11].text = true
            expect(@controller.columns[11].edit(@block)).
              to eq CheckBoxEnable%["可",NotChecked]+"可"
          end
          it ":text 無しは □" do
            expect(@controller.columns[11].edit(@block)).
              to eq CheckBoxEnable%["可",NotChecked]+"可"
          end
        end
          describe "初期値 可 " do
            before do
              @block.col1 = "可"
            end
            it ":text 無しは □" do
              expect(@controller.columns[11].edit(@block)).
                to eq CheckBoxEnable%["可",Checked]+"可"
            end
          end
          describe "初期値 1 " do
            before do
              @block.col1 = "1"
            end
            it ":text 無しは □" do
              expect(@controller.columns[12].edit(@block)).
                to eq CheckBoxEnable%["1",Checked]+"可"
            end
            describe "初期値 0 " do
              before do
                @block.col1 = "0"
              end
              it ":text 無しは □" do
                expect(@controller.columns[12].edit(@block)).
                  to eq CheckBoxEnable%[ "1", NotChecked]+"可"
              end
            end
          end
        end
      end
    end
  end
end
  # with_id
