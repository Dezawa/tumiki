# coding: utf-8
module Tumiki
  class Filter
    attr_reader :model, :symbol,:label,:as, :value,:type,:option
    #include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::FormOptionsHelper

    def self.find_query filter_list
      return nil unless filter_list
      arels = filter_list.map{|filt| filt.to_arel}.compact
      return nil if arels.empty?
      arel = arels.shift
      arels.inject(arel){|sum,arg| sum.and arg }
    end
    
    def initialize model,symbol,preset,args = {}
      @model = model
      @symbol = symbol
      @label  = args[:label] || @symbol.to_s
      @as     = args[:as]    || :text
      @value  = preset[symbol]&&preset[symbol][:value]
      @type   = preset[symbol]&&preset[symbol][:type] || "一致"
      @option = args
    end

    #label
    #<div class="string input optional stringish filter_form_field filter_string select_and_search" id="q_dbid_input">
    #<label for="q_dbid" class="label">Dbid</label>
    #
    # query type
    #<select name="" id="">
    #  <option selected="selected" value="dbid_contains">Contains</option>
    #  <option value="dbid_equals">Equals</option>
    #  <option value="dbid_starts_with">Starts with</option>
    #  <option value="dbid_ends_with">Ends with</option>
    #</select>
    #
    # input
    #<input maxlength="255" id="q_dbid" type="text" name="q[dbid_contains]" />
    #</div>
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
    def disp_query_type_select
      case as
      when :radio, :select ;" "
      else
        if option[:query_type] ;  option[:query_type]
        else
          select_tag("query[#{symbol}][type]",
                     options_for_select( FormQueryType,type),class: "fl"
                    )
        end
      end
    end
    def disp_input
      case as
      when :radio
        select_tag("query[#{symbol}][value]",
                 options_for_select(option[:collection],value)
                  )
      when :select
        select_tag("query[#{symbol}][value]",
                   options_for_select(option[:collection],value),
                   include_blank: true,class: "select-#{symbol}"
                  )
        # pp self.symbol
        # collection_radio_buttons(
        #   :query,
        #   symbol,
        #   option[:collection],
        #   value, "")
      else
        text_field_tag("query[#{symbol}][value]",value,
                       id: "q_#{symbol}",size: 5,class: "form-control input-sm fl")
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
  end

end
