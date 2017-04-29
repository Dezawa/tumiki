# Tumiki

ようこそ。

このパッケージは Rails application のための gem です。
controller,viewの実装のRDYを目指して居ます。

## 何ができるか

* #indexのtableのカラムの定義、その順番の変更を容易にします
** 表示方法は、通常のto_s表示のほか、format指定、radio bottum、
check box text_areaが選べます。
** 一覧表の状態で編集するmode（#edit_on_table)を可能にします
** 一覧表編集の入力形式は更にselectも選べます。
** 編集可能なカラムを指定できます。td 毎に可否を設定することも可能です
* tableでカラムソートを行わせることができます
* #indexでの絞り込みができます。


## Installation

* Gemfile
```ruby
gem 'tumiki'
```
を追加してして、
   bundle install
   rails generate tumiki:install
する

views/application にviewがcopyされ、
application_controller.rb、application_helper.rb に以下が追記

application_controller.rb
```ruby
  include Tumiki::ApplicationControllerExtension
  before_filter :tumiki_instanse_variable
```

application_helper.rb
```ruby
require "tumiki/helper"
module ApplicationHelper
  include Tumiki::Helper
end
```

## Usage

* application_controller.rb、application_helper.rb に追記

application_controller.rb
```ruby
  include Tumiki::ApplicationControllerExtension
  before_filter :tumiki_instanse_variable
```

application_helper.rb
```ruby
require "tumiki/helper"
module ApplicationHelper
  include Tumiki::Helper
end
```
  class SomeController < ApplicationController
    include Tumiki
    def index_columns
      column name:
      column title:, label: "肩書", order: :desc # 最初のclickで降順sort
      column gender:, as: :radio, correction: [[1,"男"],[2,女"]]
      collum section, as: select, include_blank: true, %w(人事 総務)
    end

    def index_filter
      query = params[:query] || {}
      filter :section,query,as: :select,collection: %w(人事 総務)
      filter :name,query
    end

contoler の index, new, show, create, update, dstroy, edit_on_table,
update_on_table 及びそれに対応する view は molode Tumiki、TumikiHelper
で定義してあるので、例えば　master table のような単純なものなら columns
の定義だけでできます。

pagenation

    def index
      super
    end

## ToDo

### labels_for

### check box