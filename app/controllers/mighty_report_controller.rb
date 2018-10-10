class MightyReportController < ApplicationController

  layout "marketing"

  def index
    @logos = [
      {image: 'ironsrc_color.png', width: 170},
      {image: 'leanplum_color.png', width: 170},
      {image: 'zendesk_color.png', width: 170},
      {image: 'adobe_color.png', width: 170},
      {image: 'amplitude_color.png', width: 170},
      {image: 'yahoo_color.png', width: 170}
    ].each{|logo| logo[:image] =  '/lib/images/logos/' + logo[:image]}

    mighty_report_folder = '/lib/images/mighty_report/'

    @report_icon = mighty_report_folder + 'report.png'
    @pie_chart_icon =  mighty_report_folder + 'pie_chart.png'
    @loss_chart_icon = mighty_report_folder + 'loss_chart.png'

    @medal_report_icon = mighty_report_folder + 'medal.svg'
    @pie_chart_report_icon = mighty_report_folder + 'pie-chart.svg'
    @smartphone_ad_report_icon = mighty_report_folder + 'smartphone-ad.svg'
  end

  def get_report
    email = params['email']

    if email.present?
      lead_source = 'Mighty Report'

      lead_data = {email: email, message: lead_source, lead_source: lead_source}

      ad_source = params['ad_source']
      lead_data.merge!(lead_source: ad_source) if ad_source.present?

      Lead.create_lead(lead_data)
      ahoy.track "Submitted Mighty Report", request.path_parameters

      flash[:success] = "Thanks for requesting the report. We'll be in touch soon!"
    else
      flash[:error] = "Please enter your email."
    end

    redirect_to mighty_report_path(form: 'mighty-report')
  end

end
