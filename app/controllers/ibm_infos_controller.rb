class IbmInfosController < ApplicationController
    def index
        @infos = IbmInfo.all
    end

    def show
        @info = IbmInfo.find(params[:id])
    end

    def new
        @info = IbmInfo.new
    end
    
    def create
        @info = IbmInfo.new
        @info.IBMid = params[:ibm_info][:IBMid]
        @info.password = params[:ibm_info][:password]
        @info.report_name = params[:ibm_info][:report_name]

        b = Watir::Browser.new(:chrome)
        ibm_login_url = 'https://www.ibm.com/account/reg/us-en/login?formid=urx-34710'
        b.goto(ibm_login_url)

        b.text_field(name: 'ibmid').set @info.IBMid
        b.button(type: 'submit').click
        b.text_field(name: 'password').set @info.password
        b.button(type: 'submit').click

        sleep 5
        b.button(type: 'submit').click
        sleep 5

        #Go to the report
        b.div(title: '‪sample product report‬').click #need to figure out why the variable isn't working
        
        #Switch to the correct iframe where the report document is housed
        b.driver.switch_to.frame('rsIFrameManager_1') # Switch to numerical method to prevent brittleness

        #Scrape the entire XML of this page of the report
        page_one = doc = Nokogiri::HTML(b.html)

        #is it a bar chart?
        if doc.xpath("//*[@class=\"element-shape bundle-shape\"]")
            bar_chart_one = doc.xpath("//*[@class=\"element-shape bundle-shape\"]")
        end
        b.close

        if @info.save
            redirect_to @info
        else
            render :new
        end
    end
end
