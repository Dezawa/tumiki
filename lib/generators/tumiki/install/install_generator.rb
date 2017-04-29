require "rails"
require "tempfile"

require "pp"
module Tumiki
  class InstallGenerator < ::Rails::Generators::Base

    def insert_into_controller
      orig =
        File.join Rails.root , %w(app controllers application_controller.rb)
      code = File.read(orig)
      reg_require = %r(^\s*include +Tumiki::ApplicationControllerExtension\s*#*$)
      reg_replace =  /^\s*class +ApplicationController.*$/
      str_replace = "class ApplicationController < ActionController::Base\n" +
                    "  include Tumiki::ApplicationControllerExtension\n" +
                    "  before_filter :tumiki_instanse_variable\n"
      return if reg_require =~ code
      code = rep_code( code,reg_replace,str_replace)
      temp = Tempfile.open("controller")
      temp.puts code
      temp.close
      FileUtils.mv temp.path,orig
      puts "insert 2 lines into application_controller"
    end
    def insert_into_helper
      orig = File.join Rails.root , %w(app helpers application_helper.rb)
      code = File.read(orig)
      reg_req1 = /^\s*include +Tumiki::Helper\s*#*$/
      reg_rep1 = /(^\s*module +ApplicationHelper\s*$)/
      str_rep1 =  "module ApplicationHelper\n  include Tumiki::Helper\n"
      reg_req = %r(^\s*require +['"]tumiki\/helper['"]\s*$)
      reg_rep =  /\R/
      str_rep = "\nrequire 'tumiki/helper'\n"
      return if reg_req1 =~ code && reg_req =~ code
      
      code = rep_code( code,reg_rep1,str_rep1) unless reg_req1 =~ code
      code = rep_code( code,reg_rep,str_rep) unless reg_req =~ code
      temp = Tempfile.open("helper")
      temp.puts code
      temp.close
      FileUtils.mv temp.path,orig
      puts "insert 2 lines into application_helper"
    end
    def copy_view
      src_dir =
        File.expand_path("../../../../../app/views/application", __FILE__)
      views = Dir.glob(src_dir + "/*.erb")
      dist = Rails.root + "app" + "views" + "application"
      FileUtils.mkdir_p dist
      FileUtils.cp views,dist
      puts "Copy or Over write views into app/views/application/*erb"
    end

    private
    def rep_code src,replace_reg,replace_str
      src.sub(replace_reg,replace_str)
    end
  end
end
