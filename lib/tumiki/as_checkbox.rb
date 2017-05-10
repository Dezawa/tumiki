# coding: utf-8
module Tumiki
  module AsCheckbox
    # checkboxの右に表示する文字列
    # cprrection で決める
    # □可/否 という表示
    def edit_(model,with_id=nil)
      edit_or_disp(model,with_id,false)
    end
    def disp(model)
      edit_or_disp(model,nil,true)
    end

    # correctionが
    #  無い :: value=1 でlabelなし
    #  1次元 :: value = label として扱う
    #  2次元 :: labelを□の後に続ける
    #  要素が二つ以上の場合はまだ実装していない
    def edit_or_disp(model,with_id,bool)
      return correction_to_value(model) if text && correction.blank?
      
      valu_key =
        if correction.blank? ; [["","1"]]
        else                 ;  correction     
        end
 
        # case correction
        # when nil ; []
        # when true ; []
        # when :check_only ;[[nil,1],[nil,0]]
        # else ; option[:correction]
        # end
      value,key = valu_key.first
      safe_join([check_box_tag( name(model,with_id), key,
                                model.send(symbol) == key||model.send(symbol).to_s == key,
                                disabled:  bool),
                 valu_key.map{|v,k| v}.compact.join("/")
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
