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
        dashboard = false
        report = false

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
        b.button(title: 'My content').click
        b.wait
        b.div(title: @info.report_name).click
        b.wait
        
        #Check to see if the report is actually a dashboard
        if b.url.include?('dashboard')
            dashboard = true
        else
            report = true
        end

        #Switch to the correct iframe where the report document is housed
        if b.iframe(id: 'rsIFrameManager_1').exists? && dashboard == false
            b.driver.switch_to.frame('rsIFrameManager_1')
        elsif b.iframe.exists? && dashboard == false
            b.driver.switch_to.frame(1)
        end

        #get a basic nokogiri XML document to use for checks
        doc = Nokogiri::HTML.parse(b.html)

        #get the page count of report
        page_count = doc.xpath("//*[@class=\"clsTabBox_inactive\"]").count

        #assign the first page of the report XML to our hash
        page_xml[page_count] = {:xml => doc}

        #get page names to click later
        if page_count > 0 #BUT ONLY IF IT IS A MULTI PAGE REPORT
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
                page_xml[count] = {:xml => Nokogiri::HTML.parse(b.html)}
                count += 1
            end
        end

        #PAGE 1 CHECKS
        area_graph = Hash.new
        area_graph[:n_axis_values] = []
        area_graph[:w_axis_values] = []
        box_plot_graph = Hash.new
        box_plot_graph[:n_axis_values] = []
        box_plot_graph[:w_axis_value] = []
        if report == true
            area_graph_test = page_xml[0][:xml].xpath("//*[@class=\"Rave2BundleAreaRenderer large\"]")
            if area_graph_test.count < 0
                area_graph[:is_there] = true
                
                area_graph_test.css('text').each do |t|
                    if t.text.include?('0')
                        area_graph[:n_axis_values] << t.text
                    else
                        area_graph[:w_axis_value] << t.text
                    end
                end
            else
                area_graph[:is_there] = false
            end

            box_plot_test = page_xml[0][:xml].xpath("//*[@class=\"Rave2BundleBoxPlotRenderer large\"]")
            if box_plot_test.count < 0
                box_plot_graph[:is_there] = true

                box_plot_test.css('text').each do |t|
                    if t.text.include?('0')
                        box_plot_graph[:n_axis_values] << t.text
                    else
                        box_plot_graph[:w_axis_value] << t.text
                    end
                end
            else
                box_plot_graph[:is_there] = false
            end
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
