# coding: utf-8
require 'tumiki/as_area'
require 'tumiki/as_checkbox'
require 'tumiki/as_hidden'
require 'tumiki/as_radio'
require 'tumiki/as_select'
require 'tumiki/klass_date_time'
module Tumiki
  class Column
    include  ActionView::Helpers::UrlHelper
    include  ActionView::Helpers::UrlHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::RoutingUrlFor
    attr_reader :symbol,:label,:as,:order, :comment, :option,:controller, :path
    attr_reader :help, :td_option, :text_size,:domain, :params, :asc
    attr_accessor :edit_on_table, :editable, :klass
    attr_reader :help, :comment,:tr_option
    
    
    KlassModules = { date_time: KlassDateTime }
    AsModules = { select: AsSelect, checkbox: AsCheckbox, radio: AsRadio,
                  area:   AsArea, hidden: AsHidden}
    
    def initialize controller,domain, symbol,params,args = {}
      @comment    = args.delete(:comment)
      @help       = args.delete(:help)
      @controller = controller
      @params     = params
      @symbol     = symbol
      @label      = args.delete(:label) || @symbol.to_s
      @as         = args.delete(:as)    || :text
      @td_option  = args.delete(:td_option) || {}
      @text_size  = args.delete(:text_size) || 15
      @editable   = args.delete(:editable)
      @edit_on_table = args.delete(:edit_on_table )
      @tr_option = args.delete(:tr_option)
      @domain = domain      
      @order  = args.delete(:order)
      action  = args.delete(:action)
      
      if @order
        @path = controller.class.to_s.gsub(/::/,"_").
                sub(/Controller/,(action ? "_#{action}_path" : "_path")).
                downcase
      end
      
      @option = args

      if a = @option.delete(:align)
        @td_option[:class] ||= []
        @td_option[:class] << "text-#{a}"
      end
      # 値のインスタンスの ruby class によって特別扱いが必用なときの措置
      # 例えば :date_time のときに　fmt%value では駄目だなぁ、、、とか
      klass = @option.delete(:klass)
      extend KlassModules[klass] if KlassModules[klass]

      extend AsModules[as] if  AsModules[as]
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
      if option[:link] #&& !(editable?(model) && @edit_on_table)
        link_to  disp, option[:link].call(model),class: klass
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
      elsif option[:link] #&& !(editable?(model) && @edit_on_table)
        link_to  disp(model), option[:link].call(model),class: klass
      else
        disp(model)
      end
    end
    
    def name model,with_id=nil
      with_id ?  "#{domain}[#{model.id}][#{symbol}]" : "#{domain}[#{symbol}]"
    end
    
    def edit(model,with_id=nil)
      text_field_tag name(model,with_id),
                     to_s_by_format(model),
                     {style: "width:#{text_size}0px;", class: klass}
    end

    def disp(model)
      if symbol.is_a?(String)
        symbol
      elsif option[:format]
        to_s_by_format(model)
      elsif option[:correction]
        correction = option[:correction].rassoc( model.send(symbol))
        correction ?      correction.first : ""
      else
        model.send(symbol).to_s
      end
    end
    
    def edit_field(model,with_id=nil)
      if editable?(model)
        edit(model,with_id)
      else
        disp(model)
      end
    end
    
    def to_s_by_format(model)
      val = model.send(symbol)
      return val.to_s unless option[:format]
      if val.respond_to?(:strftime)
        val.strftime(option[:format])
      else
        val ? option[:format] % val : ""
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
    def editable? model
      case editable
      when TrueClass ; true
      when Symbol    ; model.send(editable)
      when Proc      ; editable.call(model)
      else           ; false
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
