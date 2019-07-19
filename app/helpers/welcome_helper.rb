module WelcomeHelper
    def get_last(num, chart_data)
        chart_json = JSON.parse(chart_data)
        chart_json.sort_by{ |k,_| k.to_s.to_date }.reverse.first(num)
    end
end