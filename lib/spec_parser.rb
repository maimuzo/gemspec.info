require "yaml"

#
# get unknown specs of the version, and parse it, and save it.
# 未知のバージョンの詳細を取得し、解析して保存する。
#
# kick:
# script/runner 'SpecParser.new(true, true).scan.add_unknown_gem_versions.update_spec'
# script/runner 'SpecParser.new(true, true).scan.update_spec'
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
    
  # add a unknown a gem, a version, a spec yaml, and a detail
  # 未知のgem、version、yaml形式のspec、詳細を追加する
  def update_spec
    @scaned_gem_and_versions.each do |line|
      line[:versions].each do |version|
        puts "got record : #{line[:gem]}[#{version}]" if @verbose
        # add a unknown gem name or a version
        # 未知のgemかバージョンなら登録する
        rubygem = Rubygem.find_by_name(line[:gem])
        if rubygem.nil?
          rubygem = Rubygem.create(:name => line[:gem])
          puts "add gem : " + line[:gem] if @verbose
        end
        version = rubygem.versions.find_by_version(version)
        if version.nil?
          version = rubygem.versions.create(:version => version)
          puts "add version : #{line[:gem]}[#{version}]" if @verbose
        end
        # get a spec and add it if this system dosn't have a spec
        # もしspecをキャッシュしてなければ、取得して保存する
        if version.spec.nil?
          spec_yaml = get_unknown_spec(rubygem, version)
          version.create_spec(:yaml => spec_yaml)
          added_spec_counter(version.gemversion)
          puts "get the spec from a command line, and save it : #{line[:gem]}[#{version}]" if @verbose
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
    puts "spec : " + geminfo.inspect if @verbose and geminfo == false
    unless geminfo == false
      detail = {
        :platform => geminfo.platform,
        :executables => geminfo.executables.to_s,
        :date => geminfo.date,
        :summary => geminfo.summary,
        :description => geminfo.description.to_s,
        :homepage => geminfo.homepage,
        :authors => geminfo.authors.to_s,
        :email => geminfo.email,
        :installmessage => geminfo.post_install_message          
      }
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
  
  
end

