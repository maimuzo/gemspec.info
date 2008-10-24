require "yaml"

#
# Scan unknown version of gem, and add to DB.
# 未知のバージョンを調査して、DBに保存する
# kick:
# script/runner 'SpecScanner.new(true, true).scan.add_unknown_gem_versions'
#
class SpecScanner
  def initialize(report = false, verbose = false, gem_path = '/usr/local/bin/gem')
    # searched number of gem name
    @scaned_name = 0
    @scaned_name_array = []

    # searched number of version
    @scaned_version = 0
    @scaned_version_array = []

    # added number of gem name
    @added_name = 0
    @added_name_array = []

    # added number of version
    @added_version = 0
    @added_version_array = []

    # flag of varbose
    @verbose = verbose
    
    # flag of report
    @report = report
    
    @scaned_gem_and_versions = []
    @gem_path = gem_path
  end
  
  # list up all gem name and all version, and return a version list
  # すべてのgem名とバージョンを取得し、そのリストを返す
  def scan(to_downcase = true)
    begin
      lines = `#{@gem_path} list -ra`.split("\n")
    rescue
      puts "Catch exception from command line"
      show_result_of_gem_version
      exit(1)
    end
    @scaned_gem_and_versions = []
    lines.each do |line|
      puts "scaned line : #{line}" if @verbose
      next if "*** REMOTE GEMS ***" == line or "" == line or /Bulk updating/ =~ line
      gem_name_and_versions = line.scan(/^(.+)\s\((.+)\)$/).first
      gem_name = gem_name_and_versions[0].strip
      gem_name = gem_name.downcase if to_downcase
      versions = gem_name_and_versions[1].split(",").map do |version| version.strip end
      #古い物から登録する
      versions.reverse!
      puts "parsed gem name : " + gem_name if @verbose
      puts "parsed versions : " + versions.join(', ') if @verbose
      @scaned_gem_and_versions << {:gem => gem_name, :versions => versions}
    end
    self
  end
  
  
  # call a yield method for each the version
  # if this system don't have this version.
  # add a gem name if it's unknown name.
  # 未知のバージョンならば
  # version毎にyieldを呼び出す。
  # もし未知のgem名ならば、それを追加する。
  def add_unknown_gem_versions
    @scaned_gem_and_versions.each do |line|
      gem_name = line[:gem]
      versions = line[:versions]
      
      scaned_name_countup(gem_name)
      rubygem = Rubygem.find_by_name(gem_name)
      if rubygem.nil?
        # add this gem name
        rubygem = Rubygem.create(:name => gem_name)
        added_name_countup(gem_name)
        puts "added #{gem_name}" if @verbose
        # if the system could not find by gem name,
        # call a add_unkown_version method for all version
        # もしgem名が見つからなければ、全てのバージョンでadd_unkown_versionを呼び出す
        versions.each do |version|
          scaned_version_countup("#{gem_name}[#{version}]")
          add_unkown_version(rubygem, version)
        end
      else  
        begin
          versions.each do |version|
            scaned_version_countup("#{gem_name}[#{version}]")
            # call a add_unkown_version method if this system dosn't know this version
            # もしこのバージョンが未知なら、add_unkown_versionを呼び出す
            if rubygem.versions.find_by_version(version).nil?
              add_unkown_version(rubygem, version)
            else
              puts "skip #{gem_name} [#{version}]" if @verbose
            end
          end
        rescue => n
          puts n
          puts n.backtrace
          puts "Catch a exception from #{rubygem.name} #{version}"
          show_result_of_gem_version
          exit(1)
        end
      end
    end
    show_result_of_gem_version
    self
  end

private  
  
  # save a unknown version
  # 未知のバージョンを保存する
  def add_unkown_version(rubygem, version)
    # when found a unknown version
    begin
      rubygem.versions.create(:version => version)
      puts "added #{rubygem.name} [#{version}]" if @verbose
      added_version_countup("#{rubygem.name}[#{version}]")
    rescue => n
      puts n
      puts n.backtrace
      puts "Catch a exception from #{rubygem.name} #{version}"
      show_result_of_gem_version
      exit(1)
    end
  end

   # show result of this scanning
   # 調査結果を表示する
  def show_result_of_gem_version
    if @report
      puts "scaned gems:#{@scaned_name}, scaned version:#{@scaned_version}"
      puts "added gems:#{@added_name}, added version:#{@added_version}"
      @added_name_array.each {|name| @scaned_name_array.delete(name)}
      puts "did not add gems : " + @scaned_name_array.join(", ")
      @added_version_array.each {|version| @scaned_version_array.delete(version)}
      puts "did not add versions : " + @scaned_version_array.join(", ")
    end
  end
  
  def scaned_name_countup(name)
    if @report
      @scaned_name += 1
      @scaned_name_array << name
    end
  end
  
  def scaned_version_countup(version)
    if @report
      @scaned_version += 1
      @scaned_version_array << version
    end
  end
  
  def added_name_countup(name)
    if @report
      @added_name += 1
      @added_name_array << name
    end
  end
  
  def added_version_countup(version)
    if @report
      @added_version += 1
      @added_version_array << version
    end
  end
end
