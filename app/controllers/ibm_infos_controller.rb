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
        page_names = []
        count = 0
        page_xml = {}

        b = Watir::Browser.new(:chrome)
        ibm_login_url = 'https://www.ibm.com/account/reg/us-en/login?formid=urx-34710'
        b.goto(ibm_login_url)

        b.text_field(name: 'ibmid').set @info.IBMid
        b.button(type: 'submit').click
        b.text_field(name: 'password').set @info.password
        b.button(type: 'submit').click

        b.wait
        b.button(type: 'submit').click
        b.wait

        #Go to the report
        b.div(title: '‪sample product report‬').click #need to figure out why the variable isn't working
        b.wait
        #Switch to the correct iframe where the report document is housed
        b.driver.switch_to.frame('rsIFrameManager_1')

        #get the page count of report
        page_count = doc.xpath("//*[@class=\"clsTabBox_inactive\"]").count

        #assign the first page of the report XML to our hash
        page_xml[page_count] = {:xml => Nokogiri::HTML(b.html)}

        #get page names to click later
        page_count.times do
            name = doc.xpath("//*[@class=\"clsTabBox_inactive\"]")[count].text
            page_names << name
            count += 1
        end

        count = 0

        #go to each page and scrape the XML
        page_count.times do
            b.div(text: page_names[count]).click
            b.wait
            page_xml[count] = {:xml => Nokogiri::HTML(b.html)}
            count += 1
        end

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
