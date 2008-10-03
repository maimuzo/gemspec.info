# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class SpecParser
  def parse
    get_gem_specifications do |base_rubygem, version, spec_yaml|
      puts gem_name
      rubygem = Rubygem.find_by_name(gem_name)
      rubygem = Rubygem.create(:name => gem_name) if rubygem.nil?

      puts version
      gem_version = rubygem.versions.find_by_version(version)
      if gem_version.nil?
        gem_version = rubygem.versions.create(:version => version)
      end

      puts geminfo.inspect
      unless geminfo.nil?
        if gem_version.info.nil?
          gem_version.create_info(
            :platform => geminfo.platform,
            :executables => geminfo.executables.to_s,
            :date => geminfo.date,
            :summary => geminfo.summary,
            :description => geminfo.description.to_s,
            :homepage => geminfo.homepage,
            :authors => geminfo.authors.to_s,
            :email => geminfo.email
          )
        end
        gem_dependencies(geminfo.dependencies).each do |rec|
          puts rec.inspect
          unless gem_version.dependencies.find_by_gem_and_version(rec[:gem], rec[:version])
            gem_version.dependencies.create(rec)
          end
        end
      end
    end    
  end
  
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
end
