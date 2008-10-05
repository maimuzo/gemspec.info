require 'net/http' 

class Sync_core
  def initialize(lastupdate, core_domain = "core.gemspec.info", port = 80)
    clone_site = YAML.load_file("./config/clone_site.yml")
    @core_domain = core_domain
    @port = port
    @auth_account = clone_site["account"]
    @auth_password = clone_site["password"]
    @lastupdate = lastupdate
    Net::HTTP.version_1_2   # おまじない
  end

  # exapmle
  # GET /need_to_update.yml
  # GET /need_to_update.yml?lastupdate=2008/09/01
  def get_unknown_versions_from_core
    timestamp = @lastupdate.strftime("%Y/%m/%d")
    local_path = "/need_to_update.yaml" + "?" + timestamp
    spec = ""
    get_body(local_path) do |body|
      puts "body : " + body if @verbose
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
    Net::HTTP.start(@core_domain, @port) {|http|
      response = http.request(req)
      case response
      when Net::HTTPSuccess     then yield(response.body)
      else
        puts "Can not get yaml."
        puts "it accesses to '#{@core_domain}:#{@port}' with auth_account '#{@auth_account}' and password '#{@auth_password}'"
        puts "see the following body:"
        puts response.body
        exit(1)
      end
    }
  end
end
