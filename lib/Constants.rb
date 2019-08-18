require 'erb'
require 'json5'
require 'helper/FileOutHelper'

module Pptools
    class Constants < Thor
        class Category 
            attr_reader :name, :description, :items, :categories
            def initialize(name, description, items = [], categories = []) 
                @name = name
                @description = description
                @items = items
                @categories = categories
            end
        end
        
        class Item 
            attr_reader :type, :name, :value, :description
            def initialize(type, name, value, description) 
                @type = type
                @name = name
                @value = value
                @description = description
            end
        end
        
        @categoryTemplate = ''
        @itemTemplate = ''
        no_commands do
            def load_item(node)
                arr = []
                node.each do |item|
                    arr.push(Item.new(item['type'], item['key'], item['value'], item['description']))
                end
                arr
            end

            def load_category(key, node)
                categories = []
                items = load_item(node['items'] || [])
                description = node['description'] || ''

                node.delete('description')
                node.delete('items')

                node.each_pair do |itemKey, item|
                    next if (!item.is_a?(Hash))

                    categories.push(load_category(itemKey, item))
                end

                return Category.new(key, description, items, categories)
            end

            def load_records()
                arr = []
                root = JSON5.parse(File.read('./data/Constants.json5'))
                root.each_pair do |key, val|
                    arr.push(load_category(key, val))
                end
                arr
            end

            def output_tree(record, depth = 0)
                depth = depth + 1
                if record.is_a?(Category)
                    return ERB.new(File.read(@categoryTemplate), nil, '-').result(binding)
                end
                if record.is_a?(Item)
                    return ERB.new(File.read(@itemTemplate), nil, '-').result(binding)
                end
            end

            def exec(input_file, template_file, categoryTemplate, itemTemplate, output_file)
                @categoryTemplate = categoryTemplate
                @itemTemplate = itemTemplate
                records = load_records()
                result = ERB.new(File.read(template_file), nil, '-').result(binding)
                output_relative(input_file, template_file, result, output_file)
            end
        end

        desc "client", "create codemaster file for client"
        option :input, :required => true, aliases: '-i', desc: '入力データファイルパス。'
        option :output, aliases: '-o', desc: '結果の出力ファイルパス。指定しない場合inputと同じディレクトリに出力します'
        def client()
            exec(
                options[:input],
                './templates/client/HKConstants.ts.erb', 
                './templates/client/HKConstantsCategory.ts.erb', 
                './templates/client/HKConstantsItem.ts.erb',
                options[:output],
            )
        end

        desc "server", "create codemaster file for server"
        option :input, :required => true, aliases: '-i', desc: '入力データファイルパス。'
        option :output, aliases: '-o', desc: '結果の出力ファイルパス。指定しない場合inputと同じディレクトリに出力します'
        def server()
            exec(
                options[:input],
                './templates/server/HKConstants.java.erb', 
                './templates/server/HKConstantsCategory.java.erb', 
                './templates/server/HKConstantsItem.java.erb',
                options[:output],
            )
        end

        desc "view", "create codemaster file"
        def view()
        end
    end
end
