# coding: utf-8
require "tumiki/version"
require 'tumiki/column'
require 'tumiki/filter'
require 'tumiki/query'
#
#TumikiはView、controllerの実装を助けるためのRailsのためのパッケージです。
#
#== 何ができるか
#1. indexでのtable、columnソート、絞り込みの実装を助けます
#
#1. table上でデータを編集する手段を提供します。(OnTabelEdit, OnCellEdit)
#
#1. index,show,edit のシンプルなview(views/application)とそのためのcontroller(application_controllerにincludeされるmodule Tumiki)を用意してあるので管理画面的なものはcolumnの定義だけでcodeなしで実装できます
#
#1. シンプルとは言え、カラムソート、絞り込み、css-class指定による装飾ができます。
#
#== INSTALL
#1. Gem
#Gemfileに以下を追加し、bundle install する。
#カラムソートのソート方向表示のためにfont-awesomeを使うのでそれも入れる。
#  gem 'tumiki' , github: 'Dezawa/tumiki'
#  gem 'font-awesome-rails'
#
#2. rake install
#  rails g tumiki:install
#これにより、以下がおこなわれます
#
#* file copy
#Tumikiの実行にあるとよい、views/application/*.html.erb、app/assets/ が
#copyされます。同名のfileがあると上書きされます。(いずれも tumiki_ で始まります)
#
#* fileの編集
#
#application_controller.rbに以下が追加されます
#  include Tumiki::ApplicationControllerExtensionTumiki
#  before_filter :tumiki_instanse_variable
#
#application_helper.rbに以下が追加されます
#  require 'tumiki/helper'
#  module ApplicationHelper
#    include Tumiki::Helper
#
#== USAGE
#=== Controller
#表示する項目をmethod #columnで定義する。index, show などでの表示順は
#定義順である
#  def index_columns
#    column :id
#    column :name ,label: "名前"
#    column :admin   ,as: :checkbox, correction: %w(管理者)
#    column :section ,as: :select, correction: %w(総務 経理)
#    column :section ,as: :select, correction: [["総務",1],["経理",2]]
#    column :section ,as: :radio, correction: [["総務",1],["経理",2]]
#    column :section ,editable: false, link: lambda{|m| section_path m}
#  end
#
#定義はArray @columnsに入る。これ以外に入れたい場合はoptional paramaterで指定する
#  def index_columns
#    @kolumns = []
#    column :id, {},@kolumns
#    column :name ,{label: "名前"},@kolumns
#  end
#    
#action show,edit,newの場合は次の順で探される
#- show : show_columns -> index_columns
#- new : new_columns -> edit_columns -> show_columns -> index_columns 
#- edit : new_columns -> edit_columns -> show_columns -> index_columns 
#
#table上で編集する edit_on_table, レコード追加＋編集する add_on_tableの場合は
#index_columns を用いる。
#
#これらを定義せず、それぞれのactionの中でcolumnを定義しても良い。
#
#=== View
#Tumiki標準のvonntrollerでは、modelのcorrenctionは @models、@modelに格納されて
#viewに渡される
#
#==== viewで使うmethod
#class Tumiki::Column のmethod。#label , #disp , #edit , #edit_field 
#
#=== <th> は attribute名、指定した文字列、もしくは ソートへのlinkとなる
#=== <td> は defaultは to_s。
#as optionにより、id(等)を表示用文字列に変換、checkbox、radioボタン、
#もしくは何らかへの link とできる
#
#=== OnTableEdit
#tableで一覧表示して、編集を可能にすることができる。
#mode無し :: クリックすると編集可能になる。cell毎に　model.updateする
#mode有り :: 全体を編集可能にしたり不可にしたり。teble全体をまとめてupdateする
#
#いずれも、カラム単位で編集可否を設定するが、さらに object毎の可否の設定も可能
#
#== 使う上での制約
#=== 表示collectionの代入変数
#  普通の使い方では、Model Userのcollection は @users に代入するが
#　　tumiki_helper.rb を使う場合は @models に代入する
#
#=== Controllerでのmethod の override
#==== tumiki_instanse_variable
#Tumiki moduleやtumiki関連helperが使うインスタンス変数を定義している
#ここの定義と異なる場合は、over ride が必要
#@Model :: モデルが入る。controller名から　s?Controller を削除したものを定義している。
#model名とcontrollerの対応が違っている場合、over rideする必要がある。
#
#@Domain :: モデルをpluralしsingularizeする
#@ModelPathBase :: edit_product_path などのpathを作成するときのbase。
# モデルをpluralしsingularizeする
#
#@CorrectionPath :: products_path などのpathを作成する。モデルをpluralする
#
#==== index_relation
#index、edit_on_table で使う。
#defulat では モデル.allを返している。
#このあと order(order_params) がchainされて@modelsに correctionがしまわれる。
#pageingや検索条件の設定を行ったmethodでover rideする
#
#==== permit_attrs
#on_cell_edit や update_on_tableでのstrong_paramaterでつかう。
#defaultは　[] 空。
#
#=== カラムソートやlink、OnTableEdit を使う場合
#* th,td tagにclass設定が必要なので、table出力には以下のいずれかの方法を使う
#* modelessなOnTableEditを使う場合は tumiki.coffee が必要
#
#==== helpers/tumiki_helperを使う
#tumiki_table :: <table><thead><th><tbody><tr><td> 全て出力する
#tumiki_thead :: <thead><tr><th> を出力する
#tumiki_th :: <th> を出力する
#tumiki_tbody :: <tbody><tr><td>  を出力する
#tumiki_tr :: tbodyの一行分を を出力する
#tumiki_td :: tbodyの一cell分を を出力する
#
#==== Tumiki::Columnのmethodを使う
#th :: columnのoptionに応じたclass等をつけたth-tag
#header :: thタグ内に表示する文字列
#header_with_th :: th-tagに包まれた header
#disp_field :: columnのoptionに応じた修飾のついた表示データ
#td :: columnのoptionに応じたclass等を付けたtd-tag
#disp_field_with_td :: td-tagに包まれた表示データ
#
#== カラムの指定のしかた
#=== TH のコントロール
#　 column :name  :: "name"
#  column :name, label: "名前" :: "名前"
#  column :name, order: next_asc(:name)  :: <a href="/products?asc=desc&order=name"></a>
#     orderを使う場合は、collectionの生成において Product.all.order(order_params)
#     の様に、order(order_params)を入れる。
#     @default_order に無指定時のorderを入れておくことができる
#
#=== TDのコントロール
#==== default
#　 column :name :: model.send(:name).to_s が表示される
#
#==== formatで修飾
#　 column :name,format: "名前は%s" :: format % val を表示
#　 column :start_at, format: "%Y/%m/%d %H:%M" :: strftime をもつobjectの場合は　を表示
#
#==== correctionで修飾
#product_id → product.name の様な変換や、editable → 編集可可能/編集不可 の
#様な変換を行いたい場合
#  column :enable ,  correction: [["可",true],["否",false]]
#  column :product_id ,  correction: Product.pluck(:name,:id)
#
#==== as で修飾
#disableな select, radio buttom, check box で表示する。
#
#これらを使う場合は、correction も必要となる
#* select :: column :enable , as: :select, correction: [["可",true],["否",false]]
#* radio buttom :: column :enable, as: :radio, correction: [["可",true],["否",false]]
#* check box :: column :enable, as: :checkbox, correction: [["可",true],["否",false]]
#index table でのcheck box なので、1つだけしかサポートしていない。 bollean的な項目を想定
#
#===== リンク
#自分へのlink, 関連へのlink などができる
# column :name, link: lambda{|m| product_path(m)} :: 自分へのlink
# column :maker_name, link: lambda{|m| maker_path(m.maker)} :: 関連へのlink
#
#
#== On Table Edit
#index table のon cell で修正ができる。mode無しと mode有りがある
#
#Tumiki が提供する indedx.html.erb がある。独自のview を用いる場合は
#Tumiki が提供する indedx.html.erbを参考に設定していただくのがよい
# 
#=== Tumiki が提供する indedx.html.erbを使う場合
#column の editable option と actionで設定する @on_table_edit の値で管理する。
#
#
#==== @on_table_edit
#nill,false :: editable option に関わらず常に編集不能
#:all       :: index にて editable なcellが編集可能になる。forcusが外れたとき(type=text)もしくはデータに変更が有った時(type=radio,checkbox、select)にDBに反映される。
#:edit :: index では編集不能。編集ボタンが表示され、それで編集modeになる。
#:add :: index では編集不能。編集ボタンと追加ボタンが表示され、それで編集modeになる。
#:editting  :: editable なcellが編集可能になる。更新ボタンが表示され押すと更新される
#
#==== editable option
#editable の評価がtrueなら編集可能となる。
#* column :name, editable: true :: name 欄は常に編集可能
#* column :cost, editable: :enable :: model.send(:enable) の結果による
#* column :name, editable: lambda{|m| m.enable} :: lambda の結果による
#
#=== Tumiki が提供する indedx.html.erbを＊＊ 使わない ＊＊場合
#editable option の働きは同じである。一覧での編集可否はview、helperで決まる。
#
#==== TumikiHelper
#* tumiki_index_table(columns, models) を用いて一覧表を表示すると、一覧表は同じ動きとなる。
#* tumiki_edit_on_table_buttom を呼ぶと @edit_on_table の値に応じて 追加,編集,更新 ボタンが表示される。
#==== mode有りOn Table Edit
#@edit_on_table の値によって、modeが変わる
#nil, false, 未定義 :: mode無の onTabelEdit となる。
#:edit :: 編集可能画面となる。<%= tumiki_edit_on_table_buttom %> を呼ぶと
#更新buttomが表示される。
#以外 :: 編集不可な画面。<%= tumiki_edit_on_table_buttom %> を呼ぶと
#編集buttomが表示される。
#
#* controllerに edit_on_table, update_on_tableを用意する。
#* index, edit_on_table に共通な column 宣言が必要なので、Controller に
#method index_columns を用意するのを薦める。
#
#===== edit_on_table
#method index_columns index_relation を使ったdefaultな methodが module Tumiki
#に用意されている。必要によりover rideを。
#
#===== update_on_table
#
#method index_columns を使ったdefaultな methodが module Tumiki
#に用意されている。必要によりover rideを。
#
#
#==== mode無し On Table Edit
#* controllerにmethod on_cell_edit を用意する。
#* tumiki.coffee が必要
#
#* 入力を select, radio buttom, check box で行いたい場合は、as optionをつける。
#無い場合は、type=text な入力となる。 
#
#
#=== option 一覧
#==== TH関連
#label: 無いと symbolが使われる
#order: thにソートリンクを作る。labelと併用可
#
#==== TD
#correction: 表示にあたって、データ変換が必要な場合
#as:  　　 :select, :radio,:checkbox。  :correction オプションが必要
#format:　 データを整形する。　日時関連の項目の場合、klass: :date_timeも必要
#link:     リンクを貼る
#editable:  編集可能にする
#text_size: text_fieldの幅。bootstrapが無い場合のsize=XXの場合の値を用いる 
#
module Tumiki
  extend ActionView::Helpers::FormOptionsHelper
  attr_reader :columns
  

  # # controller名から /s?Controller/ を取ったものが model名では無い場合は
  # # over ride する
  def model_class
    @Modle ||= eval(self.class.name.sub(/s?Controller/,""))
  end

  #表示attrを定義する。model Columnのインスタンスを作り、配列に格納する
  # column :symbol_of_attr,label: "LABEL", as: :radio, correction: [],,,,
  #hashパラメータの詳細は Column#initialize 参照
  #
  #arg_columns:: 無指定時は @columnsが使われる。指定時はそれが使われる
  #@edit_on_table:: column実行時の値で動きが変わる。
  #   :: 詳細は  Column#disp,Column#edit等を参照
  def column symbol,args={},arg_columns=nil
    columns = arg_columns ? arg_columns : ( @columns ||=  [] )
    args[ :edit_on_table ] ||= @edit_on_table
    columns << Column.new( self, @Domain, symbol,params,args)
  end

  #
  # preset :: 初期の内容　{ symbol: value }
  # * arg
  # ** :label
  # ** :as  :text, :radio, :select
  def filter symbol,preset={},args={}
    @filter_list ||= []
    @filter_list << Filter.new(@Model,symbol,preset,args)
    #pp  @filter_list
  end

  # index_columns の over ride 必須
  # index_relation を over ride しない場合、all が呼ばれる
  # pagenationはindex_relation で行う
  # mode有りのOnTabelEdotを行う場合は、@edit_on_table=true を活かす
  def index
    index_columns
    index_filter
    #pp @columns.map(&:symbol)
    @models ||= relation
  end
@FindWhere 
  def relation
    @page ||= [params[:page].to_i , 1].max
    models = index_relation.where(Filter.find_query(@filter_list)).
             order(order_params)
    @Pagenation ? models.paginate( :page => @page,:per_page => @Pagenation) : models
  end
  
  def new
    new_columns || edit_columns || show_columns || index_columns
    @model = @Model.new(@New)
  end
  
  def create
    @model = @Model.new( params[@Domain].permit(permit_attrs) )#params[@Domain])
    if @Create 
      @Create.each{|k,v| @model[k] = v }
    end
    if @model.save
      # page =  if @Pagenation
      #           (@Model.where(@FindWhere).count.to_f/@Pagenation).ceil
      #         end
      # @models = @Pagenation ? pagenate(page) : find(page)
      # redirect_to :action => "index" ,:page => page
      redirect_to :action => :index
    else
      logger.info("#{@Model.name} createエラー：#{@model.errors.full_messages.join(',  ')}")
      edit_columns || show_columns || index_columns
      render action: :edit
    end
  end
  
  def show
    show_columns || index_columns
    @page = params[:page]
    @model = @Model.find(params[:id])
  end
  
  def edit
    @edit = true
    @page = params[:page]
    @back = params[:back]
    @back_params = params[:back_params]
    edit_columns || show_columns || index_columns
    @model = @Model.find(params[:id])
  end
  def update
    edit_columns || show_columns || index_columns
    @page = params.delete(:page)
    @params = params
    @model = @Model.find(params[:id])
    if @model.update(params[@Domain].permit permit_attrs)#params[@Domain]) 
      @Model.send(@Refresh,true) if @refresh #BookKamoku.kamokus true
      if params[:back]
        if params[:back_params]
          key,val = params[:back_params].split(",")
          redirect_to(:action =>  params[:back],key.to_sym => val)
        else
          redirect_to(:action =>  params[:back])
        end
      else
        redirect_to :action => "index" ,:page => @page
      end
    else
      render action: :edit
    end
  end
  #end

  def edit_on_table
    @edit = true
    @edit_on_table = :editting
    index_columns
    @models = relation #index_relation.order(order_params)
    if (@add_no = params[:add_no].to_i) >0
      @models += new_models
    end
    render action: :index
  end

  def add_on_table
    @edit = true
    #@models= find #@Model.all(@conditions)
    @page = params[:page] || 1 
    @edit_on_table = :editting
    index_columns
    @models ||= relation    
    @add_no = params[@Domain][:add_no].to_i
    @new_models = new_models
    @models += @new_models
    render action: :index
  end
  
  def new_models
    models = @add_no.times.map{ model_class.new(@NewModel) }
    models.each_with_index{|model,id| model.id = -id}
    models
  end


  def update_on_table
    update_on
    @Model.send(@Refresh,true) if @Refresh
    @edit_on_table = :edit
    redirect_to action: :index
  end

  def update_on
    index_columns
    models = [] 
    new_models = []
    @errors = []
    @result = true
    @modelList = params[@Domain] || { }
    @modelList.each_pair{|i,model| id=i.to_i
      logger.debug("Update_on_table:#{i} id=#{id} maxid=#{@maxid} #{model}")
      case model
      when ActionController::Parameters
        model = model.permit( permit_attrs )
      when ActiveSupport::HashWithIndifferentAccess,Hash
      end

      if id < 1
        next if model.values.all?{|v| v == "" }
        @model=@Model.new(model)
        if @model.save 
          new_models << @model
        else
          @result = false 
          @errors <<  @model.errors if @model.errors.size>0
        end
      else
        #  unless UbeModel.new(model) == models[id]
        @mdl = @Model.find(id)
        @result &=  @mdl.update(model) # @model.update_attributes(permit_attr)
        @errors << @mdl.errors if @mdl.errors.size>0
        models << @mdl
      end
    }
    @models = models + new_models
  end
  
  def index_relation
    # model_class.pagenate(params[:page])
    if @FindWhere
      model_class.where(@FindWhere)
    else
      model_class.all
    end
  end

  # Parameters: {"data"=>{"deny_ip"=>{"1"=>{"deny"=>"true"}}}}
  def on_cell_edit
    model_hash = params[:data] # {"deny_ip"=>{"1"=>{"deny"=>"true"}}}
    key = params[:data].keys.first #"deny_ip"
    id = model_hash[key].keys.first  # {"1"=>{"deny"=>"true"}}
    model = model_class.find(id)
    model.update( model_hash[key][id].permit(permit_attrs))
    render json: true
  end

  def on_cell_edit_preset
    key = params[:data].keys.first # 
    param = params[:data][key].permit(permit_attrs)
  end
  
  def index_columns
    @columns ||=  []
  end
  def new_columns
    @columns = nil # @columns ||=  []
  end
  def show_columns
    @columns = nil # @columns ||=  []
  end
  def edit_columns
    @columns = nil # @columns ||=  []
  end
  def index_filter ; end

  def attr_list
    permit_attrs
  end
  def permit_attrs
    index_columns unless @columns
    @columns.map{|column|
      column.symbol if column.editable || column.as == :hidden
    }.compact
  end

  def permit_params
    params[@Domain].permit permit_attrs
  end
  #
  
  NextAsc =
    {nil => { nil => "" ,"" => :asc , "asc" => :desc, "desc" => :asc },
     :desc => { nil => "" ,"" => :desc , "asc" => :desc, "desc" => :asc }
    }
  def next_asc symbol,asc=nil
    #pp [symbol,asc, params[:asc],NextAsc[asc][params[:asc]]] if symbol == :access_cnt
    params[:order] == symbol.to_s ? NextAsc[asc][params[:asc]] : ""
  end

  def order_params
    params[:order] ? ["#{params[:order]} #{params[:asc]}",@default_order].compact.join(",") : @default_order
  end
  
  #controllerのTumikiが用意しているmethodを使うために必要なインスタンス変数を
  #定義するための拡張
   module ApplicationControllerExtension
     #以下の変数を定義する
     #@Model::controller名から作成。 Tumiki::SamplesController => Tumiki::Sample
     #@Domain ::モデル名から作成。viewでのname、id作成に用いる  tumiki/sample
     #@ModelPathBase::モデル名から作成。show,editなどのroute。 tumiki/sample_path
     #@CorrectionPath::モデル名から作成。indexなどのroute。 tumiki/samples_path
     def tumiki_instanse_variable
       begin
         @Model = eval(self.class.name.sub(/s?Controller/,""))
         plural = ActiveModel::Naming.plural @Model
         @Domain = plural.singularize
         @ModelPathBase  = @Domain+"_path"
         @CorrectionPath = plural+"_path"
       rescue NameError
         @Model = ""
       end
     end
     #extend self
   end
end
#ApplicationController
