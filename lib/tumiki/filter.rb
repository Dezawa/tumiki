# coding: utf-8
module Tumiki
  class Filter
    
    AttrReader = [ :label,:as,:collection,:query_type ]
    attr_reader :model, :symbol,:type, :value, :option,*AttrReader
    #include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::FormOptionsHelper

    #絞り込みのための条件を作って返す。
    #  where(Filter.find_query(@filter_list))
    #の様に用いる。
    #
    #filter_list :: Tumiki#filter で作成された絞り込み条件の配列
    def self.find_query filter_list
      return nil unless filter_list
      arels = filter_list.map{|filt| filt.to_arel}.compact
      return nil if arels.empty?
      arel = arels.shift
      arels.inject(arel){|sum,arg| sum.and arg }
    end

    #=== Usage
    #module Tumiki#filter に定義された
    # def filter symbol,preset={},args={}
    #を通して使われる。
    #
    #model :: 検索対象となる Active Recode model
    #
    #symbol :: 検索条件を設定するcolumn
    #
    #preset :: 検索条件を保存しているhash。
    #          構造は { symbol => {:vlue => 値, :type => 一致,前方,含む,後方}}
    #
    #args :: :label,:as,:collection,:query_type,:klass
    #label :: 検索条件を入力するinputの前に表示される文字列。なければsymbolを使う
    #
    #as :: 検索条件を入力するinputの型。radio, :select, :match
    #      radio,selectはそのtypeのinputとなる。matchはダミーで、一致,前方,含む,後方以外の目的で使う場合に用いる。例えば範囲の片方とか。
    #collection :: radio、selectの場合の選択肢
    #
    #query_type :: 一致,前方,含む,後方のいずれかに固定する場合に指定
    #
    #klass :: inputのCSSのclassに追加される
    def initialize model,symbol,preset,args = {}
      @model = model
      @symbol = symbol
      @value  = preset[symbol]&&preset[symbol][:value]
      @type   = preset[symbol]&&preset[symbol][:type] || "一致"
      @klass  = args.delete(:klass) 
      AttrReader.each{|sym|
        instance_variable_set("@#{sym}", args.delete(sym) )
      }
      @label  ||= @symbol.to_s
      @as     ||= :text
      @klass  ||= ""
      @option = args
    end

    FormDivClass = "string input optional stringish filter_form_field "+
                   "filter_string select_and_search"
    def disp
      #("<div class='#{FormDivClass}  id='q_#{symbol}_input'" +
       safe_join( [ disp_label,disp_query],"\n") #+
     #  "</div>"
     # ).html_safe
    end
    def disp_query
      ("<div class='form-inline fl'" +
       disp_query_type_select + disp_input ).html_safe
    end

    FormQueryType = ["含む", "一致", "前方", "後方"]
    #[["含む"], ["一致"], ["前方"], ["後方"]]
    
    #絞り込み条件を"含む", "一致", "前方", "後方"から選ぶselectを表示する
    #as が :radio, :select, :match の場合は表示不要なので空文字列
    def disp_query_type_select
      case as
      when :radio, :select, :match ;" "
      else
        query_type || select_tag("query[#{symbol}][type]",
                                 options_for_select( FormQueryType,type),
                                 class: klass("fl")
                                )
      end
    end

    #絞り込み条件を入力するinputを出力する。
    def disp_input
      case as
      when :radio
        select_tag("query[#{symbol}][value]",
                 options_for_select(collection,value)
                  )
      when :select
        select_tag("query[#{symbol}][value]",
                   options_for_select(collection,value),
                   include_blank: true,
                   class: klass("select-#{symbol}")
                  )
      else
        text_field_tag("query[#{symbol}][value]",value,
                       id: "q_#{symbol}",size: 4,
                       class: klass("form-control input-sm fl"))
      end
    end
    
    def to_arel
      return nil if value.blank?
      case as
      when :radio
         model.arel_table[symbol].eq value
      else
        case type
        when "一致" ;  model.arel_table[symbol].eq value
        when "含む" ;  model.arel_table[symbol].matches("%#{value}%") 
        when "前方" ;  model.arel_table[symbol].matches("#{value}%")
        when "後方" ;  model.arel_table[symbol].matches("%#{value}")
        end
      end
    end
    def klass kls=""
      [@klass,kls].join(" ")
    end
  end

end
