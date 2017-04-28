# coding: utf-8
module Tumiki
  module AsCheckbox
    # □可/否 という表示
    def edit(model,with_id=nil)
      edit_or_disp(model,with_id,false)
    end
    def disp(model)
      edit_or_disp(model,nil,true)
    end

    def edit_or_disp(model,with_id,bool)
      correction =
        case option[:correction]
        when nil ; [["可",true],["否",false]]
        when true ; []
        when :check_only ;[[nil,1],[nil,0]]
        else ; option[:correction]
        end
      value,key = correction.empty? ? ["",true] : correction.first
      safe_join([check_box_tag( name(model,with_id), key,
                                model.send(symbol) == key,
                                disabled:  bool),
                 correction.map{|v,k| v}.compact.join("/")
                ])
    end
      
    # def disp_text(model,on_table_editable = nil)
    #   correction = option[:correction] || [["可",true],["否",false]]
    #   value,key =  correction.first
    #   # option[:correction].map{|value,key|
    #   safe_join([check_box_tag( "#{domain}[#{model.id}][#{symbol}]", key,
    #                             model.send(symbol) == key,
    #                             disabled:  !(editable?(model))),
    #              correction.map{|v,k| v}.join("/")
    #             ]
    #            )
    # end
  end
end
