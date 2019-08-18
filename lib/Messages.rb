require 'erb'
require 'json5'
require 'helper/FileOutHelper'

module Pptools
    class Messages < Thor
        class Record
            attr_reader :id, :message, :level
            def initialize(id, message, levelConverter = nil)
                @id = id
                @message = message 
                @level = nil
                if levelConverter
                    @level = levelConverter.convert(id)
                end
            end
        end
        
        class ConverterTS
            def level(id)
                id[0] || 'X'
            end
            def convert(id)
                case level(id)
                when 'I'
                    return 'ErrorLevel.Information'
                when 'E'
                    return 'ErrorLevel.Error'
                when 'W'
                    return 'ErrorLevel.Warning'
                else
                    return 'ErrorLevel.Notning'
                end
            end
        end
    
        no_commands do
            def load_data(input_file, levelConverter = nil)
                records = []
                data = JSON5.parse(File.read(input_file))
                data.each_pair do |key, value|
                    messageArray = value['message'] || []
                    record = Record.new(key, messageArray.join('\n'), levelConverter)
                    records.push(record)
                end
                records
            end

            def exec(input_file, template_file, output_file)
                records = load_data(input_file, ConverterTS.new())
                result =  ERB.new(File.read(template_file), nil, '-').result(binding)
                output_relative(input_file, template_file, result, output_file)
            end
        end

        desc "client", "create message file for client"
        option :input, :required => true, aliases: '-i', desc: '入力データファイルパス。'
        option :output, aliases: '-o', desc: '結果の出力ファイルパス。指定しない場合inputと同じディレクトリに出力します'
        def client()
            template_file = './templates/client/Messages.ts.erb'
            exec(options[:input], template_file, options[:output])
        end

        desc "server", "create message file for server"
        option :input, :required => true, aliases: '-i', desc: '入力データファイルパス。'
        option :output, aliases: '-o', desc: '結果の出力ファイルパス。指定しない場合inputと同じディレクトリに出力します'
        def server()
            template_file = './templates/server/Message.java.erb'
            exec(options[:input], template_file, options[:output])
        end

        desc "view", "NOT implemented yet"
        option :input, :required => true, aliases: '-i', desc: '入力データファイルパス。'
        def view()
        end
    end
end
