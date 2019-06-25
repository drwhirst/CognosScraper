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
        legend_count = 0
        legend_count_2 = 0
        page_xml_count = 0
        page_xml = []
        report = false
        graphs = []
        dashboard = false
        sum_of_all_graphs = 0
        graph_types = ['hierarchicalPackedBubble', 'area', 'river','smoothArea', 'stepArea', 'heatmap', 'bubble', 'line', 'smoothLine', 'tiledmap', 'marimekko', 'network', 'pie', 'radar', 'treemap', 'waterfall', 'wordcloud', 'dial', 'simpleCombination', 'clusteredBar', 'clusteredColumn', 'floatingBar', 'floatingColumn', 'stackedBar', 'stackedColumn', 'bullet', 'packedBubble', 'point', 'scatter'] 
        graphs_with_legends = ['hierarchicalPackedBubble', 'heatmap', 'bubble']
    
        b = Watir::Browser.new(:chrome)
        ibm_login_url = 'https://www.ibm.com/account/reg/us-en/login?formid=urx-34710'
        b.goto(ibm_login_url)

        b.text_field(name: 'ibmid').set @info.IBMid
        b.button(type: 'submit').click
        b.text_field(name: 'password').set @info.password
        b.button(type: 'submit').click

        sleep 10
        if b.button(type: 'submit').exists?  && b.button(class: 'ibm-btn-pri ibm-btn-blue-50').exists?
            b.button(type: 'submit').click
        end

        #Go to the report
        sleep 15
        b.button(title: 'My content').click
        sleep 5
        b.div(title: @info.report_name).click
        
        #Check to see if the report is actually a dashboard
        if b.url.include?('dashboard')
            dashboard = true
        else
            report = true
        end

        #Switch to the correct iframe where the report document is housed
        sleep 15
        if b.iframe.exists? && dashboard == false
            b.driver.switch_to.frame(1)
        end

        #get a basic nokogiri XML document to use for checks and to store later
        doc = Nokogiri::HTML.parse(b.html)
        
        #get the page count of report
        page_count = doc.xpath("//*[@class=\"clsTabBox_inactive\"]").count
        page_xml[page_xml_count] ={:xml => doc}
        page_xml_count += 1

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
                sleep 10
                page_xml[page_xml_count] = {:xml => Nokogiri::HTML.parse(b.html)}
                count += 1
                page_xml_count += 1
            end
        elsif doc.text.include?('Page down')
            end_of_pages_check = b.execute_script("return document.getElementById('btnNext')")
            until end_of_pages_check.html.include?('true')
                b.td(text: 'Page down').click
                sleep 2
                page_xml[page_xml_count] ={:xml => Nokogiri::HTML.parse(b.html)}
                page_xml_count += 1
                end_of_pages_check = b.execute_script("return document.getElementById('btnNext')")
            end
        end

        count = 0

        if report == true
            page_xml_count.times do
                graph_types.each do |g|
                    graph_test = page_xml[count][:xml].xpath("//*[@data-vizbundle=\"com.ibm.vis.#{g}\"]")
                        if graph_test.count > 0
                        sum_of_all_graphs += graph_test.count
                        graph = {}
                        arr_x = []
                        arr_y = []
                        graph_test.each do |t|
                            graph[:type] = g

                            if page_xml[count][:xml].css('#S_2_legend').count > 0
                                legend_xml_all = page_xml[count][:xml].css('#S_2_legend')
                                legend_xml = legend_xml_all[legend_count]
                                legend = {}
                                graphs_with_legends.each do |x| 
                                    if graph[:type] == x && legend_xml != nil
                                        legend[:min_value] = legend_xml.css('#o_0_startLabel').text
                                        legend[:max_value] = legend_xml.css('#o_0_endLabel').text
                                        legend[:label] = legend_xml.css('.lgd-title').text
                                        legend_count += 1
                                    end
                                end
                            end
                            
                            if page_xml[count][:xml].css('#S_3_legend').count > 0
                                legend_xml_all = page_xml[count][:xml].css('#S_3_legend')
                                legend_xml = legend_xml_all[legend_count_2]
                                legend_2 = {}
                                graphs_with_legends.each do |x| 
                                    if graph[:type] == x && legend_xml != nil
                                        legend[:min_value] = legend_xml.css('#o_2_startLabel').text
                                        legend[:max_value] = legend_xml.css('#o_2_endLabel').text
                                        legend[:label] = legend_xml.css('.lgd-title').text
                                        legend_count_2 += 1
                                    end
                                end
                            end
                            
                            if legend
                                graph[:legend] = legend
                            else
                                graph[:legend] = legend_2
                            end

                            t.css('text').each do |i|
                                if i.text.include?('0')
                                    arr_y << i.text
                                else
                                    arr_x << i.text
                                end
                            end
                            arr_y.delete_if { |x| x.empty? }
                            arr_x.delete_if { |x| x.empty? }
                            graph[:y_values] = arr_y
                            graph[:x_values] = arr_x
                            graphs << graph
                        end
                    end
                end
                count += 1
                legend_count = 0
                legend_count_2 = 0
            end
        end
        graphs.uniq!
        p graphs
        b.close

        @info.report_xml = graphs.to_s

        if @info.save
            redirect_to @info
        else
            render :new
        end
    end
end
