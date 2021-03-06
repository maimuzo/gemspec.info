# 
# 
# kick:
# script/runner 'SpecPackager.new(true).pack()'
# script/runner 'SpecPackager.new(true).unpack("~/Sources/gemspec/gemspec.info/20081013_131255.zip")'
# script/runner -e production 'SpecPackager.new(true).unpack("./../first_gem_pack.zip")'

#
class SpecPackager
  def initialize(verbose = false, tmp = Dir.tmpdir)
    @tmp = tmp
    @verbose = verbose
    @output = 0
    @input = 0
  end
  
  # load specs from zip file on working directory
  def unpack(zippath_with_file_name)
    case zippath_with_file_name[0, 1]
    when '~' then zippath_with_file_name[0] = ENV["HOME"]
    when '.' then zippath_with_file_name[0] = Dir.pwd unless zippath_with_file_name[0, 2] == '..'
    end
    temp = Tempfile.open("unpack", @tmp)
    temp.close(true)
    @input_workdir = temp.path
    puts "working directory is [#{@input_workdir}]"
    puts "zip file : #{zippath_with_file_name}"
    WorkingDirectory.new(@verbose).work_on(@input_workdir) do |current_dir|
      command = "unzip -j #{zippath_with_file_name}"
      puts "unzip command : #{command}" if @verbose
      `#{command}`
      raise "Can't find zip file at #{zippath_with_file_name}" unless 0 == $?
      puts "finished to unzip. scanning all specs..." if @verbose
      Rubygem.find(:all, :include => [:versions]).each do |gem|
        gem.versions.each do |version|
          input_from_yaml_file(version) if version.spec.nil?
        end
      end
    end
    puts "loaded #{@input} spec files from #{zippath_with_file_name}"
    puts "please delete working directory [#{@input_workdir}] after check it." if @verbose
  end
  
  # make zip file from saved specs on working directory
  def pack(zippath_without_filename = Dir.pwd, basename = Time.now.strftime("%Y%m%d_%H%M%S"))
    if '/' == zippath_without_filename[-1, 1]
      puts "don't need / at last. [#{zippath_without_filename}]"
      exit(4)
    end
    workdir = @tmp + "/" + basename
    zipfile = zippath_without_filename + "/" + basename + ".zip"
    puts "working directory is [#{workdir}]"
    puts "zip file : #{zipfile}"
    WorkingDirectory.new(@verbose).work_on(workdir) do |current_dir|
      Rubygem.find(:all, :include => [:versions]).each do |gem|
        gem.versions.each do |version|
          unless version.spec.nil?
            output_to_yaml_file(version) unless version.spec.yaml.blank?
          end
        end
      end
      command = "zip -jr #{zipfile} #{workdir}"
      puts "zip command : #{command}" if @verbose
      `#{command}`
      raise "Can't zip by the following command: [#{command}]" unless 0 == $?
    end
    puts "wrote #{@output} spec files to #{zipfile}"
    puts "please delete working directory [#{@input_workdir}] after check it." if @verbose
  end

protected
  
  # save to a file from the database
  def output_to_yaml_file(version)
    filepath = version.to_param + ".yml"
    File::open(filepath, "w") do |file|
      file.write(version.spec.yaml)
      puts "output #{filepath} from database" if @verbose
      @output += 1
    end
  end

  # load from a file to the database
  def input_from_yaml_file(version)
    filepath = version.to_param + ".yml"
    begin
      File::open(filepath, "r") do |file|
        version.create_spec(:yaml => file.read)
        puts "input #{filepath} to database" if @verbose
        @input += 1
      end
    rescue
    end
  end  
  
end
