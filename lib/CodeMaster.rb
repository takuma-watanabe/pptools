require 'erb'
require 'json5'
require 'helper/FileOutHelper'

module Pptools
    class CodeMaster < Thor
        class Record 
            attr_reader :logicalName, :phisicalName, :description, :items
            def initialize(lName, pName, description) 
                @logicalName = lName
                @phisicalName = pName
                @description = description
                @items = []
            end
        
            def addItem(item)
                @items.push(item)
            end
        end
        
        class Item 
            attr_reader :logicalName, :phisicalName, :value, :order
            def initialize(lName, pName, value, order) 
                @logicalName = lName
                @phisicalName = pName
                @value = value
                @order = order
            end
        end

        no_commands do
            def load_data()
                records = []
                data = JSON5.parse(File.read('./data/CodeMaster.json5'))
                data.each_pair do |key, value|
                    record = Record.new(value['name'], key, value['description'])
                    value['items'].each do |itemName, item|
                        record.addItem(Item.new(item['label'], itemName, item['value'], item['order']))
                    end
                    records.push(record)
                end
                records
            end

            def exec(input_file, template_file, output_file)
                records = load_data()
                result = ERB.new(File.read(template_file), nil, '-').result(binding)
                output_relative(input_file, template_file, result, output_file)
            end
        end

        desc "client", "create message file for client"
        option :input, :required => true, aliases: '-i', desc: '入力データファイルパス。'
        option :output, aliases: '-o', desc: '結果の出力ファイルパス。指定しない場合inputと同じディレクトリに出力します'
        def client()
            template_file = './templates/client/CodeMaster.ts.erb'
            exec(options[:input], template_file, options[:output])
        end

        desc "server", "create message file for server"
        option :input, :required => true, aliases: '-i', desc: '入力データファイルパス。'
        option :output, aliases: '-o', desc: '結果の出力ファイルパス。指定しない場合inputと同じディレクトリに出力します'
        def server()
            template_file = './templates/server/CodeMaster.java.erb'
            exec(options[:input], template_file, options[:output])
        end

        desc "view", "NOT implemented yet"
        def view()
        end
    end
end
