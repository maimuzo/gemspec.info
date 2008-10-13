# 
# 
# kick:
# script/runner 'SpecPackager.new(true).pack()'
# script/runner 'SpecPackager.new(true).unpack("~/Sources/gemspec/gemspec.info/20081013_131255.zip")'
# script/runner -e production 'SpecPackager.new(true).unpack("./20081013_131255.zip")'
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
    work_on_workdir(@input_workdir) do |current_dir|
      command = "unzip -j #{zippath_with_file_name}"
      puts "unzip command : #{command}" if @verbose
      `#{command}`
      raise "Can't find zip file at #{zippath_with_file_name}" unless 0 == $?
      puts "finished to unzip. scanning all specs..." if @verbose
      Rubygem.find(:all).each do |gem|
        gem.versions.each do |version|
          input_from_yaml_file(version) if version.spec.nil?
        end
      end
    end
    puts "loaded #{@input} spec files from #{zippath_with_file_name}"
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
    work_on_workdir(workdir) do |current_dir|
      Rubygem.find(:all).each do |gem|
        gem.versions.each do |version|
          unless version.spec.nil?
            output_to_yaml_file(version) unless version.spec.yaml.blank?
          end
        end
      end
      command = "zip -j #{zipfile} #{workdir}/*"
      puts "zip command : #{command}" if @verbose
      `#{command}`
      raise "Can't zip by the following command: [#{command}]" unless 0 == $?
    end
    puts "wrote #{@output} spec files to #{zipfile}"
  end

protected

  # setup working directory, and call yield on the workdir
  def work_on_workdir(workdir)
    begin
      if 0 == Dir.chdir(workdir)
        puts "Work directory is exist. [#{workdir}]"
        exit(1)
      end
    rescue      
    end
    
    begin
      if 0 == Dir.mkdir(workdir)
        Dir.chdir(workdir)
        yield(workdir)
        Dir.chdir("..")
        unless @verbose
          # サブディレクトリを階層が深い順にソートした配列を作成
          dirlist = Dir::glob(workdir + "**/").sort {
            |a,b| b.split('/').size <=> a.split('/').size
          }

          # サブディレクトリ配下の全ファイルを削除後、サブディレクトリを削除
          dirlist.each {|d|
            Dir::foreach(d) {|f|
              File::delete(d+f) if ! (/\.+$/ =~ f)
            }
            Dir::rmdir(d)
          }
        end
      end
    rescue => e
      puts "error message : [#{e.to_s}]"
      exit(2)
    end
  end
  
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
