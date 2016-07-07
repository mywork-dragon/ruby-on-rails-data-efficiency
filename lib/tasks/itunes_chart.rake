namespace 'itunes_chart' do

  desc 'Run iTunes tope free'
  task :run_tunes_top_free => [:environment] do
    ItunesChartService.run_itunes_top_free
  end
  
end