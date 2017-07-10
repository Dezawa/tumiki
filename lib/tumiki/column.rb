# coding: utf-8
require 'tumiki/as_area'
require 'tumiki/as_checkbox'
require 'tumiki/as_hidden'
require 'tumiki/as_radio'
require 'tumiki/as_select'
require 'tumiki/klass_date_time'
module Tumiki
  # 
  # Tumiki::Columnは表示attribute毎に定義し、以下を提供する
  # 表示、編集での表現のサポート
  # 一覧表でのカラムソートの機能
  # 
  # 表示、編集での表現のサポート
  #
  # 1.label 
  #
  # -indexなどでの一覧表の th に用いる label
  #
  # -show, edit などでの label for などに用いる label
  # 
  # column.label mode として用いる。modeは 無し, :i18n, :for, :for_i18n の4種
  # 
  # 1. disp
  #
  # 値の表示
  #
  # column.disp(model) として用いる。option :as, :text, :format, :link, 
  # :editable、 columnを定義した時の @edit_on_table によって、
  # 単純な to_s、formatによる整形、他pageへのlink、disableなラジオボタン、
  # checkbox、select などになる。
  # 
  # 1. edit :: 編集可能な表示
  #   column.edit(model) として用いる。option :as, :text, :format, :link, 
  #   :editable と、 columnを定義した時の @edit_on_table によって、
  #   typeが text, radio, checkbox, aria, hidden な inputやselect になる。
  #   radio button の場合、button label(があれば)に label for を被せる。
  #   
  # 4.
  # edit_form :: 一覧表での編集可能な表示
  #   column.edit_form(model) として用いる。
  # 
  #   editとの違いは、name、id に　model.id が追加されることである。
  #      name="domain[id][attr]",  id="domain_id_attr"
  #   これにより、一覧表での編集が可能になる。
  # 
  #   model が編集可能な状態であり、かつ attr も編集可能である場合に編集状態に
  #   なる。column定義時に @edit_on_table が :editting であると disable=falseと
  #   なる。:on_cell の場合 disable であるが、tumiki.js との連携で、double click
  #   でenableとなる。前者を EditOnTable mode、後者を OnCellEdit mode と読んでいる。
  #   前者は[更新]action(#update_on_table)で DB に反映される。後者はcellの
  #   修正毎に DB に反映される。
  #   
  # 5. 
  # 編集可能の判断
  #   column の :editable option の内容によって動きが変わる。
  #   column#editable?(model)で評価される。
  # 
  #   無指定 :: 編集不能
  #   true   :: 編集可能
  #   Symbon :: model.send(editable) の結果による
  #   Proc   :: editable.call(model) の結果による
  # 
  #   current_user の権限で判定が変わる場合は、Proc の中で current_userを
  #   参照すればよい。
  # 
  # 
  # 一覧表でのカラムソートの機能(要:tumiki_helper#tumiki_index_table_th)
  #   option :order が定義されていると、th がカラムソートのlinkとなる。
  #   昇順降順の表示に font-awesome を用いれいるので gem 'font-awesome-rails'
  #   が必要となる。
  #     order:  :asc :: 最初のクリックで 昇順、次で降順、次に昇順となる
  #     order:  :desc :: 最初のクリックで 降順、次に昇順、次に降順となる
  # 
  # その他のoption
  #  :text_size  :: text_field, select の入力幅を指定する。 text_size 20
  #  :align      :: disp の時の水平方向配置  align: :right,:center
  #  :include_blank :: select の時の空白許可  include_blank: true
  class Column
    include  ActionView::Helpers::UrlHelper
    include  ActionView::Helpers::UrlHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::OutputSafetyHelper
    extend  ActionView::Helpers::FormOptionsHelper
    include ActionView::RoutingUrlFor

    attr_reader :symbol, :comment, :params,:controller,:domain
    AttrReader =
      [:label, :as, :text,  :link,  # 表示方法に関わる option
       :format, :text_size,:align,  # 表示形式に関わる option
       :order,                      # indexの時のカラムソート関連
       :correction, :include_blank, # as: :radio, :select の関連
       :option,
       :tr_option,
       :help, :comment
      ]
    AttrAccessor = [ :edit_on_table, :editable, :klass ]
    
    attr_reader  :asc,:path ,*AttrReader
    attr_accessor *AttrAccessor
    
    KlassModules = { date_time: KlassDateTime }
    AsModules = { select: AsSelect, checkbox: AsCheckbox, radio: AsRadio,
                  area:   AsArea, hidden: AsHidden}
    
    def initialize controller,domain, symbol,params,args = {}
      #pp [:column, args[:editable]]
      @controller, @domain, @symbol, @params =
                                     controller, domain, symbol, params
      extend ActionView::Helpers::FormOptionsHelper
      AttrReader.each{|sym|
        instance_variable_set("@#{sym}", args.delete(sym) )
      }
      AttrAccessor.each{|sym|
        instance_variable_set("@#{sym}", args.delete(sym) )
      }
      @editable =  true if @editable.is_a? NilClass
      @as         ||=  :text
      @td_option  = args.delete(:td_option) || {}
      #@text_size  ||=  15
      action  = args.delete(:action)
      if @correction && !@correction.first.is_a?(Array)
        @correction =  @correction.zip(@correction)
      end
      if @order
        @path = controller.class.to_s.gsub(/::/,"_").
                sub(/Controller/,(action ? "_#{action}_path" : "_path")).
                downcase
      end
      @option = args

      if align
        @td_option[:class] ||= []
        @td_option[:class] << "text-#{align}"
      end
      # 値のインスタンスの ruby class によって特別扱いが必用なときの措置
      # 例えば :date_time のときに　fmt%value では駄目だなぁ、、、とか
      klass = @option.delete(:klass)
      extend KlassModules[klass] if KlassModules[klass]

      extend AsModules[as] if  AsModules[as]
    end

    # label の返し方色々
    # * mode = nil   ::  :label || :symbol 
    # * mode = :i18n :: I18n.t(symbol)
    # * mode = :for  :: <label for='domain_symbol'>:label || :symbol</label>
    # * mode = :for_i18n :: <label for='domain_symbol'>I18n.t(symbol)</label>
    def label mode=nil
       str =
         case mode
         when :i18n, :for_i18n ; I18n.t(symbol)
         else
           if  @label == :i18n ; I18n.t(symbol)
           else                ; @label || symbol.to_s.classify
           end
         end

       case mode
       when :i18n, nil ;  str
       when :for,:for_i18n ; label_tag("#{domain}_#{symbol}",str)
       end
    end

    # 表示 色々
    # ２パターンある。いずれも :format があると整形される
    # 1. 値の to_s を返す。as: が無いか :text, または text: true
    # 2. as: が text では無いとき、かつ text: true でない時、その形式の disable で表示される
    #
    # 但し、:link が指定されている時は、表示方法(link label)は 1 の形式となる。
    #
    #
    #
    # disp :: 下請け。AsModules により、over write される。
    def  disp(model,with_id=nil)
      if symbol.is_a?(String)
        symbol
      elsif format
        to_s_by_format(model)
      elsif correction
        crrctn = correction.rassoc( model.send(symbol))
        crrctn ? crrctn.first : ""
      else
        model.send(symbol).to_s
      end
    end


    # 編集 色々
    # ２パターンある。いずれも :format があると整形される
    # 1. model が編集不能な場合、desp の動きとなる。
    # 2. 編集可能なcellとなる
    # 3. 見かけROだがダブルクリックでそのcellだけ編集可能になる
    # 4. 編集可能なcellとなる
    #
    # 1,2 は show や on_table_edit でない index、編集権のないcolumn で使われる
    # 3 は on_cell_edit の時に使われる。 @edit_on_table == :on_cell のとき。
    # 4 は edit_on_tabel の時に使われる。@edit_on_table == :editing のとき。
    #
    # 3,4 で編集可能になるのは、上記条件に加え
    # (1) model が編集可能(lockされていたり、current_userに編集権が無いときは)
    #   model の編集可否はcolumn の #editable?  で判定する
    #
    def edit(model,with_id=nil)
      #pp  editable?(model)
      unless editable?(model)
        disp(model)
      else
        edit_(model,with_id)
      end
    end

    # 基本的に editと同じだが、name、id に object.id も付加され
    # domein[attribute][id] となるところが異なる。
    # index, edit_on_table など複数の objectを扱う場合に用いる
    def edit_field(model,with_id=true)
      if editable?(model)
        edit_(model,with_id)
      else
        disp(model,with_id)
      end
    end
    # AsModules により、over write される。
    def edit_(model,with_id=nil)
      opt = text_size ? {style: "width:#{text_size}0px;", class: klass} :
              { class: klass}
        text_field_tag name(model,with_id),
                       to_s_by_format(model),opt
    end
      
    
    # AscIcon = { "" => "glyphicon glyphicon-sort",
    #             "desc" => "glyphicon glyphicon-sort-by-attributes-alt",
    #             "asc"  => "glyphicon glyphicon-sort-by-attributes"}

    # # th タグ内のデータを返す
    # # :label があれば それをなければ symbol.to_s を
    # # :order が有る場合は ソートへのlinkもつける
    # def header
    #   if order
    #     link_to(content_tag("span", label, class: AscIcon[order]),
    #             #"/"
    #             #products_path
    #             #send( :products_path)
    #             #@params.merge(controller: controller,action: option[:action]||:index)
    #             #controller: controller,action: (option[:action]||:index)
    #             "#{option[:action]||:index}"
    #             )
    #   else
    #     label
    #   end
    # end

    # # th にソートのlinkをつけることが有る。そのような時のために
    # # th-tagのhelper
    # def th options={},&block
    #   ("#{options_to_attr options,'<th'}>" + yield + "</th>").html_safe
    # end
    # def header_with_th  options={}
    #   th(options){ header}
    # end

    # show の時に呼ばれる
    def tr(model)
      safe_join(
        ["<tr#{tr_option(model)}>".html_safe,
         content_tag("td",label),
         content_tag("td",disp_field(model)),
         "</tr>".html_safe
        ],
        "\n"
      ) 
    end
    def tr_option model
    end
      # editableでは<td>に　class をつける。このような場合のために、
    # th-tag のhelper
    def td options={},&block
      ("#{options_to_attr options,'<td'}>" + yield + "</td>").html_safe
    end

    def td_option model=nil
      case @td_option
      when Hash ; @td_option.dup
      when Symbol ; model.send(@td_option)
      when Proc
        @td_option.call(model)
      end
    end
    def disp_field_with_td(model,on_table_edit=nil)
      td(class: @klass){disp_field(model,on_table_edit) }
    end

    # tdタグ内のデータを返す
    # :linkが有る場合は<a>タグを返す
    # 　無い場合はtextを返す
    # 　　as: select, radio, checkboxが有る場合は desable で表示する
    # 　　editable: true で有る場合は、引数 on_table_edit paramater により挙動が変わる
    # 　　　on_table_edit true  :: 入力可能なfieldが帰る
    #                     false :: <td>のclassに"editable_*"が付き、clickすると入力可能になる。
    def disp_field(model)
      disp = disp_text(model)
      if link #&& !(editable?(model) && @edit_on_table)
        link_to  disp, link.call(model),class: klass
      else
        disp
      end
    end

    # AsModules により、over write される
    # disp_field の下請けで返すStringを生成する
    def disp_text(model)
      #pp [edit_on_table,symbol,editable?(model)]
      if edit_on_table == :editting && editable?(model)
        #!@edit_on_table && editable?(model)
        edit(model,true)
      elsif link #&& !(editable?(model) && @edit_on_table)
        link_to  disp(model), link.call(model),class: klass
      else
        disp(model)
      end
    end
    
    def name model,with_id=nil
      if with_id
        #pp ["#{domain}[#{model.id}][#{symbol}]",symbol]
        "#{domain}[#{model.id}][#{symbol}]"
      else
        "#{domain}[#{symbol}]"
      end
    end
    
    def id model,with_id=nil
      if with_id
        #pp ["#{domain}_#{model.id}_#{symbol}",symbol]
        "#{domain}_#{model.id}_#{symbol}"
      else
        "#{domain}_#{symbol}"
      end
    end
    
    
    
    def to_s_by_format(model)
      val = model.send(symbol)
      return val.to_s unless format
      if val.respond_to?(:strftime)
        val.strftime(format)
      else
        val ? format % val : ""
      end.html_safe
    end
    def editable_option(model)
      _klass  = "editable" +
                case as
                when :radio,:checkbox,:select ; "_#{as}"
                else ; ""
                end
      editable?(model) && edit_on_table == :all ? {class: _klass} : {}
    end

    # model が編集可能であるかどうかを返す。
    # column#editable が Symbol,Proc であるときはmodelに問い合わせる
    #   model自体の編集可否
    # column毎の編集可否は, controller で column を定義する際に評価して、
    # :editable を設定する。
    # 例えば
    #  (1) editable: current_admin :: 管理者なら編集可能
    #  (2) editable: Proc.new{|model| model.status == "作成"} :: statusで決まる
    #  (3) editable: current_user.editor? && Proc.new{|model| model.status == "作成"} :: status と current_userの資格で決まる
    def editable? model
      #pp [ :aeg, editable, @editable]
      case editable
      when TrueClass ; true
      when Symbol    ; model.send(editable)
      when Proc      ; editable.call(model)
      else           ; false
      end
    end
    def correction_to_value( model )
      #pp [model,correction]
      return model.send(symbol).to_s unless correction
      case correction.first
      when Array
        ary = correction.rassoc( model.send(symbol))
        ary ? ary[0] : ""
        #when String,Integer ;
      else
        format ? to_s_by_format(model) : model.send(symbol).to_s
      end      
    end
    def options_to_attr(option,prefix="")
      return prefix if option.blank? || option.empty?
      prefix + " " +
        case option
        when String ; option
        when Hash   ; option.map{|k,v| "#{k}=\"#{v}\""}.join(" ")
        when Array  ; option.join(" ")
        else        ; option.to_s
        end
    end

    NextAsc = 
      {:asc  => { nil => :asc  ,"" => :asc , "asc" => :desc, "desc" => :asc },
       :desc => { nil => :desc ,"" => :desc , "asc" => :desc, "desc" => :asc }
      }
    def next_asc
      if params[:asc].blank? || params[:order] != symbol.to_s
        order
      elsif params[:order] == symbol.to_s
        @asc = [params[:asc]].blank? ? order : params[:asc]
        {  "asc" => :desc, "desc" => :asc }[params[:asc]]
      end
    end
  end
end
