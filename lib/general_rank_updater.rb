# kick
# script/runner 'GeneralRankUpdater.new(true).update'
# script/runner -e production 'GeneralRankUpdater.new.update'
class GeneralRankUpdater
  def initialize(verbose = false)
    @verbose = verbose
  end
  
  # そのGemに対する情報量と、その情報にプラス評価した人の数で配点する
  def update
    Rubygem.find(:all, :include => [:what, :strength, :weakness, :gemcasts, :unchikus, {:versions => [:obstacles]}]).each do |gem|
      @rec_count = 0
      total_point = calclate_point(gem, 2.0)
      gem.what.each do |target|
        total_point += 1.0
        total_point += calclate_point(target, 0.5)
      end
      gem.strength.each do |target|
        total_point += 1.0
        total_point += calclate_point(target, 0.5)
      end
      gem.weakness.each do |target|
        total_point += 1.0
        total_point += calclate_point(target, 0.5)
      end
      gem.gemcasts.each do |target|
        total_point += 5.0
        total_point += calclate_point(target, 1.5)
      end
      gem.unchikus.each do |target|
        total_point += 3.0
        total_point += calclate_point(target, 1.0)
      end
      gem.versions.each do |version|
        version.obstacles.each do |target|
          total_point += 4.0
          total_point += calclate_point(target, 1.2)
        end
      end
      puts "#{gem.name} gat #{total_point.to_s} point from #{@rec_count.to_s} posts." if @verbose
      if gem.general_point.nil?
        general_point = gem.build_general_point(:point => total_point.round)
      else
        general_point = gem.general_point
        general_point.point = total_point.round
      end
      unless general_point.save
        puts "can not save!!" if @verbose
      end
    end
  end
  
  # プラス評価している人×レートで配点
  def calclate_point(target, rate)
    result = target.result_of_rating
    buff = result[:plus].to_f * rate
    @rec_count += 1
    puts "#{target.class.to_s} : #{buff.to_s} (plus:#{result[:plus]}/rate:#{rate})"
    buff
  end
end
