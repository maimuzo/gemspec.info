require "yaml"

#
# get unknown specs of the version, and parse it, and save it.
# 未知のバージョンの詳細を取得し、解析して保存する。
#
# kick:
# script/runner 'SpecParser.new.scan.add_unknown_gem_versions.update_spec'
# script/runner 'SpecParser.new(true).scan.add_unknown_gem_versions'
# script/runner 'SpecParser.new(true, true).scan.update_spec'
# script/runner 'SpecParser.new(true, true).load_from_ar.update_spec'
#
class SpecParser < SpecScanner
  
  def initialize(report = false, verbose = false)
    super(report, verbose)
    # result counter
    @scaned_spec = 0
    @added_spec = 0
    @scaned_spec_array = []
    @added_spec_array = []
  end
  
  # generate @scaned_gem_and_versions from Rubygem and Version(ActiveRecord)
  def load_from_ar
    @scaned_gem_and_versions = []
    rubygems = Rubygem.find(:all)
    rubygems.each do |rubygem|
      versions = rubygem.versions
      array_version = []
      versions.each do |version|
        array_version << version.version
      end
      @scaned_gem_and_versions << {:gem => rubygem.name, :versions => array_version}
    end
    puts "loaded gem name and version" if @verbose
    self
  end
  
  # add a unknown a gem, a version, a spec yaml, and a detail
  # 未知のgem、version、yaml形式のspec、詳細を追加する
  def update_spec
    @scaned_gem_and_versions.each do |line|
      # add a unknown gem name
      # 未知のgemなら登録する
      puts "got record : #{line[:gem]}" if @verbose
      rubygem = Rubygem.find_by_name(line[:gem])
      if rubygem.nil?
        rubygem = Rubygem.create(:name => line[:gem])
        puts "add gem : " + line[:gem] if @verbose
      end
      line[:versions].each do |version_name|
        puts "got record : #{line[:gem]}[#{version_name}]" if @verbose
        # add a unknown version
        # 未知のバージョンなら登録する
        version = rubygem.versions.find_by_version(version_name)
        if version.nil?
          version = rubygem.versions.create(:version => version_name)
          puts "add version : #{line[:gem]}[#{version_name}]" if @verbose
        end
        # get a spec and add it if this system dosn't have a spec
        # もしspecをキャッシュしてなければ、取得して保存する
        if version.spec.nil?
          spec_yaml = get_unknown_spec(rubygem, version)
          spec_yaml = remove_dust(spec_yaml)
          version.create_spec(:yaml => spec_yaml)
          added_spec_counter(version.gemversion)
          puts "get the spec from a command line, and save it : #{line[:gem]}[#{version.version}]" if @verbose
          parse(version, spec_yaml)
        end
      end
    end
    show_result_of_spec
  end

private

  # parse spec, and save it or force update it
  # specの解析と、保存または上書き
  def parse(version, spec_yaml_source)
    geminfo = YAML.load(spec_yaml_source)
    puts "spec : " + geminfo.inspect if @verbose
    unless geminfo == false
      detail = {}
      detail[:platform] = geminfo.platform unless geminfo.platform.nil?
      detail[:executables] = geminfo.executables.to_s unless geminfo.executables.nil?
      detail[:date] = geminfo.date unless geminfo.date.nil?
      detail[:summary] = geminfo.summary unless geminfo.summary.nil?
      detail[:description] = geminfo.description.to_s unless geminfo.description.nil?
      detail[:homepage] = geminfo.homepage unless geminfo.homepage.nil?
      detail[:authors] = geminfo.authors.to_s unless geminfo.authors.nil?
      detail[:email] = geminfo.email unless geminfo.email.nil?
      detail[:installmessage] = geminfo.post_install_message unless geminfo.post_install_message.nil?          
      # add or update
      if version.detail.nil?
        version.create_detail(detail)
        puts "add a detail" if @verbose
      else
        version.detail.update_attributes(detail)
        puts "update the detail" if @verbose
      end
      added_spec_counter(version.gemversion)     
      
      gem_dependencies(geminfo.dependencies).each do |rec|
        puts "found dependency : " + rec.inspect if @verbose
        # add a dependence if unknown one
        # 未知の依存関係なら追加
        if version.dependencies.find_by_depgem_and_depversion(rec[:gem], rec[:version]).nil?
          version.dependencies.create(rec)
          puts "add dependency : #{rec[:depgem]}[#{rec[:depversion]}]" if @verbose
        end
      end
    end
  end

  # parse dependencies between gems
  # gem間の依存関係を解析
  def gem_dependencies(depend_yaml)
    result = []
    depend_yaml.each { |depend|
      req = depend.version_requirements.requirements
      result << {
        :depgem => depend.name, 
        :depversion => req[0][0].to_s + " " + req[0][1].version
      }
    }
    result
  end
  
  # get spec using gem specification command.
  # gem specificationコマンドから詳細を得る
  def get_unknown_spec(rubygem, version)
    begin
      command = "gem specification #{rubygem.name} --version #{version.version} -r -q 2>/dev/null"
      spec_yaml = `#{command}`
      spec_yaml = '' unless 0 == $?
      spec_yaml
    rescue => n
      puts n
      puts n.backtrace
      show_result_of_spec
      exit(1)
    end    
  end

  # show result of this scanning
  # 調査結果を表示する
  def show_result_of_spec
    if @report
      @added_spec_array.each {|spec| @scaned_spec_array.delete(spec)}
      puts "scaned spec:#{@scaned_spec}"
      puts "added spec:#{@added_spec}"
      puts "did not add following specs of version : " + @scaned_spec_array.join(", ")
    end
  end

  def scaned_spec_counter(version)
    if @report
      @scaned_spec_array << version
      @scaned_spec += 1
    end
  end
  
  def added_spec_counter(version)
    if @report
      @added_spec_array << version
      @added_spec += 1
    end
  end
  
  def remove_dust(spec_yaml)
    lines = spec_yaml.split("\n")
    cleared_line = []
    lines.each do |line|
      cleared_line << line unless /Bulk updating Gem source index for/ =~ line
    end
    cleared_line.join("\n")
  end
end

