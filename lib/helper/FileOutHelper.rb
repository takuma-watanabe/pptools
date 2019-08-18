def output_relative(input_file_path, template_file, contents, output_file = nil)
    real_out_file = output_file

    if !output_file
        full_path = File.expand_path(input_file_path)
        dir = File.dirname(full_path)
        name = File.basename(template_file, '.erb')
        real_out_file = File.join(dir, name)
    end

    File.open(real_out_file, "w") do |f| 
        f.write(contents)
    end
end
