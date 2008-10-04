require 'net/http'
require "yaml"


#
# get unknown specs of the version from core.gemspec.info, and parse it, and save it.
# core.gemspc.infoから未知のバージョンの詳細を取得し、解析して保存する。
#
# kick:
# script/runner 'SpecParser.update(Date.yesterday, "localhost:3000")'
#
class SpecParser
  
  def initialize(lastupdate, core_domain = "core.gemspec.info")
    clone_site = YAML.load_file("../config/clone_site.yml")
    @core_domain = core_domain
    @auth_account = clone_site.account
    @auth_password = clone_site.password
    @lastupdate = lastupdate
    Net::HTTP.version_1_2   # おまじない
  end
  
  # coreから指定のあったgemのバージョンを解析してdetailを更新する
  # gemとversionは追加のみ。上書きしない。
  def update
    version_structures = get_unknown_versions_from_core
    version_structures.each do |structure|
      # add a unknown unknown gem name with the id
      rubygem = Rubygem.find_by_id_and_name(structure.gem_id, structure.gem)
      rubygem = Rubygem.create(:id => structure.gem_id, :name => structure.gem) if rubygem.nil?
      version = rubygem.versions.find_by_id_and_version(structure.version_id, structure.version)
      version = rubygem.versions.create(:id => structure.version_id, :version => structure.version)
      # add or load spec yaml
      if version.spec.nil?
        spec_yaml = get_unknown_spec(rubygem, version)
        version.create_spec(:yaml => spec_yaml)
      else
        spec_yaml = version.spec.yaml
      end
      parse(version, spec_yaml)
    end
  end
  
  # parse spec, and save it or force update it
  # specの解析と、保存または上書き
  def parse(version, spec_yaml_source)
    geminfo = YAML.load(spec_yaml_source)
    # puts geminfo.inspect
    unless geminfo.nil?
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
      else
        version.detail.update_attributes(detail)
      end
      
      gem_dependencies(geminfo.dependencies).each do |rec|
        puts rec.inspect
        # add a dependence if unknown one
        # 未知の依存関係なら追加
        unless version.dependencies.find_by_gem_and_version(rec[:gem], rec[:version])
          version.dependencies.create(rec)
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
        :gem => depend.name, 
        :version => req[0][0].to_s + " " + req[0][1].version
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
      exit(1)
    end    
  end
  
  # exapmle
  # GET /need_to_update.yml
  # GET /need_to_update.yml?lastupdate=2008/09/01
  def get_unknown_versions_from_core
    timestamp = @lastupdate.strftime("%Y/%m/%d")
    local_path = "/need_to_update.yaml" + "?" + timestamp
    spec = ""
    get_body(local_path) do |body|
      spec = YAML.load(body)
    end
    spec
  end
  
  # connect to http://@core_domain/local_path, and call yield with body
  # To connect to the server needs a BASIC authentication. 
  # http://@core_domain/local_pathに接続して、bodyと共にyeildに渡す
  # 接続にはベーシック認証が必要
  def get_body(local_path)
    req = Net::HTTP::Get.new(local_path)
    req.basic_auth @auth_account, @auth_password
    Net::HTTP.start(@core_domain) {|http|
      response = http.request(req)
      yield(response.body)
    }
  end
end

