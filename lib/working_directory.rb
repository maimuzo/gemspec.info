# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class WorkingDirectory
  def initialize(verbose = false)
    @verbose = verbose
  end

  # setup working directory, and call yield on the workdir
  def work_on(workdir)
    # 既にworkdirが存在する場合はエラー
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
      puts e.backtrace
      exit(2)
    end
  end
end
