# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'timeout'
require 'pathname'
require "yaml"
require 'erb'

# 実験用
#require 'rdoc'
#require 'rdoc/rdoc'


# kick
# script/runner 'RdocGen.new(false, "/opt/local/bin/gem", "/Users/maimuzo/Sources/gemspec/gemspec.info/tmp/test_gem_home").init_rdoc.generate_all.update_rdoc_and_diagram_status'
# script/runner 'RdocGen.new(false, "/opt/local/bin/gem", "/Volumes/Backup/gemspec_gemhome").init_rdoc.generate_all.update_rdoc_and_diagram_status'
# script/runner 'RdocGen.new(false, "/opt/local/bin/gem", "/Users/maimuzo/Sources/gemspec/gemspec.info/tmp/test_gem_home").update_rdoc_and_diagram_status'
#
# なぜかrequire "rdoc"と"rdoc/rdoc"してrdocを作ろうとすると、rdocとallisonが喧嘩しちゃうので、MacOS標準のrdocを使うようにしてみた
# 何故これで正常に動くのかは不明
# でもRubyのプロセスではないので、timeoutが効かない
class RdocGen
  
  def initialize(verbose = false, gem_path = '/usr/local/bin/gem', gem_home = '/Volumes/Backup/gemspec_gemhome', runtime = '', rdoc_lib_path = '/usr/bin/rdoc', tmp = Dir.tmpdir)
    @verbose = verbose
    @gem_home = Pathname.new(gem_home)
    temp = Tempfile.open("rdoc", tmp)
    temp.close(true)
    @tmp_dir = Pathname.new(temp.path.to_s)
    @gem_path = Pathname.new(gem_path)
    @runtime = Pathname.new(runtime)
    @rdoc_lib_path = Pathname.new(rdoc_lib_path)
    @diagram_wrapper_html = "diagrams.html"
  end

  # 生成済みrdocファイルとrdocのパスを削除する
  def init_rdoc(with_files = false)
    opt = {
      :conditions => ["NOT(versions.rdoc_path IS NULL OR versions.rdoc_path = '')"],
    }
    Version.find(:all, opt).each do |version|
      if with_files
        rdoc_dir = @gem_home + 'rdoc' + version.to_param
        command = "rm -rf #{rdoc_dir.to_s}"
        `#{command}`
      end
      version.rdoc_path = ''
      version.diagram_path = ''
      version.save
    end
    self
  end
  
  # rdoc_dirにある空のディレクトリを削除する
  def delete_empty_dirs
    rdoc_dir_base = @gem_home + 'rdoc'
    Pathname.glob(rdoc_dir_base.to_s + '/*') { |d|
      if d.directory? and d.children.size == 0
        puts "delete empty directory: " + d.to_s
        d.rmdir
      end
    }
  end
  
  # まだrdocを持ってないgemに対してテンプレートを適用したrdocを生成する
  # 参考
  # http://subtech.g.hatena.ne.jp/cho45/20071006/1191619884
  # http://blog.evanweaver.com/files/doc/fauna/allison/files/README.html
  # http://www.kmc.gr.jp/~ohai/rdoc.ja.html
  def generate_all(limit = 100)
    generated_rdoc_counter = 0
    total_version_counter = 0
    error_gems = []
    WorkingDirectory.new(@verbose).work_on(@tmp_dir.to_s) do |current_temp_dir|
      mkdir_if_not_exist(@tmp_dir + 'extract_temporary')
      mkdir_if_not_exist(@gem_home + 'rdoc')
      
#      opt = {
#        # :conditions => ["NOT(versions.gemfile IS NULL OR versions.gemfile = '') AND NOT(specs.yaml IS NULL OR specs.yaml = '')"],
#        :conditions => ["(versions.rdoc_path IS NULL OR versions.rdoc_path = '') AND NOT(versions.gemfile IS NULL OR versions.gemfile = '') AND NOT(specs.yaml IS NULL OR specs.yaml = '') AND rubygems.name LIKE :gem", {:gem => 'h%'}],
#        :include => [:rubygem, :spec]
#      }
#      versions = Version.find(:all, opt)
#      total_version_counter = versions.size

      puts "find all versions..." if @verbose
      all_versions = []
      Rubygem.find(:all).each do |rubygem|
        version = rubygem.lastest_version
        all_versions << version if version.rdoc_path.blank? and not version.gemfile.blank? and not version.spec.nil? and not version.spec.yaml.blank?
      end
      puts "sorting..." if @verbose
      all_versions.sort! do |a,b|
        a.last_gen_rdoc = Time.at(0) if a.last_gen_rdoc.nil?
        b.last_gen_rdoc = Time.at(0) if b.last_gen_rdoc.nil?
        a.last_gen_rdoc <=> b.last_gen_rdoc
      end
      versions = []
      total_version_counter = 0
      limit.times do
        versions << all_versions.shift
        total_version_counter += 1
        break if all_versions.size == 0
      end
      
      versions.each do |version|
        begin
          version.last_gen_rdoc = Time.now
          version.save
          puts "generate rdoc about: " + version.gemfile
          gemfile_path = @gem_home + 'cache' + version.gemfile
          extract_base_dir = @tmp_dir + 'extract_temporary'
          extract_dir = extract_base_dir + File::basename(version.gemfile, '.*')
          rdoc_scan_dir = extract_dir.to_s + '/rdoc/*'
          rdoc_dir = @gem_home + 'rdoc' + version.to_param
          mkdir_if_not_exist(rdoc_dir)
          extract_gem(gemfile_path, extract_base_dir)
          spec = YAML.load(version.spec.yaml)
          args = setup_args(spec, extract_dir)
          need_regenerate = false
          if generate_rdoc(args, extract_dir)
            # '--diagram'のための画像ラッパーHTMLを作る
            generate_diagram_wrapper_html(extract_dir, args, version)
            # check empty
            generated_files = Dir.glob(rdoc_scan_dir)
            puts "scan files at: " + rdoc_scan_dir if @verbose
            puts "generated_files: " + generated_files.join(', ') if @verbose
            puts "generated_files count: " + generated_files.size.to_s
            if 0 < generated_files.size
              move_rdoc_dir(extract_dir, rdoc_dir)
              generated_rdoc_counter += 1 
              puts " => Success to generate RDoc for " + version.gemfile
            else
              need_regenerate = true
            end
          else
            need_regenerate = true
          end
          if need_regenerate
            puts " => Fault to generate RDoc with a diagram, re-generate only RDoc for " + version.gemfile
            `rm -rf #{(extract_dir + 'rdoc').to_s}`
            args = setup_args(spec, extract_dir, false)
            if generate_rdoc(args, extract_dir)
              generated_files = Dir.glob(rdoc_scan_dir)
              puts "scan files at: #{rdoc_scan_dir} agein" if @verbose
              puts "re-generated_files: " + generated_files.join(', ') if @verbose
              puts "re-generated_files count: " + generated_files.size.to_s
              if 0 < generated_files.size
                move_rdoc_dir(extract_dir, rdoc_dir)
                generated_rdoc_counter += 1 
                puts " => Success to generate RDoc for " + version.gemfile
              else
                puts " => Fault to re-generate RDoc only for " + version.gemfile
                error_gems << version.gemfile
              end
            else
              puts " => Fault to re-generate RDoc only for " + version.gemfile
              error_gems << version.gemfile
            end
          end
        rescue => e
          puts "ERROR : #{e.to_s}"
          puts e.backtrace
        end
      end
    end
    puts "gems : #{total_version_counter} / generated : #{generated_rdoc_counter}"
    puts "fault generate rdoc : #{error_gems.join(' ')}"
    self
  end
  
  # 配置済みrdocディレクトリをスキャンして、配置済みコンテンツ情報を更新する
  def update_rdoc_and_diagram_status(all_check = false)
    SystemState.update_rdocs_now

    document_root = Pathname.new(RAILS_ROOT) + 'public'
    rdoc_path_at_server = document_root + 'system/rdoc'
    
    if all_check
      versions = Version.find(:all)
    else
#      opt = {
#        :conditions => ["versions.rdoc_path IS NULL OR versions.rdoc_path = ''"],
#      }
#      versions = Version.find(:all, opt)  
      versions = []
      Rubygem.find(:all).each do |rubygem|
        version = rubygem.lastest_version      
        versions << version if version.rdoc_path.blank?
      end
    end
    puts "version count : " + versions.size.to_s if @verbose
    versions.each do |version|
      version_name = version.to_param
      puts version_name if @verbose
      if (rdoc_path_at_server + version_name).directory? and 0 < Dir.glob((rdoc_path_at_server + version_name).to_s + '/*').size
        version.rdoc_path = '/system/rdoc/' + version_name + '/'
      else
        version.rdoc_path = ''
      end   
      if (rdoc_path_at_server + version_name + @diagram_wrapper_html).file?
        version.diagram_path = '/system/rdoc/' + version_name + '/' + @diagram_wrapper_html
      else
        version.diagram_path = ''
      end   
      version.save
      if not version.rdoc_path.blank? and not version.diagram_path.blank?
        puts "found rdoc and diagram: " + version_name
      elsif not version.rdoc_path.blank?
        puts "found rdoc: " + version_name
      end
    end
    SystemState.update_counters
    self
  end

  # rdocをHEに登録する
  # 
  # 参考
  # http://d.hatena.ne.jp/jitte/20080112/1200153854
  def add_rdoc_to_he
    
  end
  
protected

  # gemfile_pathで示されたgemファイルをtemp_dirに解凍する
  # gemを解凍する
  # cd /Volumes/Backup/gemspec_gemhome/unpack
  # gem unpack /Volumes/Backup/gemspec_gemhome/cache/git-trip-0.0.5.gem
  def extract_gem(gemfile_path, extract_dir)
    begin
      command = "cd #{extract_dir.to_s}; #{@gem_path.to_s} unpack #{gemfile_path.to_s}"
      puts " Step 1. extract command : #{command}" if @verbose
      result = `#{command}`
      unless 0 == $?
        return ''
      else
        return result
      end
    rescue => e
      puts "ERROR : #{e.to_s}" if @verbose
      return ''
    end    
  end
  
  # specで指定されたファイルやディレクトリが実際に存在するかチェックし、存在するものだけ配列で返す
  def add_exist_dirs_and_files(extract_dir, target_array)
    exist_paths = []
    target_array.each do |target|
      exist_paths << target if (extract_dir + target).exist?
    end
    exist_paths
  end
  
  # 展開したgemのトップレベルディレクトリに存在するファイル名の配列を返す
  # (specに指定が無くても、これらのファイルはrdocに含める)
  def pick_up_top_level_files(target_dir)
    exist_files = []
    Pathname.glob(target_dir.to_s + "/*").each do |path|
      exist_files << File::basename(path) if path.file?
    end
    exist_files
  end
  
  # 各rdocに渡すオプションを整理する
  def setup_args(spec, extract_dir, with_diagram = true)
    args = []
    args << spec.rdoc_options
    args << ['--quiet', '--inline-source', "--template", "/opt/local/lib/ruby/gems/1.8/gems/allison-2.0.3/lib/allison"]
    args << ['--diagram'] if with_diagram
    args << ['--main', '"README"'] if not args.include?('--main') and (extract_dir + 'README').file?
    args << ['--op', 'rdoc'] unless args.include?('--op') or args.include?('-o')
    args << add_exist_dirs_and_files(extract_dir, spec.require_paths.clone)
    args << add_exist_dirs_and_files(extract_dir, spec.extra_rdoc_files)
    args << pick_up_top_level_files(extract_dir)
    args = args.flatten.map do |arg| arg.to_s end
    args
  end
  
  # rdocを生成する
  #
  # コマンドラインサンプル
  # allison --title 'RDoc for Gem[0.0.1] from RubyForge'  --charset utf-8  --op ../doc/git-trip-0.0.5 --fmt html --diagram --line-numbers --main README --promiscuous ../unpack/git-trip-0.0.5/
  def generate_rdoc(args, extract_dir)
    begin
      timeout(60 * 10) do
        puts " Step 2. move into : " + extract_dir.to_s if @verbose
        Dir.chdir(extract_dir.to_s)

        rdoc_command = ""
        rdoc_command << @runtime.to_s + " " unless @runtime.to_s.blank?
        rdoc_command << "#{@rdoc_lib_path.to_s} #{args.join(' ')}"
        puts " Step 3. RDoc command : " + rdoc_command if @verbose

        
#        rdoc = RDoc::RDoc.new
#        rdoc.document args

        
        `#{rdoc_command}`
        unless 0 == $?
          puts "Error : can not generate rdoc files."
          return false
        end


      end
      return true
    rescue => e
      puts "ERROR : #{e.to_s}"
      puts "current directory : " + Dir.pwd
      puts e.backtrace
      return false
    end
  end
  
  # --diagramオプションで生成したクラスダイアグラムの画像を表示するHTMLを生成する
  def generate_diagram_wrapper_html(extract_dir, args, version)
    begin
      diagram_dir = extract_dir + 'rdoc' + 'dot'
      exist_files = []
      Pathname.glob(diagram_dir.to_s + "/*.png").each do |path|
        exist_files << File::basename(path) if path.file?
      end
      diagram_file = extract_dir + 'rdoc' + @diagram_wrapper_html
      puts " Step 4. generate diagram wrapper html : " + diagram_file.to_s if @verbose
      puts "diagram images: " + exist_files.join(" ") if @verbose
      
      return false if exist_files.empty?
      
      erb_params = {}
      erb_params[:images] = exist_files
      erb_params[:title] = choose_default_or_next('--title', args, version.to_param)
      erb_params[:gemname] = version.rubygem.name
      erb_params[:version] = version.version

      @erb ||= ERB.new(diagram_template_erb)

      diagram_file.open("w") do |file|
        file.puts @erb.result(binding)
      end
    rescue => e
      puts "Error : can not generate a diagram wrapper html : " + version.to_param
      puts "Message : #{e.to_s}"
      puts e.backtrace
      return false
    end
    return true
  end
  
  # rdoc用オプションから必要な値を取り出すか、デフォルト値を返す
  def choose_default_or_next(keyword, args, default)
    if args.include?(keyword)
      return args[(args.index(keyword) + 1)]
    else
      return default
    end
  end

  # クラスダイアグラム用のerbテンプレートを返す
  def diagram_template_erb
    template = <<EOM
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
  <title><%= erb_params[:title] %> | class diagrams | gemspec.info</title>
  <link type="text/css" href="rdoc-style.css" media="screen" rel="stylesheet"/>
  <meta name="keywords" content="<%= erb_params[:gemname] %> version <%= erb_params[:version] %>, class diagrams">
</head>
<body>
  <div id="container">
    <div class="curve" id="preheader_curve_0"></div>
    <div class="curve" id="preheader_curve_1"></div>
    <div class="curve" id="preheader_curve_2"></div>
    <div class="curve" id="preheader_curve_3"></div>
    <div class="curve" id="preheader_curve_4"></div>
    <div class="curve" id="preheader_curve_5"></div>
    <div id="header">
      <span id="title">
        <p>&nbsp;</p>
        <h1>Class diagrams of <%= erb_params[:gemname] %> version <%= erb_params[:version] %></h1>
      </span>
    </div>
    <div class="clear"></div>
    <div id="content">
      <% erb_params[:images].each do |image| %>
      <p><img src="./dot/<%= image %>" alt="Class diagrams of <%= erb_params[:gemname] %> version <%= erb_params[:version] %>" /></p>
      <% end %>
    </div>
  </div>
  <div class="clear" id="footer">Generated on Jan 21, 2008 / Allison 2 &copy; 2007 <a href="http://cloudbur.st">Cloudburst, LLC</a></div>
</body>
</html>    
EOM
    template
  end
  
  # 生成できたrdocファイルを配置する
  def move_rdoc_dir(from, to)
    command = "mv #{(from + 'rdoc').to_s}/* #{to.to_s}"
    puts " Step 5. move rdoc-dir command : " + command if @verbose
    `#{command}`
    unless 0 == $?
      puts "Error : can not move rdoc files."
      return false
    end
  end
  
  # ディレクトリが存在しなければ作成する
  # pathはPathnameのインスタンス
  def mkdir_if_not_exist(path)
    unless path.directory?
      path.mkdir
    end
  end

end
