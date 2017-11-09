# coding: utf-8
module Tumiki::Helper

  def tumiki_index_table labels, models
    content_tag("table",class: "table table-borderd text-nowrap"){
      safe_join([tumiki_index_table_header(labels),
                 tumiki_index_table_body( labels, models,show_edit_delete)
                ],"\n"
               )
    }                 
  end
  
  def tumiki_index_table_header labels
    content_tag("thead") do
      if @TableHeaderDouble
        tumiki_label_multi_lines([@TableHeaderDouble],labels)
      elsif @TableHeaderMulti
        tumiki_label_multi_lines(@TableHeaderMulti,labels)
      else
        tumiki_index_table_header_sub labels
      end
    end
  end
  
  def tumiki_index_table_header_sub labels
    content_tag("tr"){
      safe_join(
        labels.map{|label| tumiki_index_table_th label}.compact,
        "\n")
    }
  end

  # ary_of_list
  # [5, [2,label: "勤務時間"], [9,label: "積算勤務日数"]]
  def tumiki_label_multi_lines(ary_of_list,labels)
    row = "" #<tr>"
    lbl_idx=0
    firstline = true
    #row += #"</tr>\n"
    ary_of_list.each{ |list| 
      row += "<tr>"
      list.each_with_index{|style,idx|
        case style
        when Integer   
          next unless firstline
          (1..style).each{
            row += "<th rowspan=#{ary_of_list.size+1} class='#{labels[lbl_idx].symbol}'>#{labels[lbl_idx].label}</th>"
            lbl_idx += 1
          }
        when  Array; 
          row += "<th colspan=#{style[0]} >#{style[1]}</th>"
          lbl_idx += style[0]
        end
      }
      firstline = false
      row += "</tr>"
    }#.join("</tr><tr>\n")

    row += "<tr>\n"
    lbl_idx=0
    ary_of_list[0].each_with_index{|style,idx|
      case style
      when Integer   ;        lbl_idx += style
      when Array; 
        (1..style[0]).each{
          row += "<th class='#{labels[lbl_idx].symbol}'>#{labels[lbl_idx].label }</th>" if labels[lbl_idx]
          lbl_idx += 1
        }
      end
    }
    return row.html_safe
  end

  # AecIcon = { "" => "glyphicon glyphicon-sort",
  #             desc:  "glyphicon glyphicon-sort-by-attributes-alt",
  #             asc:   "glyphicon glyphicon-sort-by-attributes"}
  
  AecIcon = { "" => "fa fa-sort",nil => "fa fa-sort",
              "desc" =>  "fa fa-sort-desc",
              "asc" =>   "fa fa-sort-asc",
            }
  def tumiki_index_table_th label,mode: nil
    return nil if label.as == :hidden
    if label.order
      url_option = params.merge(order: label.symbol,asc: label.next_asc)

      url_option.delete("controller")
      content_tag("th",class: "text-center bg-success #{label.symbol}"){
        link_to(
          "<span>#{label.label mode}<i class='#{AecIcon[label.asc]}'></i></span>".html_safe,
          url_option
        )
      }
    else
      content_tag("th", label.label,class: "text-center bg-success #{label.symbol}" )
    end
  end
  
  def tumiki_index_table_body  labels, models
    content_tag("tbody"){
      safe_join( models.
                 map{|model|
                   tumiki_index_table_tr labels, model },"\n")
    }
  end
  def tumiki_index_table_tr  labels, model
    content_tag("tr",labels.try(:tr_option)){
      tumiki_index_table_tr_  labels, model
    }
  end
  def tumiki_index_table_tr_  labels, model
    safe_join(
      [labels.map{|label|  tumiki_index_table_td label, model },
       tumiki_show_edit_delete_link(model)
      ].flatten,"\n")
  end
  def tumiki_show_edit_delete_link(model)
    return nil unless  [ nil, false, :edit,:add].include?(@edit_on_table)
    param = select_params
    return "" unless @Show || @Edit ||  deletable(model)
    safe_join(
      [@Show && content_tag(:td,show_edit_link("表示",:show,model,param)),
       @Edit && content_tag(:td,show_edit_link("編集",:edit,model,param)),
       deletable?(model) &&
       content_tag(:td,link_to('削除', model,
                               :method => :delete,
                               :data => { :confirm => 'Are you sure?'},
                               class:  'btn btn-danger btn-xs'
                              )
                  )
      ].compact,"\n")
  end
  # 表示ボタン、編集ボタンを出力する
  #
  # label :: ボタンのラベル
  # symbol :: :show または :edit
  # model  :: 表示または編集の対象
  def show_edit_link(label,symbol,model,param)
    link_to(label,
            { action: symbol,id: model.id,page: @page}.merge(param),
            class:  'btn btn-default btn-xs'
            ) if model
  end
  def deletable?(obj=nil)
    #logger.debug("### deletable #{@Delete} => #{@Delete.call(obj)}") if @Delete.class == Proc
    (case @Delete
     when Symbol  ; controller.send(@Delete)
     when Proc    ; @Delete.call(obj)
     else         ; @Delete
     end
    ) ? true : nil
  end
  def tumiki_index_table_td  label, model
    #puts model.send label.symbol
      #pp [ "######### tumiki_index_table_td td_option ##############",label.td_option(model)]
    option = label.td_option(model) || {}
    editable_option = @editable ? label.editable_option(model) : {}
    option[:class]  = [option[:class],label.symbol.to_s,
                       editable_option.delete(:class)
                      ].flatten.compact.join(" ")
    option[:id] = "#{@Domain}_#{model.id}_#{label.symbol}"
    option.merge! editable_option
    if label.as == :hidden
     label.edit(model,true)
    else
      #pp [ "################ tumiki_index_table_td ##############################",option]
      content_tag("td",option){ label.disp_text model }
    end
  end

  def tumiki_edit_on_table_buttom(opt = nil)
    case @edit_on_table
    when nil,false ; ""
    when :editting
      safe_join([
                  form_tag({action: :update_on_table}),
                  submit_tag("更新"),
                  opt
                ].compact
               )
    when :add
      safe_join(
        [*add_buttom , *edit_buttom , new_buttom ,
          "</form>".html_safe].compact
      )
      
    when :edit
      safe_join(
        [ *edit_buttom , new_buttom ,
          "</form>".html_safe].compact
      )
    end
  end

  def new_buttom
    if @New
      link_to("作成", {action: :new}, class: "btn btn-default")
    end
  end
  def add_buttom
    [form_tag( {action: :edit_on_table},
                    class: "form-inline fl",method: :get) ,
          submit_tag("追加"),
          text_field_tag(:add_no,1,style: "width:20px;"),
          hidden_field_tag('page' ,@page ),
          "　"
    ]
  end
  def edit_buttom
    [link_to("編集", {action: :edit_on_table}, class: "btn btn-default"),
     hidden_field_tag('page' ,@page )
    ]
  end
  
  def tumiki_update_on_table_buttom
    return "" unless @on_table_editable
    safe_join([
                tag("form",{action: :update_on_table,method: :post}),
              submit_tag("更新")
              ]
             )
  end
  def deletable model=nil
    deletable? #true
  end

  #################33
  def  filtering_bootstrap filter_list
    return "" unless filter_list
    #pp ["filter_list",filter_list]
    form_tag({action: :index},method: :get) do
      safe_join(
        [ *hiddens_from_parms([:query]) ,
          content_tag("div ",submit_tag( "絞込"),class: "fl"),
          content_tag("div",class: "fl"){
            safe_join( filter_list.map{|filter|
                         #content_tag("div",class: "fl"){
                         content_tag("table",class: "fl"){
                           content_tag("tr"){
                             safe_join( [content_tag("td",filter.label),
                                         content_tag("td",filter.disp_query_type_select),
                                         content_tag("td",filter.disp_input)]
                                      )
                           }
                         }
                         #}
                       },
                       "\n"
                     )
          }
        ].compact.flatten.compact,"\n").html_safe
    end
  end

  def  filtering filter_list
    return "" unless filter_list
    content_tag("div"){
      safe_join(
        [
          submit_tag( "絞込"),

          filter_list.map{|filter|
            [
              filter.label,
              filter.disp_query_type_select,
              filter.disp_input
            ]
          }
        ].flatten.compact,"\n"
      )
    }
  end
  def hiddens_from_parms(symbols)
    return nil if (selected = select_params(symbols)).empty?
    url_for( {action: :index}.merge(selected))[/\?(.*)/,1].
      split("&").
      map{|args| hidden_field_tag( *args.split("="))}
  end
  def pagenation(models)
    unless @Pagenation && [ nil, false, :edit,:add].include?(@edit_on_table)
      ""
    else
      will_page_options = {  :previous_label=>'前へ', :next_label=>'次へ',:page_gap => "..."}
      unless controller.session[controller.class.name+"_per_page"]
        will_paginate(models,will_page_options  )
      else
        safe_join([form_tag(:action => :change_per_page),
                   will_paginate(models,will_page_options.merge(:container => false)  ),
                   "　",
                   hidden_field_tag('page',@page),
                   text_field_tag('line_per_page',@Pagenation,:size => 1),
                   "件/ページ",
                   link_with_help("","Common#perpage"),
                   "</form>".html_safe
                  ]
                 )
      end
    end
  end

  def link_with_help(text,help,url_option="#")
    popover,helpmsg =
      if help && (help_obj = Help.find_by(key: help))
        [{ "data-toggle" => "popover",title: help_obj.title,
          "data-content" => help_obj.content.gsub(/\n/,"<br>"),
          "data-trigger"=>"click hover",
          "data-html"=>"true",
          rel: "popover"
         },
         "<img src='/st/images/help.png' class='help'>"
        ]
      else
        [{},""]
      end
    link_to("#{text}#{helpmsg}".html_safe,url_option,popover)
  end
  def select_params(symbols=[])
    param = params.dup
    #pp [:select_params,param]
    [:utf8, :commit ,:controller ,:action,@Domain].each{|sym| param.delete(sym)}
    symbols.each{|sym| param.delete(sym)}
    #pp param
    param
  end
  def  filtering filter_list
    return "" unless filter_list
    safe_join(
      [content_tag("div",submit_tag( "絞込"),class: "col-xs-1"),
       content_tag("div",class: "col-xs-11"){
         content_tag("div",class: "row"){
           safe_join( filter_list.map{|filter|
                        content_tag("div",class: "col-xs-3"){
                          content_tag("div",class: "form-groupe"){
                            safe_join(
                              [# content_tag("label",filter.label,class: "label",
                                #            for: "q_#{filter.symbol}"),
                                filter.label,
                                filter.disp_query_type_select,
                                filter.disp_input
                              ],
                              "\n"
                            )
                          }
                        }
                      })
         }
       }
      ].flatten.compact,"\n")
  end

end
